import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/companion_models.dart';
import '../models/goal_model.dart';
import '../services/content_seeder.dart';
import 'content_provider.dart';
import 'user_provider.dart';

/// Stream of user goals from Firestore
final userGoalsStreamProvider = StreamProvider<List<GoalModel>>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  final repo = ref.watch(contentRepositoryProvider);

  if (authUser == null) {
    // Fallback: return initial templates as in-memory stream for guest/unauthenticated state
    return Stream.value(ContentSeeder.getInitialGoalTemplates('guest_user'));
  }

  // Ensure default goals are seeded for new user
  repo.ensureInitialUserGoals(authUser.uid);

  return repo.streamUserGoals(authUser.uid);
});

/// Stream of streak logs for the current week (Mon-Sun)
final weekStreakStreamProvider = StreamProvider<List<StreakLogModel>>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  final repo = ref.watch(contentRepositoryProvider);

  if (authUser == null) {
    return Stream.value([]);
  }

  return repo.streamUserWeekStreak(authUser.uid);
});
