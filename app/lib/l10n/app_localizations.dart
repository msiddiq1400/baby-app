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
  /// **'Freshly pumped milk (CDC guidance):\n• Room, 25°C or cooler: up to 4 hours\n• Cooler bag with ice packs: up to 24 hours\n• Fridge: up to 4 days\n• Freezer: best within 6 months, up to 12 months\n\nThawed milk: use within 24 hours in the fridge, or within 2 hours once warmed. Never refreeze thawed milk.\nLeftover milk after a feed: use within 2 hours, then throw away.\n\nIn Pakistani summers rooms are often hotter than 25°C, so put milk in the fridge or a cooler with ice right after pumping.'**
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
  /// **'Recorded by the parent in Baby App.'**
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
