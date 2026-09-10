import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../models/clip_model.dart';
import '../../providers/user_provider.dart';
import '../../services/clips_service.dart';

class ClipsFeedScreen extends ConsumerStatefulWidget {
  const ClipsFeedScreen({super.key});

  @override
  ConsumerState<ClipsFeedScreen> createState() => _ClipsFeedScreenState();
}

class _ClipsFeedScreenState extends ConsumerState<ClipsFeedScreen> {
  @override
  void initState() {
    super.initState();
    ClipsService.seedClipsIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProfileProvider).value;
    final canUpload = user?.hasUploadPermission ?? false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0D131A) : const Color(0xFFF6F4EF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141C26) : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFC27351), size: 24),
            const SizedBox(width: 8),
            Text(
              'Clips',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
          ],
        ),
        actions: [
          if (canUpload)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC27351),
                  backgroundColor: const Color(0xFFC27351).withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Upload Clip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () => context.push('/clips-upload'),
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<ClipModel>>(
        stream: ClipsService.streamAllClips(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFC27351)));
          }

          final allClips = snapshot.data!;

          // Partition into Curated Shelves (B.5)
          final scholarAnswers = allClips.where((c) => c.category == 'fiqh_answer').toList();
          final majlisAndEvents = allClips.where((c) => c.category == 'majlis_update' || c.category == 'event_highlight').toList();
          final spiritualReflections = allClips.where((c) => c.category == 'spiritual_reflection').toList();
          final dailyAyatHadith = allClips.where((c) => c.category == 'ayat_of_day' || c.category == 'hadith_of_day').toList();
          final generalClips = allClips.where((c) => c.category == 'general').toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              // Shelf 1: Scholar Answers & Fiqh
              if (scholarAnswers.isNotEmpty)
                _buildClipShelf(
                  title: 'Scholar Answers & Fiqh',
                  subtitle: 'Direct authentic rulings from verified Shia scholars',
                  icon: Icons.school_rounded,
                  accentColor: const Color(0xFFC27351),
                  clips: scholarAnswers,
                  isDark: isDark,
                ),

              // Shelf 2: Majlis & Events Near You
              if (majlisAndEvents.isNotEmpty)
                _buildClipShelf(
                  title: 'Majlis & Community Events',
                  subtitle: 'Live updates from followed Mosques & Imambargahs',
                  icon: Icons.mosque_rounded,
                  accentColor: const Color(0xFF4D7C68),
                  clips: majlisAndEvents,
                  isDark: isDark,
                ),

              // Shelf 3: Daily Reflections
              if (spiritualReflections.isNotEmpty)
                _buildClipShelf(
                  title: 'Spiritual Reflections',
                  subtitle: 'Insights on Duas, Ziyarat & the path of Ahlulbayt (a.s.)',
                  icon: Icons.self_improvement_rounded,
                  accentColor: const Color(0xFFB8860B),
                  clips: spiritualReflections,
                  isDark: isDark,
                ),

              // Shelf 4: Daily Quran & Hadith Clips
              if (dailyAyatHadith.isNotEmpty)
                _buildClipShelf(
                  title: 'Ayat & Hadith of the Day',
                  subtitle: 'Short sacred contemplations for daily barakah',
                  icon: Icons.auto_stories_rounded,
                  accentColor: const Color(0xFF1B2A3D),
                  clips: dailyAyatHadith,
                  isDark: isDark,
                ),

              // Shelf 5: General Curations
              if (generalClips.isNotEmpty)
                _buildClipShelf(
                  title: 'Curated Explainers',
                  subtitle: 'Explore foundational Shia concepts and history',
                  icon: Icons.explore_rounded,
                  accentColor: Colors.deepPurple,
                  clips: generalClips,
                  isDark: isDark,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildClipShelf({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<ClipModel> clips,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrollable shelf (B.5)
        SizedBox(
          height: 380,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: clips.length,
            itemBuilder: (context, index) {
              final clip = clips[index];
              return Container(
                width: 240,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: ClipCard(clip: clip, isDark: isDark),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class ClipCard extends StatefulWidget {
  final ClipModel clip;
  final bool isDark;

  const ClipCard({super.key, required this.clip, required this.isDark});

  @override
  State<ClipCard> createState() => _ClipCardState();
}

class _ClipCardState extends State<ClipCard> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.clip.videoUrl));
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.setVolume(0); // Muted by default
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0 : 1.0);
    });
  }

  void _showReportDialog(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.flag_rounded, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            Text('Report Clip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Help keep Muntazir authentic and respectful. Please describe the issue with this clip:',
              style: TextStyle(fontSize: 12.5),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g. Inaccurate fiqh attribution, audio issue...',
                hintStyle: const TextStyle(fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC27351),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isNotEmpty) {
                await ClipsService.reportClip(
                  reelId: widget.clip.reelId,
                  reporterId: 'viewer',
                  reason: reason,
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted for admin review.')),
                  );
                }
              }
            },
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clip = widget.clip;
    final isDark = widget.isDark;

    // Determine source badge label (B.5)
    final String sourceLabel;
    if (clip.roleAtUpload == 'scholar') {
      sourceLabel = 'From ${clip.authorName}';
    } else if (clip.roleAtUpload == 'venue_admin') {
      sourceLabel = clip.venueName != null ? '${clip.venueName} Event' : 'Community Venue';
    } else {
      sourceLabel = 'Muntazir Curations';
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Video Player or Thumbnail
          if (_isInitialized && _controller != null)
            GestureDetector(
              onTap: _togglePlayPause,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else if (clip.thumbnailUrl.isNotEmpty)
            Image.network(
              clip.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: const Color(0xFF1B2A3D)),
            )
          else
            Container(color: const Color(0xFF1B2A3D)),

          // 2. Dark Gradient Overlay for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // 3. Top Row: Source Badge & Report / Sound Button
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Source Tag (B.5)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        clip.roleAtUpload == 'scholar'
                            ? Icons.verified_rounded
                            : (clip.roleAtUpload == 'venue_admin' ? Icons.mosque_rounded : Icons.auto_awesome),
                        color: const Color(0xFFD4AF37),
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 130),
                        child: Text(
                          sourceLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                Row(
                  children: [
                    // Mute / Unmute Button
                    InkWell(
                      onTap: _toggleMute,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Report Button (B.8)
                    InkWell(
                      onTap: () => _showReportDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.flag_outlined, size: 14, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 4. Play/Pause Center Indicator
          if (!_isPlaying)
            Center(
              child: GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 1.5),
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                ),
              ),
            ),

          // 5. Bottom Info & Conversion Action Button (B.6)
          Positioned(
            bottom: 14,
            left: 14,
            right: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  clip.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),

                // Conversion Button (B.6: core purpose to convert curiosity into actual practice)
                if (clip.linkedContentId != null && clip.linkedContentId!.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC27351),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.auto_stories_rounded, size: 14),
                      label: Text(
                        _getConversionButtonLabel(clip.linkedContentId!),
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        ClipsService.trackConversionTap(
                          reelId: clip.reelId,
                          linkedContentId: clip.linkedContentId!,
                          userId: 'active_user',
                          actionType: 'read_content',
                        );
                        context.push('/reader/${clip.linkedContentId}');
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getConversionButtonLabel(String contentId) {
    if (contentId.contains('surah')) {
      return 'Read this Surah';
    } else if (contentId.contains('ziyarat')) {
      return 'Recite this Ziyarat';
    } else {
      return 'Read this Dua';
    }
  }
}
