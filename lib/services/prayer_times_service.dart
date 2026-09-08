import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String sunset;
  final String maghrib;
  final String isha;
  final String midnight;
  final String dateHijri;

  const PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.sunset,
    required this.maghrib,
    required this.isha,
    required this.midnight,
    required this.dateHijri,
  });

  factory PrayerTimesModel.defaultNajaf() {
    return const PrayerTimesModel(
      fajr: '04:42',
      sunrise: '06:02',
      dhuhr: '12:08',
      asr: '15:38',
      sunset: '18:14',
      maghrib: '18:32',
      isha: '19:48',
      midnight: '23:25',
      dateHijri: '17 Safar 1448',
    );
  }
}

class PrayerTimesService {
  /// Fetch Shia Ithna-Ashari prayer times (method 7 = Institute of Geophysics, University of Tehran / Leva Qum)
  static Future<PrayerTimesModel> getShiaPrayerTimes({
    String city = 'Najaf',
    String country = 'Iraq',
  }) async {
    try {
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$city&country=$country&method=7',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final timings = json['data']?['timings'];
        final hijri = json['data']?['date']?['hijri'];

        if (timings != null) {
          final hijriDay = hijri?['day'] ?? '17';
          final hijriMonth = hijri?['month']?['en'] ?? 'Safar';
          final hijriYear = hijri?['year'] ?? '1448';

          return PrayerTimesModel(
            fajr: timings['Fajr'] ?? '04:42',
            sunrise: timings['Sunrise'] ?? '06:02',
            dhuhr: timings['Dhuhr'] ?? '12:08',
            asr: timings['Asr'] ?? '15:38',
            sunset: timings['Sunset'] ?? '18:14',
            maghrib: timings['Maghrib'] ?? '18:32',
            isha: timings['Isha'] ?? '19:48',
            midnight: timings['Midnight'] ?? '23:25',
            dateHijri: '$hijriDay $hijriMonth $hijriYear',
          );
        }
      }
    } catch (e) {
      debugPrint('PrayerTimesService note (using default): $e');
    }

    return PrayerTimesModel.defaultNajaf();
  }
}
