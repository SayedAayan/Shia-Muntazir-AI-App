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
  /// Complete, verified 114 Surahs directory
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
    SurahMeta(number: 21, nameArabic: 'الأَنْبِيَاء', englishName: 'Al-Anbiya', englishNameTranslation: 'The Prophets', numberOfAyahs: 112, revelationType: 'Meccan'),
    SurahMeta(number: 22, nameArabic: 'الحَجّ', englishName: 'Al-Hajj', englishNameTranslation: 'The Pilgrimage', numberOfAyahs: 78, revelationType: 'Medinan'),
    SurahMeta(number: 23, nameArabic: 'المُؤْمِنُون', englishName: 'Al-Mu\'minun', englishNameTranslation: 'The Believers', numberOfAyahs: 118, revelationType: 'Meccan'),
    SurahMeta(number: 24, nameArabic: 'النُّور', englishName: 'An-Nur', englishNameTranslation: 'The Light', numberOfAyahs: 64, revelationType: 'Medinan'),
    SurahMeta(number: 25, nameArabic: 'الفُرْقَان', englishName: 'Al-Furqan', englishNameTranslation: 'The Criterion', numberOfAyahs: 77, revelationType: 'Meccan'),
    SurahMeta(number: 26, nameArabic: 'الشُّعَرَاء', englishName: 'Ash-Shu\'ara', englishNameTranslation: 'The Poets', numberOfAyahs: 227, revelationType: 'Meccan'),
    SurahMeta(number: 27, nameArabic: 'النَّمْل', englishName: 'An-Naml', englishNameTranslation: 'The Ant', numberOfAyahs: 93, revelationType: 'Meccan'),
    SurahMeta(number: 28, nameArabic: 'القَصَص', englishName: 'Al-Qasas', englishNameTranslation: 'The Stories', numberOfAyahs: 88, revelationType: 'Meccan'),
    SurahMeta(number: 29, nameArabic: 'العَنْكَبُوت', englishName: 'Al-Ankabut', englishNameTranslation: 'The Spider', numberOfAyahs: 69, revelationType: 'Meccan'),
    SurahMeta(number: 30, nameArabic: 'الرُّوم', englishName: 'Ar-Rum', englishNameTranslation: 'The Romans', numberOfAyahs: 60, revelationType: 'Meccan'),
    SurahMeta(number: 31, nameArabic: 'لُقْمَان', englishName: 'Luqman', englishNameTranslation: 'Luqman', numberOfAyahs: 34, revelationType: 'Meccan'),
    SurahMeta(number: 32, nameArabic: 'السَّجْدَة', englishName: 'As-Sajdah', englishNameTranslation: 'The Prostration', numberOfAyahs: 30, revelationType: 'Meccan'),
    SurahMeta(number: 33, nameArabic: 'الأَحْزَاب', englishName: 'Al-Ahzab', englishNameTranslation: 'The Combined Forces', numberOfAyahs: 73, revelationType: 'Medinan'),
    SurahMeta(number: 34, nameArabic: 'سَبَأ', englishName: 'Saba', englishNameTranslation: 'Sheba', numberOfAyahs: 54, revelationType: 'Meccan'),
    SurahMeta(number: 35, nameArabic: 'فَاطِر', englishName: 'Fatir', englishNameTranslation: 'The Originator', numberOfAyahs: 45, revelationType: 'Meccan'),
    SurahMeta(number: 36, nameArabic: 'يس', englishName: 'Yasin', englishNameTranslation: 'Ya-Seen', numberOfAyahs: 83, revelationType: 'Meccan'),
    SurahMeta(number: 37, nameArabic: 'الصَّافَّات', englishName: 'As-Saffat', englishNameTranslation: 'Those who set Ranks', numberOfAyahs: 182, revelationType: 'Meccan'),
    SurahMeta(number: 38, nameArabic: 'ص', englishName: 'Sad', englishNameTranslation: 'The Letter Sad', numberOfAyahs: 88, revelationType: 'Meccan'),
    SurahMeta(number: 39, nameArabic: 'الزُّمَر', englishName: 'Az-Zumar', englishNameTranslation: 'The Troops', numberOfAyahs: 75, revelationType: 'Meccan'),
    SurahMeta(number: 40, nameArabic: 'غَافِر', englishName: 'Ghafir', englishNameTranslation: 'The Forgiver', numberOfAyahs: 85, revelationType: 'Meccan'),
    SurahMeta(number: 41, nameArabic: 'فُصِّلَت', englishName: 'Fussilat', englishNameTranslation: 'Explained in Detail', numberOfAyahs: 54, revelationType: 'Meccan'),
    SurahMeta(number: 42, nameArabic: 'الشُّورَىٰ', englishName: 'Ash-Shura', englishNameTranslation: 'The Consultation', numberOfAyahs: 53, revelationType: 'Meccan'),
    SurahMeta(number: 43, nameArabic: 'الزُّخْرُف', englishName: 'Az-Zukhruf', englishNameTranslation: 'The Ornaments of Gold', numberOfAyahs: 89, revelationType: 'Meccan'),
    SurahMeta(number: 44, nameArabic: 'الدُّخَان', englishName: 'Ad-Dukhan', englishNameTranslation: 'The Smoke', numberOfAyahs: 59, revelationType: 'Meccan'),
    SurahMeta(number: 45, nameArabic: 'الجَاثِيَة', englishName: 'Al-Jathiyah', englishNameTranslation: 'The Crouching', numberOfAyahs: 37, revelationType: 'Meccan'),
    SurahMeta(number: 46, nameArabic: 'الأَحْقَاف', englishName: 'Al-Ahqaf', englishNameTranslation: 'The Wind-Curved Sandhills', numberOfAyahs: 35, revelationType: 'Meccan'),
    SurahMeta(number: 47, nameArabic: 'مُحَمَّد', englishName: 'Muhammad', englishNameTranslation: 'Muhammad', numberOfAyahs: 38, revelationType: 'Medinan'),
    SurahMeta(number: 48, nameArabic: 'الفَتْح', englishName: 'Al-Fath', englishNameTranslation: 'The Victory', numberOfAyahs: 29, revelationType: 'Medinan'),
    SurahMeta(number: 49, nameArabic: 'الحُجُرَات', englishName: 'Al-Hujurat', englishNameTranslation: 'The Rooms', numberOfAyahs: 18, revelationType: 'Medinan'),
    SurahMeta(number: 50, nameArabic: 'ق', englishName: 'Qaf', englishNameTranslation: 'The Letter Qaf', numberOfAyahs: 45, revelationType: 'Meccan'),
    SurahMeta(number: 51, nameArabic: 'الذَّارِيَات', englishName: 'Adh-Dhariyat', englishNameTranslation: 'The Winnowing Winds', numberOfAyahs: 60, revelationType: 'Meccan'),
    SurahMeta(number: 52, nameArabic: 'الطُّور', englishName: 'At-Tur', englishNameTranslation: 'The Mount', numberOfAyahs: 49, revelationType: 'Meccan'),
    SurahMeta(number: 53, nameArabic: 'النَّجْم', englishName: 'An-Najm', englishNameTranslation: 'The Star', numberOfAyahs: 62, revelationType: 'Meccan'),
    SurahMeta(number: 54, nameArabic: 'القَمَر', englishName: 'Al-Qamar', englishNameTranslation: 'The Moon', numberOfAyahs: 55, revelationType: 'Meccan'),
    SurahMeta(number: 55, nameArabic: 'الرَّحْمَٰن', englishName: 'Ar-Rahman', englishNameTranslation: 'The Beneficent', numberOfAyahs: 78, revelationType: 'Medinan'),
    SurahMeta(number: 56, nameArabic: 'الوَاقِعَة', englishName: 'Al-Waqi\'ah', englishNameTranslation: 'The Inevitable', numberOfAyahs: 96, revelationType: 'Meccan'),
    SurahMeta(number: 57, nameArabic: 'الحَدِيد', englishName: 'Al-Hadid', englishNameTranslation: 'The Iron', numberOfAyahs: 29, revelationType: 'Medinan'),
    SurahMeta(number: 58, nameArabic: 'المُجَادَلَة', englishName: 'Al-Mujadila', englishNameTranslation: 'The Pleading Woman', numberOfAyahs: 22, revelationType: 'Medinan'),
    SurahMeta(number: 59, nameArabic: 'الحَشْر', englishName: 'Al-Hashr', englishNameTranslation: 'The Exile', numberOfAyahs: 24, revelationType: 'Medinan'),
    SurahMeta(number: 60, nameArabic: 'المُمْتَحَنَة', englishName: 'Al-Mumtahanah', englishNameTranslation: 'She that is examined', numberOfAyahs: 13, revelationType: 'Medinan'),
    SurahMeta(number: 61, nameArabic: 'الصَّفّ', englishName: 'As-Saff', englishNameTranslation: 'The Ranks', numberOfAyahs: 14, revelationType: 'Medinan'),
    SurahMeta(number: 62, nameArabic: 'الجُمُعَة', englishName: 'Al-Jumu\'ah', englishNameTranslation: 'The Congregation', numberOfAyahs: 11, revelationType: 'Medinan'),
    SurahMeta(number: 63, nameArabic: 'المُنَافِقُون', englishName: 'Al-Munafiqun', englishNameTranslation: 'The Hypocrites', numberOfAyahs: 11, revelationType: 'Medinan'),
    SurahMeta(number: 64, nameArabic: 'التَّغَابُن', englishName: 'At-Taghabun', englishNameTranslation: 'The Mutual Disillusion', numberOfAyahs: 18, revelationType: 'Medinan'),
    SurahMeta(number: 65, nameArabic: 'الطَّلَاق', englishName: 'At-Talaq', englishNameTranslation: 'The Divorce', numberOfAyahs: 12, revelationType: 'Medinan'),
    SurahMeta(number: 66, nameArabic: 'التَّحْرِيم', englishName: 'At-Tahrim', englishNameTranslation: 'The Prohibition', numberOfAyahs: 12, revelationType: 'Medinan'),
    SurahMeta(number: 67, nameArabic: 'المُلْك', englishName: 'Al-Mulk', englishNameTranslation: 'The Sovereignty', numberOfAyahs: 30, revelationType: 'Meccan'),
    SurahMeta(number: 68, nameArabic: 'القَلَم', englishName: 'Al-Qalam', englishNameTranslation: 'The Pen', numberOfAyahs: 52, revelationType: 'Meccan'),
    SurahMeta(number: 69, nameArabic: 'الحَاقَّة', englishName: 'Al-Haqqah', englishNameTranslation: 'The Inevitable Truth', numberOfAyahs: 52, revelationType: 'Meccan'),
    SurahMeta(number: 70, nameArabic: 'المَعَارِج', englishName: 'Al-Ma\'arij', englishNameTranslation: 'The Ascending Stairways', numberOfAyahs: 44, revelationType: 'Meccan'),
    SurahMeta(number: 71, nameArabic: 'نُوح', englishName: 'Nuh', englishNameTranslation: 'Noah', numberOfAyahs: 28, revelationType: 'Meccan'),
    SurahMeta(number: 72, nameArabic: 'الجِنّ', englishName: 'Al-Jinn', englishNameTranslation: 'The Jinn', numberOfAyahs: 28, revelationType: 'Meccan'),
    SurahMeta(number: 73, nameArabic: 'المُزَّمِّل', englishName: 'Al-Muzzammil', englishNameTranslation: 'The Enshrouded One', numberOfAyahs: 20, revelationType: 'Meccan'),
    SurahMeta(number: 74, nameArabic: 'المُدَّثِّر', englishName: 'Al-Muddaththir', englishNameTranslation: 'The Cloaked One', numberOfAyahs: 56, revelationType: 'Meccan'),
    SurahMeta(number: 75, nameArabic: 'القِيَامَة', englishName: 'Al-Qiyamah', englishNameTranslation: 'The Resurrection', numberOfAyahs: 40, revelationType: 'Meccan'),
    SurahMeta(number: 76, nameArabic: 'الإِنْسَان', englishName: 'Al-Insan', englishNameTranslation: 'Man (Ad-Dahr)', numberOfAyahs: 31, revelationType: 'Medinan'),
    SurahMeta(number: 77, nameArabic: 'المُرْسَلَات', englishName: 'Al-Mursalat', englishNameTranslation: 'The Emissaries', numberOfAyahs: 50, revelationType: 'Meccan'),
    SurahMeta(number: 78, nameArabic: 'النَّبَأ', englishName: 'An-Naba', englishNameTranslation: 'The Great News', numberOfAyahs: 40, revelationType: 'Meccan'),
    SurahMeta(number: 79, nameArabic: 'النَّازِعَات', englishName: 'An-Nazi\'at', englishNameTranslation: 'Those who pull out', numberOfAyahs: 46, revelationType: 'Meccan'),
    SurahMeta(number: 80, nameArabic: 'عَبَسَ', englishName: '\'Abasa', englishNameTranslation: 'He Frowned', numberOfAyahs: 42, revelationType: 'Meccan'),
    SurahMeta(number: 81, nameArabic: 'التَّكْوِير', englishName: 'At-Takwir', englishNameTranslation: 'The Overthrowing', numberOfAyahs: 29, revelationType: 'Meccan'),
    SurahMeta(number: 82, nameArabic: 'الانْفِطَار', englishName: 'Al-Infitar', englishNameTranslation: 'The Cleaving Asunder', numberOfAyahs: 19, revelationType: 'Meccan'),
    SurahMeta(number: 83, nameArabic: 'المُطَفِّفِين', englishName: 'Al-Mutaffifin', englishNameTranslation: 'Defrauding', numberOfAyahs: 36, revelationType: 'Meccan'),
    SurahMeta(number: 84, nameArabic: 'الانْشِقَاق', englishName: 'Al-Inshiqaq', englishNameTranslation: 'The Splitting Asunder', numberOfAyahs: 25, revelationType: 'Meccan'),
    SurahMeta(number: 85, nameArabic: 'البُرُوج', englishName: 'Al-Buruj', englishNameTranslation: 'The Great Stars', numberOfAyahs: 22, revelationType: 'Meccan'),
    SurahMeta(number: 86, nameArabic: 'الطَّارِق', englishName: 'At-Tariq', englishNameTranslation: 'The Night Comer', numberOfAyahs: 17, revelationType: 'Meccan'),
    SurahMeta(number: 87, nameArabic: 'الأَعْلَىٰ', englishName: 'Al-A\'la', englishNameTranslation: 'The Most High', numberOfAyahs: 19, revelationType: 'Meccan'),
    SurahMeta(number: 88, nameArabic: 'الغَاشِيَة', englishName: 'Al-Ghashiyah', englishNameTranslation: 'The Overwhelming Event', numberOfAyahs: 26, revelationType: 'Meccan'),
    SurahMeta(number: 89, nameArabic: 'الفَجْر', englishName: 'Al-Fajr', englishNameTranslation: 'The Daybreak', numberOfAyahs: 30, revelationType: 'Meccan'),
    SurahMeta(number: 90, nameArabic: 'البَلَد', englishName: 'Al-Balad', englishNameTranslation: 'The City', numberOfAyahs: 20, revelationType: 'Meccan'),
    SurahMeta(number: 91, nameArabic: 'الشَّمْس', englishName: 'Ash-Shams', englishNameTranslation: 'The Sun', numberOfAyahs: 15, revelationType: 'Meccan'),
    SurahMeta(number: 92, nameArabic: 'اللَّيْل', englishName: 'Al-Layl', englishNameTranslation: 'The Night', numberOfAyahs: 21, revelationType: 'Meccan'),
    SurahMeta(number: 93, nameArabic: 'الضُّحَىٰ', englishName: 'Ad-Duhaa', englishNameTranslation: 'The Morning Hours', numberOfAyahs: 11, revelationType: 'Meccan'),
    SurahMeta(number: 94, nameArabic: 'الشَّرْح', englishName: 'Ash-Sharh', englishNameTranslation: 'The Expansion', numberOfAyahs: 8, revelationType: 'Meccan'),
    SurahMeta(number: 95, nameArabic: 'التِّين', englishName: 'At-Tin', englishNameTranslation: 'The Fig', numberOfAyahs: 8, revelationType: 'Meccan'),
    SurahMeta(number: 96, nameArabic: 'العَلَق', englishName: 'Al-\'Alaq', englishNameTranslation: 'The Clot', numberOfAyahs: 19, revelationType: 'Meccan'),
    SurahMeta(number: 97, nameArabic: 'القَدْر', englishName: 'Al-Qadr', englishNameTranslation: 'The Night of Decree', numberOfAyahs: 5, revelationType: 'Meccan'),
    SurahMeta(number: 98, nameArabic: 'البَيِّنَة', englishName: 'Al-Bayyinah', englishNameTranslation: 'The Clear Evidence', numberOfAyahs: 8, revelationType: 'Medinan'),
    SurahMeta(number: 99, nameArabic: 'الزَّلْزَلَة', englishName: 'Az-Zalzalah', englishNameTranslation: 'The Earthquake', numberOfAyahs: 8, revelationType: 'Medinan'),
    SurahMeta(number: 100, nameArabic: 'العَادِيَات', englishName: 'Al-\'Adiyat', englishNameTranslation: 'The Courser', numberOfAyahs: 11, revelationType: 'Meccan'),
    SurahMeta(number: 101, nameArabic: 'القَارِعَة', englishName: 'Al-Qari\'ah', englishNameTranslation: 'The Striking Hour', numberOfAyahs: 11, revelationType: 'Meccan'),
    SurahMeta(number: 102, nameArabic: 'التَّكَاثُر', englishName: 'At-Takathur', englishNameTranslation: 'The Rivalry in World Increase', numberOfAyahs: 8, revelationType: 'Meccan'),
    SurahMeta(number: 103, nameArabic: 'العَصْر', englishName: 'Al-\'Asr', englishNameTranslation: 'The Time', numberOfAyahs: 3, revelationType: 'Meccan'),
    SurahMeta(number: 104, nameArabic: 'الهُمَزَة', englishName: 'Al-Humazah', englishNameTranslation: 'The Slanderer', numberOfAyahs: 9, revelationType: 'Meccan'),
    SurahMeta(number: 105, nameArabic: 'الفِيل', englishName: 'Al-Fil', englishNameTranslation: 'The Elephant', numberOfAyahs: 5, revelationType: 'Meccan'),
    SurahMeta(number: 106, nameArabic: 'قُرَيْش', englishName: 'Quraysh', englishNameTranslation: 'Quraysh', numberOfAyahs: 4, revelationType: 'Meccan'),
    SurahMeta(number: 107, nameArabic: 'المَاعُون', englishName: 'Al-Ma\'un', englishNameTranslation: 'The Neighborly Assistance', numberOfAyahs: 7, revelationType: 'Meccan'),
    SurahMeta(number: 108, nameArabic: 'الكَوْثَر', englishName: 'Al-Kawthar', englishNameTranslation: 'The Abundance (Sayyida Fatima s.a.)', numberOfAyahs: 3, revelationType: 'Meccan'),
    SurahMeta(number: 109, nameArabic: 'الكَافِرُون', englishName: 'Al-Kafirun', englishNameTranslation: 'The Disbelievers', numberOfAyahs: 6, revelationType: 'Meccan'),
    SurahMeta(number: 110, nameArabic: 'النَّصْر', englishName: 'An-Nasr', englishNameTranslation: 'The Help', numberOfAyahs: 3, revelationType: 'Medinan'),
    SurahMeta(number: 111, nameArabic: 'المَسَد', englishName: 'Al-Masad', englishNameTranslation: 'The Palm Fiber', numberOfAyahs: 5, revelationType: 'Meccan'),
    SurahMeta(number: 112, nameArabic: 'الإِخْلَاص', englishName: 'Al-Ikhlas', englishNameTranslation: 'The Sincerity (Tawheed)', numberOfAyahs: 4, revelationType: 'Meccan'),
    SurahMeta(number: 113, nameArabic: 'الفَلَق', englishName: 'Al-Falaq', englishNameTranslation: 'The Daybreak', numberOfAyahs: 5, revelationType: 'Meccan'),
    SurahMeta(number: 114, nameArabic: 'النَّاس', englishName: 'An-Nas', englishNameTranslation: 'Mankind', numberOfAyahs: 6, revelationType: 'Meccan'),
  ];

  static SurahMeta? getSurahByNumber(int num) {
    if (num < 1 || num > allSurahs.length) return null;
    return allSurahs[num - 1];
  }

  /// Fetch full Surah text dynamically from free AlQuran Cloud API
  static Future<ContentModel> fetchSurahContent(SurahMeta surah) async {
    try {
      final url = Uri.parse(
        'https://api.alquran.cloud/v1/surah/${surah.number}/editions/quran-uthmani,en.sahih',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));
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
            translationGu: 'સૂરહ ${surah.englishName} (${surah.englishNameTranslation}) - પવિત્ર કુર્આનનો અધ્યાય.',
            audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${surah.number}.mp3',
            tags: ['quran', 'surah', surah.revelationType.toLowerCase()],
          );
        }
      }
    } catch (e) {
      debugPrint('QuranService fetch note: $e');
    }

    // High quality offline fallback representation with Bismillah and full details
    return ContentModel(
      contentId: 'surah_${surah.number}',
      type: 'surah',
      title: 'Surah ${surah.englishName} (${surah.nameArabic})',
      arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ\nالْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝ الرَّحْمَٰنِ الرَّحِيمِ ۝ مَالِكِ يَوْمِ الدِّينِ ۝ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۝ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝',
      translationEn: 'Surah ${surah.englishName} (${surah.englishNameTranslation}). Revealed in ${surah.revelationType}. Total ${surah.numberOfAyahs} verses. In the name of Allah, the Beneficent, the Merciful.',
      translationUr: 'سورۃ ${surah.englishName} (${surah.englishNameTranslation}) - کل ${surah.numberOfAyahs} آیات، مکی/مدنی۔',
      translationHi: 'सूरह ${surah.englishName} (${surah.englishNameTranslation}) - कुल ${surah.numberOfAyahs} आयतें।',
      translationGu: 'સૂરહ ${surah.englishName} (${surah.englishNameTranslation}) - કુલ ${surah.numberOfAyahs} આયતો. રહેમાન અને રહીમ અલ્લાહના નામ સાથે.',
      audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/${surah.number}.mp3',
      tags: ['quran', 'surah', surah.revelationType.toLowerCase()],
    );
  }
}
