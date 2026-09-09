import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AyatStats {
  final int today;
  final int thisWeek;
  final int total;
  final int streak;

  const AyatStats({
    required this.today,
    required this.thisWeek,
    required this.total,
    required this.streak,
  });
}

class AyatTrackerService {
  static const String _todayKey = 'quran_ayat_today_count';
  static const String _todayDateKey = 'quran_ayat_today_date';
  static const String _weekKey = 'quran_ayat_week_count';
  static const String _weekStartKey = 'quran_ayat_week_start';
  static const String _totalKey = 'quran_ayat_total_count';
  static const String _streakKey = 'quran_streak_days_count';
  static const String _lastReadDateKey = 'quran_last_read_date';

  static final ValueNotifier<AyatStats> statsNotifier = ValueNotifier(
    const AyatStats(today: 0, thisWeek: 0, total: 0, streak: 0),
  );

  static Future<void> init() async {
    await refreshStats();
  }

  static String _dateKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static Future<AyatStats> refreshStats() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = _dateKey(now);

    final storedTodayDate = prefs.getString(_todayDateKey);
    int todayCount = prefs.getInt(_todayKey) ?? 0;

    if (storedTodayDate != todayStr) {
      todayCount = 0;
      await prefs.setString(_todayDateKey, todayStr);
      await prefs.setInt(_todayKey, 0);
    }

    // Weekly reset check (Monday start)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStr = _dateKey(monday);
    final storedWeekStart = prefs.getString(_weekStartKey);
    int weekCount = prefs.getInt(_weekKey) ?? 0;

    if (storedWeekStart != mondayStr) {
      weekCount = todayCount;
      await prefs.setString(_weekStartKey, mondayStr);
      await prefs.setInt(_weekKey, weekCount);
    }

    final totalCount = prefs.getInt(_totalKey) ?? 0;
    final streak = prefs.getInt(_streakKey) ?? 0;

    final stats = AyatStats(
      today: todayCount,
      thisWeek: weekCount,
      total: totalCount,
      streak: streak,
    );
    statsNotifier.value = stats;
    return stats;
  }

  /// Automatically record reading of [count] verses
  static Future<void> recordAyatRead(int count) async {
    if (count <= 0) return;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayStr = _dateKey(now);

    final storedTodayDate = prefs.getString(_todayDateKey);
    int todayCount = prefs.getInt(_todayKey) ?? 0;
    if (storedTodayDate != todayStr) {
      todayCount = 0;
      await prefs.setString(_todayDateKey, todayStr);
    }
    todayCount += count;
    await prefs.setInt(_todayKey, todayCount);

    // Week update
    int weekCount = prefs.getInt(_weekKey) ?? 0;
    weekCount += count;
    await prefs.setInt(_weekKey, weekCount);

    // Total update
    int totalCount = prefs.getInt(_totalKey) ?? 0;
    totalCount += count;
    await prefs.setInt(_totalKey, totalCount);

    // Streak update
    final lastReadDate = prefs.getString(_lastReadDateKey);
    int streak = prefs.getInt(_streakKey) ?? 0;

    if (lastReadDate != todayStr) {
      if (lastReadDate != null) {
        final yesterday = now.subtract(const Duration(days: 1));
        final yesterdayStr = _dateKey(yesterday);
        if (lastReadDate == yesterdayStr) {
          streak += 1;
        } else {
          streak = 1;
        }
      } else {
        streak = 1;
      }
      await prefs.setString(_lastReadDateKey, todayStr);
      await prefs.setInt(_streakKey, streak);
    }

    final stats = AyatStats(
      today: todayCount,
      thisWeek: weekCount,
      total: totalCount,
      streak: streak,
    );
    statsNotifier.value = stats;
  }
}
