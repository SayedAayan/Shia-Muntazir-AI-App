import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/user_provider.dart';

class QadhaTrackerWidget extends ConsumerStatefulWidget {
  const QadhaTrackerWidget({super.key});

  @override
  ConsumerState<QadhaTrackerWidget> createState() => _QadhaTrackerWidgetState();
}

class _QadhaTrackerWidgetState extends ConsumerState<QadhaTrackerWidget> {
  static const String _storageKey = 'qadha_counts_cache';

  Map<String, int> _counts = {
    'Fajr': 12,
    'Dhuhr': 15,
    'Asr': 15,
    'Maghrib': 8,
    'Isha': 8,
    'Roza (Fast)': 5,
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQadhaData();
  }

  Future<void> _loadQadhaData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getString(_storageKey);
      if (local != null) {
        final map = jsonDecode(local) as Map<String, dynamic>;
        setState(() {
          _counts = map.map((k, v) => MapEntry(k, v as int));
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFC27351)));
    }

    final totalRemaining = _counts.values.fold<int>(0, (acc, val) => acc + val);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Top Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2A3D),
            borderRadius: BorderRadius.circular(20),
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
                    '$totalRemaining prayers & fasts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
        const SizedBox(height: 18),

        Text(
          'Daily Obligatory Prayers (Wajib)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1B2A3D),
          ),
        ),
        const SizedBox(height: 12),

        ..._counts.entries.map((entry) {
          final name = entry.key;
          final count = entry.value;
          final isFast = name.contains('Roza');

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF17202C) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
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
                        count == 0 ? 'All fulfilled ✓' : '$count remaining',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: count == 0
                              ? const Color(0xFF4D7C68)
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),

                // -1 Button (Recited 1)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color: const Color(0xFFC27351),
                  iconSize: 32,
                  onPressed: count > 0 ? () => _updateCount(name, -1) : null,
                ),

                // Count Badge
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1B2A3D),
                    ),
                  ),
                ),

                // +1 Button (Owed 1)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: const Color(0xFF4D7C68),
                  iconSize: 32,
                  onPressed: () => _updateCount(name, 1),
                ),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }
}
