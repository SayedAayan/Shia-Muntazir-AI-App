import 'package:flutter_test/flutter_test.dart';
import 'package:muntazir/models/user_model.dart';
import 'package:muntazir/models/content_model.dart';
import 'package:muntazir/models/goal_model.dart';
import 'package:muntazir/models/companion_models.dart';
import 'package:muntazir/services/content_seeder.dart';

void main() {
  test('UserModel serialization and deserialization test', () {
    final user = UserModel(
      uid: 'test_uid_123',
      name: 'Ali Raza',
      age: 28,
      gender: 'brother',
      email: 'aliraza@example.com',
      marja: 'sistani',
      language: 'en',
      theme: 'dark',
      role: 'user',
    );

    final map = user.toMap();
    expect(map['name'], 'Ali Raza');
    expect(map['age'], 28);
    expect(map['marja'], 'sistani');

    final parsedUser = UserModel.fromMap(map, 'test_uid_123');
    expect(parsedUser.name, 'Ali Raza');
    expect(parsedUser.email, 'aliraza@example.com');
    expect(parsedUser.role, 'user');
  });

  test('ContentModel and Seed Data verification', () {
    final seed = ContentSeeder.defaultContentSeed;
    expect(seed.length, greaterThanOrEqualTo(8));

    final duaAhad = seed.firstWhere((c) => c.contentId == 'dua_ahad');
    expect(duaAhad.title, 'Dua-e-Ahad');
    expect(duaAhad.type, 'dua');
    expect(duaAhad.arabicText.contains('الْعَظِيمِ'), isTrue);
    expect(duaAhad.translationEn.isNotEmpty, isTrue);
    expect(duaAhad.translationUr.isNotEmpty, isTrue);
    expect(duaAhad.translationHi.isNotEmpty, isTrue);
    expect(duaAhad.tags.contains('morning'), isTrue);

    // Serialization test
    final map = duaAhad.toMap();
    final fromMap = ContentModel.fromMap(map, 'dua_ahad');
    expect(fromMap.title, 'Dua-e-Ahad');
    expect(fromMap.tags.length, duaAhad.tags.length);
  });

  test('GoalModel serialization test', () {
    final goal = GoalModel(
      goalId: 'goal_123',
      userId: 'user_456',
      title: 'Imam Mahdi\'s Servant',
      description: 'Daily practice for presence',
      items: ['dua_ahad', 'ziyarat_ale_yasin'],
      streakCount: 7,
      progressToday: 0.5,
      createdAt: DateTime.now(),
    );

    final map = goal.toMap();
    expect(map['title'], 'Imam Mahdi\'s Servant');
    expect(map['streak_count'], 7);
    expect((map['items'] as List).length, 2);

    final parsed = GoalModel.fromMap(map, 'goal_123');
    expect(parsed.goalId, 'goal_123');
    expect(parsed.progressToday, 0.5);
  });

  test('StreakLogModel serialization and progress calculation test', () {
    const log = StreakLogModel(
      logId: 'user1_goal1_dua_ahad_2026-09-08',
      userId: 'user1',
      goalId: 'goal1',
      contentId: 'dua_ahad',
      date: '2026-09-08',
      status: 'done',
    );

    final map = log.toMap();
    expect(map['goalId'], 'goal1');
    expect(map['contentId'], 'dua_ahad');
    expect(map['status'], 'done');
    expect(map['date'], '2026-09-08');

    final parsed = StreakLogModel.fromMap(map, log.logId);
    expect(parsed.logId, 'user1_goal1_dua_ahad_2026-09-08');
    expect(parsed.contentId, 'dua_ahad');
    expect(parsed.status, 'done');

    // Test completion ratio calculation
    final completedItems = [parsed.contentId];
    final totalItems = ['dua_ahad', 'ziyarat_ale_yasin'];
    final progress = completedItems.length / totalItems.length;
    expect(progress, 0.5);

    // If second item added
    completedItems.add('ziyarat_ale_yasin');
    final allDone = completedItems.length >= totalItems.length;
    expect(allDone, isTrue);
  });
}
