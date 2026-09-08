import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/main_navigation_shell.dart';
import '../screens/reader/content_reader_screen.dart';

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
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
});
