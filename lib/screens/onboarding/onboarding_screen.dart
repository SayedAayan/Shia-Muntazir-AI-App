import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'welcome_step.dart';
import 'details_step.dart';
import 'marja_step.dart';
import 'language_step.dart';
import 'theme_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onComplete() {
    context.go('/home');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _currentPage > 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(_totalPages - 1, (index) {
                  final active = _currentPage == index + 1;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFFD4AF37)
                          : (isDark ? Colors.grey[800] : Colors.grey[300]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              )
            : null,
        centerTitle: true,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // Controls wizard navigation strictly
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            WelcomeStep(onNext: _nextPage),
            DetailsStep(onNext: _nextPage, onBack: _previousPage),
            MarjaStep(onNext: _nextPage, onBack: _previousPage),
            LanguageStep(onNext: _nextPage, onBack: _previousPage),
            ThemeStep(onComplete: _onComplete, onBack: _previousPage),
          ],
        ),
      ),
    );
  }
}
