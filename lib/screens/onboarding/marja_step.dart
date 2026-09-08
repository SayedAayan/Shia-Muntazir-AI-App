import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';

class MarjaStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const MarjaStep({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<MarjaStep> createState() => _MarjaStepState();
}

class _MarjaStepState extends ConsumerState<MarjaStep> {
  late String _selectedMarja;
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final current = ref.read(onboardingProvider);
    _selectedMarja = current.marja;
    _customController = TextEditingController(text: current.customMarja);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _submit() {
    ref.read(onboardingProvider.notifier).updateMarja(
          _selectedMarja,
          _customController.text.trim(),
        );
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
            'Select Your Marja',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your Marja-e-Taqleed helps provide fiqh rulings and guidance specific to your practice.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),

          // Option 1: Sistani
          _buildMarjaCard(
            title: 'Ayatollah Sayyid Ali al-Sistani',
            subtitle: 'Najaf al-Ashraf, Iraq',
            value: 'sistani',
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Option 2: Khamenei
          _buildMarjaCard(
            title: 'Ayatollah Sayyid Ali Khamenei',
            subtitle: 'Tehran / Qom, Iran',
            value: 'khamenei',
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Option 3: Other
          _buildMarjaCard(
            title: 'Other Marja / Scholar',
            subtitle: 'Specify your Marja of Taqlid',
            value: 'other',
            isDark: isDark,
          ),

          // Conditional Custom Marja Field
          if (_selectedMarja == 'other') ...[
            const SizedBox(height: 14),
            TextField(
              controller: _customController,
              decoration: InputDecoration(
                labelText: 'Name of Marja',
                hintText: 'e.g. Ayatollah Makarem Shirazi, Ayatollah Khoei',
                prefixIcon: const Icon(Icons.edit_note_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ],
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
                        Text('Next: Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  Widget _buildMarjaCard({
    required String title,
    required String subtitle,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _selectedMarja == value;

    return InkWell(
      onTap: () => setState(() => _selectedMarja = value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64), // min 48dp+ tap target
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
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
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
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? (isDark ? Colors.white : const Color(0xFF1B3B5A)) : null,
                    ),
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
          ],
        ),
      ),
    );
  }
}
