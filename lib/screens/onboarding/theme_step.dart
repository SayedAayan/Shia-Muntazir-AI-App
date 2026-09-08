import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/user_provider.dart';

class ThemeStep extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const ThemeStep({super.key, required this.onComplete, required this.onBack});

  @override
  ConsumerState<ThemeStep> createState() => _ThemeStepState();
}

class _ThemeStepState extends ConsumerState<ThemeStep> {
  late String _selectedTheme;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTheme = ref.read(onboardingProvider).theme;
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      ref.read(onboardingProvider.notifier).updateTheme(_selectedTheme);
      await ref.read(themeProvider.notifier).setTheme(_selectedTheme);

      final userService = ref.read(userServiceProvider);
      await ref.read(onboardingProvider.notifier).completeOnboarding(userService);

      if (mounted) {
        widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Appearance',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select your preferred color theme. You can also adjust this later in settings.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),

          // Option 1: Light
          _buildThemeCard(
            title: 'Light Theme',
            subtitle: 'Warm parchment tones with deep blue and gold accents',
            icon: Icons.light_mode_rounded,
            value: 'light',
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Option 2: Dark
          _buildThemeCard(
            title: 'Dark Theme',
            subtitle: 'Sleek, high contrast dark palette gentle on the eyes at night',
            icon: Icons.dark_mode_rounded,
            value: 'dark',
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Option 3: System
          _buildThemeCard(
            title: 'Follow System',
            subtitle: 'Automatically matches your device display settings',
            icon: Icons.brightness_auto_rounded,
            value: 'system',
            isDark: isDark,
          ),
          const SizedBox(height: 36),

          // Submit / Back Buttons
          Row(
            children: [
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: _isLoading ? null : widget.onBack,
                  child: const Text('Back', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3B5A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Complete Setup', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              SizedBox(width: 8),
                              Icon(Icons.check_circle_outline_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _selectedTheme == value;

    return InkWell(
      onTap: () {
        setState(() => _selectedTheme = value);
        // Instant visual feedback
        ref.read(themeProvider.notifier).setTheme(value);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1B3B5A).withValues(alpha: 0.5) : const Color(0xFFEBF2F7))
              : (isDark ? Colors.grey[900] : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1B3B5A)
                    : (isDark ? Colors.grey[800] : Colors.grey[200]),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFFD4AF37) : (isDark ? Colors.grey[300] : Colors.grey[700]),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
