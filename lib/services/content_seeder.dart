import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content_model.dart';
import '../models/goal_model.dart';

class ContentSeeder {
  static final List<ContentModel> defaultContentSeed = [
    // 1. Dua-e-Ahad
    const ContentModel(
      contentId: 'dua_ahad',
      type: 'dua',
      title: 'Dua-e-Ahad',
      arabicText:
          'اَللَّهُمَّ رَبَّ النُّورِ الْعَظِيمِ، وَرَبَّ الْكُرْسِيِّ الرَّفِيعِ، وَرَبَّ الْبَحْرِ الْمَسْجُورِ، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالزَّبُورِ، وَرَبَّ الظِّلِّ وَالْحَرُورِ، وَمُنْزِلَ الْقُرْآنِ الْعَظِيمِ، وَرَبَّ الْمَلَائِكَةِ الْمُقَرَّبِينَ وَالْأَنْبِيَاءِ وَالْمُرْسَلِينَ.',
      translationEn:
          'O Allah, Lord of the Great Light, Lord of the Exalted Throne, Lord of the turbulent sea, and Revealer of the Torah, the Injeel, and the Zaboor, and Lord of the shade and the heat, and Revealer of the Great Quran, and Lord of the Archangels, Prophets, and Messengers.',
      translationUr:
          'اے اللہ! اے عظیم نور کے پروردگار، اے بلند مرتبت عرش کے رب، اے متلاطم سمندر کے مالک، اور تورات، انجیل اور زبور کو نازل فرمانے والے، اور سایہ اور دھوپ کے پروردگار، اور قرآنِ عظیم کو نازل کرنے والے، اور مقرب فرشتوں اور تمام انبیاء و مرسلین کے رب۔',
      translationHi:
          'ऐ अल्लाह! ऐ अज़ीम नूर के रब, ऐ बुलन्द अर्श के परवरदिगार, और तौरात, इंजील और ज़बूर को नाज़िल करने वाले, और कुरान-ए-अज़ीम के उतारने वाले।',
      audioUrl: 'https://media.duas.org/duas/ahad.mp3',
      tags: ['morning', 'fajr', 'imam mahdi', 'covenant', 'daily', '40 days'],
    ),

    // 2. Ziyarat Ale-Yasin
    const ContentModel(
      contentId: 'ziyarat_ale_yasin',
      type: 'ziyarat',
      title: 'Ziyarat Ale-Yasin',
      arabicText:
          'سَلَامٌ عَلَى آلِ يس، السَّلَامُ عَلَيْكَ يَا دَاعِيَ اللَّهِ وَرَبَّانِيَّ آيَاتِهِ، السَّلَامُ عَلَيْكَ يَا بَابَ اللَّهِ وَدَيَّانَ دِينِهِ، السَّلَامُ عَلَيْكَ يَا خَلِيفَةَ اللَّهِ وَنَاصِرَ حَقِّهِ.',
      translationEn:
          'Peace be upon the Family of Yasin! Peace be upon you, O inviter to Allah and scholar of His signs! Peace be upon you, O door to Allah and maintainer of His religion! Peace be upon you, O Caliph of Allah and supporter of His truth!',
      translationUr:
          'سلام ہو آلِ یٰسین پر! سلام ہو آپ پر اے اللہ کی طرف دعوت دینے والے اور اس کی نشانیوں کے عالم! سلام ہو آپ پر اے بابِ خدا اور دینِ خدا کے سرپرست! سلام ہو آپ پر اے خلیفۃ اللہ اور حق کے مددگار!',
      translationHi:
          'सलाम हो आले यासीन पर! सलाम हो आप पर ऐ खुदा की तरफ बुलाने वाले और उसकी निशानियों के इल्म वाले! सलाम हो आप पर ऐ खलीफ़तुल्लाह और हक के मददगार!',
      audioUrl: 'https://media.duas.org/ziyarat/ale_yasin.mp3',
      tags: ['ziyarat', 'imam mahdi', 'friday', 'presence', 'spiritual'],
    ),

    // 3. Ziyarat Ashura
    const ContentModel(
      contentId: 'ziyarat_ashura',
      type: 'ziyarat',
      title: 'Ziyarat Ashura',
      arabicText:
          'السَّلَامُ عَلَيْكَ يَا أَبَا عَبْدِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا ابْنَ رَسُولِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا خِيَرَةَ اللَّهِ وَابْنَ خِيَرَتِهِ، السَّلَامُ عَلَيْكَ يَا ابْنَ أَمِيرِ الْمُؤْمِنِينَ وَابْنَ سَيِّدِ الْوَصِيِّينَ.',
      translationEn:
          'Peace be upon you, O Aba Abdillah! Peace be upon you, O son of the Messenger of Allah! Peace be upon you, O chosen one of Allah and son of His chosen one! Peace be upon you, O son of the Commander of the Faithful and master of successors!',
      translationUr:
          'سلام ہو آپ پر اے ابا عبداللہ! سلام ہو آپ پر اے رسول اللہ کے فرزند! سلام ہو آپ پر اے امیر المومنین اور اوصیاء کے سردار کے فرزند!',
      translationHi:
          'सलाम हो आप पर ऐ अबा अब्दुल्लाह! सलाम हो आप पर ऐ रसूलुल्लाह के बेटे! सलाम हो आप पर ऐ अमीरुल मोमिनीन के फरज़न्द!',
      audioUrl: 'https://media.duas.org/ziyarat/ashura.mp3',
      tags: ['ziyarat', 'karbala', 'imamhussain', 'muharram', 'arbaeen', 'daily'],
    ),

    // 4. Dua Kumayl
    const ContentModel(
      contentId: 'dua_kumayl',
      type: 'dua',
      title: 'Dua Kumayl',
      arabicText:
          'اَللَّهُمَّ إِنِّي أَسْأَلُكَ بِرَحْمَتِكَ الَّتِي وَسِعَتْ كُلَّ شَيْءٍ، وَبِقُوَّتِكَ الَّتِي قَهَرْتَ بِهَا كُلَّ شَيْءٍ، وَخَضَعَ لَهَا كُلُّ شَيْءٍ، وَذَلَّ لَهَا كُلُّ شَيْءٍ.',
      translationEn:
          'O Allah, I beseech Thee by Thy mercy which encompasses all things, and by Thy power wherewith Thou overcomest all things, and to which all things submit, and by Thy might through which Thou hast humbled all things.',
      translationUr:
          'اے اللہ! میں تجھ سے سوال کرتا ہوں تیری اس رحمت کے ذریعے جو ہر شے کا احاطہ کیے ہوئے ہے، اور تیری اس طاقت کے واسطے جس سے تو نے ہر چیز پر غلبہ پایا، اور جس کے آگے ہر چیز جھک گئی اور عاجز ہو گئی۔',
      translationHi:
          'ऐ अल्लाह! मैं तुझसे सवाल करता हूँ तेरी उस रहमत के ज़रिये जो हर चीज़ पर छाई हुई है, और तेरी उस कुव्वत के वास्ते जिसके आगे हर चीज़ झुक गई।',
      audioUrl: 'https://media.duas.org/duas/kumayl.mp3',
      tags: ['thursday', 'forgiveness', 'maghrib', 'imam ali', 'weekly'],
    ),

    // 5. Surah Al-Fatiha (The Opening)
    const ContentModel(
      contentId: 'surah_fatiha',
      type: 'surah',
      title: 'Surah Al-Fatiha',
      arabicText:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ. الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ. الرَّحْمَٰنِ الرَّحِيمِ. مَالِكِ يَوْمِ الدِّينِ. إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ. اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ. صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ.',
      translationEn:
          'In the Name of Allah, the All-beneficent, the All-merciful. All praise belongs to Allah, Lord of all the worlds, the All-beneficent, the All-merciful, Master of the Day of Retribution. You alone we worship, and to You alone we turn for help. Guide us on the straight path, the path of those whom You have blessed, not of those with whom You are angry, nor of those who go astray.',
      translationUr:
          'اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے۔ سب تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا پالنے والا ہے۔ بڑا مہربان نہایت رحم فرمانے والا ہے۔ روزِ جزا کا مالک ہے۔ ہم تیری ہی عبادت کرتے ہیں اور تجھ ہی سے مدد مانگتے ہیں۔ ہمیں سیدھے راستے کی ہدایت فرما، ان لوگوں کا راستہ جن پر تو نے انعام فرمایا، نہ ان کا راستہ جن پر غضب نازل ہوا اور نہ گمراہوں کا۔',
      translationHi:
          'अल्लाह के नाम से जो निहायत मेहरबान और रहम वाला है। सब तारीफें अल्लाह के लिए हैं जो तमाम जहानों का पालने वाला है। निहायत मेहरबान, रहम वाला, रोज़-ए-जज़ा का मालिक। हम तेरी ही इबादत करते हैं और तुझ ही से मदद चाहते हैं।',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001001.mp3',
      tags: ['quran', 'daily', 'prayer', 'surah', 'opening'],
    ),

    // 6. Surah Yasin (Heart of Quran)
    const ContentModel(
      contentId: 'surah_yasin',
      type: 'surah',
      title: 'Surah Yasin',
      arabicText:
          'يس. وَالْقُرْآنِ الْحَكِيمِ. إِنَّكَ لَمِنَ الْمُرْسَلِينَ. عَلَىٰ صِرَاطٍ مُسْتَقِيمٍ. تَنْزِيلَ الْعَزِيزِ الرَّحِيمِ. لِتُنْذِرَ قَوْمًا مَا أُنْذِرَ آبَاؤُهُمْ فَهُمْ غَافِلُونَ.',
      translationEn:
          'Ya Seen. By the wise Quran, indeed you are from among the messengers, on a straight path. A revelation of the Exalted in Might, the Merciful, that you may warn a people whose forefathers were not warned, so they are unaware.',
      translationUr:
          'یٰسین۔ حکمت والے قرآن کی قسم۔ بے شک آپ رسولوں میں سے ہیں۔ سیدھے راستے پر۔ یہ غالب اور رحم کرنے والے کا اتارا ہوا ہے۔ تاکہ آپ اس قوم کو خبردار کریں جن کے باپ دادا کو خبردار نہیں کیا گیا تھا، سو وہ غافل ہیں۔',
      translationHi:
          'या-सीन। हिकमत वाले कुरान की क़सम। बेशक आप रसूलों में से हैं, सीधे रास्ते पर। यह ज़बरदस्त और रहम फरमाने वाले का नाज़िल किया हुआ है।',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/036001.mp3',
      tags: ['quran', 'morning', 'salvation', 'surah', 'heart of quran'],
    ),

    // 7. Ziyarat Waritha
    const ContentModel(
      contentId: 'ziyarat_waritha',
      type: 'ziyarat',
      title: 'Ziyarat Waritha',
      arabicText:
          'السَّلَامُ عَلَيْكَ يَا وَارِثَ آدَمَ صَفْوَةِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا وَارِثَ نُوحٍ نَبِيِّ اللَّهِ، السَّلَامُ عَلَيْكَ يَا وَارِثَ إِبْرَاهِيمَ خَلِيلِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا وَارِثَ مُوسَى كَلِيمِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا وَارِثَ عِيسَى رُوحِ اللَّهِ.',
      translationEn:
          'Peace be upon you, O inheritor of Adam, the chosen one of Allah! Peace be upon you, O inheritor of Noah, the prophet of Allah! Peace be upon you, O inheritor of Abraham, the friend of Allah! Peace be upon you, O inheritor of Moses, the one who spoke to Allah! Peace be upon you, O inheritor of Jesus, the spirit of Allah!',
      translationUr:
          'سلام ہو آپ پر اے آدمؑ کے وارث جو اللہ کے برگزیدہ ہیں! سلام ہو آپ پر اے نوحؑ کے وارث جو اللہ کے نبی ہیں! سلام ہو آپ پر اے ابراہیمؑ کے وارث جو اللہ کے خلیل ہیں! سلام ہو آپ پر اے موسیٰؑ کے وارث جن سے اللہ نے کلام کیا! سلام ہو آپ پر اے عیسیٰؑ کے وارث جو اللہ کی روح ہیں!',
      translationHi:
          'सलाम हो आप पर ऐ आदम (अ.स) के वारिस जो अल्लाह के चुने हुए हैं! सलाम हो आप पर ऐ नूह (अ.स) के वारिस! सलाम हो आप पर ऐ इब्राहिम (अ.स) के वारिस!',
      audioUrl: 'https://media.duas.org/ziyarat/waritha.mp3',
      tags: ['ziyarat', 'prophets', 'karbala', 'legacy', 'imamhussain'],
    ),

    // 8. Dua-e-Tawassul
    const ContentModel(
      contentId: 'dua_tawassul',
      type: 'dua',
      title: 'Dua-e-Tawassul',
      arabicText:
          'اَللَّهُمَّ إِنِّي أَسْأَلُكَ وَأَتَوَجَّهُ إِلَيْكَ بِنَبِيِّكَ نَبِيِّ الرَّحْمَةِ مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَآلِهِ، يَا أَبَا الْقَاسِمِ، يَا رَسُولَ اللَّهِ، يَا إِمَامَ الرَّحْمَةِ، يَا سَيِّدَنَا وَمَوْلَانَا، إِنَّا تَوَجَّهْنَا وَاسْتَشْفَعْنَا وَتَوَسَّلْنَا بِكَ إِلَى اللَّهِ.',
      translationEn:
          'O Allah, I beseech Thee and turn towards Thee through Thy Prophet, the Prophet of Mercy, Muhammad (peace and blessings of Allah be upon him and his progeny). O Abul-Qasim, O Messenger of Allah, O Guide of Mercy, O our master and leader! We turn towards you and seek your intercession before Allah.',
      translationUr:
          'اے اللہ! میں تجھ سے سوال کرتا ہوں اور تیری طرف متوجہ ہوتا ہوں تیرے نبیِ رحمت محمد مصطفیٰ (ص) کے واسطے سے۔ اے ابوالقاسم! اے اللہ کے رسول! اے رحمت کے پیشوا! ہم نے آپ کے وسیلے سے اللہ کی بارگاہ میں التجا کی اور شفاعت طلب کی۔',
      translationHi:
          'ऐ अल्लाह! मैं तुझसे सवाल करता हूँ और तेरी तरफ रुजू करता हूँ तेरे नबी-ए-रहमत हज़रत मुहम्मद (स.अ.व) के वास्ते से।',
      audioUrl: 'https://media.duas.org/duas/tawassul.mp3',
      tags: ['intercession', 'tuesday', 'ahlulbayt', 'supplication'],
    ),
  ];

