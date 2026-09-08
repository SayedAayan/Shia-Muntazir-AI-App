class StreakLogModel {
  final String logId;
  final String userId;
  final String goalId;
  final String contentId;
  final String date; // YYYY-MM-DD
  final String status; // "done" | "missed"

  const StreakLogModel({
    required this.logId,
    required this.userId,
    required this.goalId,
    required this.contentId,
    required this.date,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'userId': userId,
      'goalId': goalId,
      'contentId': contentId,
      'date': date,
      'status': status,
    };
  }

  factory StreakLogModel.fromMap(Map<String, dynamic> map, String id) {
    return StreakLogModel(
      logId: id,
      userId: map['userId'] as String? ?? '',
      goalId: map['goalId'] as String? ?? '',
      contentId: map['contentId'] as String? ?? '',
      date: map['date'] as String? ?? '',
      status: map['status'] as String? ?? 'done',
    );
  }
}

class QadhaEntryModel {
  final String entryId;
  final String userId;
  final String type; // "namaz" | "roza"
  final String prayerName; // "fajr" | "zuhr" | "asr" | "maghrib" | "isha"
  final String date;
  final String status; // "pending" | "cleared"

  const QadhaEntryModel({
    required this.entryId,
    required this.userId,
    required this.type,
    required this.prayerName,
    required this.date,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'userId': userId,
      'type': type,
      'prayer_name': prayerName,
      'date': date,
      'status': status,
    };
  }

  factory QadhaEntryModel.fromMap(Map<String, dynamic> map, String id) {
    return QadhaEntryModel(
      entryId: id,
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? 'namaz',
      prayerName: map['prayer_name'] as String? ?? '',
      date: map['date'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
    );
  }
}

class QuestionModel {
  final String questionId;
  final String userId;
  final String text;
  final String status; // "ai_answered" | "pending_scholar" | "answered"
  final String? aiAnswer;
  final String? scholarAnswer;
  final String? answeredBy;
  final List<Map<String, String>> marjaComparison;
  final DateTime createdAt;

  const QuestionModel({
    required this.questionId,
    required this.userId,
    required this.text,
    this.status = 'ai_answered',
    this.aiAnswer,
    this.scholarAnswer,
    this.answeredBy,
    this.marjaComparison = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'userId': userId,
      'text': text,
      'status': status,
      'ai_answer': aiAnswer,
      'scholar_answer': scholarAnswer,
      'answered_by': answeredBy,
      'marja_comparison': marjaComparison,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestionModel(
      questionId: id,
      userId: map['userId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      status: map['status'] as String? ?? 'ai_answered',
      aiAnswer: map['ai_answer'] as String?,
      scholarAnswer: map['scholar_answer'] as String?,
      answeredBy: map['answered_by'] as String?,
      marjaComparison: (map['marja_comparison'] as List<dynamic>?)
              ?.map((e) => Map<String, String>.from(e as Map))
              .toList() ??
          [],
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class CommunityEventModel {
  final String eventId;
  final String title;
  final String type; // "majlis" | "ziyarat" | "arbaeen"
  final double latitude;
  final double longitude;
  final String address;
  final DateTime date;
  final String description;

  const CommunityEventModel({
    required this.eventId,
    required this.title,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'title': title,
      'type': type,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory CommunityEventModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityEventModel(
      eventId: id,
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? 'majlis',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      description: map['description'] as String? ?? '',
    );
  }
}
