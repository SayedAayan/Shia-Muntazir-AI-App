import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends Notifier<Locale> {
  static const String _key = 'user_app_locale';

  @override
  Locale build() {
    _loadLocale();
    return const Locale('en');
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(_key) ?? 'en';
    state = _stringToLocale(lang);
  }

  Future<void> setLocale(String langCode) async {
    final newLocale = _stringToLocale(langCode);
    state = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, langCode);
  }

  Locale _stringToLocale(String code) {
    switch (code.toLowerCase()) {
      case 'ur':
        return const Locale('ur');
      case 'hi':
        return const Locale('hi');
      case 'gu':
        return const Locale('gu');
      case 'en':
      default:
        return const Locale('en');
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});
