class GoalModel {
  final String goalId;
  final String userId;
  final String title;
  final String description;
  final List<String> items; // list of contentId
  final int streakCount;
  final double progressToday; // completed_items / total_items
  final String createdVia; // "ai" | "manual" | "template"
  final DateTime createdAt;

  const GoalModel({
    required this.goalId,
    required this.userId,
    required this.title,
    required this.description,
    required this.items,
    this.streakCount = 0,
    this.progressToday = 0.0,
    this.createdVia = 'template',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'goalId': goalId,
      'userId': userId,
      'title': title,
      'description': description,
      'items': items,
      'streak_count': streakCount,
      'progress_today': progressToday,
      'created_via': createdVia,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map, String id) {
    return GoalModel(
      goalId: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      items: (map['items'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      streakCount: (map['streak_count'] as num?)?.toInt() ?? 0,
      progressToday: (map['progress_today'] as num?)?.toDouble() ?? 0.0,
      createdVia: map['created_via'] as String? ?? 'template',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  GoalModel copyWith({
    String? goalId,
    String? userId,
    String? title,
    String? description,
    List<String>? items,
    int? streakCount,
    double? progressToday,
    String? createdVia,
    DateTime? createdAt,
  }) {
    return GoalModel(
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      items: items ?? this.items,
      streakCount: streakCount ?? this.streakCount,
      progressToday: progressToday ?? this.progressToday,
      createdVia: createdVia ?? this.createdVia,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
