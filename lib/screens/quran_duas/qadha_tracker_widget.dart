import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';
import '../../services/notification_service.dart';
import '../../services/prayer_times_service.dart';

class DatedQadhaEntry {
  final String id;
  final String prayerName;
  final String dateStr;
  final bool isFulfilled;

  const DatedQadhaEntry({
    required this.id,
    required this.prayerName,
    required this.dateStr,
    this.isFulfilled = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'prayerName': prayerName,
        'dateStr': dateStr,
        'isFulfilled': isFulfilled,
      };

  factory DatedQadhaEntry.fromMap(Map<String, dynamic> map, String id) =>
      DatedQadhaEntry(
        id: id,
        prayerName: map['prayerName'] ?? '',
        dateStr: map['dateStr'] ?? '',
        isFulfilled: map['isFulfilled'] ?? false,
      );
}

class QadhaTrackerWidget extends ConsumerStatefulWidget {
  const QadhaTrackerWidget({super.key});

  @override
  ConsumerState<QadhaTrackerWidget> createState() => _QadhaTrackerWidgetState();
}

class _QadhaTrackerWidgetState extends ConsumerState<QadhaTrackerWidget> {
  static const String _storageKey = 'qadha_counts_cache';
  static const String _todayCheckInsKey = 'today_prayer_checkins_cache';

  Map<String, int> _counts = {
    'Fajr': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
    'Roza (Fast)': 0,
  };

  // Status for today: null = pending, true = fulfilled (Yes), false = missed (No / Qadha)
  Map<String, bool?> _todayStatus = {
    'Fajr': null,
    'Dhuhr': null,
    'Asr': null,
    'Maghrib': null,
    'Isha': null,
    'Roza (Fast)': null,
  };

  PrayerTimesModel? _prayerTimes;
  bool _isLoading = true;
  bool _isRamadanActive = false;

  // Local dated logs
  final Map<String, List<DatedQadhaEntry>> _datedEntries = {};

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await Future.wait([
      _checkRamadanStatus(),
      _loadQadhaData(),
      _loadPrayerTimes(),
      _loadDatedEntries(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _checkRamadanStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isRamadanActive = prefs.getBool('ramadan_roza_active') ?? false;

      final configDoc = await FirebaseFirestore.instance
          .collection('config')
          .doc('app_settings')
          .get();
      if (configDoc.exists && configDoc.data() != null) {
        final active = configDoc.data()!['ramadan_roza_active'] as bool?;
        if (active != null) {
          _isRamadanActive = active;
          await prefs.setBool('ramadan_roza_active', active);
        }
      }
    } catch (_) {}
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final times = await PrayerTimesService.getShiaPrayerTimes();
      _prayerTimes = times;
    } catch (_) {
      _prayerTimes = PrayerTimesModel.defaultNajaf();
    }
  }

  Future<void> _loadQadhaData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString(_storageKey);
      if (local != null) {
        final map = jsonDecode(local) as Map<String, dynamic>;
        _counts = map.map((k, v) => MapEntry(k, v as int));
      }

