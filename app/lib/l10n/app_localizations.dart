import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ur'),
    Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby App'**
  String get appTitle;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track feeds, sleep and more for your baby'**
  String get signInSubtitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInButton;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUpButton;

  /// No description provided for @switchToSignUp.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get switchToSignUp;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email and tap the link to confirm — it opens the app and signs you in.'**
  String get checkEmail;

  /// No description provided for @switchToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get switchToSignIn;

  /// No description provided for @addBabyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your baby'**
  String get addBabyTitle;

  /// No description provided for @babyNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Baby\'s name'**
  String get babyNameLabel;

  /// No description provided for @birthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDateLabel;

  /// No description provided for @sexLabel.
  ///
  /// In en, this message translates to:
  /// **'Sex (optional)'**
  String get sexLabel;

  /// No description provided for @sexFemale.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get sexFemale;

  /// No description provided for @sexMale.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get sexMale;

  /// No description provided for @birthWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth weight in kg (optional)'**
  String get birthWeightLabel;

  /// No description provided for @invalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight between 0.3 and 7 kg'**
  String get invalidWeight;

  /// No description provided for @ageMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String ageMonths(int count);

  /// No description provided for @ageDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String ageDays(int count);

  /// No description provided for @durationHm.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String durationHm(int hours, int minutes);

  /// No description provided for @durationM.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String durationM(int minutes);

  /// No description provided for @agoLabel.
  ///
  /// In en, this message translates to:
  /// **'{duration} ago'**
  String agoLabel(String duration);

  /// No description provided for @feeds.
  ///
  /// In en, this message translates to:
  /// **'Feeds'**
  String get feeds;

  /// No description provided for @diapers.
  ///
  /// In en, this message translates to:
  /// **'Diapers'**
  String get diapers;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @bottleTotal.
  ///
  /// In en, this message translates to:
  /// **'{ml} ml by bottle'**
  String bottleTotal(int ml);

  /// No description provided for @lastFeed.
  ///
  /// In en, this message translates to:
  /// **'Last: {ago}'**
  String lastFeed(String ago);

  /// No description provided for @diaperCounts.
  ///
  /// In en, this message translates to:
  /// **'{wet} wet · {dirty} dirty'**
  String diaperCounts(int wet, int dirty);

  /// No description provided for @sleepingSince.
  ///
  /// In en, this message translates to:
  /// **'Sleeping since {time}'**
  String sleepingSince(String time);

  /// No description provided for @sleptToday.
  ///
  /// In en, this message translates to:
  /// **'Slept today'**
  String get sleptToday;

  /// No description provided for @logFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get logFeed;

  /// No description provided for @logDiaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get logDiaper;

  /// No description provided for @startSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get startSleep;

  /// No description provided for @endSleep.
  ///
  /// In en, this message translates to:
  /// **'Woke up'**
  String get endSleep;

  /// No description provided for @feedTypeBreast.
  ///
  /// In en, this message translates to:
  /// **'Breast'**
  String get feedTypeBreast;

  /// No description provided for @feedTypeBottleBreastMilk.
  ///
  /// In en, this message translates to:
  /// **'Expressed milk'**
  String get feedTypeBottleBreastMilk;

  /// No description provided for @feedTypeFormula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get feedTypeFormula;

  /// No description provided for @sideLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get sideLeft;

  /// No description provided for @sideRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get sideRight;

  /// No description provided for @sideBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get sideBoth;

  /// No description provided for @amountMl.
  ///
  /// In en, this message translates to:
  /// **'Amount (ml)'**
  String get amountMl;

  /// No description provided for @feedMinutes.
  ///
  /// In en, this message translates to:
  /// **'Duration in minutes (optional)'**
  String get feedMinutes;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount between 1 and 1000 ml'**
  String get invalidAmount;

  /// No description provided for @invalidMinutes.
  ///
  /// In en, this message translates to:
  /// **'Enter minutes between 1 and 180'**
  String get invalidMinutes;

  /// No description provided for @diaperWet.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get diaperWet;

  /// No description provided for @diaperDirty.
  ///
  /// In en, this message translates to:
  /// **'Dirty'**
  String get diaperDirty;

  /// No description provided for @chooseDiaper.
  ///
  /// In en, this message translates to:
  /// **'Choose wet, dirty or both'**
  String get chooseDiaper;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @sleepNap.
  ///
  /// In en, this message translates to:
  /// **'Nap'**
  String get sleepNap;

  /// No description provided for @sleepNight.
  ///
  /// In en, this message translates to:
  /// **'Night sleep'**
  String get sleepNight;

  /// No description provided for @sleepingNow.
  ///
  /// In en, this message translates to:
  /// **'sleeping'**
  String get sleepingNow;

  /// No description provided for @todayTimeline.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTimeline;

  /// No description provided for @nothingLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet today'**
  String get nothingLoggedToday;
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
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'ur':
      {
        switch (locale.scriptCode) {
          case 'Latn':
            return AppLocalizationsUrLatn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
