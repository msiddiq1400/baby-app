// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Baby App';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get fieldRequired => 'Required';

  @override
  String get saveButton => 'Save';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get language => 'Language';

  @override
  String get signOut => 'Sign out';

  @override
  String get signInTitle => 'Welcome';

  @override
  String get signInSubtitle => 'Track feeds, sleep and more for your baby';

  @override
  String get nameLabel => 'Your name';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get invalidEmail => 'Enter a valid email';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signUpButton => 'Create account';

  @override
  String get switchToSignUp => 'New here? Create an account';

  @override
  String get verifyTitle => 'Enter your code';

  @override
  String verifySubtitle(String email) {
    return 'We sent a 6-digit code to $email';
  }

  @override
  String get codeLabel => '6-digit code';

  @override
  String get verifyButton => 'Confirm';

  @override
  String get resendCode => 'Send a new code';

  @override
  String resendIn(int seconds) {
    return 'Send a new code in ${seconds}s';
  }

  @override
  String get codeSent => 'A new code has been sent';

  @override
  String get invalidCode => 'That code is wrong or has expired';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'or';

  @override
  String get switchToSignIn => 'Already have an account? Sign in';

  @override
  String get addBabyTitle => 'Add your baby';

  @override
  String get babyNameLabel => 'Baby\'s name';

  @override
  String get birthDateLabel => 'Date of birth';

  @override
  String get sexLabel => 'Sex (optional)';

  @override
  String get sexFemale => 'Girl';

  @override
  String get sexMale => 'Boy';

  @override
  String get birthWeightLabel => 'Birth weight in kg (optional)';

  @override
  String get invalidWeight => 'Enter a weight between 0.3 and 7 kg';

  @override
  String ageMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String ageDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String durationHm(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String durationM(int minutes) {
    return '${minutes}m';
  }

  @override
  String agoLabel(String duration) {
    return '$duration ago';
  }

  @override
  String get feeds => 'Feeds';

  @override
  String get diapers => 'Diapers';

  @override
  String get sleep => 'Sleep';

  @override
  String bottleTotal(int ml) {
    return '$ml ml by bottle';
  }

  @override
  String lastFeed(String ago) {
    return 'Last: $ago';
  }

  @override
  String diaperCounts(int wet, int dirty) {
    return '$wet wet · $dirty dirty';
  }

  @override
  String sleepingSince(String time) {
    return 'Sleeping since $time';
  }

  @override
  String get sleptToday => 'Slept today';

  @override
  String get logFeed => 'Feed';

  @override
  String get logDiaper => 'Diaper';

  @override
  String get startSleep => 'Sleep';

  @override
  String get endSleep => 'Woke up';

  @override
  String get feedTypeBreast => 'Breast';

  @override
  String get feedTypeBottleBreastMilk => 'Expressed milk';

  @override
  String get feedTypeFormula => 'Formula';

  @override
  String get sideLeft => 'Left';

  @override
  String get sideRight => 'Right';

  @override
  String get sideBoth => 'Both';

  @override
  String get amountMl => 'Amount (ml)';

  @override
  String get feedMinutes => 'Duration in minutes (optional)';

  @override
  String get invalidAmount => 'Enter an amount between 1 and 1000 ml';

  @override
  String get invalidMinutes => 'Enter minutes between 1 and 180';

  @override
  String get diaperWet => 'Wet';

  @override
  String get diaperDirty => 'Dirty';

  @override
  String get chooseDiaper => 'Choose wet, dirty or both';

  @override
  String get timeLabel => 'Time';

  @override
  String get sleepNap => 'Nap';

  @override
  String get sleepNight => 'Night sleep';

  @override
  String get sleepingNow => 'sleeping';

  @override
  String get todayTimeline => 'Today';

  @override
  String get nothingLoggedToday => 'Nothing logged yet today';

  @override
  String get tabToday => 'Today';

  @override
  String get tabGrowth => 'Growth';

  @override
  String get deleteButton => 'Delete';

  @override
  String get deleteConfirmTitle => 'Delete this entry?';

  @override
  String get editFeed => 'Edit feed';

  @override
  String get editDiaper => 'Edit diaper';

  @override
  String get editSleep => 'Edit sleep';

  @override
  String get sleepStartLabel => 'Fell asleep';

  @override
  String get sleepEndLabel => 'Woke up';

  @override
  String get stillAsleep => 'Still asleep';

  @override
  String get invalidSleepTimes => 'Wake-up time must be after falling asleep';

  @override
  String get growthTitle => 'Growth';

  @override
  String get addMeasurement => 'Add measurement';

  @override
  String get editMeasurement => 'Edit measurement';

  @override
  String get dateLabel => 'Date';

  @override
  String get weightKgLabel => 'Weight (kg)';

  @override
  String get lengthCmLabel => 'Length (cm)';

  @override
  String get headCmLabel => 'Head circumference (cm)';

  @override
  String get enterOneMeasurement => 'Enter at least one measurement';

  @override
  String get invalidWeightKg => 'Enter a weight between 0.3 and 40 kg';

  @override
  String get invalidLengthCm => 'Enter a length between 20 and 130 cm';

  @override
  String get invalidHeadCm => 'Enter a size between 20 and 60 cm';

  @override
  String get metricWeight => 'Weight';

  @override
  String get metricLength => 'Length';

  @override
  String get metricHead => 'Head';

  @override
  String percentileValue(String percentile) {
    return 'Percentile: $percentile';
  }

  @override
  String changeSince(String change, String date) {
    return '$change since $date';
  }

  @override
  String get atBirth => 'At birth';

  @override
  String get noMeasurements =>
      'No measurements yet. Add one after your next weigh-in.';

  @override
  String get chooseSexForChart =>
      'To compare with the WHO growth curves, choose:';

  @override
  String get curvesLegend =>
      'Grey lines: WHO Child Growth Standards, 3rd to 97th percentile. Your baby: coloured line.';

  @override
  String get percentileExplain =>
      'A percentile compares your baby with others of the same age and sex; the 50th is the middle. A steady curve over time matters more than any single number. Talk to your doctor if the line crosses two of the grey curves or flattens out.';

  @override
  String get whoAgeLimit => 'WHO curves in the app cover birth to 24 months.';

  @override
  String get tabHealth => 'Health';

  @override
  String get vaccinesTitle => 'Vaccinations';

  @override
  String get vaccineScheduleNote =>
      'Pakistan EPI schedule (government vaccination programme). Always confirm dates with your vaccinator or pediatrician.';

  @override
  String get visitAtBirth => 'At birth';

  @override
  String visitWeeks(int count) {
    return '$count weeks';
  }

  @override
  String visitMonths(int count) {
    return '$count months';
  }

  @override
  String dueOn(String date) {
    return 'Due $date';
  }

  @override
  String get statusDone => 'All given';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusDueSoon => 'Due soon';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String givenOn(String date) {
    return 'Given $date';
  }

  @override
  String get markGiven => 'Given';

  @override
  String get markVisitGiven => 'Mark all as given';

  @override
  String get recordVaccination => 'Record vaccination';

  @override
  String get editVaccination => 'Edit vaccination';

  @override
  String get dateGivenLabel => 'Date given';

  @override
  String get batchLabel => 'Batch number (optional)';

  @override
  String get clinicLabel => 'Clinic or doctor (optional)';

  @override
  String get notesLabel => 'Notes (optional)';

  @override
  String nextVisit(String visit, String date) {
    return 'Next: $visit, $date';
  }

  @override
  String get allVaccinesDone => 'All scheduled vaccines are recorded.';

  @override
  String get catchUpNote =>
      'Missed a vaccine? Most can still be given late, and the series usually doesn\'t need to restart. Ask your vaccinator or pediatrician about a catch-up plan.';

  @override
  String vaccinesDueTomorrow(String name) {
    return '$name\'s vaccines are due tomorrow';
  }

  @override
  String vaccinesDueToday(String name) {
    return '$name\'s vaccines are due today';
  }

  @override
  String vaccinesOverdueReminder(String name) {
    return '$name\'s vaccines are overdue';
  }

  @override
  String get healthTitle => 'Health';

  @override
  String get tabVaccines => 'Vaccines';

  @override
  String get tabMedicines => 'Medicines';

  @override
  String get addMedicine => 'Add medicine';

  @override
  String get editMedicine => 'Edit medicine';

  @override
  String get medicineNameLabel => 'Medicine name';

  @override
  String get prescribedDoseLabel =>
      'Dose prescribed by the doctor (e.g. 2.5 ml)';

  @override
  String get scheduleAtTimes => 'At set times';

  @override
  String get scheduleAsNeeded => 'When needed';

  @override
  String get doseTimesLabel => 'Dose times';

  @override
  String get addTime => 'Add time';

  @override
  String get presetOnce => 'Once a day';

  @override
  String get presetTwice => '2 times a day';

  @override
  String get presetThrice => '3 times a day';

  @override
  String get presetEvery6h => 'Every 6 hours';

  @override
  String get chooseTimes => 'Add at least one time';

  @override
  String get startDateLabel => 'Start date';

  @override
  String get durationDaysLabel => 'For how many days? (empty if ongoing)';

  @override
  String get invalidDays => 'Enter between 1 and 365 days';

  @override
  String get prescribedByLabel => 'Prescribed by (optional)';

  @override
  String get medicineSafetyNote =>
      'Give medicines only as your doctor prescribed. This app stores the prescription and reminds you; it never calculates or suggests a dose.';

  @override
  String get noMedicines => 'No medicines added.';

  @override
  String get finishedMedicines => 'Finished';

  @override
  String untilDate(String date) {
    return 'Until $date';
  }

  @override
  String get ongoing => 'Ongoing';

  @override
  String get doseGiven => 'Given';

  @override
  String get doseSkipped => 'Skipped';

  @override
  String get doseMissed => 'Missed';

  @override
  String get markDoseGiven => 'Given';

  @override
  String get skipDose => 'Skip';

  @override
  String get undoDose => 'Undo';

  @override
  String get recordDoseNow => 'Record a dose now';

  @override
  String lastGiven(String time) {
    return 'Last given $time';
  }

  @override
  String medicineReminderTitle(String name) {
    return 'Medicine time for $name';
  }

  @override
  String medicineReminderBody(String medicine, String dose) {
    return '$medicine: $dose';
  }
}
