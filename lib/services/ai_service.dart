import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiService {
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static String get _apiKey {
    final fromDotEnv = dotenv.env['GEMINI_API_KEY'];
    if (fromDotEnv != null && fromDotEnv.isNotEmpty) return fromDotEnv;
    const fromDefine = String.fromEnvironment('GEMINI_API_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    return '';
  }

  /// System prompt establishing strict Shia Islamic grounding
  static const String _shiaSystemInstruction = '''
You are "Muntazir AI", a dignified and compassionate Shia Islamic spiritual companion.
Your answers are strictly grounded in the Holy Quran and teachings of Prophet Muhammad (s.a.w.) and the 14 Infallibles (Ahlulbayt a.s.), including Nahj al-Balagha, Mafatih al-Jinan, and Sahifa al-Sajjadiyya.
Provide gentle, respectful, and spiritually uplifting guidance.
For fiqh questions, refer to the user's Marja-e-Taqleed (Ayatollah Sistani or Ayatollah Khamenei). Always maintain the disclaimer that you are an AI assistant and not a Mujtahid issuing binding fatwas.
''';

  /// Match user's feeling/intention to Duas & Ziyarat in our library
  static Future<Map<String, dynamic>> matchIntentionToGoals(String intention) async {
    if (_apiKey.isEmpty) {
      return _localRuleBasedGoalMatcher(intention);
    }

    try {
      final url = Uri.parse('$_geminiBaseUrl?key=$_apiKey');
      final prompt = '''
User spiritual intention: "$intention"

Available library items:
- "dua_ahad": Dua-e-Ahad (Morning covenant renewal with Imam Mahdi a.t.f.s.)
- "ziyarat_ale_yasin": Ziyarat Ale-Yasin (Direct salutations to Imam az-Zaman a.t.f.s.)
- "ziyarat_ashura": Ziyarat Ashura (Karbala remembrance, grief, loyalty to Imam Hussain a.s.)
- "dua_kumayl": Dua Kumayl (Thursday night repentance, seeking Allah's mercy and forgiveness)
- "surah_al_fatiha": Surah Al-Fatiha (Opening of Quran, healing, daily recitation)
- "surah_yasin": Surah Yasin (Heart of the Quran, peace, departed souls)
- "ziyarat_waritha": Ziyarat Waritha (Prophetic legacy, inheritance of truth)
- "dua_tawassul": Dua-e-Tawassul (Seeking intercession through the 14 Infallibles)

Recommend the most suitable 1-2 items from the list.
Return ONLY a valid JSON object with the following schema:
{
  "title": "Short title for the practice",
  "description": "1 sentence description of why these were chosen",
  "advice": "2-3 sentences of comforting Shia spiritual advice",
  "matched_items": ["item_id_1", "item_id_2"]
}
''';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': _shiaSystemInstruction}
            ]
          },
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'response_mime_type': 'application/json',
            'temperature': 0.4,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawJson = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (rawJson != null) {
          final parsed = jsonDecode(rawJson) as Map<String, dynamic>;
          return {
            'title': parsed['title'] ?? 'Personal Spiritual Habit',
            'description': parsed['description'] ?? 'Tailored to your intention.',
            'advice': parsed['advice'] ?? 'May Allah grant peace to your heart.',
            'matched_items': List<String>.from(parsed['matched_items'] ?? ['dua_ahad']),
          };
        }
      }
    } catch (e) {
      debugPrint('Gemini goal matcher note: $e');
    }

    return _localRuleBasedGoalMatcher(intention);
  }

  /// Ask Shia Fiqh / Spiritual question
  static Future<String> askSpiritualQuestion({
    required String question,
    required String marja,
  }) async {
    if (_apiKey.isEmpty) {
      return 'Please check your internet connection or configure GEMINI_API_KEY. In the meantime, please consult your Marja ($marja) official office or a local scholar for rulings.';
    }

    try {
      final url = Uri.parse('$_geminiBaseUrl?key=$_apiKey');
      final prompt = '''
User follows Marja: Ayatollah $marja.
User question: "$question"

Please provide an authentic, respectful answer according to Shia Ithna-Ashari Islamic traditions and Ayatollah $marja's rulings where applicable.
Cite the relevant Hadith or principle if helpful.
End with a gentle reminder to verify critical matters with the Marja's official representative (e.g. sistani.org or leader.ir).
''';

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [
              {'text': _shiaSystemInstruction}
            ]
          },
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.5,
            'maxOutputTokens': 800,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
    } catch (e) {
      debugPrint('Gemini Q&A note: $e');
    }

    return _getShiaFiqhFallback(question, marja);
  }

  /// Authentic Shia Fiqh and spiritual fallback knowledge base
  static String _getShiaFiqhFallback(String question, String marja) {
    final q = question.toLowerCase();

    if (q.contains('sahw') || q.contains('sajda') || q.contains('prostration')) {
      return '''According to Ayatollah $marja:
Sajdah as-Sahw (Prostration of Forgetfulness) is required when certain inadvertent mistakes occur in wajib prayers:
1. Talking inadvertently.
2. Forgetting one sajdah (and having moved past the ruku of the next rakat).
3. Reciting Salam at the wrong position.
4. In 4-rakat prayers, when having doubt between 4 and 5 rakats after the 2nd sajdah.

Method: Immediately after the final Salam of the prayer:
1. Make intention (Niyyah) for Sajdah as-Sahw.
2. Place forehead on the Turbah (soil of Karbala) and recite:
"بِسْمِ اللَّهِ وَبِاللَّهِ، السَّلَامُ عَلَيْكَ أَيُّهَا النَّبِيُّ وَرَحْمَةُ اللَّهِ وَبَرَكَاتُهُ"
(Bismillahi wa billah, as-salamu 'alayka ayyuhan-Nabiyyu wa rahmatullahi wa barakatuh).
3. Sit up, perform a second Sajdah with the same Dhikr.
4. Sit up and recite Tashahhud followed by the final Salam.

(Source: Islamic Laws / Tawdih al-Masa'il, Mas'ala on Sajdah as-Sahw).''';
    } else if (q.contains('ahad') || q.contains('virtue')) {
      return '''Virtues of Dua-e-Ahad (Bihar al-Anwar, Vol. 53):
Imam Ja'far al-Sadiq (peace be upon him) narrates:
"Whoever recites this supplication for forty mornings will be numbered amongst the sincere helpers of our Qa'im (Imam al-Mahdi a.t.f.s.). If he passes away before the reappearance of the Imam, Allah will raise him from his grave so that he may serve alongside the Hujjah."

It is recommended to recite it after Salat al-Fajr before sunrise, placing your right hand on your right thigh at the conclusion while tapping it thrice and saying:
"الْعَجَلَ الْعَجَلَ يَا مَوْلَايَ يَا صَاحِبَ الزَّمَانِ"
(Al-Ajal, Al-Ajal, Ya Mawlaya Ya Sahib az-Zaman).''';
    } else if (q.contains('jummah') || q.contains('friday prayer')) {
      return '''Salat al-Jummah rulings under Ayatollah $marja:
- According to Ayatollah Sistani: During the Major Occultation of Imam al-Mahdi (a.t.f.s.), Salat al-Jummah is Wajib Takhyiri (an elective obligation). A believer may choose either Friday prayer or Zuhr prayer. When established with all valid conditions (including a just Imam and 2 Khutbahs), it is valid and suffices for Zuhr, though performing Zuhr also out of precaution (Ihtiyat) is acceptable.
- According to Ayatollah Khamenei: Friday prayer holds paramount social and spiritual importance in Islamic society, and attending it is highly emphasized.''';
    } else if (q.contains('yasin') || q.contains('ale-yasin')) {
      return '''Spiritual significance of Ziyarat Ale-Yasin:
Reported in Mafatih al-Jinan through the 4th Special Deputy (Abu al-Hasan Ali bin Muhammad al-Samarri), this Ziyarat is narrated directly from Imam al-Mahdi (a.t.f.s.), who instructed:
"Whenever you wish to turn toward Allah through us, recite as Allah has declared: Salamun 'ala Al-e-Yasin..."

It offers salutations to the Imam in all his states: standing, sitting, bowing, prostrating, reciting, and supplicating for his Shia. It concludes with an affirmation of belief in the 14 Infallibles.''';
    }

    return '''According to Shia Ithna-Ashari jurisprudence under Ayatollah $marja:
Prayer, fasting, and spiritual deeds require sincere intention (Qurbatan ila Allah). For specific fatwas regarding your query ("$question"), please refer directly to your Marja's official desk (sistani.org or leader.ir) or consult an authorized representative in your locality.''';
  }

  /// Instant local fallback matching if offline or key absent
  static Map<String, dynamic> _localRuleBasedGoalMatcher(String query) {
    final q = query.toLowerCase();

    if (q.contains('mahdi') || q.contains('morning') || q.contains('fajr') || q.contains('wait')) {
      return {
        'title': 'Covenant with Imam az-Zaman',
        'description': 'Daily morning practice for presence and renewal of allegiance.',
        'advice': 'Reciting Dua-e-Ahad after Fajr keeps your heart tethered to the Imam of our time. Small daily habits form enduring faith.',
        'matched_items': ['dua_ahad', 'ziyarat_ale_yasin'],
      };
    } else if (q.contains('grief') || q.contains('sad') || q.contains('karbala') || q.contains('hussain')) {
      return {
        'title': 'Karbala Solace Practice',
        'description': 'Remembrance and seeking peace through salutations to Aba Abdillah (a.s.).',
        'advice': 'Tears shed in remembrance of Imam Hussain (a.s.) are a balm for troubled hearts. Connect with Karbala daily through Ziyarat Ashura.',
        'matched_items': ['ziyarat_ashura', 'ziyarat_waritha'],
      };
    } else if (q.contains('repent') || q.contains('sin') || q.contains('forgive') || q.contains('thursday') || q.contains('kumayl')) {
      return {
        'title': 'Night of Repentance & Mercy',
        'description': 'Seeking divine forgiveness through the supplication of Imam Ali (a.s.).',
        'advice': 'No sin is greater than Allah’s boundless mercy. Spend Thursday evenings supplicating with Dua Kumayl.',
        'matched_items': ['dua_kumayl'],
      };
    } else {
      return {
        'title': 'Daily Spiritual Light',
        'description': 'Harmonious practice combining Quranic light and intercession.',
        'advice': 'Consistency in reciting the words of Ahlulbayt brings tranquil serenity to daily life.',
        'matched_items': ['surah_al_fatiha', 'dua_tawassul'],
      };
    }
  }
}
