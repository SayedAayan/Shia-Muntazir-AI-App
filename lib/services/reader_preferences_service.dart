import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderPreferencesService {
  static const String _favoritesKey = 'user_favorites_list';
  static const String _lastReadPrefix = 'last_read_verse_';
  static const String _inlineTranslationKey = 'inline_translation_mode';
  static const String _fontSizeKey = 'reader_arabic_font_size';

  static final ValueNotifier<List<String>> favoritesNotifier =
      ValueNotifier<List<String>>([]);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    favoritesNotifier.value = prefs.getStringList(_favoritesKey) ?? [];
  }

  static bool isFavorite(String contentId) {
    return favoritesNotifier.value.contains(contentId);
  }

  static Future<bool> toggleFavorite(String contentId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = List<String>.from(favoritesNotifier.value);

    bool isNowFav = false;
    if (list.contains(contentId)) {
      list.remove(contentId);
      isNowFav = false;
    } else {
      list.add(contentId);
      isNowFav = true;
    }

    favoritesNotifier.value = list;
    await prefs.setStringList(_favoritesKey, list);
    return isNowFav;
  }

  static Future<int> getLastReadVerse(String contentId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_lastReadPrefix$contentId') ?? 0;
  }

  static Future<void> saveLastReadVerse(String contentId, int verseIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_lastReadPrefix$contentId', verseIndex);
  }

  static Future<bool> isInlineTranslationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_inlineTranslationKey) ?? true;
  }

  static Future<void> setInlineTranslationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_inlineTranslationKey, enabled);
  }

  static Future<double> getArabicFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 26.0;
  }

  static Future<void> saveArabicFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }
}
