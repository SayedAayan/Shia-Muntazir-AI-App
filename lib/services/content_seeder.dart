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
          'اَللَّهُمَّ رَبَّ النُّورِ الْعَظِيمِ، وَرَبَّ الْكُرْسِيِّ الرَّفِيعِ، وَرَبَّ الْبَحْرِ الْمَسْجُورِ، وَمُنْزِلَ التَّوْرَاةِ وَالْإِنْجِيلِ وَالزَّبُورِ، وَرَبَّ الظِّلِّ وَالْحَرُورِ، وَمُنْزِلَ الْقُرْآنِ الْعَظِيمِ، وَرَبَّ الْمَلَائِكَةِ الْمُقَرَّبِينَ وَالْأَنْبِيَاءِ وَالْمُرْسَلِينَ. ۝ اَللَّهُمَّ إِنِّي أَسْأَلُكَ بِوَجْهِكَ الْكَرِيمِ، وَبِنُورِ وَجْهِكَ الْمُنِيرِ، وَمُلْكِكَ الْقَدِيمِ، يَا حَيُّ يَا قَيُّومُ، أَسْأَلُكَ بِاسْمِكَ الَّذِي أَشْرَقَتْ بِهِ السَّمَاوَاتُ وَالْأَرَضُونَ. ۝ اَللَّهُمَّ بَلِّغْ مَوْلَانَا الْإِمَامَ الْهَادِيَ الْمَهْدِيَّ الْقَائِمَ بِأَمْرِكَ، صَلَوَاتُ اللَّهِ عَلَيْهِ وَعَلَى آبَائِهِ الطَّاهِرِينَ، عَنْ جَمِيعِ الْمُؤْمِنِينَ وَالْمُؤْمِنَاتِ فِي مَشَارِقِ الْأَرْضِ وَمَغَارِبِهَا. ۝ اَللَّهُمَّ إِنِّي أُجَدِّدُ لَهُ فِي صَبِيحَةِ يَوْمِي هَٰذَا، وَمَا عِشْتُ مِنْ أَيَّامِي، عَهْدًا وَعَقْدًا وَبَيْعَةً لَهُ فِي عُنُقِي، لَا أَحُولُ عَنْهَا وَلَا أَزُولُ أَبَدًا.',
      translationEn:
          'O Allah, Lord of the Great Light, Lord of the Exalted Throne, Lord of the turbulent sea, and Revealer of the Torah, the Injeel, and the Zaboor, and Lord of the shade and the heat, and Revealer of the Great Quran, and Lord of the Archangels, Prophets, and Messengers. ۝ O Allah, I beseech Thee by Thy Noble Countenance, and by the Light of Thy illuminating Face, and by Thy primordial kingdom. O Ever-Living, O Self-Subsisting! ۝ O Allah, convey to our master, the guiding Imam, the Mahdi, who rises with Thy command (prayers of Allah be upon him and his pure fathers), from all the believing men and women in the easts of the earth and its wests. ۝ O Allah, I renew unto him in the morning of this day, and for all days of my life, a covenant, a bond, and an allegiance upon my neck, from which I will never deviate nor falter.',
      translationUr:
          'اے اللہ! اے عظیم نور کے پروردگار، اے بلند مرتبت عرش کے رب، اے متلاطم سمندر کے مالک، اور تورات، انجیل اور زبور کو نازل فرمانے والے، اور سایہ اور دھوپ کے پروردگار، اور قرآنِ عظیم کو نازل کرنے والے، اور مقرب فرشتوں اور تمام انبیاء و مرسلین کے رب۔ ۝ اے اللہ! میں تیرے کرم والے رخ اور تیرے روشن چہرے کے نور کا واسطہ دے کر تجھ سے سوال کرتا ہوں۔ ۝ اے اللہ! ہمارے مولا و آقا، ہدایت یافتہ اور ہدایت دینے والے قائم بالامر امام مہدی (عج) تک، جن پر اور ان کے پاکیزہ آباء و اجداد پر تیرا درود ہو، تمام مومنین اور مومنات کی جانب سے سلام و درود پہنچا۔ ۝ اے اللہ! میں آج کی صبح اور اپنی زندگی کے تمام ایام میں ان کے ساتھ اپنے عہد، عقد اور بیعت کی تجدید کرتا ہوں، جس سے میں کبھی پھروں گا نہیں اور نہ روگردانی کروں گا۔',
      translationHi:
          'ऐ अल्लाह! ऐ अज़ीम नूर के रब, ऐ बुलन्द अर्श के परवरदिगार, और तौरात, इंजील और ज़बूर को नाज़िल करने वाले, और कुरान-ए-अज़ीम के उतारने वाले। ۝ ऐ अल्लाह! हमारे मौला और आका, हिदायत देने वाले इमाम महदी (अ.त.फ़.स) तक तमाम मोमिनीन व मोमिनात की तरफ से दरूद व सलाम पहुंचा। ۝ ऐ अल्लाह! मैं आज की सुबह और अपनी ज़िंदगी के तमाम दिनों में उनके साथ अपने अहद और बैअत का नवीनीकरण करता हूँ।',
      translationGu:
          'હે અલ્લાહ! મહાન નૂરના રબ, ઉચ્ચ અર્શના પરવરદિગાર, અને તૌરાત, ઇન્જીલ અને ઝબૂરને ઉતારનાર, અને મહાન કુરઆનને નાઝિલ કરનાર. ۝ હે અલ્લાહ! અમારા મૌલા અને માર્ગદર્શક ઇમામ મહદી (અ.સ) સુધી પૂર્વ અને પશ્ચિમના તમામ મોમિનો તરફથી સલામ પહોંચાડ. ۝ હે અલ્લાહ! હું આ સવારે અને મારા જીવનના દરેક દિવસે તેમના સાથે મારા અહદ અને બયઅતનું નવીનીકરણ કરું છું.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001001.mp3',
      tags: ['morning', 'fajr', 'imam mahdi', 'covenant', 'daily', '40 days'],
    ),

    // 2. Ziyarat Ale-Yasin
    const ContentModel(
      contentId: 'ziyarat_ale_yasin',
      type: 'ziyarat',
      title: 'Ziyarat Ale-Yasin',
      arabicText:
          'سَلَامٌ عَلَى آلِ يس، السَّلَامُ عَلَيْكَ يَا دَاعِيَ اللَّهِ وَرَبَّانِيَّ آيَاتِهِ، السَّلَامُ عَلَيْكَ يَا بَابَ اللَّهِ وَدَيَّانَ دِينِهِ، السَّلَامُ عَلَيْكَ يَا خَلِيفَةَ اللَّهِ وَنَاصِرَ حَقِّهِ، السَّلَامُ عَلَيْكَ يَا حُجَّةَ اللَّهِ وَدَلِيلَ إِرَادَتِهِ. ۝ السَّلَامُ عَلَيْكَ يَا تَالِيَ كِتَابِ اللَّهِ وَتَرْجُمَانَهُ، السَّلَامُ عَلَيْكَ فِي آنَاءِ لَيْلِكَ وَأَطْرَافِ نَهَارِكَ، السَّلَامُ عَلَيْكَ يَا بَقِيَّةَ اللَّهِ فِي أَرْضِهِ. ۝ أَشْهَدُ أَنَّكَ الْإِمَامُ الْمَهْدِيُّ قَوْلًا وَفِعْلًا، وَأَنَّ الْحَقَّ مَعَكُمْ وَفِيكُمْ، لَا أَمْرَ إِلَّا بِأَمْرِكُمْ.',
      translationEn:
          'Peace be upon the Family of Yasin! Peace be upon you, O caller to Allah and manifestor of His signs! Peace be upon you, O door to Allah and maintainer of His religion! Peace be upon you, O vicegerent of Allah and helper of His truth! Peace be upon you, O proof of Allah and indicator of His will! ۝ Peace be upon you, O reciter of Allah’s Book and its interpreter! Peace be upon you in the watches of your night and the ends of your day! Peace be upon you, O Remnant of Allah on His earth! ۝ I bear witness that you are indeed the Imam, the Mahdi, in word and deed, and that truth is with you and within you.',
      translationUr:
          'سلام ہو آلِ یٰسین پر! سلام ہو آپ پر اے اللہ کی طرف دعوت دینے والے اور اس کی نشانیوں کے عالم! سلام ہو آپ پر اے بابِ خدا اور دینِ خدا کے سرپرست! سلام ہو آپ پر اے خلیفۃ اللہ اور حق کے مددگار! ۝ سلام ہو آپ پر اے کتابِ خدا کی تلاوت فرمانے والے اور اس کی ترجمانی کرنے والے! سلام ہو آپ پر رات کی ساعتوں اور دن کے تمام حصوں میں! سلام ہو آپ پر اے زمین میں اللہ کی بقیہ نشانی! ۝ میں گواہی دیتا ہوں کہ آپ قول و فعل میں برحق امام مہدی ہیں اور حق آپ کے ساتھ ہے۔',
      translationHi:
          'सलाम हो आले यासीन पर! सलाम हो आप पर ऐ खुदा की तरफ बुलाने वाले और उसकी निशानियों के इल्म वाले! सलाम हो आप पर ऐ बाबे खुदा और दीन के मुहाफ़िज़! ۝ सलाम हो आप पर ऐ कलामुल्लाह की तिलावत फरमाने वाले! सलाम हो आप पर ऐ ज़मीन में बक़ीयतुल्लाह!',
      translationGu:
          'સલામ હો આલે યાસીન પર! આપ પર સલામ હો હે અલ્લાહ તરફ બોલાવનાર અને તેની નિશાનીઓના જ્ઞાતા! આપ પર સલામ હો હે બાબુલ્લાહ અને દીનના રક્ષક! ۝ આપ પર સલામ હો હે કુર્આનની તિલાવત કરનાર! આપ પર સલામ હો હે પૃથ્વી પર બકીયતુલ્લાહ!',
      audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/36.mp3',
      tags: ['ziyarat', 'imam mahdi', 'friday', 'presence', 'spiritual'],
    ),

    // 3. Ziyarat Ashura
    const ContentModel(
      contentId: 'ziyarat_ashura',
      type: 'ziyarat',
      title: 'Ziyarat Ashura',
      arabicText:
          'السَّلَامُ عَلَيْكَ يَا أَبَا عَبْدِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا ابْنَ رَسُولِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا خِيَرَةَ اللَّهِ وَابْنَ خِيَرَتِهِ، السَّلَامُ عَلَيْكَ يَا ابْنَ أَمِيرِ الْمُؤْمِنِينَ وَابْنَ سَيِّدِ الْوَصِيِّينَ، السَّلَامُ عَلَيْكَ يَا ابْنَ فَاطِمَةَ سَيِّدَةِ نِسَاءِ الْعَالَمِينَ. ۝ السَّلَامُ عَلَيْكَ يَا ثَارَ اللَّهِ وَابْنَ ثَارِهِ وَالْوِتْرَ الْمَوْتُورَ، السَّلَامُ عَلَيْكَ وَعَلَى الْأَرْوَاحِ الَّتِي حَلَّتْ بِفِنَائِكَ، عَلَيْكُمْ مِنِّي جَمِيعًا سَلَامُ اللَّهِ أَبَدًا مَا بَقِيتُ وَبَقِيَ اللَّيْلُ وَالنَّهَارُ. ۝ يَا أَبَا عَبْدِ اللَّهِ، لَقَدْ عَظُمَتِ الرَّزِيَّةُ وَجَلَّتْ وَعَظُمَتِ الْمُصِيبَةُ بِكَ عَلَيْنَا وَعَلَى جَمِيعِ أَهْلِ الْإِسْلَامِ. ۝ إِنِّي سِلْمٌ لِمَنْ سَالَمَكُمْ وَحَرْبٌ لِمَنْ حَارَبَكُمْ إِلَىٰ يَوْمِ الْقِيَامَةِ.',
      translationEn:
          'Peace be upon you, O Aba Abdillah! Peace be upon you, O son of the Messenger of Allah! Peace be upon you, O chosen one of Allah and son of His chosen one! Peace be upon you, O son of the Commander of the Faithful and master of successors! Peace be upon you, O son of Fatima, mistress of the women of the worlds! ۝ Peace be upon you, whose blood is avenged by Allah, and the son of him whose blood is avenged by Allah, and the unavenged lone soul! Peace be upon you and upon the souls that gathered around your domain. Upon you all from me is the peace of Allah forever, as long as I live and as long as the night and the day endure. ۝ O Aba Abdillah! Tremendous was the calamity and huge was the misfortune of your loss for us and for all the people of Islam. ۝ I am at peace with those who make peace with you, and at war with those who make war with you, until the Day of Resurrection.',
      translationUr:
          'سلام ہو آپ پر اے ابا عبداللہ! سلام ہو آپ پر اے رسول اللہ کے فرزند! سلام ہو آپ پر اے امیر المومنین اور اوصیاء کے سردار کے فرزند! سلام ہو آپ پر اے سیدۃ نساء العالمین بی بی فاطمہ زہرا (س) کے لختِ جگر! ۝ سلام ہو آپ پر اے اللہ کے خون اور اس کے خون کے فرزند! سلام ہو آپ پر اور ان پاکیزہ ارواح پر جو آپ کے قرب میں آ کر آرام فرما ہوئیں۔ آپ سب پر میری طرف سے ہمیشہ اللہ کا سلام ہو جب تک میں زندہ ہوں اور رات اور دن باقی ہیں۔ ۝ اے ابا عبداللہ! آپ کا غم بہت عظیم ہے اور آپ پر وارد ہونے والی مصیبت تمام اہلِ اسلام کے لیے انتہائی گراں اور دلدوز ہے۔ ۝ میں قیامت تک آپ سے صلح رکھنے والوں کے ساتھ صلح پر اور آپ سے برسرِ پیکار لوگوں سے برسرِ پیکار ہوں۔',
      translationHi:
          'सलाम हो आप पर ऐ अबा अब्दुल्लाह! सलाम हो आप पर ऐ रसूलुल्लाह के बेटे! सलाम हो आप पर ऐ अमीरुल मोमिनीन के फरज़न्द! सलाम हो आप पर ऐ सय्यदतुन्निसा बीबी फातिमा के प्यारे! ۝ मैं उस हर शख्स से सुलह रखता हूँ जो आपसे सुलह रखे, और उस हर शख्स से बरसर-ए-पैकार हूँ जो आपसे जंग करे कयामत के दिन तक।',
      translationGu:
          'સલામ હો આપ પર હે અબા અબ્દિલ્લાહ! સલામ હો આપ પર હે રસૂલુલ્લાહના પ્યારા પુત્ર! સલામ હો આપ પર હે અમીરૂલ મોમિનીનના પુત્ર! સલામ હો આપ પર હે જનાબે ફાતિમા ઝહરાના લખ્તે જિગર! ۝ કયામત સુધી હું તેની સાથે સુલેહ રાખું છું જે તમારી સાથે સુલેહ રાખે અને તેની સામે વિરોધ રાખું છું જે તમારો વિરોધ કરે.',
      audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/55.mp3',
      tags: ['ziyarat', 'karbala', 'imamhussain', 'muharram', 'arbaeen', 'daily'],
    ),

    // 4. Dua Kumayl
    const ContentModel(
      contentId: 'dua_kumayl',
      type: 'dua',
      title: 'Dua Kumayl',
      arabicText:
          'اَللَّهُمَّ إِنِّي أَسْأَلُكَ بِرَحْمَتِكَ الَّتِي وَسِعَتْ كُلَّ شَيْءٍ، وَبِقُوَّتِكَ الَّتِي قَهَرْتَ بِهَا كُلَّ شَيْءٍ، وَخَضَعَ لَهَا كُلُّ شَيْءٍ، وَذَلَّ لَهَا كُلُّ شَيْءٍ، وَبِجَبَرُوتِكَ الَّتِي غَلَبْتَ بِهَا كُلَّ شَيْءٍ، وَبِعِزَّتِكَ الَّتِي لَا يَقُومُ لَهَا شَيْءٌ. ۝ اَللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تَهْتِكُ الْعِصَمَ. اَللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تُنْزِلُ النِّقَمَ. اَللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تُغَيِّرُ النِّعَمَ. اَللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تَحْبِسُ الدُّعَاءَ. اَللَّهُمَّ اغْفِرْ لِيَ الذُّنُوبَ الَّتِي تُنْزِلُ الْبَلَاءَ. ۝ اَللَّهُمَّ إِنِّي أَتَقَرَّبُ إِلَيْكَ بِذِكْرِكَ، وَأَسْتَشْفِعُ بِكَ إِلَىٰ نَفْسِكَ، وَأَسْأَلُكَ بِجُودِكَ أَنْ تُدْنِيَنِي مِنْ قُرْبِكَ، وَأَنْ تُوزِعَنِي شُكْرَكَ، وَأَنْ تُلْهِمَنِي ذِكْرَكَ. ۝ يَا سَرِيعَ الرِّضَا، اغْفِرْ لِمَنْ لَا يَمْلِكُ إِلَّا الدُّعَاءَ، فَإِنَّكَ فَعَّالٌ لِمَا تَشَاءُ، يَا مَنِ اسْمُهُ دَوَاءٌ وَذِكْرُهُ شِفَاءٌ وَطَاعَتُهُ غِنًى!',
      translationEn:
          'O Allah, I beseech Thee by Thy mercy which encompasses all things, and by Thy power wherewith Thou overcomest all things, and to which all things submit, and by Thy might through which Thou hast humbled all things. ۝ O Allah, forgive me those sins which tear apart protective veils. O Allah, forgive me those sins which draw down tribulations. O Allah, forgive me those sins which alter blessings. O Allah, forgive me those sins which withhold supplication. O Allah, forgive me those sins which bring down misfortunes. ۝ O Allah, I draw near to Thee through remembrance of Thee, and seek intercession with Thee through Thyself, and beseech Thee by Thy munificence to bring me close to Thy presence, and grant me gratitude unto Thee, and inspire me with Thy remembrance. ۝ O He whose pleasure is quickly won, forgive him who owns nothing save prayer, for Thou doest what Thou wilt. O He whose Name is medicine, and whose remembrance is healing, and whose obedience is wealth!',
      translationUr:
          'اے اللہ! میں تجھ سے سوال کرتا ہوں تیری اس رحمت کے ذریعے جو ہر شے کا احاطہ کیے ہوئے ہے، اور تیری اس طاقت کے واسطے جس سے تو نے ہر چیز پر غلبہ پایا، اور جس کے آگے ہر چیز جھک گئی اور عاجز ہو گئی۔ ۝ اے اللہ! میرے ان گناہوں کو معاف فرما جو عصمت کے پردوں کو چاک کر دیتے ہیں، ان گناہوں کو معاف فرما جو مصیبتیں نازل کرتے ہیں، ان گناہوں کو معاف فرما جو نعمتوں کو بدل ڈالتے ہیں، ان گناہوں کو معاف فرما جو دعاؤں کو روک دیتے ہیں، اور ان گناہوں کو بخش دے جو بلائیں نازل کرتے ہیں۔ ۝ اے جلدی راضی ہونے والے! اسے بخش دے جس کے پاس دعا کے سوا کچھ بھی نہیں، تو جو چاہتا ہے کرتا ہے، اے وہ پاک ذات جس کا نام دوا ہے اور جس کا ذکر شفا ہے اور جس کی اطاعت تونگری ہے!',
      translationHi:
          'ऐ अल्लाह! मैं तुझसे सवाल करता हूँ तेरी उस रहमत के ज़रिये जो हर चीज़ पर छाई हुई है, और तेरी उस कुव्वत के वास्ते जिसके आगे हर चीज़ झुक गई। ۝ ऐ अल्लाह! मेरे उन गुनाहों को माफ़ फरमा जो परदों को चाक कर देते हैं, जो नेमतों को बदल देते हैं और जो दुआओं को रोक देते हैं। ۝ ऐ जल्द राज़ी होने वाले! उसे बख़्श दे जिसके पास दुआ के सिवा कुछ नहीं। ऐ वो ज़ात जिसका नाम दवा है और जिसका ज़िक्र शिफ़ा है!',
      translationGu:
          'હે અલ્લાહ! હું તારી એવી રહમત દ્વારા યાચના કરું છું જે તમામ બાબતો પર વ્યાપેલી છે, અને તારી તાકાત કે જેના આગળ દરેક વસ્તુ નમ્ર બને છે. ۝ હે અલ્લાહ! મારા એ ગુનાહો માફ કર જે મુસીબતો લાવે છે અને દુઆઓને અટકાવે છે. ۝ હે ત્વરિત રાજી થનાર! તેને ક્ષમા કર જેની પાસે દુઆ સિવાય કશું નથી, હે તે જેનું નામ દવા છે અને જેનું સ્મરણ શિફા છે!',
      audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/67.mp3',
      tags: ['thursday', 'forgiveness', 'maghrib', 'imam ali', 'weekly'],
    ),

    // 5. Dua-e-Tawassul
    const ContentModel(
      contentId: 'dua_tawassul',
      type: 'dua',
      title: 'Dua-e-Tawassul',
      arabicText:
          'اَللَّهُمَّ إِنِّي أَسْأَلُكَ وَأَتَوَجَّهُ إِلَيْكَ بِنَبِيِّكَ نَبِيِّ الرَّحْمَةِ مُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَآلِهِ، يَا أَبَا الْقَاسِمِ، يَا رَسُولَ اللَّهِ، يَا إِمَامَ الرَّحْمَةِ، يَا سَيِّدَنَا وَمَوْلَانَا، إِنَّا تَوَجَّهْنَا وَاسْتَشْفَعْنَا وَتَوَسَّلْنَا بِكَ إِلَى اللَّهِ وَقَدَّمْنَاكَ بَيْنَ يَدَيْ حَاجَاتِنَا، يَا وَجِيهًا عِنْدَ اللَّهِ اشْفَعْ لَنَا عِنْدَ اللَّهِ. ۝ يَا أَبَا الْحَسَنِ، يَا أَمِيرَ الْمُؤْمِنِينَ، يَا عَلِيَّ بْنَ أَبِي طَالِبٍ، يَا حُجَّةَ اللَّهِ عَلَى خَلْقِهِ، يَا سَيِّدَنَا وَمَوْلَانَا، إِنَّا تَوَجَّهْنَا وَاسْتَشْفَعْنَا وَتَوَسَّلْنَا بِكَ إِلَى اللَّهِ، يَا وَجِيهًا عِنْدَ اللَّهِ اشْفَعْ لَنَا عِنْدَ اللَّهِ. ۝ يَا فَاطِمَةُ الزَّهْرَاءُ، يَا بِنْتَ مُحَمَّدٍ، يَا قُرَّةَ عَيْنِ الرَّسُولِ، يَا سَيِّدَتَنَا وَمَوْلَاتَنَا، إِنَّا تَوَجَّهْنَا وَاسْتَشْفَعْنَا وَتَوَسَّلْنَا بِكِ إِلَى اللَّهِ، يَا وَجِيهَةً عِنْدَ اللَّهِ اشْفَعِي لَنَا عِنْدَ اللَّهِ.',
      translationEn:
          'O Allah, I beseech Thee and turn towards Thee through Thy Prophet, the Prophet of Mercy, Muhammad (peace and blessings of Allah be upon him and his progeny). O Abul-Qasim, O Messenger of Allah, O Guide of Mercy, O our master and leader! We turn towards you and seek your intercession before Allah, and present you before our needs. O eminent one in the sight of Allah, intercede for us with Allah! ۝ O Abul-Hasan, O Commander of the Faithful, O Ali ibn Abi Talib, O Proof of Allah over His creation, our master and leader! We seek your intercession before Allah, intercede for us with Allah! ۝ O Fatima Zahra, O daughter of Muhammad, O delight of the Messenger\'s eyes, our mistress and leader! Intercede for us with Allah!',
      translationUr:
          'اے اللہ! میں تجھ سے سوال کرتا ہوں اور تیری بارگاہ میں متوجہ ہوتا ہوں تیرے نبیِ رحمت حضرت محمد مصطفیٰ (ص) کے واسطے سے۔ اے ابوالقاسم! اے اللہ کے رسول! اے رحمت کے پیشوا! ہم نے آپ کے وسیلے سے اللہ کی بارگاہ میں التجا کی اور شفاعت طلب کی اور آپ کو اپنی حاجات کے آگے پیش کیا۔ اے اللہ کے نزدیک باعزت و باوجاہت! اللہ کے حضور ہماری شفاعت فرمائیں! ۝ اے ابوالحسن! اے امیر المومنین علی بن ابی طالب! اے بندگانِ خدا پر اللہ کی حجت! اے اللہ کی بارگاہ میں عزت والے، اللہ کے حضور ہماری شفاعت فرمائیں! ۝ اے فاطمہ زہرا، اے دخترِ رسول، اے رسول کی آنکھوں کی ٹھنڈک، اللہ کے حضور ہماری شفاعت فرمائیں!',
      translationHi:
          'ऐ अल्लाह! मैं तुझसे सवाल करता हूँ और तेरी तरफ रुजू करता हूँ तेरे नबी-ए-रहमत हज़रत मुहम्मद (स.अ.व) के वास्ते से। ऐ रसूलुल्लाह! ऐ रहमत के इमाम! हम आपके वसीले से अल्लाह की बारगाह में शफ़ाअत के तलबगार हैं। ۝ ऐ अमीरुल मोमिनीन अली इब्ने अबी तालिब! अल्लाह के हुज़ूर हमारी शफ़ाअत फरमाइए! ۝ ऐ फातिमा ज़हरा, ऐ रसूल की प्यारी बेटी, अल्लाह के हुज़ूर हमारी शफ़ाअत फरमाइए!',
      translationGu:
          'હે અલ્લાહ! હું તારી પાસે યાચના કરું છું તારા નબીએ રહમત હઝરત મુહમ્મદ (સ.અ.વ) ના વસીલાથી. હે રસૂલુલ્લાહ! હે રહમતના ઇમામ! અમે તમારા વસીલાથી અલ્લાહની દરબારમાં શફાઅત ઇચ્છીએ છીએ. ۝ હે અમીરૂલ મોમિનીન અલી ઇબ્ને અબી તાલિબ! અલ્લાહની હજૂર અમારી શફાઅત કરો! ۝ હે ફાતિમા ઝહરા, અલ્લાહની હજૂર અમારી શફાઅત કરો!',
      audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/56.mp3',
      tags: ['intercession', 'tuesday', 'ahlulbayt', 'supplication'],
    ),

    // 6. Dua-e-Faraj
    const ContentModel(
      contentId: 'dua_faraj',
      type: 'dua',
      title: 'Dua-e-Faraj (Salamati Imam-e-Zamana)',
      arabicText:
          'اَللَّهُمَّ كُنْ لِوَلِيِّكَ الْحُجَّةِ بْنِ الْحَسَنِ، صَلَوَاتُكَ عَلَيْهِ وَعَلَى آبَائِهِ، فِي هَٰذِهِ السَّاعَةِ وَفِي كُلِّ سَاعَةٍ، وَلِيًّا وَحَافِظًا، وَقَائِدًا وَنَاصِرًا، وَدَلِيلًا وَعَيْنًا، حَتَّىٰ تُسْكِنَهُ أَرْضَكَ طَوْعًا، وَتُمَتِّعَهُ فِيهَا طَوِيلًا، بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ.',
      translationEn:
          'O Allah! Be for Thy representative, the Proof, son of al-Hasan (Thy blessings be upon him and upon his forefathers), in this hour and in every hour, a guardian, a protector, a leader, a helper, a guide, and an eye, until Thou causest him to dwell in Thy earth in peace, and grantest him long enjoyment therein, by Thy mercy, O most Merciful of the merciful!',
      translationUr:
          'اے معبود! اپنے ولی اور حجت، حضرت حسن عسکری کے فرزند (جن پر اور ان کے آباء پر تیرا درود و سلام ہو) کے لیے اس گھڑی اور ہر گھڑی میں سرپرست، نگہبان، پیشوا، مددگار، رہنما اور نگراں بن جا، یہاں تک کہ تو انہیں اپنی زمین پر امن و سلامتی کے ساتھ حاکم بنا دے اور ایک طویل مدت تک انہیں اس میں متمتع فرما، تیری رحمت کے واسطے اے سب سے زیادہ رحم کرنے والے!',
      translationHi:
          'ऐ अल्लाह! अपने वली और हुज्जत, हज़रत हसन अस्करी के बेटे (जिन पर और उनके पुरखों पर तेरा दरूद हो) के लिए इस घड़ी और हर घड़ी में सरपरस्त, निगहबान, रहबर और मददगार बन जा, यहाँ तक कि तू उन्हें अपनी ज़मीन पर अमन के साथ बसा दे और लंबे समय तक हुकूमत अता फरमा।',
      translationGu:
          'હે અલ્લાહ! તારા વલી અને હુજ્જત, હઝરત હસન અસ્કરીના પુત્ર માટે આ ઘડીએ અને દરેક ઘડીએ રક્ષક, માર્ગદર્શક અને મદદગાર બન, જ્યાં સુધી તું તેમને શાંતિપૂર્વક પૃથ્વી પર રાજ્ય ન સોંપે અને લાંબા સમય સુધી આશીર્વાદ ન આપે.',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001001.mp3',
      tags: ['imam mahdi', 'daily', 'qunut', 'protection', 'faraj'],
    ),

    // 7. Ziyarat Waritha
    const ContentModel(
      contentId: 'ziyarat_waritha',
      type: 'ziyarat',
      title: 'Ziyarat Waritha',
      arabicText:
          'السَّلَامُ عَلَيْكَ يَا وَارِثَ آدَمَ صَفْوَةِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا وَارِثَ نُوحٍ نَبِيِّ اللَّهِ، السَّلَامُ عَلَيْكَ يَا وَارِثَ إِبْرَاهِيمَ خَلِيلِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا وَارِثَ مُوسَىٰ كَلِيمِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا وَارِثَ عِيسَىٰ رُوحِ اللَّهِ، السَّلَامُ عَلَيْكَ يَا وَارِثَ مُحَمَّدٍ حَبِيبِ اللَّهِ. ۝ السَّلَامُ عَلَيْكَ يَا وَارِثَ أَمِيرِ الْمُؤْمِنِينَ عَلَيْهِ السَّلَامُ، السَّلَامُ عَلَيْكَ يَا ابْنَ مُحَمَّدٍ الْمُصْطَفَىٰ، السَّلَامُ عَلَيْكَ يَا ابْنَ عَلِيٍّ الْمُرْتَضَىٰ، السَّلَامُ عَلَيْكَ يَا ابْنَ فَاطِمَةَ الزَّهْرَاءِ. ۝ أَشْهَدُ أَنَّكَ قَدْ أَقَمْتَ الصَّلَاةَ، وَآتَيْتَ الزَّكَاةَ، وَأَمَرْتَ بِالْمَعْرُوفِ، وَنَهَيْتَ عَنِ الْمُنْكَرِ، وَأَطَعْتَ اللَّهَ وَرَسُولَهُ حَتَّىٰ أَتَاكَ الْيَقِينُ.',
      translationEn:
          'Peace be upon you, O inheritor of Adam, the chosen one of Allah! Peace be upon you, O inheritor of Nuh, the Prophet of Allah! Peace be upon you, O inheritor of Ibrahim, the intimate friend of Allah! Peace be upon you, O inheritor of Musa, who spoke to Allah! Peace be upon you, O inheritor of Isa, the spirit of Allah! Peace be upon you, O inheritor of Muhammad, the beloved of Allah! ۝ Peace be upon you, O inheritor of the Commander of the Faithful! Peace be upon you, O son of Muhammad al-Mustafa! Peace be upon you, O son of Ali al-Murtadha! Peace be upon you, O son of Fatima al-Zahra! ۝ I bear witness that you established prayer, gave zakat, commanded what is right, forbade what is wrong, and obeyed Allah and His Messenger until certainty came unto you.',
      translationUr:
          'سلام ہو آپ پر اے آدم (ع) کے وارث جو اللہ کے برگزیدہ بندے ہیں! سلام ہو آپ پر اے نوح (ع) کے وارث! سلام ہو آپ پر اے ابراہیم (ع) خلیل اللہ کے وارث! سلام ہو آپ پر اے موسیٰ (ع) کلیم اللہ کے وارث! سلام ہو آپ پر اے عیسیٰ (ع) روح اللہ کے وارث! سلام ہو آپ پر اے حبیبِ خدا حضرت محمد مصطفیٰ (ص) کے وارث! ۝ سلام ہو آپ پر اے امیر المومنین کے وارث! سلام ہو آپ پر اے فرزندِ علی مرتضیٰ اور فرزندِ فاطمہ زہرا! ۝ میں گواہی دیتا ہوں کہ آپ نے نماز قائم کی، زکوٰۃ ادا کی، نیکی کا حکم دیا اور برائی سے روکا، اور اپنی شہادت تک اللہ اور اس کے رسول کی اطاعت کی۔',
      translationHi:
          'सलाम हो आप पर ऐ आदम (अ.स) के वारिस जो अल्लाह के चुने हुए हैं! सलाम हो आप पर ऐ नूह (अ.स) के वारिस! सलाम हो आप पर ऐ इब्राहिम (अ.स) के वारिस! सलाम हो आप पर ऐ रसूलुल्लाह और अमीरुल मोमिनीन के वारिस! ۝ मैं गवाही देता हूँ कि आपने नमाज़ कायम की, अम्र बिल मारूफ किया और खुदा की राह में शहादत पाई।',
      translationGu:
          'સલામ હો આપ પર હે આદમ (અ.સ) ના વારસ! સલામ હો આપ પર હે નૂહ (અ.સ) ના વારસ! સલામ હો આપ પર હે ઇબ્રાહીમ (અ.સ) ના વારસ! સલામ હો આપ પર હે અમીરૂલ મોમિનીન અને ફાતિમા ઝહરાના વારસ! ۝ હું સાક્ષી આપું છું કે આપે નમાઝ કાયમ કરી અને શહાદત પ્રાપ્ત કરી.',
      audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/62.mp3',
      tags: ['ziyarat', 'prophets', 'karbala', 'legacy', 'imamhussain'],
    ),

    // 8. Surah Al-Fatiha (The Opening)
    const ContentModel(
      contentId: 'surah_fatiha',
      type: 'surah',
      title: 'Surah Al-Fatiha',
      arabicText:
          'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ ۝١ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝٢ الرَّحْمَٰنِ الرَّحِيمِ ۝٣ مَالِكِ يَوْمِ الدِّينِ ۝٤ إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ ۝٥ اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ ۝٦ صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ ۝٧',
      translationEn:
          'In the Name of Allah, the All-beneficent, the All-merciful. ۝1 All praise belongs to Allah, Lord of all the worlds, ۝2 the All-beneficent, the All-merciful, ۝3 Master of the Day of Retribution. ۝4 You alone we worship, and to You alone we turn for help. ۝5 Guide us on the straight path, ۝6 the path of those whom You have blessed, not of those with whom You are angry, nor of those who go astray. ۝7',
      translationUr:
          'اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے۔ ۝۱ سب تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا پالنے والا ہے۔ ۝۲ بڑا مہربان نہایت رحم فرمانے والا ہے۔ ۝۳ روزِ جزا کا مالک ہے۔ ۝۴ ہم تیری ہی عبادت کرتے ہیں اور تجھ ہی سے مدد مانگتے ہیں۔ ۝۵ ہمیں سیدھے راستے کی ہدایت فرما، ۝۶ ان لوگوں کا راستہ جن پر تو نے انعام فرمایا، نہ ان کا راستہ جن پر غضب نازل ہوا اور نہ گمراہوں کا۔ ۝۷',
      translationHi:
          'अल्लाह के नाम से जो निहायत मेहरबान और रहम वाला है। ۝१ सब तारीफें अल्लाह के लिए हैं जो तमाम जहानों का पालने वाला है। ۝२ निहायत मेहरबान, रहम वाला, ۝३ रोज़-ए-जज़ा का मालिक। ۝४ हम तेरी ही इबादत करते हैं और तुझ ही से मदद चाहते हैं। ۝५ हमें सीधे रास्ते की हिदायत फरमा, ۝६ उन लोगों का रास्ता जिन पर तूने इनआम फरमाया, न उनका जिन पर ग़ज़ब हुआ और न गुमराहों का। ۝७',
      translationGu:
          'અલ્લાહના નામથી જે અત્યંત કૃપાળુ અને દયાળુ છે. ۝૧ તમામ પ્રશંસા અલ્લાહ માટે છે જે સમગ્ર વિશ્વનો પાલનહાર છે. ۝૨ પરમ કૃપાળુ, દયાળુ, ۝૩ ન્યાયના દિવસનો માલિક. ۝૪ અમે તારી જ ઇબાદત કરીએ છીએ અને તારી જ મદદ માંગીએ છીએ. ۝૫ અમને સીધા માર્ગ પર ચલાવ, ۝૬ એ લોકોના માર્ગ પર જેના પર તેં કૃપા કરી છે, નહિ કે જેમના પર કોપ થયો અથવા જે ભટકી ગયા. ۝૭',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/001001.mp3',
      tags: ['quran', 'daily', 'prayer', 'surah', 'opening'],
    ),

    // 9. Surah Yasin (Heart of Quran)
    const ContentModel(
      contentId: 'surah_yasin',
      type: 'surah',
      title: 'Surah Yasin',
      arabicText:
          'يس ۝١ وَالْقُرْآنِ الْحَكِيمِ ۝٢ إِنَّكَ لَمِنَ الْمُرْسَلِينَ ۝٣ عَلَىٰ صِرَاطٍ مُسْتَقِيمٍ ۝٤ تَنْزِيلَ الْعَزِيزِ الرَّحِيمِ ۝٥ لِتُنْذِرَ قَوْمًا مَا أُنْذِرَ آبَاؤُهُمْ فَهُمْ غَافِلُونَ ۝٦ لَقَدْ حَقَّ الْقَوْلُ عَلَىٰ أَكْثَرِهِمْ فَهُمْ لَا يُؤْمِنُونَ ۝٧ إِنَّا جَعَلْنَا فِي أَعْنَاقِهِمْ أَغْلَالًا فَهِيَ إِلَى الْأَذْقَانِ فَهُمْ مُقْمَحُونَ ۝٨ وَجَعَلْنَا مِنْ بَيْنِ أَيْدِيهِمْ سَدًّا وَمِنْ خَلْفِهِمْ سَدًّا فَأَغْشَيْنَاهُمْ فَهُمْ لَا يُبْصِرُونَ ۝٩',
      translationEn:
          'Ya-Seen. ۝1 By the wise Quran, ۝2 indeed you are from among the messengers, ۝3 on a straight path. ۝4 A revelation of the Exalted in Might, the Merciful, ۝5 that you may warn a people whose forefathers were not warned, so they are unaware. ۝6 The decree has already proved true against most of them, so they do not believe. ۝7 Indeed, We have put shackles on their necks up to their chins, so their heads are forced back. ۝8 And We have placed a barrier before them and a barrier behind them and covered them so they cannot see. ۝9',
      translationUr:
          'یاسین۔ ۝۱ حکمت سے بھرپور قرآن کی قسم! ۝۲ بے شک آپ رسولوں میں سے ہیں۔ ۝۳ سیدھے راستے پر ہیں۔ ۝۴ یہ غالب اور مہربان خدا کی طرف سے نازل کیا ہوا ہے۔ ۝۵ تاکہ آپ اس قوم کو ڈرائیں جس کے باپ دادا کو نہیں ڈرایا گیا تھا تو وہ غفلت میں پڑے ہیں۔ ۝۶ یقیناً ان میں سے اکثر پر بات ثابت ہو چکی ہے سو وہ ایمان نہیں لائیں گے۔ ۝۷ ہم نے ان کی گردنوں میں طوق ڈال دیے ہیں جو ٹھوڑیوں تک ہیں جس سے ان کے سر اوپر اٹھے ہوئے ہیں۔ ۝۸ اور ہم نے ایک دیوار ان کے آگے اور ایک دیوار ان کے پیچھے بنا دی پھر انہیں ڈھانپ دیا سو وہ کچھ نہیں دیکھتے۔ ۝۹',
      translationHi:
          'या-सीन। ۝१ हिकमत वाले कुरआन की कसम! ۝२ बेशक आप रसूलों में से हैं, ۝३ सीधे रास्ते पर हैं। ۝४ यह ज़बरदस्त और रहम वाले का उतारा हुआ है। ۝५ ताकि आप उस कौम को आगाह करें जिसके बाप-दादा को आगाह नहीं किया गया था। ۝६ और हमने उनके आगे एक दीवार बना दी और उनके पीछे एक दीवार और उन्हें ढांक दिया सो वे देखते नहीं। ۝९',
      translationGu:
          'યા-સીન. ۝૧ હિકમતથી ભરેલા કુર્આનની કસમ! ۝૨ બેશક આપ રસૂલોમાંથી છો, ۝૩ સીધા માર્ગ પર. ۝૪ આ શક્તિશાળી અને દયાળુ પરવરદિગાર તરફથી નાઝિલ થયેલ છે. ۝૫ જેથી આપ તે પ્રજાને સાવચેત કરો જેમના પૂર્વજો અજાણ હતા. ۝૮ અને અમે તેમના આગળ અને પાછળ દીવાલ બનાવી તેમને ઢાંકી દીધા જેથી તેઓ જોઈ શકતા નથી. ۝૯',
      audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/36.mp3',
      tags: ['quran', 'heart of quran', 'surah', 'jummah'],
    ),

    // 10. Surah Al-Mulk (The Sovereignty)
    const ContentModel(
      contentId: 'surah_mulk',
      type: 'surah',
      title: 'Surah Al-Mulk',
      arabicText:
          'تَبَارَكَ الَّذِي بِيَدِهِ الْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ ۝١ الَّذِي خَلَقَ الْمَوْتَ وَالْحَيَاةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًا ۚ وَهُوَ الْعَزِيزُ الْغَفُورُ ۝٢ الَّذِي خَلَقَ سَبْعَ سَمَاوَاتٍ طِبَاقًا ۖ مَا تَرَىٰ فِي خَلْقِ الرَّحْمَٰنِ مِنْ تَفَاوُتٍ ۖ فَارْجِعِ الْبَصَرَ هَلْ تَرَىٰ مِنْ فُطُورٍ ۝٣',
      translationEn:
          'Blessed is He in whose hand is the dominion, and He is over all things competent. ۝1 He who created death and life to test you as to which of you is best in deed — and He is the Exalted in Might, the Forgiving. ۝2 He who created seven heavens in layers. You see no inconsistency in the creation of the Most Merciful. So return your vision to the sky: do you see any breaks? ۝3',
      translationUr:
          'بڑی برکت والی ہے وہ ذات جس کے ہاتھ میں ساری بادشاہی ہے اور وہ ہر چیز پر قادر ہے۔ ۝۱ جس نے موت اور زندگی کو پیدا کیا تاکہ تمہیں آزمائے کہ تم میں سے عمل کے اعتبار سے کون بہتر ہے، اور وہ زبردست بخشنے والا ہے۔ ۝۲ جس نے سات آسمان اوپر تلے بنائے، تم رحمن کی آفرینش میں کوئی خلل اور نقص نہ دیکھو گے، نگاہ دوڑا کر دیکھو کیا تمہیں کوئی شگاف نظر آتا ہے؟ ۝۳',
      translationHi:
          'निहायत बरकत वाली है वह ज़ात जिसके हाथ में सारी हुकूमत है और वह हर चीज़ पर कादिर है। ۝१ जिसने मौत और ज़िन्दगी को पैदा किया ताकि तुम्हें आज़माए कि तुममें से किसका अमल सबसे बेहतर है। ۝२',
      translationGu:
          'અતિ બરકતવાળી છે તે હસ્તી જેના હાથમાં તમામ હુકૂમત છે અને તે દરેક બાબત પર સમર્થ છે. ۝૧ જેણે મૃત્યુ અને જીવનનું સર્જન કર્યું જેથી તમારી કસોટી કરે કે તમારામાંથી કોના કર્મ ઉત્તમ છે. ۝૨',
      audioUrl: 'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/67.mp3',
      tags: ['quran', 'night', 'grave', 'surah', 'protection'],
    ),

    // 11. Surah Al-Ikhlas (The Sincerity / Tawheed)
    const ContentModel(
      contentId: 'surah_ikhlas',
      type: 'surah',
      title: 'Surah Al-Ikhlas',
      arabicText:
          'قُلْ هُوَ اللَّهُ أَحَدٌ ۝١ اللَّهُ الصَّمَدُ ۝٢ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝٣ وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ ۝٤',
      translationEn:
          'Say: He is Allah, the One! ۝1 Allah, the Eternal Refuge! ۝2 He neither begets nor is born, ۝3 nor is there to Him any equivalent. ۝4',
      translationUr:
          'کہہ دیجیے کہ وہ اللہ ایک ہے! ۝۱ اللہ بے نیاز ہے! ۝۲ نہ اس نے کسی کو جنا اور نہ وہ جنا گیا! ۝۳ اور نہ کوئی اس کا ہمسر و برابر ہے! ۝۴',
      translationHi:
          'कह दीजिए कि वह अल्लाह एक है! ۝१ अल्लाह बेनियाज़ है! ۝२ न उसने किसी को जन्मा और न वह जना गया! ۝३ और न कोई उसके बराबर का है! ۝४',
      translationGu:
          'કહો: તે અલ્લાહ એક છે! ۝૧ અલ્લાહ બેનિયાઝ (સ્વયંપૂર્ણ) છે! ۝૨ ન તેણે કોઈને જન્મ આપ્યો છે કે ન તે જન્મ્યો છે! ۝૩ અને કોઈ તેના બરાબર નથી! ۝૪',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/112001.mp3',
      tags: ['quran', 'tawheed', 'daily', 'prayer', 'short'],
    ),

    // 12. Surah Al-Falaq
    const ContentModel(
      contentId: 'surah_falaq',
      type: 'surah',
      title: 'Surah Al-Falaq',
      arabicText:
          'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝١ مِنْ شَرِّ مَا خَلَقَ ۝٢ وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝٣ وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝٤ وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ ۝٥',
      translationEn:
          'Say: I seek refuge in the Lord of daybreak ۝1 from the evil of that which He created, ۝2 and from the evil of darkness when it settles, ۝3 and from the evil of the blowers in knots, ۝4 and from the evil of an envier when he envies. ۝5',
      translationUr:
          'کہہ دیجیے کہ میں صبح کے رب کی پناہ مانگتا ہوں۔ ۝۱ ہر اس چیز کے شر سے جو اس نے پیدا کی۔ ۝۲ اور اندھیری رات کے شر سے جب وہ چھا جائے۔ ۝۳ اور گرہوں میں پھونکنے والوں کے شر سے۔ ۝۴ اور حسد کرنے والے کے شر سے جب وہ حسد کرے۔ ۝۵',
      translationHi:
          'कह दीजिए: मैं सुबह के रब की पनाह मांगता हूँ ۝१ हर उस चीज़ के शर से जो उसने बनाई, ۝२ और अंधेरी रात के शर से जब वह छा जाए, ۝३ और गांठों में फूंकने वालों के शर से, ۝४ और हसद करने वाले के शर से जब वह हसद करे। ۝५',
      translationGu:
          'કહો: હું પરોઢના પાલનહારનું શરણું લઉં છું ۝૧ તેની બનાવેલી દરેક વસ્તુની અનિષ્ટતાથી, ۝૨ અને રાતના અંધકારની અનિષ્ટતાથી જ્યારે તે છવાઈ જાય, ۝૩ અને ઈર્ષા કરનારની અનિષ્ટતાથી જ્યારે તે ઈર્ષા કરે. ۝૫',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/113001.mp3',
      tags: ['quran', 'protection', 'daily', 'muawwidhatayn'],
    ),

    // 13. Surah An-Nas
    const ContentModel(
      contentId: 'surah_nas',
      type: 'surah',
      title: 'Surah An-Nas',
      arabicText:
          'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝١ مَلِكِ النَّاسِ ۝٢ إِلَٰهِ النَّاسِ ۝٣ مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝٤ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝٥ مِنَ الْجِنَّةِ وَالنَّاسِ ۝٦',
      translationEn:
          'Say: I seek refuge in the Lord of mankind, ۝1 the Sovereign of mankind, ۝2 the God of mankind, ۝3 from the evil of the retreating whisperer — ۝4 who whispers into the breasts of mankind — ۝5 from among the jinn and mankind. ۝6',
      translationUr:
          'کہہ دیجیے کہ میں تمام انسانوں کے پروردگار کی پناہ مانگتا ہوں، ۝۱ تمام انسانوں کے بادشاہ کی، ۝۲ تمام انسانوں کے معبود کی، ۝۳ وسوسہ ڈالنے والے پیچھے ہٹ جانے والے کے شر سے، ۝۴ جو انسانوں کے سینوں میں وسوسے ڈالتا ہے، ۝۵ خواہ وہ جنات میں سے ہو یا انسانوں میں سے۔ ۝۶',
      translationHi:
          'कह दीजिए: मैं तमाम इंसानों के रब की पनाह मांगता हूँ, ۝१ इंसानों के बादशाह की, ۝२ इंसानों के माबूद की, ۝३ उस वसवसा डालने वाले के शर से जो पीछे हट जाता है, ۝४ जो लोगों के सीनों में वसवसे डालता है, ۝५ जिन्नों में से हो या इंसानों में से। ۝६',
      translationGu:
          'કહો: હું માનવજાતના રબનું શરણું લઉં છું, ۝૧ માનવોના બાદશાહની, ۝૨ માનવોના ઈશ્વરની, ۝૩ છુપાઈને વસવસા નાખનાર શેતાનની બુરાઈથી, ۝૪ જે લોકોના હૃદયમાં વસવસા નાખે છે, ۝૫ જીન્નાતોમાંથી કે માનવોમાંથી. ۝૬',
      audioUrl: 'https://everyayah.com/data/Alafasy_128kbps/114001.mp3',
      tags: ['quran', 'protection', 'daily', 'muawwidhatayn'],
    ),
  ];

  /// Clean pre-built goal templates with 0 initial streak and 0 progress (Section 3.3, C.5, C.6)
  static List<GoalModel> getInitialGoalTemplates(String userId) {
    return [
      GoalModel(
        goalId: 'template_mahdi_servant',
        userId: userId,
        title: 'Imam Mahdi\'s Servant',
        description: 'A quiet daily practice for presence and covenant renewal',
        items: const ['dua_ahad', 'ziyarat_ale_yasin'],
        streakCount: 0,
        progressToday: 0.0,
        createdVia: 'template',
        createdAt: DateTime.now(),
      ),
      GoalModel(
        goalId: 'template_40_days_ahad',
        userId: userId,
        title: '40 Days of Dua-e-Ahad',
        description: 'Begin the morning with intention to join the companions',
        items: const ['dua_ahad'],
        streakCount: 0,
        progressToday: 0.0,
        createdVia: 'template',
        createdAt: DateTime.now(),
      ),
      GoalModel(
        goalId: 'template_arbaeen_journey',
        userId: userId,
        title: 'Arbaeen Journey',
        description: 'Ziyarat, reflection, and remembrance of Karbala',
        items: const ['ziyarat_ashura', 'ziyarat_waritha'],
        streakCount: 0,
        progressToday: 0.0,
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
