import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF070D18) : const Color(0xFFF7F9FC),
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Text(
              'Muntazir',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.2,
                color: isDark ? const Color(0xFFE2C374) : const Color(0xFF0F2942),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'مُنتَظِر',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFE2C374).withValues(alpha: 0.8) : Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: isDark ? const Color(0xFFE2C374) : Colors.black87,
            ),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: userProfileAsync.when(
        data: (user) {
          final greetingName = user?.name.isNotEmpty == true ? user!.name : 'Believer';

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            children: [
              // Hero Radial Streak Ring Card
              _buildRadialStreakHero(greetingName, isDark),
              const SizedBox(height: 20),

              // Active Spiritual Routines Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Spiritual Routines',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFFE2C374)),
                    label: const Text(
                      'Add Goal',
                      style: TextStyle(color: Color(0xFFE2C374), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Glassmorphic Routine Card 1: Dua-e-Ahad
              _buildRoutineCard(
                title: 'Dua-e-Ahad',
                category: 'Morning Routine • After Fajr',
                status: 'Completed',
                isCompleted: true,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // Glassmorphic Routine Card 2: Ziyarat Ale-Yasin
              _buildRoutineCard(
                title: 'Ziyarat of Imam Husayn (as)',
                category: 'Daily Spiritual Connection',
                status: 'Pending',
                isCompleted: false,
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // Shia Prayer Tracker Pill Bar
              _buildPrayerTrackerPill(isDark),
              const SizedBox(height: 30),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFE2C374))),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildRadialStreakHero(String greetingName, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF101C33), const Color(0xFF070D18)]
              : [const Color(0xFFEBF2FA), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2C374).withValues(alpha: isDark ? 0.35 : 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2C374).withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Greeting Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2C374).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2C374).withValues(alpha: 0.3)),
            ),
            child: Text(
              'Salam, $greetingName',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE2C374),
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Circular Radial Progress with Golden Glow
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer ambient glow ring
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE2C374).withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              // Circular progress track
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: 0.70, // 70% completed today
                  strokeWidth: 8,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE2C374)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Center Streak Display
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        '7',
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2C374),
                          letterSpacing: -1,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.local_fire_department_rounded, color: Color(0xFFE2C374), size: 36),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'DAYS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Subtitle
          const Text(
            'Consecutive Days of Taqarrub',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),

          // Progress line
          Text(
            '2 of 3 Spiritual Goals Recited Today',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineCard({
    required String title,
    required String category,
    required String status,
    required bool isCompleted,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D172A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFF00C48C).withValues(alpha: 0.3)
              : const Color(0xFFE2C374).withValues(alpha: 0.25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? const Color(0xFF00C48C).withValues(alpha: 0.15)
                  : const Color(0xFFE2C374).withValues(alpha: 0.15),
            ),
            child: Icon(
              isCompleted ? Icons.check_circle_rounded : Icons.auto_stories_rounded,
              color: isCompleted ? const Color(0xFF00C48C) : const Color(0xFFE2C374),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00C48C).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00C48C).withValues(alpha: 0.5)),
              ),
              child: const Text(
                'Completed',
                style: TextStyle(
                  color: Color(0xFF00C48C),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            )
          else
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE2C374),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {},
              child: const Text(
                'Recite Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerTrackerPill(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D172A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.access_time_filled_rounded, color: Color(0xFFE2C374), size: 18),
              const SizedBox(width: 8),
              Text(
                'Next: Maghribain Prayer Window',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[200] : Colors.black87,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2C374).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '6:45 PM',
              style: TextStyle(
                color: Color(0xFFE2C374),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
