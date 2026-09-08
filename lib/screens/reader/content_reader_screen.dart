import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/content_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/user_provider.dart';

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
  String _selectedTranslation = 'en'; // 'en', 'ur', 'hi', 'none'
  bool _isRecitedToday = false;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
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
      if (mounted) {
        setState(() => _duration = d);
      }
    });

    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() => _position = p);
      }
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
          _audioError = 'Unable to stream audio: $e';
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

    if (mounted) {
      setState(() => _isRecitedToday = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF4D7C68), // Sage Green
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Barakallah! "${content.title}" marked as recited.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentDetailProvider(widget.contentId));
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
        title: contentAsync.when(
          data: (content) => Text(
            content?.title ?? 'Spiritual Reader',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
          ),
          loading: () => const Text('Loading...'),
          error: (err, stack) => const Text('Error'),
        ),
        actions: [
          // Quick Font Size Adjuster
          IconButton(
            icon: Icon(
              Icons.format_size_rounded,
              color: isDark ? Colors.white70 : const Color(0xFF1B2A3D),
            ),
            tooltip: 'Adjust Font Size',
            onPressed: () => _showFontSizeBottomSheet(context, isDark),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: contentAsync.when(
        data: (content) {
          if (content == null) {
            return const Center(child: Text('Content not found.'));
          }
          return _buildReaderContent(content, isDark);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC27351)),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Failed to load text: $err'),
          ),
        ),
      ),
    );
  }

  Widget _buildReaderContent(ContentModel content, bool isDark) {
    final translationText = _getTranslationText(content);

    return Column(
      children: [
        // Translation Selection Chips
        _buildTranslationSelector(isDark),

        // Audio Player Bar
        if (content.audioUrl != null && content.audioUrl!.isNotEmpty)
          _buildAudioPlayerCard(content.audioUrl!, isDark),

        // Main Scrollable Reader Canvas
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
            children: [
              // Type Badge & Title
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC27351).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    content.type.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Color(0xFFC27351),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  content.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bismillah Divider
              Center(
                child: Text(
                  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  style: TextStyle(
                    fontSize: _arabicFontSize * 0.9,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFC28B45), // Ochre Gold
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                ),
              ),
              const SizedBox(height: 24),

              // Full Arabic Text Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF17202C) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Text(
                  content.arabicText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: _arabicFontSize,
                    height: 2.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                    color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Translation Card
              if (_selectedTranslation != 'none' && translationText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141C26) : const Color(0xFFF3EFE6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE2DBCF),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.translate_rounded,
                            size: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getLanguageLabel(_selectedTranslation),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        translationText,
                        textAlign: _selectedTranslation == 'ur'
                            ? TextAlign.right
                            : TextAlign.left,
                        textDirection: _selectedTranslation == 'ur'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        style: TextStyle(
                          fontSize: _arabicFontSize * 0.65,
                          height: 1.7,
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 100), // Space for bottom action bar
            ],
          ),
        ),

        // Sticky Bottom Action Bar
        _buildBottomActionBar(content, isDark),
      ],
    );
  }

  /// Translation selector chips
  Widget _buildTranslationSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141C26) : const Color(0xFFF2ECE1),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          _buildChip('English', 'en', isDark),
          const SizedBox(width: 8),
          _buildChip('اردو (Urdu)', 'ur', isDark),
          const SizedBox(width: 8),
          _buildChip('हिंदी (Hindi)', 'hi', isDark),
          const SizedBox(width: 8),
          _buildChip('Arabic only', 'none', isDark),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String code, bool isDark) {
    final isSelected = _selectedTranslation == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTranslation = code),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFC27351) // Terracotta
                : (isDark ? const Color(0xFF1C2736) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFFC27351)
                  : (isDark ? Colors.white12 : Colors.grey.shade300),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : const Color(0xFF1B2A3D)),
            ),
          ),
        ),
      ),
    );
  }

  /// Audio Player Card with controls and scrub bar
  Widget _buildAudioPlayerCard(String audioUrl, bool isDark) {
    final isPlaying = _playerState == PlayerState.playing;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Play / Pause Circle Button
              GestureDetector(
                onTap: () => _toggleAudio(audioUrl),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFC27351),
                  ),
                  child: _isLoadingAudio
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ),
              const SizedBox(width: 14),

              // Audio Title & Timing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Recitation (Free CDN)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Audio Speed / Restart icon
              IconButton(
                icon: Icon(
                  Icons.replay_rounded,
                  size: 20,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                tooltip: 'Restart',
                onPressed: () {
                  _audioPlayer.seek(Duration.zero);
                },
              ),
            ],
          ),

          // Slider scrub bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: const Color(0xFFC27351),
              inactiveTrackColor: isDark ? Colors.white12 : Colors.grey[200],
              thumbColor: const Color(0xFFC27351),
            ),
            child: Slider(
              min: 0,
              max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
              value: _position.inSeconds
                  .clamp(0, _duration.inSeconds > 0 ? _duration.inSeconds : 1)
                  .toDouble(),
              onChanged: _duration.inSeconds > 0 ? _seekAudio : null,
            ),
          ),

          if (_audioError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _audioError!,
                style: const TextStyle(fontSize: 11, color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }

  /// Sticky Bottom Action Bar with "Mark as Recited"
  Widget _buildBottomActionBar(ContentModel content, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10161E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecitedToday
                  ? const Color(0xFF4D7C68) // Sage Green
                  : const Color(0xFFC27351), // Terracotta
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: () => _markAsRecited(content),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isRecitedToday
                      ? Icons.check_circle_rounded
                      : Icons.arrow_forward_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isRecitedToday ? 'Recited Today ✓' : 'Mark as Recited',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Font Size Adjuster Bottom Sheet
  void _showFontSizeBottomSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Arabic Text Size',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                        ),
                      ),
                      Text(
                        '${_arabicFontSize.toInt()} pt',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC27351),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        color: const Color(0xFFC27351),
                        iconSize: 28,
                        onPressed: _arabicFontSize > 18
                            ? () {
                                setState(() => _arabicFontSize -= 2);
                                setModalState(() {});
                              }
                            : null,
                      ),
                      Expanded(
                        child: Slider(
                          min: 18,
                          max: 42,
                          divisions: 12,
                          activeColor: const Color(0xFFC27351),
                          value: _arabicFontSize,
                          onChanged: (val) {
                            setState(() => _arabicFontSize = val);
                            setModalState(() {});
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        color: const Color(0xFFC27351),
                        iconSize: 28,
                        onPressed: _arabicFontSize < 42
                            ? () {
                                setState(() => _arabicFontSize += 2);
                                setModalState(() {});
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Preview box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'اَللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَآلِ مُحَمَّدٍ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: _arabicFontSize,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getTranslationText(ContentModel content) {
    switch (_selectedTranslation) {
      case 'ur':
        return content.translationUr;
      case 'hi':
        return content.translationHi;
      case 'en':
        return content.translationEn;
      default:
        return '';
    }
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'ur':
        return 'URDU TRANSLATION (اردو ترجمہ)';
      case 'hi':
        return 'HINDI TRANSLITERATION (हिंदी)';
      case 'en':
        return 'ENGLISH TRANSLATION';
      default:
        return 'TRANSLATION';
    }
  }
}
