import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home/home_screen.dart';
import 'goals/goals_streaks_screen.dart';
import 'clips/clips_feed_screen.dart';
import 'quran_duas/quran_duas_screen.dart';
import 'ask/ask_screen.dart';
import 'community/community_screen.dart';

class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final bottomNavIndexProvider =
    NotifierProvider<BottomNavNotifier, int>(BottomNavNotifier.new);

class MainNavigationShell extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  // 6 Tabs: Home → Goals → Clips → Read → Ask → Community (Part B spec)
  final List<Widget> _screens = const [
    HomeScreen(),
    GoalsStreaksScreen(),
    ClipsFeedScreen(),
    QuranDuasScreen(),
    AskScreen(),
    CommunityScreen(),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bottomNavIndexProvider.notifier).setIndex(widget.initialIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const activeColor = Color(0xFFC27351); // Terracotta
    final inactiveColor = isDark ? Colors.grey[500] : Colors.grey[600];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.06),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.local_fire_department_rounded,
                  label: 'Goals',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.play_circle_filled_rounded,
                  label: 'Clips',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.menu_book_rounded,
                  label: 'Read',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.chat_bubble_rounded,
                  label: 'Ask',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
                _buildNavItem(
                  index: 5,
                  icon: Icons.groups_rounded,
                  label: 'Community',
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color activeColor,
    required Color? inactiveColor,
  }) {
    final isSelected = ref.watch(bottomNavIndexProvider) == index;

    return Expanded(
      child: InkWell(
        onTap: () => ref.read(bottomNavIndexProvider.notifier).setIndex(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48), // Minimum 48x48dp tap target
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? activeColor : inactiveColor,
                size: 22,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
