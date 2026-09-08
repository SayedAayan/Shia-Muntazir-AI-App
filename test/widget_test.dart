import 'package:flutter_test/flutter_test.dart';
import 'package:muntazir/models/user_model.dart';
import 'package:muntazir/models/content_model.dart';
import 'package:muntazir/models/goal_model.dart';
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
}
