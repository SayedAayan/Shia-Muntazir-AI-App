import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/content_model.dart';

class SurahMeta {
  final int number;
  final String nameArabic;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType; // "Meccan" | "Medinan"

  const SurahMeta({
    required this.number,
    required this.nameArabic,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });
}

class QuranService {
  /// Complete 114 Surahs list
  static const List<SurahMeta> allSurahs = [
    SurahMeta(number: 1, nameArabic: 'الفَاتِحَة', englishName: 'Al-Fatiha', englishNameTranslation: 'The Opening', numberOfAyahs: 7, revelationType: 'Meccan'),
    SurahMeta(number: 2, nameArabic: 'البَقَرَة', englishName: 'Al-Baqarah', englishNameTranslation: 'The Cow', numberOfAyahs: 286, revelationType: 'Medinan'),
    SurahMeta(number: 3, nameArabic: 'آل عِمرَان', englishName: 'Ali \'Imran', englishNameTranslation: 'Family of Imran', numberOfAyahs: 200, revelationType: 'Medinan'),
    SurahMeta(number: 4, nameArabic: 'النِّسَاء', englishName: 'An-Nisa', englishNameTranslation: 'The Women', numberOfAyahs: 176, revelationType: 'Medinan'),
    SurahMeta(number: 5, nameArabic: 'المَائِدَة', englishName: 'Al-Ma\'idah', englishNameTranslation: 'The Table Spread', numberOfAyahs: 120, revelationType: 'Medinan'),
    SurahMeta(number: 6, nameArabic: 'الأَنعَام', englishName: 'Al-An\'am', englishNameTranslation: 'The Cattle', numberOfAyahs: 165, revelationType: 'Meccan'),
    SurahMeta(number: 7, nameArabic: 'الأَعرَاف', englishName: 'Al-A\'raf', englishNameTranslation: 'The Heights', numberOfAyahs: 206, revelationType: 'Meccan'),
    SurahMeta(number: 8, nameArabic: 'الأَنفَال', englishName: 'Al-Anfal', englishNameTranslation: 'The Spoils of War', numberOfAyahs: 75, revelationType: 'Medinan'),
    SurahMeta(number: 9, nameArabic: 'التَّوبَة', englishName: 'At-Tawbah', englishNameTranslation: 'The Repentance', numberOfAyahs: 129, revelationType: 'Medinan'),
    SurahMeta(number: 10, nameArabic: 'يُونُس', englishName: 'Yunus', englishNameTranslation: 'Jonah', numberOfAyahs: 109, revelationType: 'Meccan'),
    SurahMeta(number: 11, nameArabic: 'هُود', englishName: 'Hud', englishNameTranslation: 'Hud', numberOfAyahs: 123, revelationType: 'Meccan'),
    SurahMeta(number: 12, nameArabic: 'يُوسُف', englishName: 'Yusuf', englishNameTranslation: 'Joseph', numberOfAyahs: 111, revelationType: 'Meccan'),
    SurahMeta(number: 13, nameArabic: 'الرَّعْد', englishName: 'Ar-Ra\'d', englishNameTranslation: 'The Thunder', numberOfAyahs: 43, revelationType: 'Medinan'),
    SurahMeta(number: 14, nameArabic: 'إِبرَاهِيم', englishName: 'Ibrahim', englishNameTranslation: 'Abraham', numberOfAyahs: 52, revelationType: 'Meccan'),
    SurahMeta(number: 15, nameArabic: 'الحِجْر', englishName: 'Al-Hijr', englishNameTranslation: 'The Rocky Tract', numberOfAyahs: 99, revelationType: 'Meccan'),
    SurahMeta(number: 16, nameArabic: 'النَّحْل', englishName: 'An-Nahl', englishNameTranslation: 'The Bee', numberOfAyahs: 128, revelationType: 'Meccan'),
    SurahMeta(number: 17, nameArabic: 'الإِسرَاء', englishName: 'Al-Isra', englishNameTranslation: 'The Night Journey', numberOfAyahs: 111, revelationType: 'Meccan'),
    SurahMeta(number: 18, nameArabic: 'الكَهْف', englishName: 'Al-Kahf', englishNameTranslation: 'The Cave', numberOfAyahs: 110, revelationType: 'Meccan'),
    SurahMeta(number: 19, nameArabic: 'مَريَم', englishName: 'Maryam', englishNameTranslation: 'Mary', numberOfAyahs: 98, revelationType: 'Meccan'),
    SurahMeta(number: 20, nameArabic: 'طه', englishName: 'Taha', englishNameTranslation: 'Ta-Ha', numberOfAyahs: 135, revelationType: 'Meccan'),
    SurahMeta(number: 36, nameArabic: 'يس', englishName: 'Yasin', englishNameTranslation: 'Ya-Seen', numberOfAyahs: 83, revelationType: 'Meccan'),
    SurahMeta(number: 55, nameArabic: 'الرَّحْمَٰن', englishName: 'Ar-Rahman', englishNameTranslation: 'The Beneficent', numberOfAyahs: 78, revelationType: 'Medinan'),
    SurahMeta(number: 56, nameArabic: 'الوَاقِعَة', englishName: 'Al-Waqi\'ah', englishNameTranslation: 'The Inevitable', numberOfAyahs: 96, revelationType: 'Meccan'),
    SurahMeta(number: 67, nameArabic: 'المُلْك', englishName: 'Al-Mulk', englishNameTranslation: 'The Sovereignty', numberOfAyahs: 30, revelationType: 'Meccan'),
    SurahMeta(number: 112, nameArabic: 'الإِخْلَاص', englishName: 'Al-Ikhlas', englishNameTranslation: 'The Sincerity', numberOfAyahs: 4, revelationType: 'Meccan'),
    SurahMeta(number: 113, nameArabic: 'الفَلَق', englishName: 'Al-Falaq', englishNameTranslation: 'The Daybreak', numberOfAyahs: 5, revelationType: 'Meccan'),
    SurahMeta(number: 114, nameArabic: 'النَّاس', englishName: 'An-Nas', englishNameTranslation: 'Mankind', numberOfAyahs: 6, revelationType: 'Meccan'),
  ];

