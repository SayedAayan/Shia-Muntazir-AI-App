import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/clip_model.dart';

class ClipsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Curated initial default clips for immediate visual vibrancy
  static final List<ClipModel> defaultClips = [
    ClipModel(
      reelId: 'clip_dua_ahad_reflection',
      uploadedBy: 'scholar_sayed_baqir',
      roleAtUpload: 'scholar',
      title: 'The 40-Day Pledge: Spiritual Virtues of Dua-e-Ahad',
      category: 'spiritual_reflection',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1542816417-0983c9c9ad53?auto=format&fit=crop&w=600&q=80',
      durationSeconds: 45,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      linkedContentId: 'dua_ahad',
      authorName: 'Maulana Sayed Baqir',
    ),
    ClipModel(
      reelId: 'clip_sistani_sajdah_sahw',
      uploadedBy: 'scholar_sheikh_ali_raza',
      roleAtUpload: 'scholar',
      title: 'Sajdah as-Sahw: Step-by-Step Rulings of Ayatollah Sistani',
      category: 'fiqh_answer',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?auto=format&fit=crop&w=600&q=80',
      durationSeconds: 60,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      authorName: 'Sheikh Ali Raza',
    ),
    ClipModel(
      reelId: 'clip_mogul_masjid_wiladat',
      uploadedBy: 'venue_admin_mogul',
      roleAtUpload: 'venue_admin',
      venueId: 'venue_mogul_masjid',
      venueName: 'Masjid-e-Iranian (Mogul Masjid)',
      title: 'Grand Wiladat Celebration & Community Niyaz Announcement',
      category: 'majlis_update',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1564769625905-50e93615e769?auto=format&fit=crop&w=600&q=80',
      durationSeconds: 50,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      authorName: 'Mogul Masjid Committee',
    ),
    ClipModel(
      reelId: 'clip_ayat_kursi_reflection',
      uploadedBy: 'admin_muntazir',
      roleAtUpload: 'admin',
      title: 'Ayat of the Day: The Unshakable Throne of Allah (2:255)',
      category: 'ayat_of_day',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1507692049790-de58290a4334?auto=format&fit=crop&w=600&q=80',
      durationSeconds: 40,
      createdAt: DateTime.now().subtract(const Duration(hours: 14)),
      linkedContentId: 'surah_fatiha',
      authorName: 'Muntazir Curations',
    ),
    ClipModel(
      reelId: 'clip_hadith_safina',
      uploadedBy: 'scholar_sheikh_jawad',
      roleAtUpload: 'scholar',
      title: 'Hadith of the Ark: The Ahlulbayt are the Ark of Noah',
      category: 'hadith_of_day',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1519817650390-64a93db51149?auto=format&fit=crop&w=600&q=80',
      durationSeconds: 55,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      linkedContentId: 'ziyarat_ale_yasin',
      authorName: 'Sheikh Jawad al-Kadhimi',
    ),
    ClipModel(
      reelId: 'clip_shia_youth_charity',
      uploadedBy: 'venue_admin_aliman',
      roleAtUpload: 'venue_admin',
      venueId: 'venue_aliman_center',
      venueName: 'Al-Iman Shia Center',
      title: 'Youth Food Drive: Serving Underprivileged Families in Lucknow',
      category: 'event_highlight',
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?auto=format&fit=crop&w=600&q=80',
      durationSeconds: 70,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      authorName: 'Al-Iman Youth Wing',
    ),
  ];

  /// Seed initial clips if Firestore is empty
  static Future<void> seedClipsIfEmpty() async {
    try {
      final snap = await _firestore.collection('reels').limit(1).get();
      if (snap.docs.isEmpty) {
        for (final clip in defaultClips) {
          await _firestore.collection('reels').doc(clip.reelId).set(clip.toMap());
        }
        debugPrint('Seeded ${defaultClips.length} default Muntazir clips.');
      }
    } catch (e) {
      debugPrint('Clips seed note: $e');
    }
  }

  /// Stream all visible clips
  static Stream<List<ClipModel>> streamAllClips() {
    return _firestore
        .collection('reels')
        .where('is_hidden', isEqualTo: false)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => ClipModel.fromMap(d.data(), d.id)).toList();
      // Chronological sort: newest first (B.5)
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list.isNotEmpty ? list : defaultClips;
    });
  }

  /// Stream clips for a specific category shelf
  static Stream<List<ClipModel>> streamClipsByCategory(String category) {
    return _firestore
        .collection('reels')
        .where('category', isEqualTo: category)
        .where('is_hidden', isEqualTo: false)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => ClipModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (list.isEmpty) {
        return defaultClips.where((c) => c.category == category).toList();
      }
      return list;
    });
  }

  /// Upload clip directly to live feed (B.3: live immediately, no manual approval queue)
  static Future<void> uploadClip(ClipModel clip) async {
    await _firestore.collection('reels').doc(clip.reelId).set(clip.toMap());
  }

  /// Report clip for admin review (B.8)
  static Future<void> reportClip({
    required String reelId,
    required String reporterId,
    required String reason,
  }) async {
    final reportId = 'rep_${DateTime.now().millisecondsSinceEpoch}';
    final report = ClipReportModel(
      reportId: reportId,
      reelId: reelId,
      reporterId: reporterId,
      reason: reason,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('reel_reports').doc(reportId).set(report.toMap());
  }

  /// Track conversion action tap (B.6)
  static Future<void> trackConversionTap({
    required String reelId,
    required String linkedContentId,
    required String userId,
    required String actionType,
  }) async {
    try {
      await _firestore.collection('analytics_events').add({
        'event_name': 'reel_conversion_tap',
        'reelId': reelId,
        'linked_content_id': linkedContentId,
        'action_type': actionType,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
