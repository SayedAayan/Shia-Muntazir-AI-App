import 'package:flutter/material.dart';

class WelcomeStep extends StatelessWidget {
  final VoidCallback onNext;

  const WelcomeStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // App Emblem / Icon Container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1B3B5A), const Color(0xFF0F2338)]
                    : [const Color(0xFF2E5B88), const Color(0xFF1B3B5A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2.5,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_stories_rounded,
                size: 56,
                color: Color(0xFFD4AF37),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // App Title
          Text(
            'MUNTAZIR',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 8),

          // Subtitle in Arabic calligraphy style
          Text(
            'مُنتَظِر',
            style: theme.textTheme.titleLarge?.copyWith(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Your Shia Islamic Companion for Spiritual Goals, Prayers, and Content',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.5,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
          const Spacer(),

          // Start Button (min 48dp height)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3B5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                ),
                elevation: 3,
              ),
              onPressed: onNext,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Begin Spiritual Journey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
