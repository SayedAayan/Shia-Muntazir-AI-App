import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/companion_models.dart';
import '../../models/goal_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/user_provider.dart';

class GoalsStreaksScreen extends ConsumerWidget {
  const GoalsStreaksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userGoalsAsync = ref.watch(userGoalsStreamProvider);
    final weekStreakAsync = ref.watch(weekStreakStreamProvider);
    final authUser = ref.watch(authStateProvider).value;
    final userId = authUser?.uid ?? 'guest_user';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
        elevation: 0,
        title: Text(
          'Streaks & Goals',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFC27351),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: () => context.push('/create-goal'),
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            label: const Text(
              'New practice',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: userGoalsAsync.when(
        data: (goals) {
          final weekLogs = weekStreakAsync.value ?? [];

          int totalPlanned = 0;
          int totalCompleted = 0;
          int maxStreak = 0;

          for (final g in goals) {
            final itemsCount = g.items.length;
            totalPlanned += itemsCount;
            totalCompleted += (g.progressToday * itemsCount).round();
            if (g.streakCount > maxStreak) {
              maxStreak = g.streakCount;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Top Streak Hero Card
              _buildStreakBanner(maxStreak, weekLogs, isDark),
              const SizedBox(height: 20),

              // Overview Stats Row
              _buildStatsRow(
                totalPlanned: totalPlanned,
                totalCompleted: totalCompleted,
                activeGoals: goals.length,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Practices Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Spiritual Practices',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                    ),
                  ),
                  Text(
                    '${goals.length} active',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (goals.isEmpty)
                _buildEmptyState(context, isDark)
              else
                ...goals.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final goal = entry.value;
                  final colors = [
                    const Color(0xFFB96847), // Terracotta
                    const Color(0xFF4D7C68), // Sage Green
                    const Color(0xFFC28B45), // Ochre Gold
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: _buildGoalCard(
                      context,
                      ref,
                      goal: goal,
                      color: colors[idx % colors.length],
                      isDark: isDark,
                      userId: userId,
                    ),
                  );
                }),
              const SizedBox(height: 30),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFC27351))),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStreakBanner(int maxStreak, List<StreakLogModel> weekLogs, bool isDark) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final monday = now.subtract(Duration(days: currentWeekday - 1));
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3D),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.wb_sunny_rounded, color: Color(0xFFC28B45), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'WEEKLY STREAK',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC27351).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$maxStreak Days Active',
                  style: const TextStyle(
                    color: Color(0xFFE8C86A),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Consistency is Beloved to Allah',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Imam Ali (a.s.): "A small action done continuously is better than a great action done with weariness."',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.35,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),

          // 7-day circular indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayIndex = index + 1;
              final dayDate = monday.add(Duration(days: index));
              final isToday = dayIndex == currentWeekday;
              final isPast = dayIndex < currentWeekday;
              final dayDateStr =
                  '${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}';

              final hasCompleted = weekLogs.any(
                (log) => log.date == dayDateStr && log.status == 'done',
              );
              final isDone = hasCompleted || (isPast && maxStreak >= (currentWeekday - dayIndex));

              return Column(
                children: [
                  Text(
                    dayLabels[index],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isToday ? const Color(0xFFE8C86A) : Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? const Color(0xFF4D7C68)
                          : (isToday ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
                      border: isToday
                          ? Border.all(color: const Color(0xFFC27351), width: 2)
                          : null,
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : (isToday
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFC27351),
                                  ),
                                )
                              : null),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required int totalPlanned,
    required int totalCompleted,
    required int activeGoals,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            title: 'Recitations Today',
            value: '$totalCompleted / $totalPlanned',
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF4D7C68),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatBox(
            title: 'Active Practices',
            value: '$activeGoals Goals',
            icon: Icons.track_changes_rounded,
            color: const Color(0xFFC27351),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    WidgetRef ref, {
    required GoalModel goal,
    required Color color,
    required bool isDark,
    required String userId,
  }) {
    final completedCount = (goal.progressToday * goal.items.length).round();
    final totalCount = goal.items.length;
    final percentageStr = '${(goal.progressToday * 100).round()}%';
    final primaryContentId = goal.items.isNotEmpty ? goal.items.first : 'dua_ahad';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.auto_awesome_rounded, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                percentageStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: goal.progressToday,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$completedCount/$totalCount',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action Buttons
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () async {
                  final repo = ref.read(contentRepositoryProvider);
                  await repo.recordItemRecited(
                    userId: userId,
                    goalId: goal.goalId,
                    contentId: primaryContentId,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF4D7C68),
                        content: Text('Recited "${goal.title}" today!'),
                      ),
                    );
                  }
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 16),
                    SizedBox(width: 6),
                    Text('Mark Recited', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : const Color(0xFF1B2A3D),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                ),
                onPressed: () {
                  context.push(
                    '/reader/$primaryContentId',
                    extra: {'goalId': goal.goalId},
                  );
                },
                child: const Text('Open Reader', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFFC28B45), size: 48),
          const SizedBox(height: 12),
          Text(
            'Begin a Spiritual Habit',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose from authentic Shia templates like Dua-e-Ahad (40 days), Ziyarat Ashura, or build your own.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC27351),
              foregroundColor: Colors.white,
            ),
            onPressed: () => context.push('/create-goal'),
            child: const Text('Browse Practice Templates'),
          ),
        ],
      ),
    );
  }
}
