import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'quran_duas/quran_duas_screen.dart';
import 'ask/ask_screen.dart';
import 'community/community_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialIndex;

  const MainNavigationShell({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(), // Main Goals & Streaks dashboard
    QuranDuasScreen(),
    AskScreen(),
    CommunityScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFFD4AF37).withValues(alpha: 0.25),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
                fontSize: 11.5,
              );
            }
            return TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              fontSize: 11.5,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFFD4AF37), size: 26);
            }
            return IconThemeData(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              size: 24,
            );
          }),
        ),
        child: NavigationBar(
          height: 70, // Ensures comfortable tap targets >= 48dp
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: isDark ? const Color(0xFF141D26) : Colors.white,
          elevation: 4,
          destinations: [
            NavigationDestination(
              icon: const Badge(
                backgroundColor: Color(0xFFD4AF37),
                label: Text('🔥', style: TextStyle(fontSize: 10)),
                child: Icon(Icons.local_fire_department_outlined),
              ),
              selectedIcon: const Badge(
                backgroundColor: Color(0xFFD4AF37),
                label: Text('🔥', style: TextStyle(fontSize: 10)),
                child: Icon(Icons.local_fire_department_rounded),
              ),
              label: 'Streaks & Goals',
            ),
            const NavigationDestination(
              icon: Icon(Icons.auto_stories_outlined),
              selectedIcon: Icon(Icons.auto_stories_rounded),
              label: 'Quran & Duas',
            ),
            const NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Ask',
            ),
            const NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Community',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
