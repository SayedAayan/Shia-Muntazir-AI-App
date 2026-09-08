import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/companion_models.dart';
import '../../models/goal_model.dart';
import '../../providers/content_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final userGoalsAsync = ref.watch(userGoalsStreamProvider);
    final weekStreakAsync = ref.watch(weekStreakStreamProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Muntazir',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.help_outline_rounded,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.qr_code_scanner_rounded,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              size: 20,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: userProfileAsync.when(
        data: (user) {
          final greetingName = user?.name.isNotEmpty == true ? user!.name : 'Ali';
          final initial = greetingName.isNotEmpty ? greetingName[0].toUpperCase() : 'A';

          return userGoalsAsync.when(
            data: (goals) {
              final weekLogs = weekStreakAsync.value ?? [];
              return _buildHomeBody(
                context,
                ref,
                greetingName,
                initial,
                goals,
                weekLogs,
                isDark,
                user?.uid ?? 'guest_user',
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFFC27351)),
            ),
            error: (err, _) => Center(child: Text('Error loading goals: $err')),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC27351)),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHomeBody(
    BuildContext context,
    WidgetRef ref,
    String greetingName,
    String initial,
    List<GoalModel> goals,
    List<StreakLogModel> weekLogs,
    bool isDark,
    String userId,
  ) {
    // Compute total items and completed recitations today
    int totalPlanned = 0;
    int totalCompleted = 0;
    int maxStreak = 0;

    for (final g in goals) {
      final itemsCount = g.items.length;
      totalPlanned += itemsCount;
      final completedInGoal = (g.progressToday * itemsCount).round();
      totalCompleted += completedInGoal;
      if (g.streakCount > maxStreak) {
        maxStreak = g.streakCount;
      }
    }

    final overallPercentage = totalPlanned > 0
        ? ((totalCompleted / totalPlanned) * 100).round()
        : 0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      children: [
        // Top Greeting Row
        _buildGreetingHeader(greetingName, initial, isDark),
        const SizedBox(height: 18),

        // Hero: "YOUR DAILY NIYYAH" Card
        _buildDailyNiyyahCard(
          totalCompleted: totalCompleted,
          totalPlanned: totalPlanned,
          percentage: overallPercentage,
        ),
        const SizedBox(height: 24),

        // "Your week" Streak Tracker Card
        _buildYourWeekCard(weekLogs, maxStreak, isDark),
        const SizedBox(height: 28),

        // "Your practices" Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your practices',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            Text(
              'See all',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFC27351), // Terracotta
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Dynamic Practice Cards
        if (goals.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No goals set yet. Choose a practice template below.',
                style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          )
        else
          ...goals.asMap().entries.map((entry) {
            final idx = entry.key;
            final goal = entry.value;
            final colors = [
              const Color(0xFFB96847), // Terracotta
              const Color(0xFF4D7C68), // Sage Green
              const Color(0xFFC28B45), // Ochre Gold
            ];
            final icons = [
              Icons.auto_awesome_rounded,
              Icons.wb_sunny_outlined,
              Icons.menu_book_rounded,
            ];

            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: _buildDynamicPracticeCard(
                context,
                ref,
                goal: goal,
                color: colors[idx % colors.length],
                icon: icons[idx % icons.length],
                isDark: isDark,
                userId: userId,
              ),
            );
          }),

        const SizedBox(height: 14),

        // "Quick access" Section
        Text(
          'Quick access',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickAccessRow(context, isDark),
        const SizedBox(height: 32),
      ],
    );
  }

  /// Top Greeting Header matching screenshot
  Widget _buildGreetingHeader(String name, String initial, bool isDark) {
    final now = DateTime.now();
    final dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final monthNames = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEPT', 'OCT', 'NOV', 'DEC'
    ];
    final dateStr =
        '${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateStr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                ),
                children: [
                  const TextSpan(text: 'Assalamu alaykum, '),
                  TextSpan(
                    text: name,
                    style: const TextStyle(color: Color(0xFFC27351)),
                  ),
                ],
              ),
            ),
          ],
        ),
        // User Initial Avatar Circle in Terracotta
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFC27351),
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// Deep Navy "YOUR DAILY NIYYAH" Hero Card
  Widget _buildDailyNiyyahCard({
    required int totalCompleted,
    required int totalPlanned,
    required int percentage,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2A3D), // Deep Navy Slate
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Sparkles tag & Hijri date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFFD4AF37)),
                  SizedBox(width: 6),
                  Text(
                    'YOUR DAILY NIYYAH',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Text(
                '17 Safar',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Main Headline
          const Text(
            'Begin with\na quiet heart.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle
          const Text(
            'Small, sincere practices become a path.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Bottom Stats & Circular Gauge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TODAY\'S PRACTICE',
                    style: TextStyle(
                      color: Color(0xFFC27351),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalCompleted of $totalPlanned recitations',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Circular Percentage Badge
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFC27351),
                    width: 2.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// "Your week" Streak Card with 7 Days (Monday to Sunday)
  Widget _buildYourWeekCard(
    List<StreakLogModel> weekLogs,
    int maxStreak,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF17202C) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);

    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your week',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.wb_sunny_outlined, size: 16, color: Color(0xFFC27351)),
                const SizedBox(width: 5),
                Text(
                  '$maxStreak day streak',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC27351),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayIndex = index + 1;
              final dayDate = monday.add(Duration(days: index));
              final isToday = dayIndex == currentWeekday;
              final isPast = dayIndex < currentWeekday;

              final dayDateStr =
                  '${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}';

              // Check if any log in weekLogs has status == 'done' on this date
              final hasCompleted = weekLogs.any(
                (log) => log.date == dayDateStr && log.status == 'done',
              );

              // If past and no logs, provide completed status if streak is active
              final isDone = hasCompleted || (isPast && maxStreak >= (currentWeekday - dayIndex));

              return _buildDayCircle(
                dayLabels[index],
                isDone,
                isToday: isToday,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCircle(String day, bool isDone, {bool isToday = false}) {
    return Column(
      children: [
        Text(
          day,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? const Color(0xFF5E8D77) // Sage Green
                : (isToday ? Colors.transparent : Colors.grey.withValues(alpha: 0.1)),
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
  }

  /// Dynamic Practice Card wired to GoalModel and recitation action
  Widget _buildDynamicPracticeCard(
    BuildContext context,
    WidgetRef ref, {
    required GoalModel goal,
    required Color color,
    required IconData icon,
    required bool isDark,
    required String userId,
  }) {
    final cardBg = isDark ? const Color(0xFF17202C) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);

    final completedCount = (goal.progressToday * goal.items.length).round();
    final totalCount = goal.items.length;
    final percentageStr = '${(goal.progressToday * 100).round()}%';
    final primaryContentId = goal.items.isNotEmpty ? goal.items.first : 'dua_ahad';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
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
          // Tappable card header navigates to reader
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.push(
                '/reader/$primaryContentId',
                extra: {'goalId': goal.goalId},
              );
            },
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: isDark ? 0.18 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
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
          ),
          const SizedBox(height: 14),

          // Progress Bar with Count
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

          // Action Row: "Mark as recited" and "Read"
          Row(
            children: [
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: () async {
                    // Quick record recitation
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
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          content: Text(
                            'Recitation recorded for "${goal.title}"!',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_forward_rounded, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Mark as recited',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Open in Reader button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white70 : const Color(0xFF1B2A3D),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: () {
                  context.push(
                    '/reader/$primaryContentId',
                    extra: {'goalId': goal.goalId},
                  );
                },
                child: const Text('Read', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick access cards at the bottom
  Widget _buildQuickAccessRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/reader/dua_ahad'),
            child: _buildQuickAccessItem('Read', Icons.menu_book_rounded, isDark),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Switched to Ask tab.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: _buildQuickAccessItem('Ask a...', Icons.chat_bubble_outline_rounded, isDark),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Switched to Around You / Community tab.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: _buildQuickAccessItem('Find...', Icons.location_on_outlined, isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem(String label, IconData icon, bool isDark) {
    return Container(
      height: 72,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: const Color(0xFFC27351)),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
            ),
          ),
        ],
      ),
    );
  }
}
