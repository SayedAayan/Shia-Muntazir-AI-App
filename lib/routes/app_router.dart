import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/main_navigation_shell.dart';
import '../screens/reader/content_reader_screen.dart';
import '../screens/goals/create_goal_screen.dart';
import '../screens/scholar/scholar_dashboard_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/toolkit/toolkit_screen.dart';
import '../screens/tools/khums_calculator_screen.dart';
import '../screens/tools/daily_sadqa_screen.dart';
import '../screens/profile/verification_request_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/clips/clip_upload_screen.dart';
import '../screens/support/support_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: authState.value != null ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainNavigationShell(),
      ),
      GoRoute(
        path: '/reader/:contentId',
        builder: (context, state) {
          final contentId = state.pathParameters['contentId'] ?? 'dua_ahad';
          final goalId = state.extra is String
              ? state.extra as String
              : (state.extra is Map ? (state.extra as Map)['goalId'] as String? : null);
          return ContentReaderScreen(
            contentId: contentId,
            goalId: goalId,
          );
        },
      ),
      GoRoute(
        path: '/create-goal',
        builder: (context, state) => const CreateGoalScreen(),
      ),
      GoRoute(
        path: '/scholar-dashboard',
        builder: (context, state) => const ScholarDashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/toolkit',
        builder: (context, state) => const ToolkitScreen(),
      ),
      GoRoute(
        path: '/khums',
        builder: (context, state) => const KhumsCalculatorScreen(),
      ),
      GoRoute(
        path: '/sadqa',
        builder: (context, state) => const DailySadqaScreen(),
      ),
      GoRoute(
        path: '/verification-request',
        builder: (context, state) => const VerificationRequestScreen(),
      ),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/clips-upload',
        builder: (context, state) => const ClipUploadScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
