import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/content_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/ayat_tracker_service.dart';
import '../../services/reader_preferences_service.dart';

class ContentReaderScreen extends ConsumerStatefulWidget {
  final String contentId;
  final String? goalId;

  const ContentReaderScreen({
    super.key,
    required this.contentId,
    this.goalId,
  });

  @override
  ConsumerState<ContentReaderScreen> createState() => _ContentReaderScreenState();
}

class _ContentReaderScreenState extends ConsumerState<ContentReaderScreen> {
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoadingAudio = false;
  String? _audioError;

  // Reader customization state
  double _arabicFontSize = 26.0;
  String _selectedTranslation = 'en'; // 'en', 'ur', 'hi', 'gu', 'none'
  bool _isInlineTranslation = true;
  bool _isRecitedToday = false;
  bool _isFavorite = false;
  int _lastReadVerse = 0;

  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  bool _hasTrackedAyatToday = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await ReaderPreferencesService.init();
    final isFav = ReaderPreferencesService.isFavorite(widget.contentId);
    final lastRead = await ReaderPreferencesService.getLastReadVerse(widget.contentId);
    final isInline = await ReaderPreferencesService.isInlineTranslationEnabled();
    final fontSize = await ReaderPreferencesService.getArabicFontSize();

    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _lastReadVerse = lastRead;
        _isInlineTranslation = isInline;
        _arabicFontSize = fontSize;
      });
    }
  }

  void _initAudioPlayer() {
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
          _isLoadingAudio = false;
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _playerState = PlayerState.completed;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(String audioUrl) async {
    if (audioUrl.isEmpty) return;

    try {
      setState(() => _audioError = null);

      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else if (_playerState == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        setState(() => _isLoadingAudio = true);
        await _audioPlayer.play(UrlSource(audioUrl));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAudio = false;
          _audioError = 'Audio streaming note: Unable to play audio right now.';
        });
      }
    }
  }

  Future<void> _seekAudio(double value) async {
    final target = Duration(seconds: value.toInt());
    await _audioPlayer.seek(target);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _toggleFavorite() async {
    final newFav = await ReaderPreferencesService.toggleFavorite(widget.contentId);
    if (mounted) {
      setState(() => _isFavorite = newFav);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: newFav ? const Color(0xFFC27351) : Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          content: Text(
            newFav ? 'Added to Favorites' : 'Removed from Favorites',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      );
    }
  }

  Future<void> _saveBookmark(int verseIndex) async {
    await ReaderPreferencesService.saveLastReadVerse(widget.contentId, verseIndex);
    if (mounted) {
      setState(() => _lastReadVerse = verseIndex);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF4D7C68),
          behavior: SnackBarBehavior.floating,
          content: Text('Bookmark saved at verse ${verseIndex + 1}'),
        ),
      );
    }
  }

  void _scrollToBookmark(int verseIndex) {
    final key = _verseKeys[verseIndex];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _markAsRecited(ContentModel content) async {
    final authUser = ref.read(authStateProvider).value;
    final repo = ref.read(contentRepositoryProvider);
    final userId = authUser?.uid ?? 'guest_user';
    String? targetGoalId = widget.goalId;

    if (targetGoalId == null) {
      final goalsAsync = ref.read(userGoalsStreamProvider);
      final goals = goalsAsync.value ?? [];
      final matchingGoal = goals.cast<dynamic>().firstWhere(
            (g) => g.items.contains(content.contentId),
            orElse: () => null,
          );
      if (matchingGoal != null) {
        targetGoalId = matchingGoal.goalId;
      }
    }

    if (targetGoalId != null) {
      await repo.recordItemRecited(
        userId: userId,
        goalId: targetGoalId,
        contentId: content.contentId,
      );
    }

    // Auto-record ayat reading for Quran content (A.3)
    if (content.type == 'surah' && !_hasTrackedAyatToday) {
      final verses = _parseVerses(content);
      await AyatTrackerService.recordAyatRead(verses.length);
      _hasTrackedAyatToday = true;
    }

    if (mounted) {
      setState(() => _isRecitedToday = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF4D7C68),
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Recitation logged! May Allah accept your deed.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
  }

  List<String> _parseVerses(ContentModel content) {
    if (content.arabicText.contains('۝')) {
      return content.arabicText
          .split('۝')
          .map((v) => v.replaceAll(RegExp(r'[\d٠-٩]'), '').trim())
          .where((v) => v.isNotEmpty)
          .toList();
    }
    return content.arabicText
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> _parseTranslations(ContentModel content, String lang) {
    String text;
    switch (lang) {
      case 'ur':
        text = content.translationUr;
        break;
      case 'hi':
        text = content.translationHi;
        break;
      case 'gu':
        text = content.translationGu.isNotEmpty
            ? content.translationGu
            : content.translationEn;
        break;
      case 'en':
      default:
        text = content.translationEn;
        break;
    }

    if (text.contains('۝')) {
      return text
          .split('۝')
          .map((v) => v.replaceAll(RegExp(r'[\d٠-٩]'), '').trim())
          .where((v) => v.isNotEmpty)
          .toList();
    }
    return text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentByIdProvider(widget.contentId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Recitation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        actions: [
          // Favorite Star Toggle (C.4 / C.18)
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: _isFavorite
                  ? const Color(0xFFD4AF37)
                  : (isDark ? Colors.white70 : const Color(0xFF1B2A3D)),
              size: 26,
            ),
            tooltip: _isFavorite ? 'Remove Favorite' : 'Add to Favorites',
            onPressed: _toggleFavorite,
          ),

          // View Mode Switcher (Inline vs Continuous) (C.20)
          IconButton(
            icon: Icon(
              _isInlineTranslation ? Icons.view_agenda_rounded : Icons.view_headline_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF1B2A3D),
            ),
            tooltip: _isInlineTranslation ? 'Switch to Continuous' : 'Switch to Inline',
            onPressed: () async {
              final newMode = !_isInlineTranslation;
              setState(() => _isInlineTranslation = newMode);
              await ReaderPreferencesService.setInlineTranslationEnabled(newMode);
            },
          ),

          // Translation Selector
          IconButton(
            icon: Icon(
              Icons.translate_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF1B2A3D),
            ),
            tooltip: 'Translation Language',
            onPressed: () => _showTranslationBottomSheet(context, isDark),
          ),

          // Font Size Adjuster
          IconButton(
            icon: Icon(
              Icons.format_size_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF1B2A3D),
            ),
            tooltip: 'Font Size',
            onPressed: () => _showFontSizeBottomSheet(context, isDark),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: contentAsync.when(
        data: (content) {
          if (content == null) {
            return const Center(child: Text('Content not found.'));
          }

          // Trigger auto-tracking on Quran surah open
          if (content.type == 'surah' && !_hasTrackedAyatToday) {
            final verses = _parseVerses(content);
            AyatTrackerService.recordAyatRead(verses.length);
            _hasTrackedAyatToday = true;
          }

          return _buildReaderCanvas(content, isDark);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC27351)),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildReaderCanvas(ContentModel content, bool isDark) {
    final verses = _parseVerses(content);
    final translations = _parseTranslations(content, _selectedTranslation);

    return Column(
      children: [
        // Audio Player Bar (C.21)
        if (content.audioUrl != null && content.audioUrl!.isNotEmpty)
          _buildAudioPlayerCard(content.audioUrl!, isDark),

        // Bookmark resume alert (C.18)
        if (_lastReadVerse > 0 && _lastReadVerse < verses.length)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF4D7C68).withValues(alpha: 0.15),
            child: Row(
              children: [
                const Icon(Icons.bookmark_added_rounded, size: 18, color: Color(0xFF4D7C68)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Last read at Ayah ${_lastReadVerse + 1}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4D7C68),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _scrollToBookmark(_lastReadVerse),
                  child: const Text('Resume', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),

        // Main Scrollable Reader Canvas
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            children: [
              // Header Card with metadata
              _buildHeaderCard(content, isDark),
              const SizedBox(height: 18),

              // Bismillah Divider
              Center(
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(
                    fontSize: _arabicFontSize * 0.95,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFC28B45),
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 20),

              // Content Layout: Inline Verses vs Continuous View
              if (_isInlineTranslation)
                ...List.generate(verses.length, (idx) {
                  _verseKeys[idx] = GlobalKey();
                  final arabic = verses[idx];
                  final trans = idx < translations.length ? translations[idx] : '';
                  final isBookmarked = _lastReadVerse == idx;

                  return Container(
                    key: _verseKeys[idx],
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF17202C) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isBookmarked
                            ? const Color(0xFF4D7C68)
                            : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                        width: isBookmarked ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Verse number badge & bookmark button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFC27351).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Ayah ${idx + 1}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFC27351),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                size: 20,
                                color: isBookmarked ? const Color(0xFF4D7C68) : Colors.grey[500],
                              ),
                              tooltip: 'Bookmark this verse',
                              onPressed: () => _saveBookmark(idx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Arabic Verse Text
                        Text(
                          '$arabic ۝${idx + 1}',
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: _arabicFontSize,
                            height: 2.1,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                          ),
                        ),

                        // Inline Translation
                        if (_selectedTranslation != 'none' && trans.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF121A24) : const Color(0xFFF7F4EC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              trans,
                              style: TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                                color: isDark ? Colors.grey[300] : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                })
              else
                // Continuous View Mode (C.19)
                _buildContinuousView(content, verses, isDark),

              const SizedBox(height: 24),

              // Bottom Completion Action Button
              _buildCompleteButton(content),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCard(ContentModel content, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFC27351).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              content.type.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Color(0xFFC27351),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContinuousView(ContentModel content, List<String> verses, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF17202C) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Text(
            content.arabicText,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: _arabicFontSize,
              height: 2.2,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
          ),
        ),
        if (_selectedTranslation != 'none') ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141C26) : const Color(0xFFF3EFE6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2DBCF),
              ),
            ),
            child: Text(
              _getTranslationText(content),
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: isDark ? Colors.grey[300] : const Color(0xFF2C3E50),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompleteButton(ContentModel content) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isRecitedToday ? const Color(0xFF334155) : const Color(0xFF4D7C68),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        onPressed: _isRecitedToday ? null : () => _markAsRecited(content),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecitedToday ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              _isRecitedToday ? 'Completed for Today' : 'Mark Recitation Completed',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayerCard(String audioUrl, bool isDark) {
    final isPlaying = _playerState == PlayerState.playing;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: _isLoadingAudio
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFC27351),
                        ),
                      )
                    : Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                        size: 40,
                        color: const Color(0xFFC27351),
                      ),
                onPressed: () => _toggleAudio(audioUrl),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPlaying ? 'Audio Recitation Playing' : 'Audio Recitation',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: const Color(0xFFC27351),
                        inactiveTrackColor: Colors.grey[400],
                        thumbColor: const Color(0xFFC27351),
                      ),
                      child: Slider(
                        value: _position.inSeconds.toDouble().clamp(
                              0.0,
                              _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                            ),
                        max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                        onChanged: (val) => _seekAudio(val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          if (_audioError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _audioError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  String _getTranslationText(ContentModel content) {
    switch (_selectedTranslation) {
      case 'ur':
        return content.translationUr;
      case 'hi':
        return content.translationHi;
      case 'gu':
        return content.translationGu.isNotEmpty
            ? content.translationGu
            : content.translationEn;
      case 'en':
        return content.translationEn;
      default:
        return '';
    }
  }

  void _showTranslationBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final options = [
          {'code': 'en', 'label': 'English'},
          {'code': 'ur', 'label': 'Urdu (اردو)'},
          {'code': 'hi', 'label': 'Hindi (हिन्दी)'},
          {'code': 'gu', 'label': 'Gujarati (ગુજરાતી)'},
          {'code': 'none', 'label': 'None (Arabic Only)'},
        ];

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Translation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final isSelected = _selectedTranslation == opt['code'];
                return ListTile(
                  title: Text(opt['label']!, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFFC27351)) : null,
                  onTap: () {
                    setState(() => _selectedTranslation = opt['code']!);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Adjust Arabic Font Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        onPressed: _arabicFontSize > 18
                            ? () async {
                                final newSize = _arabicFontSize - 2;
                                setState(() => _arabicFontSize = newSize);
                                setModalState(() {});
                                await ReaderPreferencesService.saveArabicFontSize(newSize);
                              }
                            : null,
                      ),
                      Text(
                        '${_arabicFontSize.toInt()} pt',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        onPressed: _arabicFontSize < 40
                            ? () async {
                                final newSize = _arabicFontSize + 2;
                                setState(() => _arabicFontSize = newSize);
                                setModalState(() {});
                                await ReaderPreferencesService.saveArabicFontSize(newSize);
                              }
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
