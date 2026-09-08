import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/companion_models.dart';
import '../models/content_model.dart';
import '../models/goal_model.dart';
import 'content_seeder.dart';

class ContentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _contentCollection =>
      _firestore.collection('content');

  CollectionReference<Map<String, dynamic>> get _goalsCollection =>
      _firestore.collection('goals');

  CollectionReference<Map<String, dynamic>> get _streakLogsCollection =>
      _firestore.collection('streak_logs');

  /// Stream all content items
  Stream<List<ContentModel>> streamAllContent() {
    return _contentCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Stream content by type ("dua", "ziyarat", "surah")
  Stream<List<ContentModel>> streamContentByType(String type) {
    return _contentCollection
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get single content item by ID
  Future<ContentModel?> getContentById(String contentId) async {
    final doc = await _contentCollection.doc(contentId).get();
    if (!doc.exists || doc.data() == null) return null;
    return ContentModel.fromMap(doc.data()!, doc.id);
  }

  /// Filter content by keyword / tags
  Future<List<ContentModel>> searchContentByTags(List<String> keywords) async {
    final snapshot = await _contentCollection.get();
    final all = snapshot.docs
        .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
        .toList();

    return all.where((item) {
      final text = '${item.title} ${item.tags.join(" ")}'.toLowerCase();
      return keywords.any((k) => text.contains(k.toLowerCase()));
    }).toList();
  }

  /// Seed an individual content item
  Future<void> saveContentItem(ContentModel item) async {
    await _contentCollection.doc(item.contentId).set(
          item.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Stream goals for current user
  Stream<List<GoalModel>> streamUserGoals(String userId) {
    return _goalsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GoalModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Ensure initial default goals exist for a user
  Future<List<GoalModel>> ensureInitialUserGoals(String userId) async {
    final existing = await _goalsCollection.where('userId', isEqualTo: userId).get();
    if (existing.docs.isNotEmpty) {
      return existing.docs
          .map((doc) => GoalModel.fromMap(doc.data(), doc.id))
          .toList();
    }

    // Seed default templates for new user
    final templates = ContentSeeder.getInitialGoalTemplates(userId);
    final batch = _firestore.batch();
    for (final goal in templates) {
      final ref = _goalsCollection.doc(goal.goalId);
      batch.set(ref, goal.toMap());
    }
    await batch.commit();
    return templates;
  }

  /// Create a new goal
  Future<void> createGoal(GoalModel goal) async {
    await _goalsCollection.doc(goal.goalId).set(
          goal.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Stream streak logs for current week (Monday to Sunday)
  Stream<List<StreakLogModel>> streamUserWeekStreak(String userId) {
    final now = DateTime.now();
    // Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStr = _formatDateKey(monday);

    return _streakLogsCollection
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: mondayStr)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => StreakLogModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Mark an item recited for a goal today and update streaks
  Future<void> recordItemRecited({
    required String userId,
    required String goalId,
    required String contentId,
  }) async {
    final now = DateTime.now();
    final todayStr = _formatDateKey(now);
    final logId = '${userId}_${goalId}_${contentId}_$todayStr';

    // 1. Get current goal definition
    final goalDoc = await _goalsCollection.doc(goalId).get();
    if (!goalDoc.exists || goalDoc.data() == null) return;
    final goal = GoalModel.fromMap(goalDoc.data()!, goalDoc.id);

    // 2. Save this recitation's streak log
    final logRef = _streakLogsCollection.doc(logId);
    final newLog = StreakLogModel(
      logId: logId,
      userId: userId,
      goalId: goalId,
      contentId: contentId,
      date: todayStr,
      status: 'done',
    );
    await logRef.set(newLog.toMap(), SetOptions(merge: true));

    // 3. Count all completed unique items for this goal today
    final todayLogsSnap = await _streakLogsCollection
        .where('userId', isEqualTo: userId)
        .where('goalId', isEqualTo: goalId)
        .where('date', isEqualTo: todayStr)
        .where('status', isEqualTo: 'done')
        .get();

    final completedItemIds = todayLogsSnap.docs
        .map((d) => d.data()['contentId'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();

    final totalItems = goal.items.isNotEmpty ? goal.items.length : 1;
    final progressToday = (completedItemIds.length / totalItems).clamp(0.0, 1.0);
    final allCompleted = completedItemIds.length >= totalItems;

    // 4. Calculate streak count
    int newStreak = goal.streakCount;
    if (allCompleted) {
      final yesterday = now.subtract(const Duration(days: 1));
      final yesterdayStr = _formatDateKey(yesterday);
      final yesterdayLogsSnap = await _streakLogsCollection
          .where('userId', isEqualTo: userId)
          .where('goalId', isEqualTo: goalId)
          .where('date', isEqualTo: yesterdayStr)
          .where('status', isEqualTo: 'done')
          .get();

      if (yesterdayLogsSnap.docs.length >= totalItems) {
        newStreak = goal.streakCount + 1;
      } else if (goal.streakCount == 0) {
        newStreak = 1;
      }
    }

    // 5. Update goal document
    await _goalsCollection.doc(goalId).update({
      'progress_today': progressToday,
      'streak_count': newStreak,
    });
  }

  static String _formatDateKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

