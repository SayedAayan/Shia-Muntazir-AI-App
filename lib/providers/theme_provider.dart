import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _key = 'user_theme_mode';

  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.system;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(_key) ?? 'system';
    state = _stringToThemeMode(themeStr);
  }

  Future<void> setTheme(String themeStr) async {
    final mode = _stringToThemeMode(themeStr);
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, themeStr);
  }

  ThemeMode _stringToThemeMode(String str) {
    switch (str.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class FontScaleNotifier extends Notifier<double> {
  static const String _key = 'user_font_scale';

  @override
  double build() {
    _loadScale();
    return 1.0;
  }

  Future<void> _loadScale() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getDouble(_key) ?? 1.0;
  }

  Future<void> setScale(double scale) async {
    state = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, scale);
  }
}

final fontScaleProvider = NotifierProvider<FontScaleNotifier, double>(() {
  return FontScaleNotifier();
});
