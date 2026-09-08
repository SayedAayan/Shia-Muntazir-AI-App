import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';

class LanguageStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const LanguageStep({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<LanguageStep> createState() => _LanguageStepState();
}

class _LanguageStepState extends ConsumerState<LanguageStep> {
  late String _selectedLanguage;

  final List<Map<String, String>> _languages = const [
    {
      'code': 'en',
      'name': 'English',
      'native': 'English',
      'sub': 'Default App Language & Translations',
    },
    {
      'code': 'ur',
      'name': 'Urdu',
      'native': 'اردو',
      'sub': 'اردو ترجمہ اور کتب',
    },
    {
      'code': 'hi',
      'name': 'Hindi / Transliteration',
      'native': 'हिंदी / Hinglish',
      'sub': 'हिंदी अनुवाद एवं उच्चारण',
    },
    {
      'code': 'gu',
      'name': 'Gujarati',
      'native': 'ગુજરાતી',
      'sub': 'ગુજરાતી અનુવાદ અને સાહિત્ય',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = ref.read(onboardingProvider).language;
  }

  void _submit() {
    ref.read(onboardingProvider.notifier).updateLanguage(_selectedLanguage);
    widget.onNext();
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
            'Choose Language',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select your preferred language for translations, transliterations, and interface.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),

          ..._languages.map((lang) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildLanguageCard(
                code: lang['code']!,
                name: lang['name']!,
                native: lang['native']!,
                sub: lang['sub']!,
                isDark: isDark,
              ),
            );
          }),
          const SizedBox(height: 32),

          // Navigation buttons
          Row(
            children: [
              SizedBox(
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: widget.onBack,
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
                    onPressed: _submit,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Next: Theme', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
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

  Widget _buildLanguageCard({
    required String code,
    required String name,
    required String native,
    required String sub,
    required bool isDark,
  }) {
    final isSelected = _selectedLanguage == code;

    return InkWell(
      onTap: () => setState(() => _selectedLanguage = code),
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
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFD4AF37) : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 6,
                        backgroundColor: Color(0xFFD4AF37),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          native,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey[300] : Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