  /// Standard default goal templates (Section 3.3)
  static List<GoalModel> getInitialGoalTemplates(String userId) {
    return [
      GoalModel(
        goalId: 'template_mahdi_servant',
        userId: userId,
        title: 'Imam Mahdi\'s Servant',
        description: 'A quiet daily practice for presence and covenant renewal',
        items: const ['dua_ahad', 'ziyarat_ale_yasin'],
        streakCount: 6,
        progressToday: 0.50,
        createdVia: 'template',
        createdAt: DateTime.now(),
      ),
      GoalModel(
        goalId: 'template_40_days_ahad',
        userId: userId,
        title: '40 Days of Dua-e-Ahad',
        description: 'Begin the morning with intention to join the companions',
        items: const ['dua_ahad'],
        streakCount: 14,
        progressToday: 0.86,
        createdVia: 'template',
        createdAt: DateTime.now(),
      ),
      GoalModel(
        goalId: 'template_arbaeen_journey',
        userId: userId,
        title: 'Arbaeen Journey',
        description: 'Ziyarat, reflection, and remembrance of Karbala',
        items: const ['ziyarat_ashura', 'ziyarat_waritha'],
        streakCount: 3,
        progressToday: 0.33,
        createdVia: 'template',
        createdAt: DateTime.now(),
      ),
    ];
  }

  /// Automatically seed Firestore database with content
  static Future<int> seedContentToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    for (final content in defaultContentSeed) {
      final docRef = firestore.collection('content').doc(content.contentId);
      batch.set(docRef, content.toMap(), SetOptions(merge: true));
    }

    await batch.commit();
    return defaultContentSeed.length;
  }
}