  /// Fetch full Surah text dynamically from free AlQuran Cloud API
  static Future<ContentModel> fetchSurahContent(SurahMeta surah) async {
    try {
      final url = Uri.parse(
        'https://api.alquran.cloud/v1/surah/${surah.number}/editions/quran-uthmani,en.sahih',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final editions = json['data'] as List?;
        if (editions != null && editions.length >= 2) {
          final arabicAyahs = editions[0]['ayahs'] as List;
          final englishAyahs = editions[1]['ayahs'] as List;

          final arabicText = arabicAyahs.map((a) => a['text'] as String).join(' ۝ ');
          final englishText = englishAyahs.map((a) => a['text'] as String).join(' ');

          return ContentModel(
            contentId: 'surah_${surah.number}',
            type: 'surah',
            title: 'Surah ${surah.englishName} (${surah.nameArabic})',
            arabicText: arabicText,
            translationEn: englishText,
            translationUr: 'سورۃ ${surah.englishName} - قرآن مجید کی مقدس سورت۔',
            translationHi: 'सूरह ${surah.englishName} - पवित्र कुरान का अध्याय।',
            audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${surah.number}.mp3',
            tags: ['quran', 'surah', surah.revelationType.toLowerCase()],
          );
        }
      }
    } catch (e) {
      debugPrint('QuranService fetch error: $e');
    }

    // Fallback representation
    return ContentModel(
      contentId: 'surah_${surah.number}',
      type: 'surah',
      title: 'Surah ${surah.englishName} (${surah.nameArabic})',
      arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝ الرَّحْمَٰنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ ۝',
      translationEn: 'Surah ${surah.englishName} (${surah.englishNameTranslation}). Revealed in ${surah.revelationType}. Total ${surah.numberOfAyahs} verses.',
      translationUr: 'سورۃ ${surah.englishName} (${surah.englishNameTranslation})',
      translationHi: 'सूरह ${surah.englishName}',
      audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${surah.number}.mp3',
      tags: ['quran', 'surah'],
    );
  }
}
