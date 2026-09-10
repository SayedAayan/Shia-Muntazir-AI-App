import 'package:cloud_firestore/cloud_firestore.dart';

class ClipModel {
  final String reelId;
  final String uploadedBy;
  final String roleAtUpload; // "admin" | "scholar" | "venue_admin"
  final String? venueId;
  final String title;
  final String category; // 'fiqh_answer', 'spiritual_reflection', 'majlis_update', 'event_highlight', 'ayat_of_day', 'hadith_of_day', 'general'
  final String videoUrl;
  final String thumbnailUrl;
  final int durationSeconds;
  final DateTime createdAt;
  final String? linkedContentId; // optional deep-link into dua/ziyarat/surah/goal
  final String authorName;
  final String? venueName;
  final bool isHidden; // kill switch flag

  const ClipModel({
    required this.reelId,
    required this.uploadedBy,
    required this.roleAtUpload,
    this.venueId,
    required this.title,
    required this.category,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.createdAt,
    this.linkedContentId,
    required this.authorName,
    this.venueName,
    this.isHidden = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'reelId': reelId,
      'uploaded_by': uploadedBy,
      'role_at_upload': roleAtUpload,
      'venueId': venueId,
      'title': title,
      'category': category,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'created_at': Timestamp.fromDate(createdAt),
      'linked_content_id': linkedContentId,
      'author_name': authorName,
      'venue_name': venueName,
      'is_hidden': isHidden,
    };
  }

  factory ClipModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ClipModel(
      reelId: id,
      uploadedBy: map['uploaded_by'] as String? ?? '',
      roleAtUpload: map['role_at_upload'] as String? ?? 'scholar',
      venueId: map['venueId'] as String?,
      title: map['title'] as String? ?? 'Untitled Clip',
      category: map['category'] as String? ?? 'general',
      videoUrl: map['video_url'] as String? ?? '',
      thumbnailUrl: map['thumbnail_url'] as String? ?? '',
      durationSeconds: (map['duration_seconds'] as num?)?.toInt() ?? 30,
      createdAt: parseTime(map['created_at']),
      linkedContentId: map['linked_content_id'] as String?,
      authorName: map['author_name'] as String? ?? 'Muntazir Scholar',
      venueName: map['venue_name'] as String?,
      isHidden: map['is_hidden'] as bool? ?? false,
    );
  }

  ClipModel copyWith({bool? isHidden}) {
    return ClipModel(
      reelId: reelId,
      uploadedBy: uploadedBy,
      roleAtUpload: roleAtUpload,
      venueId: venueId,
      title: title,
      category: category,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      durationSeconds: durationSeconds,
      createdAt: createdAt,
      linkedContentId: linkedContentId,
      authorName: authorName,
      venueName: venueName,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}

class ClipReportModel {
  final String reportId;
  final String reelId;
  final String reporterId;
  final String reason;
  final DateTime createdAt;
  final String status; // "pending" | "reviewed"

  const ClipReportModel({
    required this.reportId,
    required this.reelId,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reelId': reelId,
      'reporter_id': reporterId,
      'reason': reason,
      'created_at': Timestamp.fromDate(createdAt),
      'status': status,
    };
  }

  factory ClipReportModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseTime(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ClipReportModel(
      reportId: id,
      reelId: map['reelId'] as String? ?? '',
      reporterId: map['reporter_id'] as String? ?? 'anonymous',
      reason: map['reason'] as String? ?? '',
      createdAt: parseTime(map['created_at']),
      status: map['status'] as String? ?? 'pending',
    );
  }
}
