import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('ur'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Muntazir'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Muntazir'**
  String get welcomeMessage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @offlineNotice.
  ///
  /// In en, this message translates to:
  /// **'You are currently offline. Cached content is available.'**
  String get offlineNotice;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navStreaks.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get navStreaks;

  /// No description provided for @navAsk.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get navAsk;

  /// No description provided for @navRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get navRead;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// No description provided for @greetingSalam.
  ///
  /// In en, this message translates to:
  /// **'Salamun Alaykum'**
  String get greetingSalam;

  /// No description provided for @dailyNiyyah.
  ///
  /// In en, this message translates to:
  /// **'YOUR DAILY NIYYAH'**
  String get dailyNiyyah;

  /// No description provided for @yourWeek.
  ///
  /// In en, this message translates to:
  /// **'Your week'**
  String get yourWeek;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get dayStreak;

  /// No description provided for @yourPractices.
  ///
  /// In en, this message translates to:
  /// **'Your practices'**
  String get yourPractices;

  /// No description provided for @newPractice.
  ///
  /// In en, this message translates to:
  /// **'New practice'**
  String get newPractice;

  /// No description provided for @recitationOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Recitation of the Day'**
  String get recitationOfTheDay;

  /// No description provided for @hadithOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Hadith of the Day'**
  String get hadithOfTheDay;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No favorites added yet. Tap the star icon on any Dua or Surah to add it here.'**
  String get noFavoritesYet;

  /// No description provided for @activeSpiritualPractices.
  ///
  /// In en, this message translates to:
  /// **'Active Spiritual Practices'**
  String get activeSpiritualPractices;

  /// No description provided for @askAiTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get askAiTitle;

  /// No description provided for @aiChatTab.
  ///
  /// In en, this message translates to:
  /// **'Muntazir AI'**
  String get aiChatTab;

  /// No description provided for @askScholarTab.
  ///
  /// In en, this message translates to:
  /// **'Ask a Scholar'**
  String get askScholarTab;

  /// No description provided for @askPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Ask a question regarding Shia fiqh, duas, or hadith...'**
  String get askPlaceholder;

  /// No description provided for @religiousDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Informational only. Please confirm with your Marja\'s office for binding fatwas.'**
  String get religiousDisclaimer;

  /// No description provided for @translationLanguage.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get translationLanguage;

  /// No description provided for @inlineTranslation.
  ///
  /// In en, this message translates to:
  /// **'Inline Translation'**
  String get inlineTranslation;

  /// No description provided for @standardView.
  ///
  /// In en, this message translates to:
  /// **'Standard View'**
  String get standardView;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
  String get fontSize;

  /// No description provided for @markAsRecited.
  ///
  /// In en, this message translates to:
  /// **'Mark as Recited'**
  String get markAsRecited;

  /// No description provided for @recitedToday.
  ///
  /// In en, this message translates to:
  /// **'Recited Today'**
  String get recitedToday;

  /// No description provided for @resumeReading.
  ///
  /// In en, this message translates to:
  /// **'Resume Reading'**
  String get resumeReading;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @audioPlaying.
  ///
  /// In en, this message translates to:
  /// **'Playing audio'**
  String get audioPlaying;

  /// No description provided for @audioPaused.
  ///
  /// In en, this message translates to:
  /// **'Audio paused'**
  String get audioPaused;

  /// No description provided for @weeklyStreak.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY STREAK'**
  String get weeklyStreak;

  /// No description provided for @removeGoal.
  ///
  /// In en, this message translates to:
  /// **'Remove Practice'**
  String get removeGoal;

  /// No description provided for @removeGoalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this practice from your active goals?'**
  String get removeGoalConfirm;

  /// No description provided for @addPractice.
  ///
  /// In en, this message translates to:
  /// **'Add Practice'**
  String get addPractice;

  /// No description provided for @templateMahdiServant.
  ///
  /// In en, this message translates to:
  /// **'Imam Mahdi\'s Servant'**
  String get templateMahdiServant;

  /// No description provided for @templateMahdiServantDesc.
  ///
  /// In en, this message translates to:
  /// **'A quiet daily practice for presence and covenant renewal'**
  String get templateMahdiServantDesc;

  /// No description provided for @ibadahToolkit.
  ///
  /// In en, this message translates to:
  /// **'Ibadah Toolkit'**
  String get ibadahToolkit;

  /// No description provided for @qiblaFinder.
  ///
  /// In en, this message translates to:
  /// **'Qibla Finder'**
  String get qiblaFinder;

  /// No description provided for @islamicCalendar.
  ///
  /// In en, this message translates to:
  /// **'Islamic Calendar'**
  String get islamicCalendar;

  /// No description provided for @tasbeehCounter.
  ///
  /// In en, this message translates to:
  /// **'Tasbeeh Counter'**
  String get tasbeehCounter;

  /// No description provided for @namazTimings.
  ///
  /// In en, this message translates to:
  /// **'Namaz Timing'**
  String get namazTimings;

  /// No description provided for @khumsCalculator.
  ///
  /// In en, this message translates to:
  /// **'Khums Calculator'**
  String get khumsCalculator;

  /// No description provided for @dailySadqa.
  ///
  /// In en, this message translates to:
  /// **'Daily Sadqa'**
  String get dailySadqa;

  /// No description provided for @khumsTitle.
  ///
  /// In en, this message translates to:
  /// **'Khums Calculator'**
  String get khumsTitle;

  /// No description provided for @khumsCalculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate Khums'**
  String get khumsCalculate;

  /// No description provided for @khumsSavings.
  ///
  /// In en, this message translates to:
  /// **'Annual Savings / Surplus'**
  String get khumsSavings;

  /// No description provided for @khumsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Deductible Annual Expenses'**
  String get khumsExpenses;

  /// No description provided for @khumsNetSurplus.
  ///
  /// In en, this message translates to:
  /// **'Khums-Eligible Surplus'**
  String get khumsNetSurplus;

  /// No description provided for @khumsPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Khums Payable (20%)'**
  String get khumsPayable;

  /// No description provided for @sahmImam.
  ///
  /// In en, this message translates to:
  /// **'Sahm al-Imam (10%)'**
  String get sahmImam;

  /// No description provided for @sahmSadat.
  ///
  /// In en, this message translates to:
  /// **'Sahm al-Sadat (10%)'**
  String get sahmSadat;

  /// No description provided for @khumsAnniversary.
  ///
  /// In en, this message translates to:
  /// **'Khums Anniversary Date'**
  String get khumsAnniversary;

  /// No description provided for @khumsDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This calculator is an informational aid, not a religious verdict (fatwa). Please consult your Marja\'s official desk or representative for specific exemptions.'**
  String get khumsDisclaimer;

  /// No description provided for @sadqaTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Sadqa Tracker'**
  String get sadqaTitle;

  /// No description provided for @sadqaLogAmount.
  ///
  /// In en, this message translates to:
  /// **'Log Sadqa'**
  String get sadqaLogAmount;

  /// No description provided for @sadqaAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get sadqaAmount;

  /// No description provided for @sadqaNote.
  ///
  /// In en, this message translates to:
  /// **'Intention / Note (optional)'**
  String get sadqaNote;

  /// No description provided for @sadqaToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get sadqaToday;

  /// No description provided for @sadqaThisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get sadqaThisWeek;

  /// No description provided for @sadqaThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get sadqaThisMonth;

  /// No description provided for @sadqaThisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get sadqaThisYear;

  /// No description provided for @sadqaHistory.
  ///
  /// In en, this message translates to:
  /// **'Sadqa History'**
  String get sadqaHistory;

  /// No description provided for @ayatReadToday.
  ///
  /// In en, this message translates to:
  /// **'Ayat Read Today'**
  String get ayatReadToday;

  /// No description provided for @ayatReadWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get ayatReadWeek;

  /// No description provided for @totalAyatRead.
  ///
  /// In en, this message translates to:
  /// **'Total Ayat Read'**
  String get totalAyatRead;

  /// No description provided for @quranStreak.
  ///
  /// In en, this message translates to:
  /// **'Quran Streak'**
  String get quranStreak;

  /// No description provided for @qadhaTracker.
  ///
  /// In en, this message translates to:
  /// **'Prayer Check-In & Qadha'**
  String get qadhaTracker;

  /// No description provided for @fajr.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// No description provided for @dhuhr.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// No description provided for @rozaFast.
  ///
  /// In en, this message translates to:
  /// **'Roza (Fast)'**
  String get rozaFast;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