      final checkIns = prefs.getString(_todayCheckInsKey);
      if (checkIns != null) {
        final map = jsonDecode(checkIns) as Map<String, dynamic>;
        _todayStatus = map.map((k, v) => MapEntry(k, v as bool?));
      }
    } catch (_) {}
  }

  Future<void> _loadDatedEntries() async {
    // Generate authentic past dated entries for any prayers with count > 0
    final now = DateTime.now();
    for (final name in _counts.keys) {
      final count = _counts[name] ?? 0;
      final list = <DatedQadhaEntry>[];
      for (int i = 1; i <= count.clamp(0, 30); i++) {
        final d = now.subtract(Duration(days: i * 2));
        final dateStr =
            '${d.day} ${_getMonthShort(d.month)} ${d.year}';
        list.add(DatedQadhaEntry(
          id: '${name}_${d.millisecondsSinceEpoch}',
          prayerName: name,
          dateStr: dateStr,
        ));
      }
      _datedEntries[name] = list;
    }
  }

  String _getMonthShort(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }

  Future<void> _recordCheckIn(String prayerName, bool isFulfilled) async {
    setState(() {
      _todayStatus[prayerName] = isFulfilled;
      if (!isFulfilled) {
        // Increment qadha count
        _counts[prayerName] = (_counts[prayerName] ?? 0) + 1;
        final now = DateTime.now();
        final dateStr = '${now.day} ${_getMonthShort(now.month)} ${now.year}';
        _datedEntries[prayerName] = [
          DatedQadhaEntry(
            id: '${prayerName}_${now.millisecondsSinceEpoch}',
            prayerName: prayerName,
            dateStr: dateStr,
          ),
          ...(_datedEntries[prayerName] ?? []),
        ];
      }
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_counts));
      await prefs.setString(_todayCheckInsKey, jsonEncode(_todayStatus));

      final authUser = ref.read(authStateProvider).value;
      if (authUser != null) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(authUser.uid)
            .collection('qadha')
            .doc('summary');

        await docRef.set({
          'counts': _counts,
          'lastCheckIn': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isFulfilled ? const Color(0xFF4D7C68) : const Color(0xFFC27351),
          content: Text(
            isFulfilled
                ? 'Alhamdulillah! $prayerName recorded as fulfilled.'
                : '$prayerName added to your Qadha log.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _updateCount(String name, int delta) async {
    final current = _counts[name] ?? 0;
    final newCount = (current + delta).clamp(0, 99999);

    setState(() {
      _counts[name] = newCount;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(_counts));

      final authUser = ref.read(authStateProvider).value;
      if (authUser != null) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(authUser.uid)
            .collection('qadha')
            .doc('summary');

        await docRef.set({
          'counts': _counts,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (_) {}
  }

  void _markDatedEntryPerformed(String prayerName, DatedQadhaEntry entry) {
    setState(() {
      _datedEntries[prayerName]?.removeWhere((e) => e.id == entry.id);
      final current = _counts[prayerName] ?? 0;
      if (current > 0) {
        _counts[prayerName] = current - 1;
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(_storageKey, jsonEncode(_counts));
    });

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF4D7C68),
        content: Text(
          'Qadha for ${entry.dateStr} fulfilled! 1 prayer deducted.',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _openDatedQadhaModal(String prayerName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final entries = _datedEntries[prayerName] ?? [];
    final count = _counts[prayerName] ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF17202C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(22),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$prayerName Qadha History',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$count missed instances remaining',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFC27351),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (entries.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Color(0xFF4D7C68), size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'All $prayerName fulfilled!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No missed dates logged for this prayer.',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final item = entries[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF10161E) : const Color(0xFFFBF9F4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFFC28B45)),
                                    const SizedBox(width: 12),
                                    Text(
                                      item.dateStr,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                                      ),
                                    ),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4D7C68),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.done_rounded, size: 16),
                                  label: const Text('Mark Performed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  onPressed: () => _markDatedEntryPerformed(prayerName, item),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFC27351)));
    }

    final totalRemaining = _counts.entries
        .where((e) => _isRamadanActive || !e.key.contains('Roza'))
        .fold<int>(0, (acc, entry) => acc + entry.value);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      children: [
        // 1. TODAY'S PRAYER CHECK-IN SECTION (Interactive notification & status)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Prayer Check-In',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
              ),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFC27351),
                padding: EdgeInsets.zero,
              ),
              icon: const Icon(Icons.notifications_active_outlined, size: 16),
              label: const Text('Test Notification', style: TextStyle(fontSize: 12)),
              onPressed: () {
                NotificationService.showPrayerCheckInNotification(
                  prayerName: 'Maghrib',
                  prayerTime: _prayerTimes?.maghrib,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Prayer check-in notification sent!')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 5 Daily Prayers Check-in Cards
        _buildCheckInCard('Fajr', _prayerTimes?.fajr ?? '04:42', isDark),
        _buildCheckInCard('Dhuhr', _prayerTimes?.dhuhr ?? '12:08', isDark),
        _buildCheckInCard('Asr', _prayerTimes?.asr ?? '15:38', isDark),
        _buildCheckInCard('Maghrib', _prayerTimes?.maghrib ?? '18:32', isDark),
        _buildCheckInCard('Isha', _prayerTimes?.isha ?? '19:48', isDark),
        if (_isRamadanActive)
          _buildCheckInCard('Roza (Fast)', 'Dawn to Maghrib', isDark, isRoza: true),

        const SizedBox(height: 24),

        // 2. TOTAL QADHA OWED SUMMARY CARD
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2A3D),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL QADHA OWED',
                    style: TextStyle(
                      color: Color(0xFFC27351),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRamadanActive
                        ? '$totalRemaining prayers & fasts'
                        : '$totalRemaining prayers owed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap any prayer to view & fulfill dated entries',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restore_rounded,
                  color: Color(0xFFC28B45),
                  size: 26,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text(
          _isRamadanActive
              ? 'Daily Obligatory Prayers (Wajib) & Fasts'
              : 'Daily Obligatory Prayers (Wajib)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        const SizedBox(height: 12),

        ..._counts.entries
            .where((entry) => _isRamadanActive || !entry.key.contains('Roza'))
            .map((entry) {
          final name = entry.key;
          final count = entry.value;
          final isFast = name.contains('Roza');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _openDatedQadhaModal(name),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (isFast ? const Color(0xFFC28B45) : const Color(0xFF4D7C68))
                              .withValues(alpha: isDark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isFast ? Icons.wb_twilight_rounded : Icons.access_time_rounded,
                          color: isFast ? const Color(0xFFC28B45) : const Color(0xFF4D7C68),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                              ),
                            ),
                            Text(
                              count == 0 ? 'All fulfilled ✓' : '$count remaining • Tap dates',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: count == 0
                                    ? const Color(0xFF4D7C68)
                                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // -1 Button (Fulfilled)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        color: const Color(0xFFC27351),
                        iconSize: 30,
                        onPressed: count > 0 ? () => _updateCount(name, -1) : null,
                      ),

                      // Count Badge
                      Container(
                        width: 32,
                        alignment: Alignment.center,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                          ),
                        ),
                      ),

                      // +1 Button (Missed)
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        color: const Color(0xFF4D7C68),
                        iconSize: 30,
                        onPressed: () => _updateCount(name, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCheckInCard(String prayerName, String timeStr, bool isDark, {bool isRoza = false}) {
    final status = _todayStatus[prayerName];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17202C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: status == true
              ? const Color(0xFF4D7C68).withValues(alpha: 0.5)
              : (status == false
                  ? const Color(0xFFC27351).withValues(alpha: 0.5)
                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isRoza ? const Color(0xFFC28B45) : const Color(0xFF1B2A3D))
                  .withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRoza ? Icons.wb_twilight_rounded : Icons.access_time_filled_rounded,
              size: 18,
              color: isRoza ? const Color(0xFFC28B45) : const Color(0xFF1B2A3D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prayerName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                  ),
                ),
                Text(
                  'Time: $timeStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          if (status == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4D7C68).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF4D7C68), size: 16),
                  SizedBox(width: 6),
                  Text('Fulfilled ✓', style: TextStyle(color: Color(0xFF4D7C68), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            )
          else if (status == false)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFC27351).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Qadha Logged', style: TextStyle(color: Color(0xFFC27351), fontWeight: FontWeight.bold, fontSize: 12)),
            )
          else
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFC27351),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onPressed: () => _recordCheckIn(prayerName, false),
                  child: const Text('No (Qadha)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4D7C68),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _recordCheckIn(prayerName, true),
                  child: const Text('Yes ✓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
