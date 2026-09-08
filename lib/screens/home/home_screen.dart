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

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            children: [
              // Top Greeting Row
              _buildGreetingHeader(greetingName, initial, isDark),
              const SizedBox(height: 18),

              // Hero: "YOUR DAILY NIYYAH" Card
              _buildDailyNiyyahCard(),
              const SizedBox(height: 24),

              // "Your week" Streak Tracker Card
              _buildYourWeekCard(isDark),
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC27351), // Terracotta
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Practice Card 1: Imam Mahdi's Servant
              _buildPracticeCard(
                title: 'Imam Mahdi\'s Servant',
                subtitle: 'A quiet daily practice for presence',
                percentage: '50%',
                progress: 0.5,
                countText: '2/4',
                color: const Color(0xFFB96847), // Terracotta
                icon: Icons.auto_awesome_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Practice Card 2: 40 Days of Dua-e-Ahad
              _buildPracticeCard(
                title: '40 Days of Dua-e-Ahad',
                subtitle: 'Begin the morning with intention',
                percentage: '86%',
                progress: 0.86,
                countText: '6/7',
                color: const Color(0xFF4D7C68), // Sage Green
                icon: Icons.wb_sunny_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Practice Card 3: Arbaeen Journey
              _buildPracticeCard(
                title: 'Arbaeen Journey',
                subtitle: 'Ziyarat, reflection, and remembrance',
                percentage: '33%',
                progress: 0.33,
                countText: '1/3',
                color: const Color(0xFFC28B45), // Ochre Gold
                icon: Icons.menu_book_rounded,
                isDark: isDark,
              ),
              const SizedBox(height: 28),

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
              _buildQuickAccessRow(isDark),
              const SizedBox(height: 32),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFC27351)),
        ),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  /// Top Greeting Header matching screenshot
  Widget _buildGreetingHeader(String name, String initial, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TUESDAY, 8 SEPT',
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
                    style: const TextStyle(color: Color(0xFFC27351)), // Terracotta
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
  Widget _buildDailyNiyyahCard() {
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
                children: const [
                  Text(
                    'TODAY\'S PRACTICE',
                    style: TextStyle(
                      color: Color(0xFFC27351),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '9 of 14 recitations',
                    style: TextStyle(
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
                child: const Text(
                  '64%',
                  style: TextStyle(
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

  /// "Your week" Streak Card with 7 Days
  Widget _buildYourWeekCard(bool isDark) {
    final cardBg = isDark ? const Color(0xFF17202C) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);

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
              children: const [
                Icon(Icons.wb_sunny_outlined, size: 16, color: Color(0xFFC27351)),
                SizedBox(width: 5),
                Text(
                  '6 day streak',
                  style: TextStyle(
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
            children: [
              _buildDayCircle('M', true),
              _buildDayCircle('T', true),
              _buildDayCircle('W', true),
              _buildDayCircle('T', true),
              _buildDayCircle('F', true),
              _buildDayCircle('S', true),
              _buildDayCircle('S', false, isToday: true),
            ],
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
                ? const Color(0xFF5E8D77) // Sage Green from screenshot
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

  /// Individual Practice Card (Imam Mahdi's Servant, 40 Days of Dua-e-Ahad, Arbaeen Journey)
  Widget _buildPracticeCard({
    required String title,
    required String subtitle,
    required String percentage,
    required double progress,
    required String countText,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    final cardBg = isDark ? const Color(0xFF17202C) : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05);

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
          Row(
            children: [
              // Icon container with light tint
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
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress Bar with Count
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                countText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // "-> Mark as recited" Button matching screenshot
          SizedBox(
            width: 160,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              onPressed: () {},
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
        ],
      ),
    );
  }

  /// Quick access cards at the bottom
  Widget _buildQuickAccessRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAccessItem('Read', Icons.menu_book_rounded, isDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickAccessItem('Ask a...', Icons.chat_bubble_outline_rounded, isDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildQuickAccessItem('Find...', Icons.location_on_outlined, isDark),
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
