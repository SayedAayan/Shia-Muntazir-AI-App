import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';

class SadqaLogEntry {
  final String id;
  final double amount;
  final String note;
  final DateTime date;

  const SadqaLogEntry({
    required this.id,
    required this.amount,
    required this.note,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory SadqaLogEntry.fromMap(Map<String, dynamic> map) => SadqaLogEntry(
        id: map['id'] ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        note: map['note'] ?? '',
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      );
}

class DailySadqaScreen extends ConsumerStatefulWidget {
  const DailySadqaScreen({super.key});

  @override
  ConsumerState<DailySadqaScreen> createState() => _DailySadqaScreenState();
}

class _DailySadqaScreenState extends ConsumerState<DailySadqaScreen> {
  static const String _storageKey = 'daily_sadqa_logs_list';
  static const String _reminderKey = 'daily_sadqa_reminder_enabled';

  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  List<SadqaLogEntry> _logs = [];
  bool _isLoading = true;
  bool _dailyReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final reminder = prefs.getBool(_reminderKey) ?? false;

    List<SadqaLogEntry> loaded = [];
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List;
        loaded = list.map((item) => SadqaLogEntry.fromMap(item)).toList();
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _logs = loaded;
        _dailyReminderEnabled = reminder;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_logs.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encoded);
  }

  Future<void> _addSadqa() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid sadqa amount.')),
      );
      return;
    }

    final entry = SadqaLogEntry(
      id: 'sadqa_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      note: _noteController.text.trim().isEmpty
          ? 'Daily Sadqa for Imam-e-Zamana (a.t.f.s.)'
          : _noteController.text.trim(),
      date: DateTime.now(),
    );

    setState(() {
      _logs.insert(0, entry);
      _amountController.clear();
      _noteController.clear();
    });

    await _saveLogs();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF4D7C68),
          behavior: SnackBarBehavior.floating,
          content: Text('Sadqa logged successfully! May Allah ward off misfortunes.'),
        ),
      );
    }
  }

  Future<void> _deleteEntry(String id) async {
    setState(() {
      _logs.removeWhere((item) => item.id == id);
    });
    await _saveLogs();
  }

  Future<void> _toggleDailyReminder(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, val);
    setState(() => _dailyReminderEnabled = val);

    if (val) {
      await NotificationService.showPrayerCheckInNotification(
        prayerName: 'Daily Sadqa Reminder',
        prayerTime: 'Start your day with charity in the name of Imam al-Mahdi (a.t.f.s.).',
      );
    }
  }

  // --- Aggregate Totals ---
  double get _todayTotal {
    final now = DateTime.now();
    return _logs
        .where((l) => l.date.year == now.year && l.date.month == now.month && l.date.day == now.day)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _thisWeekTotal {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final beginning = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return _logs
        .where((l) => l.date.isAfter(beginning) || l.date.isAtSameMomentAs(beginning))
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _thisMonthTotal {
    final now = DateTime.now();
    return _logs
        .where((l) => l.date.year == now.year && l.date.month == now.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _thisYearTotal {
    final now = DateTime.now();
    return _logs
        .where((l) => l.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
          'Daily Sadqa Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC27351)))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Running Totals Overview Grid
                Row(
                  children: [
                    Expanded(child: _buildStatTile('Today', '₹${_todayTotal.toStringAsFixed(0)}', isDark, isPrimary: true)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatTile('This Week', '₹${_thisWeekTotal.toStringAsFixed(0)}', isDark)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildStatTile('This Month', '₹${_thisMonthTotal.toStringAsFixed(0)}', isDark)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatTile('This Year', '₹${_thisYearTotal.toStringAsFixed(0)}', isDark)),
                  ],
                ),
                const SizedBox(height: 20),

                // Hadith Reminder Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2A3D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.volunteer_activism_rounded, color: Color(0xFFE8C86A), size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Imam Ali (a.s.): "Give sadqa, for it repels calamities and protects against painful afflictions."',
                          style: TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Entry Card
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
                      const Text('Log Today\'s Sadqa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Amount (₹)',
                          hintText: 'e.g. 50',
                          prefixIcon: const Icon(Icons.currency_rupee_rounded, color: Color(0xFFC27351)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF121820) : const Color(0xFFFBF9F4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        decoration: InputDecoration(
                          labelText: 'Intention / Note (Optional)',
                          hintText: 'e.g. For Salamati of Imam-e-Zamana (a.t.f.s.)',
                          prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFFC27351)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF121820) : const Color(0xFFFBF9F4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC27351),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _addSadqa,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('Save Sadqa Entry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Daily Reminder Notification Switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF17202C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: SwitchListTile(
                    title: const Text('Daily Morning Sadqa Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: const Text('Receive a gentle alert to offer charity each morning', style: TextStyle(fontSize: 12)),
                    activeThumbColor: const Color(0xFFC27351),
                    value: _dailyReminderEnabled,
                    onChanged: _toggleDailyReminder,
                  ),
                ),
                const SizedBox(height: 24),

                // Log History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Sadqa Logs', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('${_logs.length} logged', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),

                if (_logs.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No charity logs recorded yet.\nStart by logging today\'s sadqa above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ..._logs.map((entry) {
                    final d = entry.date;
                    final dateStr = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF17202C) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4D7C68).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.favorite_rounded, color: Color(0xFF4D7C68), size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${entry.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  entry.note,
                                  style: TextStyle(fontSize: 12.5, color: isDark ? Colors.grey[300] : const Color(0xFF475569)),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                dateStr,
                                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
                                onPressed: () => _deleteEntry(entry.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildStatTile(String label, String value, bool isDark, {bool isPrimary = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPrimary
            ? const Color(0xFFC27351).withValues(alpha: 0.15)
            : (isDark ? const Color(0xFF17202C) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? const Color(0xFFC27351) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isPrimary ? const Color(0xFFC27351) : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isPrimary ? const Color(0xFFC27351) : (isDark ? Colors.white : const Color(0xFF1B2A3D)),
            ),
          ),
        ],
      ),
    );
  }
}
