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
  /// **'Palna'**
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

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your code'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}'**
  String verifySubtitle(String email);

  /// No description provided for @codeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get codeLabel;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get verifyButton;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get resendCode;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Send a new code in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @codeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent'**
  String get codeSent;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'That code is wrong or has expired'**
  String get invalidCode;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

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

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get tabGrowth;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteConfirmTitle;

  /// No description provided for @editFeed.
  ///
  /// In en, this message translates to:
  /// **'Edit feed'**
  String get editFeed;

  /// No description provided for @editDiaper.
  ///
  /// In en, this message translates to:
  /// **'Edit diaper'**
  String get editDiaper;

  /// No description provided for @editSleep.
  ///
  /// In en, this message translates to:
  /// **'Edit sleep'**
  String get editSleep;

  /// No description provided for @sleepStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Fell asleep'**
  String get sleepStartLabel;

  /// No description provided for @sleepEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Woke up'**
  String get sleepEndLabel;

  /// No description provided for @stillAsleep.
  ///
  /// In en, this message translates to:
  /// **'Still asleep'**
  String get stillAsleep;

  /// No description provided for @invalidSleepTimes.
  ///
  /// In en, this message translates to:
  /// **'Wake-up time must be after falling asleep'**
  String get invalidSleepTimes;

  /// No description provided for @growthTitle.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growthTitle;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get addMeasurement;

  /// No description provided for @editMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Edit measurement'**
  String get editMeasurement;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @weightKgLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgLabel;

  /// No description provided for @lengthCmLabel.
  ///
  /// In en, this message translates to:
  /// **'Length (cm)'**
  String get lengthCmLabel;

  /// No description provided for @headCmLabel.
  ///
  /// In en, this message translates to:
  /// **'Head circumference (cm)'**
  String get headCmLabel;

  /// No description provided for @enterOneMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one measurement'**
  String get enterOneMeasurement;

  /// No description provided for @invalidWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Enter a weight between 0.3 and 40 kg'**
  String get invalidWeightKg;

  /// No description provided for @invalidLengthCm.
  ///
  /// In en, this message translates to:
  /// **'Enter a length between 20 and 130 cm'**
  String get invalidLengthCm;

  /// No description provided for @invalidHeadCm.
  ///
  /// In en, this message translates to:
  /// **'Enter a size between 20 and 60 cm'**
  String get invalidHeadCm;

  /// No description provided for @metricWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get metricWeight;

  /// No description provided for @metricLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get metricLength;

  /// No description provided for @metricHead.
  ///
  /// In en, this message translates to:
  /// **'Head'**
  String get metricHead;

  /// No description provided for @percentileValue.
  ///
  /// In en, this message translates to:
  /// **'Percentile: {percentile}'**
  String percentileValue(String percentile);

  /// No description provided for @changeSince.
  ///
  /// In en, this message translates to:
  /// **'{change} since {date}'**
  String changeSince(String change, String date);

  /// No description provided for @atBirth.
  ///
  /// In en, this message translates to:
  /// **'At birth'**
  String get atBirth;

  /// No description provided for @noMeasurements.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet. Add one after your next weigh-in.'**
  String get noMeasurements;

  /// No description provided for @chooseSexForChart.
  ///
  /// In en, this message translates to:
  /// **'To compare with the WHO growth curves, choose:'**
  String get chooseSexForChart;

  /// No description provided for @curvesLegend.
  ///
  /// In en, this message translates to:
  /// **'Grey lines: WHO Child Growth Standards, 3rd to 97th percentile. Your baby: coloured line.'**
  String get curvesLegend;

  /// No description provided for @percentileExplain.
  ///
  /// In en, this message translates to:
  /// **'A percentile compares your baby with others of the same age and sex; the 50th is the middle. A steady curve over time matters more than any single number. Talk to your doctor if the line crosses two of the grey curves or flattens out.'**
  String get percentileExplain;

  /// No description provided for @whoAgeLimit.
  ///
  /// In en, this message translates to:
  /// **'WHO curves in the app cover birth to 24 months.'**
  String get whoAgeLimit;

  /// No description provided for @tabHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get tabHealth;

  /// No description provided for @vaccinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Vaccinations'**
  String get vaccinesTitle;

  /// No description provided for @vaccineScheduleNote.
  ///
  /// In en, this message translates to:
  /// **'Pakistan EPI schedule (government vaccination programme). Always confirm dates with your vaccinator or pediatrician.'**
  String get vaccineScheduleNote;

  /// No description provided for @visitAtBirth.
  ///
  /// In en, this message translates to:
  /// **'At birth'**
  String get visitAtBirth;

  /// No description provided for @visitWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count} weeks'**
  String visitWeeks(int count);

  /// No description provided for @visitMonths.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String visitMonths(int count);

  /// No description provided for @dueOn.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueOn(String date);

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'All given'**
  String get statusDone;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @statusDueSoon.
  ///
  /// In en, this message translates to:
  /// **'Due soon'**
  String get statusDueSoon;

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statusUpcoming;

  /// No description provided for @givenOn.
  ///
  /// In en, this message translates to:
  /// **'Given {date}'**
  String givenOn(String date);

  /// No description provided for @markGiven.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get markGiven;

  /// No description provided for @markVisitGiven.
  ///
  /// In en, this message translates to:
  /// **'Mark all as given'**
  String get markVisitGiven;

  /// No description provided for @recordVaccination.
  ///
  /// In en, this message translates to:
  /// **'Record vaccination'**
  String get recordVaccination;

  /// No description provided for @editVaccination.
  ///
  /// In en, this message translates to:
  /// **'Edit vaccination'**
  String get editVaccination;

  /// No description provided for @dateGivenLabel.
  ///
  /// In en, this message translates to:
  /// **'Date given'**
  String get dateGivenLabel;

  /// No description provided for @batchLabel.
  ///
  /// In en, this message translates to:
  /// **'Batch number (optional)'**
  String get batchLabel;

  /// No description provided for @clinicLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic or doctor (optional)'**
  String get clinicLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesLabel;

  /// No description provided for @nextVisit.
  ///
  /// In en, this message translates to:
  /// **'Next: {visit}, {date}'**
  String nextVisit(String visit, String date);

  /// No description provided for @allVaccinesDone.
  ///
  /// In en, this message translates to:
  /// **'All scheduled vaccines are recorded.'**
  String get allVaccinesDone;

  /// No description provided for @catchUpNote.
  ///
  /// In en, this message translates to:
  /// **'Missed a vaccine? Most can still be given late, and the series usually doesn\'t need to restart. Ask your vaccinator or pediatrician about a catch-up plan.'**
  String get catchUpNote;

  /// No description provided for @vaccinesDueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s vaccines are due tomorrow'**
  String vaccinesDueTomorrow(String name);

  /// No description provided for @vaccinesDueToday.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s vaccines are due today'**
  String vaccinesDueToday(String name);

  /// No description provided for @vaccinesOverdueReminder.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s vaccines are overdue'**
  String vaccinesOverdueReminder(String name);

  /// No description provided for @healthTitle.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthTitle;

  /// No description provided for @tabVaccines.
  ///
  /// In en, this message translates to:
  /// **'Vaccines'**
  String get tabVaccines;

  /// No description provided for @tabMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get tabMedicines;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add medicine'**
  String get addMedicine;

  /// No description provided for @editMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit medicine'**
  String get editMedicine;

  /// No description provided for @medicineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Medicine name'**
  String get medicineNameLabel;

  /// No description provided for @prescribedDoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Dose prescribed by the doctor (e.g. 2.5 ml)'**
  String get prescribedDoseLabel;

  /// No description provided for @scheduleAtTimes.
  ///
  /// In en, this message translates to:
  /// **'At set times'**
  String get scheduleAtTimes;

  /// No description provided for @scheduleAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'When needed'**
  String get scheduleAsNeeded;

  /// No description provided for @doseTimesLabel.
  ///
  /// In en, this message translates to:
  /// **'Dose times'**
  String get doseTimesLabel;

  /// No description provided for @addTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get addTime;

  /// No description provided for @presetOnce.
  ///
  /// In en, this message translates to:
  /// **'Once a day'**
  String get presetOnce;

  /// No description provided for @presetTwice.
  ///
  /// In en, this message translates to:
  /// **'2 times a day'**
  String get presetTwice;

  /// No description provided for @presetThrice.
  ///
  /// In en, this message translates to:
  /// **'3 times a day'**
  String get presetThrice;

  /// No description provided for @presetEvery6h.
  ///
  /// In en, this message translates to:
  /// **'Every 6 hours'**
  String get presetEvery6h;

  /// No description provided for @chooseTimes.
  ///
  /// In en, this message translates to:
  /// **'Add at least one time'**
  String get chooseTimes;

  /// No description provided for @startDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDateLabel;

  /// No description provided for @durationDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'For how many days? (empty if ongoing)'**
  String get durationDaysLabel;

  /// No description provided for @invalidDays.
  ///
  /// In en, this message translates to:
  /// **'Enter between 1 and 365 days'**
  String get invalidDays;

  /// No description provided for @prescribedByLabel.
  ///
  /// In en, this message translates to:
  /// **'Prescribed by (optional)'**
  String get prescribedByLabel;

  /// No description provided for @medicineSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'Give medicines only as your doctor prescribed. This app stores the prescription and reminds you; it never calculates or suggests a dose.'**
  String get medicineSafetyNote;

  /// No description provided for @noMedicines.
  ///
  /// In en, this message translates to:
  /// **'No medicines added.'**
  String get noMedicines;

  /// No description provided for @finishedMedicines.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finishedMedicines;

  /// No description provided for @untilDate.
  ///
  /// In en, this message translates to:
  /// **'Until {date}'**
  String untilDate(String date);

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @doseGiven.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get doseGiven;

  /// No description provided for @doseSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get doseSkipped;

  /// No description provided for @doseMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get doseMissed;

  /// No description provided for @markDoseGiven.
  ///
  /// In en, this message translates to:
  /// **'Given'**
  String get markDoseGiven;

  /// No description provided for @skipDose.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipDose;

  /// No description provided for @undoDose.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoDose;

  /// No description provided for @recordDoseNow.
  ///
  /// In en, this message translates to:
  /// **'Record a dose now'**
  String get recordDoseNow;

  /// No description provided for @lastGiven.
  ///
  /// In en, this message translates to:
  /// **'Last given {time}'**
  String lastGiven(String time);

  /// No description provided for @medicineReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine time for {name}'**
  String medicineReminderTitle(String name);

  /// No description provided for @medicineReminderBody.
  ///
  /// In en, this message translates to:
  /// **'{medicine}: {dose}'**
  String medicineReminderBody(String medicine, String dose);

  /// No description provided for @tabMilk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get tabMilk;

  /// No description provided for @milkTitle.
  ///
  /// In en, this message translates to:
  /// **'Breast milk'**
  String get milkTitle;

  /// No description provided for @logPumping.
  ///
  /// In en, this message translates to:
  /// **'Log pumping'**
  String get logPumping;

  /// No description provided for @editPumping.
  ///
  /// In en, this message translates to:
  /// **'Edit pumping'**
  String get editPumping;

  /// No description provided for @addStoredMilk.
  ///
  /// In en, this message translates to:
  /// **'Add stored milk'**
  String get addStoredMilk;

  /// No description provided for @pumpedToday.
  ///
  /// In en, this message translates to:
  /// **'Pumped today: {ml} ml ({count} times)'**
  String pumpedToday(int ml, int count);

  /// No description provided for @storeMilkIn.
  ///
  /// In en, this message translates to:
  /// **'Where is this milk now?'**
  String get storeMilkIn;

  /// No description provided for @notStored.
  ///
  /// In en, this message translates to:
  /// **'Fed right away'**
  String get notStored;

  /// No description provided for @locationRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get locationRoom;

  /// No description provided for @locationCooler.
  ///
  /// In en, this message translates to:
  /// **'Cooler with ice'**
  String get locationCooler;

  /// No description provided for @locationFridge.
  ///
  /// In en, this message translates to:
  /// **'Fridge'**
  String get locationFridge;

  /// No description provided for @locationFreezer.
  ///
  /// In en, this message translates to:
  /// **'Freezer'**
  String get locationFreezer;

  /// No description provided for @locationThawed.
  ///
  /// In en, this message translates to:
  /// **'Thawed, in fridge'**
  String get locationThawed;

  /// No description provided for @pumpedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Pumped at'**
  String get pumpedAtLabel;

  /// No description provided for @pumpedOn.
  ///
  /// In en, this message translates to:
  /// **'Pumped {date}'**
  String pumpedOn(String date);

  /// No description provided for @useBy.
  ///
  /// In en, this message translates to:
  /// **'Use by {time}'**
  String useBy(String time);

  /// No description provided for @milkExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired: throw away'**
  String get milkExpired;

  /// No description provided for @milkNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 stored milk item expires soon or has expired.} other{{count} stored milk items expire soon or have expired.}}'**
  String milkNeedsAttention(int count);

  /// No description provided for @useForFeed.
  ///
  /// In en, this message translates to:
  /// **'Use for a feed'**
  String get useForFeed;

  /// No description provided for @moveToFridge.
  ///
  /// In en, this message translates to:
  /// **'Move to fridge'**
  String get moveToFridge;

  /// No description provided for @moveToCooler.
  ///
  /// In en, this message translates to:
  /// **'Move to cooler'**
  String get moveToCooler;

  /// No description provided for @moveToFreezer.
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get moveToFreezer;

  /// No description provided for @thawMilk.
  ///
  /// In en, this message translates to:
  /// **'Thaw in fridge'**
  String get thawMilk;

  /// No description provided for @throwAway.
  ///
  /// In en, this message translates to:
  /// **'Throw away'**
  String get throwAway;

  /// No description provided for @noStoredMilk.
  ///
  /// In en, this message translates to:
  /// **'No stored milk.'**
  String get noStoredMilk;

  /// No description provided for @noRefreeze.
  ///
  /// In en, this message translates to:
  /// **'Don\'t refreeze'**
  String get noRefreeze;

  /// No description provided for @storageGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'How long milk keeps'**
  String get storageGuideTitle;

  /// No description provided for @storageGuide.
  ///
  /// In en, this message translates to:
  /// **'Freshly pumped milk (CDC guidance):\n• Room, 25°C or cooler: up to 4 hours\n• Cooler bag with ice packs: up to 24 hours\n• Fridge: up to 4 days\n• Freezer: best within 6 months, up to 12 months\n\nThawed milk: use within 24 hours in the fridge, or within 2 hours once warmed. Never refreeze thawed milk.\nLeftover milk after a feed: use within 2 hours, then throw away.\n\nIn hot weather rooms are often hotter than 25°C, so put milk in the fridge or a cooler with ice right after pumping.'**
  String get storageGuide;

  /// No description provided for @loadSheddingTitle.
  ///
  /// In en, this message translates to:
  /// **'During load-shedding'**
  String get loadSheddingTitle;

  /// No description provided for @loadSheddingGuide.
  ///
  /// In en, this message translates to:
  /// **'• Keep the fridge and freezer closed. A closed fridge stays cold for about 4 hours; a full freezer for about 48 hours (24 if half full).\n• For longer outages, move milk to a cooler bag with ice or frozen gel packs. Keep a few packs frozen for this.\n• If frozen milk has thawed, don\'t refreeze it: keep it cold and use it within 24 hours.'**
  String get loadSheddingGuide;

  /// No description provided for @milkExpiresTitle.
  ///
  /// In en, this message translates to:
  /// **'Stored milk expires soon'**
  String get milkExpiresTitle;

  /// No description provided for @milkExpiresBody.
  ///
  /// In en, this message translates to:
  /// **'{ml} ml ({location}): use by {time}'**
  String milkExpiresBody(int ml, String location, String time);

  /// No description provided for @storedMilkTotal.
  ///
  /// In en, this message translates to:
  /// **'{ml} ml'**
  String storedMilkTotal(int ml);

  /// No description provided for @tabSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get tabSymptoms;

  /// No description provided for @logSymptom.
  ///
  /// In en, this message translates to:
  /// **'Log symptom'**
  String get logSymptom;

  /// No description provided for @editSymptom.
  ///
  /// In en, this message translates to:
  /// **'Edit symptom'**
  String get editSymptom;

  /// No description provided for @symptomFever.
  ///
  /// In en, this message translates to:
  /// **'Fever'**
  String get symptomFever;

  /// No description provided for @symptomCough.
  ///
  /// In en, this message translates to:
  /// **'Cough'**
  String get symptomCough;

  /// No description provided for @symptomRunnyNose.
  ///
  /// In en, this message translates to:
  /// **'Runny nose'**
  String get symptomRunnyNose;

  /// No description provided for @symptomVomiting.
  ///
  /// In en, this message translates to:
  /// **'Vomiting'**
  String get symptomVomiting;

  /// No description provided for @symptomDiarrhea.
  ///
  /// In en, this message translates to:
  /// **'Diarrhoea'**
  String get symptomDiarrhea;

  /// No description provided for @symptomConstipation.
  ///
  /// In en, this message translates to:
  /// **'Constipation'**
  String get symptomConstipation;

  /// No description provided for @symptomRash.
  ///
  /// In en, this message translates to:
  /// **'Rash'**
  String get symptomRash;

  /// No description provided for @symptomTeething.
  ///
  /// In en, this message translates to:
  /// **'Teething'**
  String get symptomTeething;

  /// No description provided for @symptomFeedingRefusal.
  ///
  /// In en, this message translates to:
  /// **'Refusing feeds'**
  String get symptomFeedingRefusal;

  /// No description provided for @symptomCrying.
  ///
  /// In en, this message translates to:
  /// **'Unusual crying'**
  String get symptomCrying;

  /// No description provided for @symptomCongestion.
  ///
  /// In en, this message translates to:
  /// **'Blocked nose'**
  String get symptomCongestion;

  /// No description provided for @symptomOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get symptomOther;

  /// No description provided for @temperatureLabel.
  ///
  /// In en, this message translates to:
  /// **'Temperature (optional)'**
  String get temperatureLabel;

  /// No description provided for @invalidTemperature.
  ///
  /// In en, this message translates to:
  /// **'Enter 30–45 °C or 86–113 °F'**
  String get invalidTemperature;

  /// No description provided for @severityLabel.
  ///
  /// In en, this message translates to:
  /// **'How bad?'**
  String get severityLabel;

  /// No description provided for @severityMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get severityMild;

  /// No description provided for @severityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityModerate;

  /// No description provided for @severitySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severitySevere;

  /// No description provided for @youngFeverWarning.
  ///
  /// In en, this message translates to:
  /// **'A temperature of 38°C (100.4°F) or higher in a baby under 3 months needs a doctor right away.'**
  String get youngFeverWarning;

  /// No description provided for @noSymptoms.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged in the last 14 days.'**
  String get noSymptoms;

  /// No description provided for @doctorSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary for the doctor'**
  String get doctorSummary;

  /// No description provided for @summarySinceStart.
  ///
  /// In en, this message translates to:
  /// **'Since symptoms started'**
  String get summarySinceStart;

  /// No description provided for @lastNDays.
  ///
  /// In en, this message translates to:
  /// **'Last {count} days'**
  String lastNDays(int count);

  /// No description provided for @showInEnglish.
  ///
  /// In en, this message translates to:
  /// **'In English (for the doctor)'**
  String get showInEnglish;

  /// No description provided for @shareButton.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareButton;

  /// No description provided for @copyButton.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyButton;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @sumTitle.
  ///
  /// In en, this message translates to:
  /// **'Health summary: {name}'**
  String sumTitle(String name);

  /// No description provided for @sumAge.
  ///
  /// In en, this message translates to:
  /// **'Age: {age}'**
  String sumAge(String age);

  /// No description provided for @sumPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period: {from} to {to}'**
  String sumPeriod(String from, String to);

  /// No description provided for @sumWeight.
  ///
  /// In en, this message translates to:
  /// **'Latest weight: {weight} ({date})'**
  String sumWeight(String weight, String date);

  /// No description provided for @sumSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get sumSymptoms;

  /// No description provided for @sumSymptomLine.
  ///
  /// In en, this message translates to:
  /// **'{symptom}: from {first} to {last} ({count, plural, =1{1 entry} other{{count} entries}})'**
  String sumSymptomLine(String symptom, String first, String last, int count);

  /// No description provided for @sumHighestTemp.
  ///
  /// In en, this message translates to:
  /// **'highest {temp} on {when}'**
  String sumHighestTemp(String temp, String when);

  /// No description provided for @sumFeedsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Feeds per day: {days}'**
  String sumFeedsPerDay(String days);

  /// No description provided for @sumWetPerDay.
  ///
  /// In en, this message translates to:
  /// **'Wet diapers per day: {days}'**
  String sumWetPerDay(String days);

  /// No description provided for @sumDirtyPerDay.
  ///
  /// In en, this message translates to:
  /// **'Dirty diapers per day: {days}'**
  String sumDirtyPerDay(String days);

  /// No description provided for @sumUsually.
  ///
  /// In en, this message translates to:
  /// **'usually about {count}'**
  String sumUsually(String count);

  /// No description provided for @sumTodaySoFar.
  ///
  /// In en, this message translates to:
  /// **'today so far {count}'**
  String sumTodaySoFar(int count);

  /// No description provided for @sumMedicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines given'**
  String get sumMedicines;

  /// No description provided for @sumMedicineLine.
  ///
  /// In en, this message translates to:
  /// **'{name} ({dose}): {count, plural, =1{1 dose} other{{count} doses}}, last {when}'**
  String sumMedicineLine(String name, String dose, int count, String when);

  /// No description provided for @sumEntries.
  ///
  /// In en, this message translates to:
  /// **'All entries'**
  String get sumEntries;

  /// No description provided for @sumFooter.
  ///
  /// In en, this message translates to:
  /// **'Recorded by the parent in Palna.'**
  String get sumFooter;

  /// No description provided for @firstSyncLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your family\'s data…'**
  String get firstSyncLoading;

  /// No description provided for @firstSyncNeedsInternet.
  ///
  /// In en, this message translates to:
  /// **'The first time, this needs an internet connection. After that the app works offline.'**
  String get firstSyncNeedsInternet;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline: changes are saved and will sync when you\'re back online.'**
  String get offlineBanner;

  /// No description provided for @unsyncedSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Some changes haven\'t synced yet'**
  String get unsyncedSignOutTitle;

  /// No description provided for @unsyncedSignOutBody.
  ///
  /// In en, this message translates to:
  /// **'If you sign out now, entries made while offline will be lost. Connect to the internet first to keep them.'**
  String get unsyncedSignOutBody;

  /// No description provided for @signOutAnyway.
  ///
  /// In en, this message translates to:
  /// **'Sign out anyway'**
  String get signOutAnyway;

  /// No description provided for @editBabyTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit baby'**
  String get editBabyTitle;

  /// No description provided for @birthLengthLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth length in cm (optional)'**
  String get birthLengthLabel;

  /// No description provided for @birthHeadLabel.
  ///
  /// In en, this message translates to:
  /// **'Birth head circumference in cm (optional)'**
  String get birthHeadLabel;

  /// No description provided for @invalidBirthLength.
  ///
  /// In en, this message translates to:
  /// **'Enter a length between 20 and 70 cm'**
  String get invalidBirthLength;

  /// No description provided for @invalidBirthHead.
  ///
  /// In en, this message translates to:
  /// **'Enter a size between 20 and 50 cm'**
  String get invalidBirthHead;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @babiesSection.
  ///
  /// In en, this message translates to:
  /// **'Babies'**
  String get babiesSection;

  /// No description provided for @addAnotherBaby.
  ///
  /// In en, this message translates to:
  /// **'Add another baby'**
  String get addAnotherBaby;

  /// No description provided for @familySection.
  ///
  /// In en, this message translates to:
  /// **'Family & caregivers'**
  String get familySection;

  /// No description provided for @familyOffline.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to see and invite family members.'**
  String get familyOffline;

  /// No description provided for @ownerLabel.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerLabel;

  /// No description provided for @caregiverLabel.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get caregiverLabel;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @inviteCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Invite a caregiver'**
  String get inviteCaregiver;

  /// No description provided for @inviteCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeTitle;

  /// No description provided for @inviteCodeHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask them to install the app, create an account and enter this code. It works once and expires in 7 days.'**
  String get inviteCodeHelp;

  /// No description provided for @inviteShareText.
  ///
  /// In en, this message translates to:
  /// **'Join {name}\'s family on Palna with this code: {code} (valid for 7 days)'**
  String inviteShareText(String name, String code);

  /// No description provided for @joinFamily.
  ///
  /// In en, this message translates to:
  /// **'Join a family with a code'**
  String get joinFamily;

  /// No description provided for @joinFamilyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Joining a family? Enter the invite code'**
  String get joinFamilyPrompt;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'6-character code'**
  String get inviteCodeLabel;

  /// No description provided for @joinButton.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinButton;

  /// No description provided for @joinedFamily.
  ///
  /// In en, this message translates to:
  /// **'You\'ve joined the family. Their data will appear in a moment.'**
  String get joinedFamily;

  /// No description provided for @invalidInvite.
  ///
  /// In en, this message translates to:
  /// **'That code is wrong, already used, or expired.'**
  String get invalidInvite;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMember;

  /// No description provided for @leaveFamily.
  ///
  /// In en, this message translates to:
  /// **'Leave family'**
  String get leaveFamily;

  /// No description provided for @removeMemberConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from the family?'**
  String removeMemberConfirm(String name);

  /// No description provided for @leaveFamilyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave this family? You\'ll stop seeing its babies.'**
  String get leaveFamilyConfirm;

  /// No description provided for @switchBaby.
  ///
  /// In en, this message translates to:
  /// **'Switch baby'**
  String get switchBaby;

  /// No description provided for @atAGlance.
  ///
  /// In en, this message translates to:
  /// **'At a glance'**
  String get atAGlance;

  /// No description provided for @hungerEstimate.
  ///
  /// In en, this message translates to:
  /// **'Usually feeds about every {interval}, so the next feed may be around {time}.'**
  String hungerEstimate(String interval, String time);

  /// No description provided for @hungerDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'A rough guide from recent feeds; always follow your baby\'s hunger cues.'**
  String get hungerDisclaimer;

  /// No description provided for @sleepUsual.
  ///
  /// In en, this message translates to:
  /// **'Usually sleeps about {usual} a day. Today so far: {today}.'**
  String sleepUsual(String usual, String today);

  /// No description provided for @awakeFor.
  ///
  /// In en, this message translates to:
  /// **'Awake for {duration}'**
  String awakeFor(String duration);

  /// No description provided for @usuallyAwake.
  ///
  /// In en, this message translates to:
  /// **'usually about {duration} between sleeps'**
  String usuallyAwake(String duration);

  /// No description provided for @vaccinesOverdueLine.
  ///
  /// In en, this message translates to:
  /// **'Vaccines overdue: {visit}'**
  String vaccinesOverdueLine(String visit);

  /// No description provided for @medsTodayLine.
  ///
  /// In en, this message translates to:
  /// **'Medicines today: {given} of {total} doses recorded'**
  String medsTodayLine(int given, int total);

  /// No description provided for @tabSolids.
  ///
  /// In en, this message translates to:
  /// **'Solids'**
  String get tabSolids;

  /// No description provided for @solidsTitle.
  ///
  /// In en, this message translates to:
  /// **'Starting solids'**
  String get solidsTitle;

  /// No description provided for @solidsTooYoung.
  ///
  /// In en, this message translates to:
  /// **'Most babies start solids around 6 months. You can read ahead in the meantime.'**
  String get solidsTooYoung;

  /// No description provided for @readinessTitle.
  ///
  /// In en, this message translates to:
  /// **'Is my baby ready?'**
  String get readinessTitle;

  /// No description provided for @texturesTitle.
  ///
  /// In en, this message translates to:
  /// **'How textures change'**
  String get texturesTitle;

  /// No description provided for @foodRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Important rules'**
  String get foodRulesTitle;

  /// No description provided for @allergensTitle.
  ///
  /// In en, this message translates to:
  /// **'Allergens'**
  String get allergensTitle;

  /// No description provided for @allergenNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get allergenNotYet;

  /// No description provided for @allergenIntroduced.
  ///
  /// In en, this message translates to:
  /// **'Introduced'**
  String get allergenIntroduced;

  /// No description provided for @allergenReaction.
  ///
  /// In en, this message translates to:
  /// **'Reaction'**
  String get allergenReaction;

  /// No description provided for @reactionSignsTitle.
  ///
  /// In en, this message translates to:
  /// **'Signs of an allergic reaction'**
  String get reactionSignsTitle;

  /// No description provided for @beliefsTitle.
  ///
  /// In en, this message translates to:
  /// **'Common beliefs vs evidence'**
  String get beliefsTitle;

  /// No description provided for @beliefLabel.
  ///
  /// In en, this message translates to:
  /// **'Often said'**
  String get beliefLabel;

  /// No description provided for @evidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'What the evidence says'**
  String get evidenceLabel;

  /// No description provided for @foodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Foods'**
  String get foodsTitle;

  /// No description provided for @searchFoods.
  ///
  /// In en, this message translates to:
  /// **'Search foods'**
  String get searchFoods;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryFruit.
  ///
  /// In en, this message translates to:
  /// **'Fruit'**
  String get categoryFruit;

  /// No description provided for @categoryVegetable.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get categoryVegetable;

  /// No description provided for @categoryGrain.
  ///
  /// In en, this message translates to:
  /// **'Grains'**
  String get categoryGrain;

  /// No description provided for @categoryLegume.
  ///
  /// In en, this message translates to:
  /// **'Daal & beans'**
  String get categoryLegume;

  /// No description provided for @categoryProtein.
  ///
  /// In en, this message translates to:
  /// **'Meat, fish & egg'**
  String get categoryProtein;

  /// No description provided for @categoryDairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoryDairy;

  /// No description provided for @categoryNut.
  ///
  /// In en, this message translates to:
  /// **'Nuts & seeds'**
  String get categoryNut;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Not yet'**
  String get categoryOther;

  /// No description provided for @fromMonths.
  ///
  /// In en, this message translates to:
  /// **'From {count} months'**
  String fromMonths(int count);

  /// No description provided for @chokingRisk.
  ///
  /// In en, this message translates to:
  /// **'Choking risk: prepare as described'**
  String get chokingRisk;

  /// No description provided for @allergenLabel.
  ///
  /// In en, this message translates to:
  /// **'Allergen: {name}'**
  String allergenLabel(String name);

  /// No description provided for @logTry.
  ///
  /// In en, this message translates to:
  /// **'Log a try'**
  String get logTry;

  /// No description provided for @editTry.
  ///
  /// In en, this message translates to:
  /// **'Edit try'**
  String get editTry;

  /// No description provided for @notTried.
  ///
  /// In en, this message translates to:
  /// **'Not tried yet'**
  String get notTried;

  /// No description provided for @triedTimes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tried once} other{Tried {count} times}}'**
  String triedTimes(int count);

  /// No description provided for @opinionLabel.
  ///
  /// In en, this message translates to:
  /// **'Did they like it?'**
  String get opinionLabel;

  /// No description provided for @opinionLiked.
  ///
  /// In en, this message translates to:
  /// **'Liked'**
  String get opinionLiked;

  /// No description provided for @opinionNeutral.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get opinionNeutral;

  /// No description provided for @opinionDisliked.
  ///
  /// In en, this message translates to:
  /// **'Disliked'**
  String get opinionDisliked;

  /// No description provided for @reactionLabel.
  ///
  /// In en, this message translates to:
  /// **'Any reaction?'**
  String get reactionLabel;

  /// No description provided for @reactionNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get reactionNone;

  /// No description provided for @reactionMild.
  ///
  /// In en, this message translates to:
  /// **'Mild'**
  String get reactionMild;

  /// No description provided for @reactionSevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get reactionSevere;

  /// No description provided for @reactionWarning.
  ///
  /// In en, this message translates to:
  /// **'Had a reaction: talk to your doctor before giving this again.'**
  String get reactionWarning;

  /// No description provided for @severeReactionNow.
  ///
  /// In en, this message translates to:
  /// **'If your baby has trouble breathing, swelling of the tongue or throat, or becomes floppy or pale, call {number} now.'**
  String severeReactionNow(String number);

  /// No description provided for @sourcesLabel.
  ///
  /// In en, this message translates to:
  /// **'Sources: {sources}'**
  String sourcesLabel(String sources);

  /// No description provided for @tabCharts.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get tabCharts;

  /// No description provided for @tabMilestones.
  ///
  /// In en, this message translates to:
  /// **'Milestones'**
  String get tabMilestones;

  /// No description provided for @byMonths.
  ///
  /// In en, this message translates to:
  /// **'By {count} months'**
  String byMonths(int count);

  /// No description provided for @areaSocial.
  ///
  /// In en, this message translates to:
  /// **'Social & emotional'**
  String get areaSocial;

  /// No description provided for @areaLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language & communication'**
  String get areaLanguage;

  /// No description provided for @areaCognitive.
  ///
  /// In en, this message translates to:
  /// **'Learning & thinking'**
  String get areaCognitive;

  /// No description provided for @areaMovement.
  ///
  /// In en, this message translates to:
  /// **'Movement'**
  String get areaMovement;

  /// No description provided for @waysToHelp.
  ///
  /// In en, this message translates to:
  /// **'Ways to help'**
  String get waysToHelp;

  /// No description provided for @actEarlyTitle.
  ///
  /// In en, this message translates to:
  /// **'When to talk to the doctor'**
  String get actEarlyTitle;

  /// No description provided for @milestonesProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String milestonesProgress(int done, int total);

  /// No description provided for @reachedOn.
  ///
  /// In en, this message translates to:
  /// **'Reached {date}'**
  String reachedOn(String date);

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency & help'**
  String get helpTitle;

  /// No description provided for @emergencyNumbersNote.
  ///
  /// In en, this message translates to:
  /// **'Tap to call. Services differ by city; save your nearest children\'s hospital too.'**
  String get emergencyNumbersNote;

  /// No description provided for @numRescue.
  ///
  /// In en, this message translates to:
  /// **'Rescue 1122: ambulance and emergencies'**
  String get numRescue;

  /// No description provided for @numEdhi.
  ///
  /// In en, this message translates to:
  /// **'Edhi ambulance'**
  String get numEdhi;

  /// No description provided for @numChhipa.
  ///
  /// In en, this message translates to:
  /// **'Chhipa ambulance (Karachi)'**
  String get numChhipa;

  /// No description provided for @numPolice.
  ///
  /// In en, this message translates to:
  /// **'Police'**
  String get numPolice;

  /// No description provided for @numFire.
  ///
  /// In en, this message translates to:
  /// **'Fire brigade'**
  String get numFire;

  /// No description provided for @callEmergencyWhen.
  ///
  /// In en, this message translates to:
  /// **'Call for help straight away if your baby'**
  String get callEmergencyWhen;

  /// No description provided for @emergencySigns.
  ///
  /// In en, this message translates to:
  /// **'• has difficulty breathing, or long pauses in breathing\n• is floppy, very drowsy or hard to wake\n• has blue, grey, pale or blotchy skin, lips or tongue, or feels cold\n• has a fit (seizure)\n• has swelling of the tongue or throat after a food or medicine'**
  String get emergencySigns;

  /// No description provided for @heatTitle.
  ///
  /// In en, this message translates to:
  /// **'Hot weather and load-shedding'**
  String get heatTitle;

  /// No description provided for @heatGuide.
  ///
  /// In en, this message translates to:
  /// **'• Keep babies out of direct sun, especially 11 am to 3 pm, and never leave them in a parked car.\n• Dress them in one light cotton layer; use shade and a fan.\n• Breastfeed more often. Babies under 6 months who only have breast milk don\'t need water; ask your doctor about extra water for formula-fed babies.\n• During load-shedding, move to the coolest room and wipe your baby with a cloth dampened in lukewarm (not cold or iced) water.'**
  String get heatGuide;

  /// No description provided for @dehydrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Signs of dehydration: see a doctor today'**
  String get dehydrationTitle;

  /// No description provided for @dehydrationSigns.
  ///
  /// In en, this message translates to:
  /// **'• fewer wet diapers than usual\n• few or no tears when crying, or a dry mouth\n• a sunken soft spot on the head, or sunken eyes\n• unusually drowsy or irritable'**
  String get dehydrationSigns;

  /// No description provided for @helpSources.
  ///
  /// In en, this message translates to:
  /// **'Based on NHS and WHO guidance. This is general information, not a diagnosis; if you\'re worried, contact a doctor.'**
  String get helpSources;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your login. Babies and entries in families that only you belong to are deleted too. In families you share, the other members keep everything, and if you\'re the owner, the next member becomes the owner. This can\'t be undone.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get deleteAccountTypeHint;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteAccountButton;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (build {build})'**
  String appVersion(String version, String build);

  /// No description provided for @deleteAccountFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account. Check your internet connection and try again.'**
  String get deleteAccountFailed;

  /// No description provided for @startFeedTimer.
  ///
  /// In en, this message translates to:
  /// **'Start a timer'**
  String get startFeedTimer;

  /// No description provided for @lastSide.
  ///
  /// In en, this message translates to:
  /// **'Last feed: {side} side'**
  String lastSide(String side);

  /// No description provided for @orEnterMinutes.
  ///
  /// In en, this message translates to:
  /// **'Or enter the minutes'**
  String get orEnterMinutes;

  /// No description provided for @leftMinutes.
  ///
  /// In en, this message translates to:
  /// **'Left (minutes)'**
  String get leftMinutes;

  /// No description provided for @rightMinutes.
  ///
  /// In en, this message translates to:
  /// **'Right (minutes)'**
  String get rightMinutes;

  /// No description provided for @feedTimerAlreadyRunning.
  ///
  /// In en, this message translates to:
  /// **'A feed timer is already running. You\'ll find it at the top of the Today screen.'**
  String get feedTimerAlreadyRunning;

  /// No description provided for @feedingNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeding now'**
  String get feedingNowTitle;

  /// No description provided for @feedingNow.
  ///
  /// In en, this message translates to:
  /// **'feeding now'**
  String get feedingNow;

  /// No description provided for @feedTimerPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get feedTimerPaused;

  /// No description provided for @feedTimerHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a side to switch. Tap the running side to pause.'**
  String get feedTimerHelp;

  /// No description provided for @finishFeed.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finishFeed;

  /// No description provided for @discardButton.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardButton;

  /// No description provided for @discardFeedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Discard this feed? The timer and its times will be deleted.'**
  String get discardFeedConfirm;

  /// No description provided for @asleepNap.
  ///
  /// In en, this message translates to:
  /// **'Napping'**
  String get asleepNap;

  /// No description provided for @asleepNight.
  ///
  /// In en, this message translates to:
  /// **'Asleep for the night'**
  String get asleepNight;

  /// No description provided for @feedingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is feeding'**
  String feedingNotificationTitle(String name);

  /// No description provided for @sleepNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is asleep'**
  String sleepNotificationTitle(String name);

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @seeReports.
  ///
  /// In en, this message translates to:
  /// **'Reports and trends'**
  String get seeReports;

  /// No description provided for @periodDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String periodDays(int count);

  /// No description provided for @feedsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Feeds a day'**
  String get feedsPerDay;

  /// No description provided for @timeBetweenFeeds.
  ///
  /// In en, this message translates to:
  /// **'Usual time between feeds'**
  String get timeBetweenFeeds;

  /// No description provided for @nursingPerDay.
  ///
  /// In en, this message translates to:
  /// **'Breastfeeding a day'**
  String get nursingPerDay;

  /// No description provided for @perBreastfeed.
  ///
  /// In en, this message translates to:
  /// **'Per breastfeed'**
  String get perBreastfeed;

  /// No description provided for @sideSplit.
  ///
  /// In en, this message translates to:
  /// **'Left / right'**
  String get sideSplit;

  /// No description provided for @bottlePerDay.
  ///
  /// In en, this message translates to:
  /// **'Bottle milk a day'**
  String get bottlePerDay;

  /// No description provided for @perBottle.
  ///
  /// In en, this message translates to:
  /// **'Per bottle'**
  String get perBottle;

  /// No description provided for @sleepPerDay.
  ///
  /// In en, this message translates to:
  /// **'Sleep a day'**
  String get sleepPerDay;

  /// No description provided for @nightSleepPerDay.
  ///
  /// In en, this message translates to:
  /// **'Night sleep'**
  String get nightSleepPerDay;

  /// No description provided for @napsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Naps a day'**
  String get napsPerDay;

  /// No description provided for @napTimePerDay.
  ///
  /// In en, this message translates to:
  /// **'Nap time a day'**
  String get napTimePerDay;

  /// No description provided for @longestSleep.
  ///
  /// In en, this message translates to:
  /// **'Longest sleep'**
  String get longestSleep;

  /// No description provided for @awakeBetweenSleeps.
  ///
  /// In en, this message translates to:
  /// **'Awake between sleeps'**
  String get awakeBetweenSleeps;

  /// No description provided for @usualBedtime.
  ///
  /// In en, this message translates to:
  /// **'Usual bedtime'**
  String get usualBedtime;

  /// No description provided for @usualWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Usual wake-up'**
  String get usualWakeUp;

  /// No description provided for @wetPerDay.
  ///
  /// In en, this message translates to:
  /// **'Wet a day'**
  String get wetPerDay;

  /// No description provided for @dirtyPerDay.
  ///
  /// In en, this message translates to:
  /// **'Dirty a day'**
  String get dirtyPerDay;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String hoursShort(int hours);

  /// No description provided for @hoursRange.
  ///
  /// In en, this message translates to:
  /// **'{from}–{to} hours'**
  String hoursRange(int from, int to);

  /// No description provided for @typicalRange.
  ///
  /// In en, this message translates to:
  /// **'Typical for this age: {range}'**
  String typicalRange(String range);

  /// No description provided for @newbornFeedsGuide.
  ///
  /// In en, this message translates to:
  /// **'Breastfed newborns usually feed 8 to 12 times a day.'**
  String get newbornFeedsGuide;

  /// No description provided for @wetGuide.
  ///
  /// In en, this message translates to:
  /// **'From day 5, 6 or more wet diapers a day is a sign of enough milk.'**
  String get wetGuide;

  /// No description provided for @dirtyGuide.
  ///
  /// In en, this message translates to:
  /// **'In the first 6 weeks, most breastfed babies have 2 or more dirty diapers a day.'**
  String get dirtyGuide;

  /// No description provided for @reportNotEnough.
  ///
  /// In en, this message translates to:
  /// **'Not enough entries yet. Keep logging and this fills in.'**
  String get reportNotEnough;

  /// No description provided for @reportAveragesNote.
  ///
  /// In en, this message translates to:
  /// **'Averages count only full days on which you logged that kind of entry; today isn\'t included yet.'**
  String get reportAveragesNote;

  /// No description provided for @reportSources.
  ///
  /// In en, this message translates to:
  /// **'Typical ranges: National Sleep Foundation (under 4 months), American Academy of Sleep Medicine (4 months and older), NHS (feeds and diapers). The shaded band on the sleep chart is the typical range. Every baby is different; if you\'re worried, talk to your doctor.'**
  String get reportSources;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @pastDays.
  ///
  /// In en, this message translates to:
  /// **'Past days'**
  String get pastDays;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @pickDate.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get pickDate;

  /// No description provided for @olderDay.
  ///
  /// In en, this message translates to:
  /// **'Day before'**
  String get olderDay;

  /// No description provided for @newerDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get newerDay;

  /// No description provided for @onThisDay.
  ///
  /// In en, this message translates to:
  /// **'On this day'**
  String get onThisDay;

  /// No description provided for @pumpingEntry.
  ///
  /// In en, this message translates to:
  /// **'Pumping'**
  String get pumpingEntry;

  /// No description provided for @nothingOnDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing was logged on this day.'**
  String get nothingOnDay;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetTitle;

  /// No description provided for @resetHelp.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a 6-digit code.'**
  String get resetHelp;

  /// No description provided for @resetCodeSentHelp.
  ///
  /// In en, this message translates to:
  /// **'If there\'s an account for this email, a code is on its way. Enter it with your new password.'**
  String get resetCodeSentHelp;

  /// No description provided for @sendCodeButton.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCodeButton;

  /// No description provided for @setPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Save new password'**
  String get setPasswordButton;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @repeatPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get repeatPasswordLabel;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'t match'**
  String get passwordsDontMatch;

  /// No description provided for @passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Your password has been changed.'**
  String get passwordChanged;

  /// No description provided for @passwordNotChanged.
  ///
  /// In en, this message translates to:
  /// **'You\'re signed in, but the new password wasn\'t saved. Try again from Settings.'**
  String get passwordNotChanged;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @illnessCold.
  ///
  /// In en, this message translates to:
  /// **'Cold'**
  String get illnessCold;

  /// No description provided for @illnessFever.
  ///
  /// In en, this message translates to:
  /// **'Fever'**
  String get illnessFever;

  /// No description provided for @illnessCough.
  ///
  /// In en, this message translates to:
  /// **'Cough'**
  String get illnessCough;

  /// No description provided for @illnessTummy.
  ///
  /// In en, this message translates to:
  /// **'Tummy bug'**
  String get illnessTummy;

  /// No description provided for @illnessEar.
  ///
  /// In en, this message translates to:
  /// **'Ear infection'**
  String get illnessEar;

  /// No description provided for @illnessRash.
  ///
  /// In en, this message translates to:
  /// **'Rash'**
  String get illnessRash;

  /// No description provided for @illnessUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unwell'**
  String get illnessUnnamed;

  /// No description provided for @startIllness.
  ///
  /// In en, this message translates to:
  /// **'Start tracking an illness'**
  String get startIllness;

  /// No description provided for @startIllnessButton.
  ///
  /// In en, this message translates to:
  /// **'Baby unwell? Start tracking an illness'**
  String get startIllnessButton;

  /// No description provided for @startIllnessHelp.
  ///
  /// In en, this message translates to:
  /// **'Symptoms, temperatures, medicine doses and doctor\'s visits from now on are shown together, day by day, until you mark the baby recovered.'**
  String get startIllnessHelp;

  /// No description provided for @editIllness.
  ///
  /// In en, this message translates to:
  /// **'Edit illness'**
  String get editIllness;

  /// No description provided for @illnessNameLabel.
  ///
  /// In en, this message translates to:
  /// **'What is it? (optional)'**
  String get illnessNameLabel;

  /// No description provided for @illnessStartedLabel.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get illnessStartedLabel;

  /// No description provided for @recoveredLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get recoveredLabel;

  /// No description provided for @recoveredOnLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovered on'**
  String get recoveredOnLabel;

  /// No description provided for @markRecovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get markRecovered;

  /// No description provided for @stillUnwell.
  ///
  /// In en, this message translates to:
  /// **'Still unwell'**
  String get stillUnwell;

  /// No description provided for @doctorVisit.
  ///
  /// In en, this message translates to:
  /// **'Doctor\'s visit'**
  String get doctorVisit;

  /// No description provided for @doctorLabel.
  ///
  /// In en, this message translates to:
  /// **'Doctor or clinic (optional)'**
  String get doctorLabel;

  /// No description provided for @diagnosisLabel.
  ///
  /// In en, this message translates to:
  /// **'What the doctor said (optional)'**
  String get diagnosisLabel;

  /// No description provided for @adviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Advice and medicines (optional)'**
  String get adviceLabel;

  /// No description provided for @nothingThisDay.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged this day.'**
  String get nothingThisDay;

  /// No description provided for @illnessDay.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String illnessDay(int day);

  /// No description provided for @illnessLasted.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String illnessLasted(int days);

  /// No description provided for @illnessStartedOn.
  ///
  /// In en, this message translates to:
  /// **'Started {date}'**
  String illnessStartedOn(String date);

  /// No description provided for @lastTemperature.
  ///
  /// In en, this message translates to:
  /// **'Last temperature: {temp} at {time}'**
  String lastTemperature(String temp, String time);

  /// No description provided for @highestTemperature.
  ///
  /// In en, this message translates to:
  /// **'Highest temperature: {temp}'**
  String highestTemperature(String temp);

  /// No description provided for @dosesToday.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 medicine dose today} other{{count} medicine doses today}}'**
  String dosesToday(int count);

  /// No description provided for @doctorVisitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 doctor\'s visit} other{{count} doctor\'s visits}}'**
  String doctorVisitsCount(int count);

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @vegFirstTitle.
  ///
  /// In en, this message translates to:
  /// **'Start with vegetables'**
  String get vegFirstTitle;

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes for babies'**
  String get recipesTitle;

  /// No description provided for @recipesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} home-style recipes, 6 to 12 months'**
  String recipesSubtitle(int count);

  /// No description provided for @recipesRules.
  ///
  /// In en, this message translates to:
  /// **'For babies: no salt, sugar, honey or stock cubes. Cook eggs until firm, take out every fish bone, and let food cool before serving. Take your baby\'s portion out before adding salt and chilli for the family.'**
  String get recipesRules;

  /// No description provided for @recipesFromMonths.
  ///
  /// In en, this message translates to:
  /// **'From {months} months'**
  String recipesFromMonths(int months);

  /// No description provided for @recipesNotYet.
  ///
  /// In en, this message translates to:
  /// **'Not yet for your baby'**
  String get recipesNotYet;

  /// No description provided for @recipeContains.
  ///
  /// In en, this message translates to:
  /// **'Contains: {allergens}'**
  String recipeContains(String allergens);

  /// No description provided for @recipeIngredients.
  ///
  /// In en, this message translates to:
  /// **'You need'**
  String get recipeIngredients;

  /// No description provided for @recipeSteps.
  ///
  /// In en, this message translates to:
  /// **'How to make it'**
  String get recipeSteps;

  /// No description provided for @recipeLogTry.
  ///
  /// In en, this message translates to:
  /// **'Log a try:'**
  String get recipeLogTry;

  /// No description provided for @recipesSource.
  ///
  /// In en, this message translates to:
  /// **'Based on NHS and WHO guidance for starting solids. A general guide, not medical advice; ask your doctor if your baby has allergies or eczema.'**
  String get recipesSource;

  /// No description provided for @pdfButton.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfButton;

  /// No description provided for @widgetLastFeed.
  ///
  /// In en, this message translates to:
  /// **'Last feed'**
  String get widgetLastFeed;

  /// No description provided for @widgetAsleep.
  ///
  /// In en, this message translates to:
  /// **'Asleep'**
  String get widgetAsleep;

  /// No description provided for @widgetAwake.
  ///
  /// In en, this message translates to:
  /// **'Awake'**
  String get widgetAwake;

  /// No description provided for @widgetEmpty.
  ///
  /// In en, this message translates to:
  /// **'Tap to open Palna'**
  String get widgetEmpty;

  /// No description provided for @widgetNextVaccine.
  ///
  /// In en, this message translates to:
  /// **'Next vaccines ({when}): {date}'**
  String widgetNextVaccine(String when, String date);

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @searchCountry.
  ///
  /// In en, this message translates to:
  /// **'Search countries'**
  String get searchCountry;

  /// No description provided for @allCountries.
  ///
  /// In en, this message translates to:
  /// **'All countries'**
  String get allCountries;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country where the baby lives'**
  String get countryLabel;

  /// No description provided for @countryHelp.
  ///
  /// In en, this message translates to:
  /// **'Used for the vaccine schedule and emergency numbers.'**
  String get countryHelp;

  /// No description provided for @vaccineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Vaccine name'**
  String get vaccineNameLabel;

  /// No description provided for @vaccineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Typhoid, Chickenpox, Flu'**
  String get vaccineNameHint;

  /// No description provided for @vaccineScheduleNoteCountry.
  ///
  /// In en, this message translates to:
  /// **'National schedule for {country}. Always confirm dates with your doctor or nurse; they can differ by region and vaccine brand.'**
  String vaccineScheduleNoteCountry(String country);

  /// No description provided for @vaccineScheduleNoteCanada.
  ///
  /// In en, this message translates to:
  /// **'Canada\'s national schedule. Each province has its own, so follow your province\'s schedule and your doctor\'s advice.'**
  String get vaccineScheduleNoteCanada;

  /// No description provided for @noScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'No built-in vaccine schedule for {country} yet'**
  String noScheduleTitle(String country);

  /// No description provided for @noScheduleBody.
  ///
  /// In en, this message translates to:
  /// **'Add each vaccine your baby gets below, and follow the schedule your doctor or health centre gives you.'**
  String get noScheduleBody;

  /// No description provided for @otherVaccines.
  ///
  /// In en, this message translates to:
  /// **'Other vaccines'**
  String get otherVaccines;

  /// No description provided for @otherVaccinesHelp.
  ///
  /// In en, this message translates to:
  /// **'Vaccines outside this schedule, such as private or travel vaccines, can be added here.'**
  String get otherVaccinesHelp;

  /// No description provided for @addOtherVaccine.
  ///
  /// In en, this message translates to:
  /// **'Add a vaccine'**
  String get addOtherVaccine;

  /// No description provided for @numAll.
  ///
  /// In en, this message translates to:
  /// **'Ambulance, fire and police'**
  String get numAll;

  /// No description provided for @numAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Ambulance'**
  String get numAmbulance;

  /// No description provided for @numNhs111.
  ///
  /// In en, this message translates to:
  /// **'NHS 111: urgent medical advice'**
  String get numNhs111;

  /// No description provided for @numPoison.
  ///
  /// In en, this message translates to:
  /// **'Poison Control'**
  String get numPoison;

  /// No description provided for @numNurseLine.
  ///
  /// In en, this message translates to:
  /// **'Nurse advice line (most provinces)'**
  String get numNurseLine;

  /// No description provided for @numUnified.
  ///
  /// In en, this message translates to:
  /// **'Unified emergency number'**
  String get numUnified;

  /// No description provided for @emergencyNumbersIn.
  ///
  /// In en, this message translates to:
  /// **'Emergency numbers ({country})'**
  String emergencyNumbersIn(String country);

  /// No description provided for @noEmergencyNumbers.
  ///
  /// In en, this message translates to:
  /// **'We don\'t have the numbers for this country yet. Save your local emergency number and your nearest children\'s hospital in your phone.'**
  String get noEmergencyNumbers;

  /// No description provided for @localEmergencyNumber.
  ///
  /// In en, this message translates to:
  /// **'your local emergency number'**
  String get localEmergencyNumber;

  /// No description provided for @weightGainTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight gain over the last month'**
  String get weightGainTitle;

  /// No description provided for @weightGainSummary.
  ///
  /// In en, this message translates to:
  /// **'About {gain} g a month (from two weights {days} days apart).'**
  String weightGainSummary(String gain, int days);

  /// No description provided for @weightGainRange.
  ///
  /// In en, this message translates to:
  /// **'Usual at this age (WHO): {low} to {high} g a month; the middle is {median} g.'**
  String weightGainRange(String low, String high, String median);

  /// No description provided for @weightGainUsual.
  ///
  /// In en, this message translates to:
  /// **'Within the usual range for babies this age.'**
  String get weightGainUsual;

  /// No description provided for @weightGainSlow.
  ///
  /// In en, this message translates to:
  /// **'Slower than most babies this age. One reading on its own isn\'t a diagnosis; mention it at the next check-up, and see a doctor sooner if your baby is feeding poorly, has few wet diapers or seems unwell.'**
  String get weightGainSlow;

  /// No description provided for @weightGainFast.
  ///
  /// In en, this message translates to:
  /// **'Faster than most babies this age. This is usually nothing to worry about; your doctor can look at it with the whole growth chart.'**
  String get weightGainFast;

  /// No description provided for @tabPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get tabPhotos;

  /// No description provided for @photosIntro.
  ///
  /// In en, this message translates to:
  /// **'One photo for each month: watch {name} grow. Tap a month to add its photo.'**
  String photosIntro(String name);

  /// No description provided for @photoNewborn.
  ///
  /// In en, this message translates to:
  /// **'Newborn'**
  String get photoNewborn;

  /// No description provided for @photoMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String photoMonths(int count);

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @photoCaptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption (optional)'**
  String get photoCaptionLabel;

  /// No description provided for @editCaption.
  ///
  /// In en, this message translates to:
  /// **'Edit caption'**
  String get editCaption;

  /// No description provided for @replacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replacePhoto;

  /// No description provided for @photoMonthTaken.
  ///
  /// In en, this message translates to:
  /// **'This month already has a photo. Open it and tap Replace.'**
  String get photoMonthTaken;
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
