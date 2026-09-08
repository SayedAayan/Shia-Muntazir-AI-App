import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';
import '../models/goal_model.dart';

class ContentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _contentCollection =>
      _firestore.collection('content');

  CollectionReference<Map<String, dynamic>> get _goalsCollection =>
      _firestore.collection('goals');

  /// Stream all content items
  Stream<List<ContentModel>> streamAllContent() {
    return _contentCollection.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ContentModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Stream content by type ("dua", "ziyarat", "surah", "aamal")
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

  /// Create a new goal
  Future<void> createGoal(GoalModel goal) async {
    await _goalsCollection.doc(goal.goalId).set(
          goal.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Update goal progress
  Future<void> updateGoalProgress(
      String goalId, double progressToday, int streakCount) async {
    await _goalsCollection.doc(goalId).update({
      'progress_today': progressToday,
      'streak_count': streakCount,
    });
  }
}
