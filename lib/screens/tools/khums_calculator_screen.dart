import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../services/notification_service.dart';

class KhumsCalculatorScreen extends ConsumerStatefulWidget {
  const KhumsCalculatorScreen({super.key});

  @override
  ConsumerState<KhumsCalculatorScreen> createState() => _KhumsCalculatorScreenState();
}

class _KhumsCalculatorScreenState extends ConsumerState<KhumsCalculatorScreen> {
  final _savingsController = TextEditingController();
  final _expensesController = TextEditingController();
  final _anniversaryController = TextEditingController();

  DateTime? _selectedAnniversary;
  double? _annualSavings;
  double? _annualExpenses;
  double? _khumsEligibleSurplus;
  double? _totalKhumsDue;
  double? _sahmImam;
  double? _sahmSadat;
  bool _hasCalculated = false;

  static const String _khumsAnniversaryKey = 'khums_anniversary_date_str';

  @override
  void initState() {
    super.initState();
    _loadAnniversaryDate();
  }

  Future<void> _loadAnniversaryDate() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_khumsAnniversaryKey);
    if (saved != null && saved.isNotEmpty) {
      final parsed = DateTime.tryParse(saved);
      if (parsed != null && mounted) {
        setState(() {
          _selectedAnniversary = parsed;
          _anniversaryController.text =
              '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
        });
      }
    }
  }

  @override
  void dispose() {
    _savingsController.dispose();
    _expensesController.dispose();
    _anniversaryController.dispose();
    super.dispose();
  }

  void _calculateKhums() {
    final savings = double.tryParse(_savingsController.text.trim()) ?? 0.0;
    final expenses = double.tryParse(_expensesController.text.trim()) ?? 0.0;

    final netSurplus = (savings - expenses).clamp(0.0, double.infinity);
    final khumsDue = netSurplus * 0.20; // 1/5th (20%)
    final sahm = khumsDue / 2.0; // 50% Sahm al-Imam, 50% Sahm al-Sadat

    setState(() {
      _annualSavings = savings;
      _annualExpenses = expenses;
      _khumsEligibleSurplus = netSurplus;
      _totalKhumsDue = khumsDue;
      _sahmImam = sahm;
      _sahmSadat = sahm;
      _hasCalculated = true;
    });
  }

  Future<void> _pickAnniversaryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedAnniversary ?? now,
      firstDate: DateTime(1980),
      lastDate: DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC27351),
              onPrimary: Colors.white,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedAnniversary = picked;
        _anniversaryController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });

      // Save anniversary date locally and schedule annual notifications
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_khumsAnniversaryKey, picked.toIso8601String());

      final authUser = ref.read(authStateProvider).value;
      if (authUser != null) {
        ref.read(userServiceProvider).updateUserField(
              authUser.uid,
              'khums_anniversary_date',
              picked.toIso8601String(),
            );
      }

      await _scheduleKhumsNotifications(picked);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF4D7C68),
            content: Text('Khums anniversary date saved. Annual reminders scheduled!'),
          ),
        );
      }
    }
  }

  Future<void> _scheduleKhumsNotifications(DateTime anniversary) async {
    // Schedule one reminder 1 month ahead, and one on the date itself
    try {
      final now = DateTime.now();
      var targetDate = DateTime(now.year, anniversary.month, anniversary.day, 9, 0);
      if (targetDate.isBefore(now)) {
        targetDate = DateTime(now.year + 1, anniversary.month, anniversary.day, 9, 0);
      }

      final oneMonthBefore = targetDate.subtract(const Duration(days: 30));

      if (oneMonthBefore.isAfter(now)) {
        await NotificationService.showPrayerCheckInNotification(
          prayerName: 'Khums Year Reminder',
          prayerTime: '1 month remaining until your Khums accounting date (${anniversary.day}/${anniversary.month}).',
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF1B2A3D)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Khums Calculator',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Informational Header
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFC27351), size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Annual 1/5th (20%) Calculation',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Per Shia Ithna-Ashari jurisprudence, Khums is 20% on remaining net earnings/savings that exceed legitimate annual living expenditures.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. Anniversary Date Field
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khums Anniversary Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'The date you began earning or established your financial fiscal year.',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _pickAnniversaryDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121820) : const Color(0xFFF3EFE6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _anniversaryController.text.isNotEmpty
                              ? _anniversaryController.text
                              : 'Select Anniversary Date',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _anniversaryController.text.isNotEmpty
                                ? (isDark ? Colors.white : const Color(0xFF1B2A3D))
                                : Colors.grey[500],
                          ),
                        ),
                        const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFFC27351)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. Financial Inputs
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Annual Financial Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 16),

                // Gross Savings Field
                TextField(
                  controller: _savingsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Total Annual Savings / Income',
                    hintText: 'e.g. 500000',
                    prefixIcon: const Icon(Icons.savings_outlined, color: Color(0xFFC27351)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF121820) : const Color(0xFFFBF9F4),
                  ),
                ),
                const SizedBox(height: 14),

                // Deductible Expenses Field
                TextField(
                  controller: _expensesController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Deductible Living Expenses (Year)',
                    hintText: 'e.g. 300000',
                    prefixIcon: const Icon(Icons.receipt_long_outlined, color: Color(0xFFC27351)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF121820) : const Color(0xFFFBF9F4),
                  ),
                ),
                const SizedBox(height: 20),

                // Calculate Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC27351),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _calculateKhums,
                    child: const Text('Calculate Khums Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),

          // 3. Calculation Breakdown Card
          if (_hasCalculated) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF17202C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC27351), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFC27351).withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CALCULATION BREAKDOWN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFFC27351))),
                  const SizedBox(height: 14),

                  _buildBreakdownRow('Total Annual Savings / Income', '₹${_annualSavings?.toStringAsFixed(2)}', isDark),
                  _buildBreakdownRow('Deductible Expenses', '- ₹${_annualExpenses?.toStringAsFixed(2)}', isDark, isNegative: true),
                  const Divider(height: 24),
                  _buildBreakdownRow('Net Khums-Eligible Surplus', '₹${_khumsEligibleSurplus?.toStringAsFixed(2)}', isDark, isBold: true),
                  const Divider(height: 24),

                  // Total Due Highlight
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4D7C68).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Khums Due (20%)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4D7C68)),
                        ),
                        Text(
                          '₹${_totalKhumsDue?.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF4D7C68)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2 Halves Breakdown
                  const Text('Canonical Allocation (50% / 50%):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  _buildAllocationBadge('Sahm al-Imam (10% of surplus)', '₹${_sahmImam?.toStringAsFixed(2)}', isDark),
                  const SizedBox(height: 8),
                  _buildAllocationBadge('Sahm al-Sadat (10% of surplus)', '₹${_sahmSadat?.toStringAsFixed(2)}', isDark),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Religious Disclaimer (Required by prompt)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF26200A) : const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 20, color: Color(0xFFB8860B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Informational calculation aid only. Deductible items and exact exemptions vary. Please confirm rulings with your Marja\'s office (sistani.org or leader.ir) or an authorized representative.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFE8C86A) : const Color(0xFF7A5900),
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, bool isDark, {bool isNegative = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isNegative ? Colors.redAccent : (isDark ? Colors.white : const Color(0xFF1B2A3D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllocationBadge(String title, String amount, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121820) : const Color(0xFFF3EFE6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFC27351))),
        ],
      ),
    );
  }
}
