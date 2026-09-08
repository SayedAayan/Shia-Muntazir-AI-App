import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiService {
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

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
      debugPrint('Gemini Q&A error: $e');
    }

    return 'Unable to reach the spiritual assistant at the moment. According to Shia jurisprudence under Ayatollah $marja, please ensure purity of intention and consult authorized representatives for binding fatwas.';
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
