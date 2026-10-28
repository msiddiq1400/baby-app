// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Palna';

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

  @override
  String get tabFeeding => 'Feeding';

  @override
  String get tabMilk => 'Milk';

  @override
  String get milkTitle => 'Breast milk';

  @override
  String get logPumping => 'Log pumping';

  @override
  String get editPumping => 'Edit pumping';

  @override
  String get addStoredMilk => 'Add stored milk';

  @override
  String pumpedToday(int ml, int count) {
    return 'Pumped today: $ml ml ($count times)';
  }

  @override
  String get storeMilkIn => 'Where is this milk now?';

  @override
  String get notStored => 'Fed right away';

  @override
  String get locationRoom => 'Room';

  @override
  String get locationCooler => 'Cooler with ice';

  @override
  String get locationFridge => 'Fridge';

  @override
  String get locationFreezer => 'Freezer';

  @override
  String get locationThawed => 'Thawed, in fridge';

  @override
  String get pumpedAtLabel => 'Pumped at';

  @override
  String pumpedOn(String date) {
    return 'Pumped $date';
  }

  @override
  String useBy(String time) {
    return 'Use by $time';
  }

  @override
  String get milkExpired => 'Expired: throw away';

  @override
  String milkNeedsAttention(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stored milk items expire soon or have expired.',
      one: '1 stored milk item expires soon or has expired.',
    );
    return '$_temp0';
  }

  @override
  String get useForFeed => 'Use for a feed';

  @override
  String get moveToFridge => 'Move to fridge';

  @override
  String get moveToCooler => 'Move to cooler';

  @override
  String get moveToFreezer => 'Freeze';

  @override
  String get thawMilk => 'Thaw in fridge';

  @override
  String get throwAway => 'Throw away';

  @override
  String get noStoredMilk => 'No stored milk.';

  @override
  String get noRefreeze => 'Don\'t refreeze';

  @override
  String get storageGuideTitle => 'How long milk keeps';

  @override
  String get storageGuide =>
      'Freshly pumped milk (CDC guidance):\n• Room, 25°C or cooler: up to 4 hours\n• Cooler bag with ice packs: up to 24 hours\n• Fridge: up to 4 days\n• Freezer: best within 6 months, up to 12 months\n\nThawed milk: use within 24 hours in the fridge, or within 2 hours once warmed. Never refreeze thawed milk.\nLeftover milk after a feed: use within 2 hours, then throw away.\n\nIn hot weather rooms are often hotter than 25°C, so put milk in the fridge or a cooler with ice right after pumping.';

  @override
  String get loadSheddingTitle => 'During load-shedding';

  @override
  String get loadSheddingGuide =>
      '• Keep the fridge and freezer closed. A closed fridge stays cold for about 4 hours; a full freezer for about 48 hours (24 if half full).\n• For longer outages, move milk to a cooler bag with ice or frozen gel packs. Keep a few packs frozen for this.\n• If frozen milk has thawed, don\'t refreeze it: keep it cold and use it within 24 hours.';

  @override
  String get milkExpiresTitle => 'Stored milk expires soon';

  @override
  String milkExpiresBody(int ml, String location, String time) {
    return '$ml ml ($location): use by $time';
  }

  @override
  String storedMilkTotal(int ml) {
    return '$ml ml';
  }

  @override
  String get tabSymptoms => 'Symptoms';

  @override
  String get logSymptom => 'Log symptom';

  @override
  String get editSymptom => 'Edit symptom';

  @override
  String get symptomFever => 'Fever';

  @override
  String get symptomCough => 'Cough';

  @override
  String get symptomRunnyNose => 'Runny nose';

  @override
  String get symptomVomiting => 'Vomiting';

  @override
  String get symptomDiarrhea => 'Diarrhoea';

  @override
  String get symptomConstipation => 'Constipation';

  @override
  String get symptomRash => 'Rash';

  @override
  String get symptomTeething => 'Teething';

  @override
  String get symptomFeedingRefusal => 'Refusing feeds';

  @override
  String get symptomCrying => 'Unusual crying';

  @override
  String get symptomCongestion => 'Blocked nose';

  @override
  String get symptomOther => 'Other';

  @override
  String get temperatureLabel => 'Temperature (optional)';

  @override
  String get invalidTemperature => 'Enter 30–45 °C or 86–113 °F';

  @override
  String get severityLabel => 'How bad?';

  @override
  String get severityMild => 'Mild';

  @override
  String get severityModerate => 'Moderate';

  @override
  String get severitySevere => 'Severe';

  @override
  String get youngFeverWarning =>
      'A temperature of 38°C (100.4°F) or higher in a baby under 3 months needs a doctor right away.';

  @override
  String get noSymptoms => 'No symptoms logged in the last 14 days.';

  @override
  String get doctorSummary => 'Summary for the doctor';

  @override
  String get summarySinceStart => 'Since symptoms started';

  @override
  String lastNDays(int count) {
    return 'Last $count days';
  }

  @override
  String get showInEnglish => 'In English (for the doctor)';

  @override
  String get shareButton => 'Share';

  @override
  String get copyButton => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String sumTitle(String name) {
    return 'Health summary: $name';
  }

  @override
  String sumAge(String age) {
    return 'Age: $age';
  }

  @override
  String sumPeriod(String from, String to) {
    return 'Period: $from to $to';
  }

  @override
  String sumWeight(String weight, String date) {
    return 'Latest weight: $weight ($date)';
  }

  @override
  String get sumSymptoms => 'Symptoms';

  @override
  String sumSymptomLine(String symptom, String first, String last, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$symptom: from $first to $last ($_temp0)';
  }

  @override
  String sumHighestTemp(String temp, String when) {
    return 'highest $temp on $when';
  }

  @override
  String sumFeedsPerDay(String days) {
    return 'Feeds per day: $days';
  }

  @override
  String sumWetPerDay(String days) {
    return 'Wet diapers per day: $days';
  }

  @override
  String sumDirtyPerDay(String days) {
    return 'Dirty diapers per day: $days';
  }

  @override
  String sumUsually(String count) {
    return 'usually about $count';
  }

  @override
  String sumTodaySoFar(int count) {
    return 'today so far $count';
  }

  @override
  String get sumMedicines => 'Medicines given';

  @override
  String sumMedicineLine(String name, String dose, int count, String when) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doses',
      one: '1 dose',
    );
    return '$name ($dose): $_temp0, last $when';
  }

  @override
  String get sumEntries => 'All entries';

  @override
  String get sumFooter => 'Recorded by the parent in Palna.';

  @override
  String get firstSyncLoading => 'Loading your family\'s data…';

  @override
  String get firstSyncNeedsInternet =>
      'The first time, this needs an internet connection. After that the app works offline.';

  @override
  String get unsyncedSignOutTitle => 'Some changes haven\'t synced yet';

  @override
  String get unsyncedSignOutBody =>
      'If you sign out now, entries made while offline will be lost. Connect to the internet first to keep them.';

  @override
  String get signOutAnyway => 'Sign out anyway';

  @override
  String get editBabyTitle => 'Edit baby';

  @override
  String get birthLengthLabel => 'Birth length in cm (optional)';

  @override
  String get birthHeadLabel => 'Birth head circumference in cm (optional)';

  @override
  String get invalidBirthLength => 'Enter a length between 20 and 70 cm';

  @override
  String get invalidBirthHead => 'Enter a size between 20 and 50 cm';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get babiesSection => 'Babies';

  @override
  String get addAnotherBaby => 'Add another baby';

  @override
  String get familySection => 'Family & caregivers';

  @override
  String get familyOffline =>
      'Connect to the internet to see and invite family members.';

  @override
  String get ownerLabel => 'Owner';

  @override
  String get caregiverLabel => 'Caregiver';

  @override
  String get youLabel => 'You';

  @override
  String get inviteCaregiver => 'Invite a caregiver';

  @override
  String get inviteCodeTitle => 'Invite code';

  @override
  String get inviteCodeHelp =>
      'Ask them to install the app, create an account and enter this code. It works once and expires in 7 days.';

  @override
  String inviteShareText(String name, String code) {
    return 'Join $name\'s family on Palna with this code: $code (valid for 7 days)';
  }

  @override
  String get joinFamily => 'Join a family with a code';

  @override
  String get joinFamilyPrompt => 'Joining a family? Enter the invite code';

  @override
  String get inviteCodeLabel => '6-character code';

  @override
  String get joinButton => 'Join';

  @override
  String get joinedFamily =>
      'You\'ve joined the family. Their data will appear in a moment.';

  @override
  String get invalidInvite => 'That code is wrong, already used, or expired.';

  @override
  String get removeMember => 'Remove';

  @override
  String get leaveFamily => 'Leave family';

  @override
  String removeMemberConfirm(String name) {
    return 'Remove $name from the family?';
  }

  @override
  String get leaveFamilyConfirm =>
      'Leave this family? You\'ll stop seeing its babies.';

  @override
  String get switchBaby => 'Switch baby';

  @override
  String awakeFor(String duration) {
    return 'Awake for $duration';
  }

  @override
  String nextNapAround(String from, String to) {
    return 'Next nap around $from–$to';
  }

  @override
  String bedtimeAround(String from, String to) {
    return 'Bedtime around $from–$to';
  }

  @override
  String napTimeNow(String to) {
    return 'Good time for a nap now (until $to)';
  }

  @override
  String bedtimeNow(String to) {
    return 'Good time for bed now (until $to)';
  }

  @override
  String get predictionFromAge =>
      'A guess from age until a week of sleep is logged';

  @override
  String get napTimesShort => 'Nap times';

  @override
  String get tabSolids => 'Solids';

  @override
  String get solidsTitle => 'Starting solids';

  @override
  String get solidsTooYoung =>
      'Most babies start solids around 6 months. You can read ahead in the meantime.';

  @override
  String get readinessTitle => 'Is my baby ready?';

  @override
  String get texturesTitle => 'How textures change';

  @override
  String get foodRulesTitle => 'Important rules';

  @override
  String get allergensTitle => 'Allergens';

  @override
  String get allergenNotYet => 'Not yet';

  @override
  String get allergenIntroduced => 'Introduced';

  @override
  String get allergenReaction => 'Reaction';

  @override
  String get reactionSignsTitle => 'Signs of an allergic reaction';

  @override
  String get beliefsTitle => 'Common beliefs vs evidence';

  @override
  String get beliefLabel => 'Often said';

  @override
  String get evidenceLabel => 'What the evidence says';

  @override
  String get foodsTitle => 'Foods';

  @override
  String get searchFoods => 'Search foods';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryFruit => 'Fruit';

  @override
  String get categoryVegetable => 'Vegetables';

  @override
  String get categoryGrain => 'Grains';

  @override
  String get categoryLegume => 'Daal & beans';

  @override
  String get categoryProtein => 'Meat, fish & egg';

  @override
  String get categoryDairy => 'Dairy';

  @override
  String get categoryNut => 'Nuts & seeds';

  @override
  String get categoryOther => 'Not yet';

  @override
  String fromMonths(int count) {
    return 'From $count months';
  }

  @override
  String get chokingRisk => 'Choking risk: prepare as described';

  @override
  String allergenLabel(String name) {
    return 'Allergen: $name';
  }

  @override
  String get logTry => 'Log a try';

  @override
  String get editTry => 'Edit try';

  @override
  String get notTried => 'Not tried yet';

  @override
  String triedTimes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tried $count times',
      one: 'Tried once',
    );
    return '$_temp0';
  }

  @override
  String get opinionLabel => 'Did they like it?';

  @override
  String get opinionLiked => 'Liked';

  @override
  String get opinionNeutral => 'Okay';

  @override
  String get opinionDisliked => 'Disliked';

  @override
  String get reactionLabel => 'Any reaction?';

  @override
  String get reactionNone => 'None';

  @override
  String get reactionMild => 'Mild';

  @override
  String get reactionSevere => 'Severe';

  @override
  String get reactionWarning =>
      'Had a reaction: talk to your doctor before giving this again.';

  @override
  String severeReactionNow(String number) {
    return 'If your baby has trouble breathing, swelling of the tongue or throat, or becomes floppy or pale, call $number now.';
  }

  @override
  String sourcesLabel(String sources) {
    return 'Sources: $sources';
  }

  @override
  String get tabCharts => 'Charts';

  @override
  String get tabMilestones => 'Milestones';

  @override
  String byMonths(int count) {
    return 'By $count months';
  }

  @override
  String get areaSocial => 'Social & emotional';

  @override
  String get areaLanguage => 'Language & communication';

  @override
  String get areaCognitive => 'Learning & thinking';

  @override
  String get areaMovement => 'Movement';

  @override
  String get waysToHelp => 'Ways to help';

  @override
  String get actEarlyTitle => 'When to talk to the doctor';

  @override
  String milestonesProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String reachedOn(String date) {
    return 'Reached $date';
  }

  @override
  String get helpTitle => 'Emergency & help';

  @override
  String get emergencyNumbersNote =>
      'Tap to call. Services differ by city; save your nearest children\'s hospital too.';

  @override
  String get numRescue => 'Rescue 1122: ambulance and emergencies';

  @override
  String get numEdhi => 'Edhi ambulance';

  @override
  String get numChhipa => 'Chhipa ambulance (Karachi)';

  @override
  String get numPolice => 'Police';

  @override
  String get numFire => 'Fire brigade';

  @override
  String get callEmergencyWhen => 'Call for help straight away if your baby';

  @override
  String get emergencySigns =>
      '• has difficulty breathing, or long pauses in breathing\n• is floppy, very drowsy or hard to wake\n• has blue, grey, pale or blotchy skin, lips or tongue, or feels cold\n• has a fit (seizure)\n• has swelling of the tongue or throat after a food or medicine';

  @override
  String get heatTitle => 'Hot weather and load-shedding';

  @override
  String get heatGuide =>
      '• Keep babies out of direct sun, especially 11 am to 3 pm, and never leave them in a parked car.\n• Dress them in one light cotton layer; use shade and a fan.\n• Breastfeed more often. Babies under 6 months who only have breast milk don\'t need water; ask your doctor about extra water for formula-fed babies.\n• During load-shedding, move to the coolest room and wipe your baby with a cloth dampened in lukewarm (not cold or iced) water.';

  @override
  String get dehydrationTitle => 'Signs of dehydration: see a doctor today';

  @override
  String get dehydrationSigns =>
      '• fewer wet diapers than usual\n• few or no tears when crying, or a dry mouth\n• a sunken soft spot on the head, or sunken eyes\n• unusually drowsy or irritable';

  @override
  String get helpSources =>
      'Based on NHS and WHO guidance. This is general information, not a diagnosis; if you\'re worried, contact a doctor.';

  @override
  String get accountSection => 'Account';

  @override
  String get dataSection => 'Your data';

  @override
  String get dataTitle => 'Export and import';

  @override
  String get dataSettingsHelp =>
      'Save everything as a spreadsheet, or bring in your log from Nara Baby or Huckleberry';

  @override
  String get exportTitle => 'Export';

  @override
  String exportHelp(String name) {
    return 'Everything logged for $name, as one CSV file. It opens in Excel or Google Sheets, and Palna can import it again.';
  }

  @override
  String get exportButton => 'Export as CSV';

  @override
  String exportSubject(String name) {
    return 'Palna log for $name';
  }

  @override
  String get importTitle => 'Import from another app';

  @override
  String importHelp(String name) {
    return 'Bring in feeds, sleep, diapers, pumping, growth, temperatures and activities. They are added to $name; entries already in Palna aren\'t doubled.';
  }

  @override
  String get importFromPalna => 'A Palna export';

  @override
  String get importStepsNara =>
      'In Nara Baby: on the Activity screen, tap your baby\'s picture, then Export Data. Save the CSV file, then choose it here.';

  @override
  String get importStepsHuckleberry =>
      'In Huckleberry: tap your child\'s icon, scroll down, tap Export tracking data as CSV. Open the emailed link, save the file, then choose it here.';

  @override
  String get importStepsPalna =>
      'A CSV file made with Export above, on this phone or another.';

  @override
  String get importChooseFile => 'Choose file';

  @override
  String get importChooseAnother => 'Choose another file';

  @override
  String get importWrongFile =>
      'This file can\'t be read. Please choose the CSV file exported from the app.';

  @override
  String get importExcelMangled =>
      'This file was opened and saved in Excel, which changes the times. Please export it again and choose it without opening it first.';

  @override
  String get importNothingFound => 'Nothing in this file can be imported.';

  @override
  String importFileBaby(String name) {
    return 'In the file: $name';
  }

  @override
  String importDates(String from, String to) {
    return '$from to $to';
  }

  @override
  String get importTemperatures => 'Temperatures';

  @override
  String importSkippedTitle(int count) {
    return 'Not imported: $count';
  }

  @override
  String get importSkipMedicine => 'Medicines (add them in Health)';

  @override
  String get importSkipSolids => 'Solid foods';

  @override
  String get importSkipMilestone => 'Milestones';

  @override
  String get importSkipVaccine => 'Vaccines (tick them in Health)';

  @override
  String get importSkipDry => 'Dry diapers';

  @override
  String get importSkipSleepGoing => 'Sleep without an end time';

  @override
  String get importSkipRange => 'Values out of range';

  @override
  String get importSkipUnreadable => 'Rows that couldn\'t be read';

  @override
  String importIntoBaby(String name) {
    return 'Everything will be added to $name.';
  }

  @override
  String importButton(int count, String name) {
    return 'Import $count entries into $name';
  }

  @override
  String get importWorking => 'Importing... Keep Palna open.';

  @override
  String importDone(int count, String name) {
    return 'Added $count entries to $name';
  }

  @override
  String importDuplicates(int count) {
    return '$count were already in Palna and were skipped.';
  }

  @override
  String get doneButton => 'Done';

  @override
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your login. Babies and entries in families that only you belong to are deleted too. In families you share, the other members keep everything, and if you\'re the owner, the next member becomes the owner. This can\'t be undone.';

  @override
  String get deleteAccountTypeHint => 'Type DELETE to confirm';

  @override
  String get deleteAccountButton => 'Delete forever';

  @override
  String appVersion(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get deleteAccountFailed =>
      'Couldn\'t delete your account. Check your internet connection and try again.';

  @override
  String get startFeedTimer => 'Start a timer';

  @override
  String lastSide(String side) {
    return 'Last feed: $side side';
  }

  @override
  String get orEnterMinutes => 'Or enter the minutes';

  @override
  String get leftMinutes => 'Left (minutes)';

  @override
  String get rightMinutes => 'Right (minutes)';

  @override
  String get feedTimerAlreadyRunning =>
      'A feed timer is already running. You\'ll find it at the top of the Today screen.';

  @override
  String get feedingNowTitle => 'Feeding now';

  @override
  String get feedingNow => 'feeding now';

  @override
  String get feedTimerPaused => 'Paused';

  @override
  String get feedTimerHelp =>
      'Tap a side to switch. Tap the running side to pause.';

  @override
  String get finishFeed => 'Finish';

  @override
  String get discardButton => 'Discard';

  @override
  String get discardFeedConfirm =>
      'Discard this feed? The timer and its times will be deleted.';

  @override
  String get asleepNap => 'Napping';

  @override
  String get asleepNight => 'Asleep for the night';

  @override
  String feedingNotificationTitle(String name) {
    return '$name is feeding';
  }

  @override
  String sleepNotificationTitle(String name) {
    return '$name is asleep';
  }

  @override
  String get reportsTitle => 'Reports';

  @override
  String periodDays(int count) {
    return '$count days';
  }

  @override
  String get feedsPerDay => 'Feeds a day';

  @override
  String get timeBetweenFeeds => 'Usual time between feeds';

  @override
  String get nursingPerDay => 'Breastfeeding a day';

  @override
  String get perBreastfeed => 'Per breastfeed';

  @override
  String get sideSplit => 'Left / right';

  @override
  String get bottlePerDay => 'Bottle milk a day';

  @override
  String get perBottle => 'Per bottle';

  @override
  String get sleepPerDay => 'Sleep a day';

  @override
  String get nightSleepPerDay => 'Night sleep';

  @override
  String get napsPerDay => 'Naps a day';

  @override
  String get napTimePerDay => 'Nap time a day';

  @override
  String get longestSleep => 'Longest sleep';

  @override
  String get awakeBetweenSleeps => 'Awake between sleeps';

  @override
  String get usualBedtime => 'Usual bedtime';

  @override
  String get usualWakeUp => 'Usual wake-up';

  @override
  String get wetPerDay => 'Wet a day';

  @override
  String get dirtyPerDay => 'Dirty a day';

  @override
  String hoursShort(int hours) {
    return '${hours}h';
  }

  @override
  String hoursRange(int from, int to) {
    return '$from–$to hours';
  }

  @override
  String typicalRange(String range) {
    return 'Typical for this age: $range';
  }

  @override
  String get newbornFeedsGuide =>
      'Breastfed newborns usually feed 8 to 12 times a day.';

  @override
  String get wetGuide =>
      'From day 5, 6 or more wet diapers a day is a sign of enough milk.';

  @override
  String get dirtyGuide =>
      'In the first 6 weeks, most breastfed babies have 2 or more dirty diapers a day.';

  @override
  String get reportNotEnough =>
      'Not enough entries yet. Keep logging and this fills in.';

  @override
  String get reportAveragesNote =>
      'Averages count only full days on which you logged that kind of entry; today isn\'t included yet.';

  @override
  String get reportSources =>
      'Typical ranges: National Sleep Foundation (under 4 months), American Academy of Sleep Medicine (4 months and older), NHS (feeds and diapers). The shaded band on the sleep chart is the typical range. Every baby is different; if you\'re worried, talk to your doctor.';

  @override
  String get journalTitle => 'Journal';

  @override
  String get pastDays => 'Past days';

  @override
  String get activities => 'Activities';

  @override
  String get activityTummyTime => 'Tummy time';

  @override
  String get activityBath => 'Bath';

  @override
  String get activityPlay => 'Play';

  @override
  String get activityOutdoors => 'Outdoors';

  @override
  String get activityReading => 'Reading';

  @override
  String get activityMassage => 'Massage';

  @override
  String get activityOther => 'Other';

  @override
  String get activityLabelHint => 'What was it? (e.g. swimming)';

  @override
  String get addActivity => 'Add activity';

  @override
  String get editActivity => 'Edit activity';

  @override
  String get activityShort => 'Activity';

  @override
  String get activityStartedLabel => 'Started';

  @override
  String get activityHowLong => 'How long';

  @override
  String get activityNotTimed => 'Not timed';

  @override
  String activityMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get activityStartTimer => 'Start timer';

  @override
  String get tummyTimer => 'Tummy timer';

  @override
  String get activityStop => 'Stop';

  @override
  String get activityStopNow => 'Stop now';

  @override
  String get activityRunning => 'Timer running';

  @override
  String activitySince(String time) {
    return 'Since $time';
  }

  @override
  String get activityTimerBusy =>
      'Another activity timer is running. Stop it first.';

  @override
  String get activitiesNoneToday => 'Tummy time, bath, play...';

  @override
  String get tummyTimeToday => 'Tummy time today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get pickDate => 'Choose a date';

  @override
  String get olderDay => 'Day before';

  @override
  String get newerDay => 'Next day';

  @override
  String get onThisDay => 'On this day';

  @override
  String get pumpingEntry => 'Pumping';

  @override
  String get nothingOnDay => 'Nothing was logged on this day.';

  @override
  String get journalNoPastDays =>
      'Past days will show here from tomorrow. Today\'s entries are on the Today tab.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetTitle => 'Reset your password';

  @override
  String get resetHelp =>
      'Enter your email and we\'ll send you a 6-digit code.';

  @override
  String get resetCodeSentHelp =>
      'If there\'s an account for this email, a code is on its way. Enter it with your new password.';

  @override
  String get sendCodeButton => 'Send code';

  @override
  String get setPasswordButton => 'Save new password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get repeatPasswordLabel => 'Repeat new password';

  @override
  String get passwordsDontMatch => 'The passwords don\'t match';

  @override
  String get passwordChanged => 'Your password has been changed.';

  @override
  String get passwordNotChanged =>
      'You\'re signed in, but the new password wasn\'t saved. Try again from Settings.';

  @override
  String get changePassword => 'Change password';

  @override
  String get illnessCold => 'Cold';

  @override
  String get illnessFever => 'Fever';

  @override
  String get illnessCough => 'Cough';

  @override
  String get illnessTummy => 'Tummy bug';

  @override
  String get illnessEar => 'Ear infection';

  @override
  String get illnessRash => 'Rash';

  @override
  String get illnessUnnamed => 'Unwell';

  @override
  String get startIllness => 'Start tracking an illness';

  @override
  String get startIllnessButton => 'Baby unwell? Start tracking an illness';

  @override
  String get startIllnessHelp =>
      'Symptoms, temperatures, medicine doses and doctor\'s visits from now on are shown together, day by day, until you mark the baby recovered.';

  @override
  String get editIllness => 'Edit illness';

  @override
  String get illnessNameLabel => 'What is it? (optional)';

  @override
  String get illnessStartedLabel => 'Started';

  @override
  String get recoveredLabel => 'Recovered';

  @override
  String get recoveredOnLabel => 'Recovered on';

  @override
  String get markRecovered => 'Recovered';

  @override
  String get stillUnwell => 'Still unwell';

  @override
  String get doctorVisit => 'Doctor\'s visit';

  @override
  String get doctorLabel => 'Doctor or clinic (optional)';

  @override
  String get diagnosisLabel => 'What the doctor said (optional)';

  @override
  String get adviceLabel => 'Advice and medicines (optional)';

  @override
  String get nothingThisDay => 'Nothing logged this day.';

  @override
  String illnessDay(int day) {
    return 'Day $day';
  }

  @override
  String illnessLasted(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String illnessStartedOn(String date) {
    return 'Started $date';
  }

  @override
  String lastTemperature(String temp, String time) {
    return 'Last temperature: $temp at $time';
  }

  @override
  String highestTemperature(String temp) {
    return 'Highest temperature: $temp';
  }

  @override
  String dosesToday(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count medicine doses today',
      one: '1 medicine dose today',
    );
    return '$_temp0';
  }

  @override
  String doctorVisitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count doctor\'s visits',
      one: '1 doctor\'s visit',
    );
    return '$_temp0';
  }

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get themeSystem => 'Phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get vegFirstTitle => 'Start with vegetables';

  @override
  String get recipesTitle => 'Recipes for babies';

  @override
  String recipesSubtitle(int count) {
    return '$count home-style recipes, 6 to 12 months';
  }

  @override
  String get recipesRules =>
      'For babies: no salt, sugar, honey or stock cubes. Cook eggs until firm, take out every fish bone, and let food cool before serving. Take your baby\'s portion out before adding salt and chilli for the family.';

  @override
  String recipesFromMonths(int months) {
    return 'From $months months';
  }

  @override
  String get recipesNotYet => 'Not yet for your baby';

  @override
  String recipeContains(String allergens) {
    return 'Contains: $allergens';
  }

  @override
  String get recipeIngredients => 'You need';

  @override
  String get recipeSteps => 'How to make it';

  @override
  String get recipeLogTry => 'Log a try:';

  @override
  String get recipesSource =>
      'Based on NHS and WHO guidance for starting solids. A general guide, not medical advice; ask your doctor if your baby has allergies or eczema.';

  @override
  String get pdfButton => 'PDF';

  @override
  String get widgetLastFeed => 'Last feed';

  @override
  String get widgetAsleep => 'Asleep';

  @override
  String get widgetAwake => 'Awake';

  @override
  String get widgetEmpty => 'Tap to open Palna';

  @override
  String widgetNextVaccine(String when, String date) {
    return 'Next vaccines ($when): $date';
  }

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get searchCountry => 'Search countries';

  @override
  String get allCountries => 'All countries';

  @override
  String get countryLabel => 'Country where the baby lives';

  @override
  String get countryHelp =>
      'Used for the vaccine schedule and emergency numbers.';

  @override
  String get vaccineNameLabel => 'Vaccine name';

  @override
  String get vaccineNameHint => 'e.g. Typhoid, Chickenpox, Flu';

  @override
  String vaccineScheduleNoteCountry(String country) {
    return 'National schedule for $country. Always confirm dates with your doctor or nurse; they can differ by region and vaccine brand.';
  }

  @override
  String get vaccineScheduleNoteCanada =>
      'Canada\'s national schedule. Each province has its own, so follow your province\'s schedule and your doctor\'s advice.';

  @override
  String noScheduleTitle(String country) {
    return 'No built-in vaccine schedule for $country yet';
  }

  @override
  String get noScheduleBody =>
      'Add each vaccine your baby gets below, and follow the schedule your doctor or health centre gives you.';

  @override
  String get otherVaccines => 'Other vaccines';

  @override
  String get otherVaccinesHelp =>
      'Vaccines outside this schedule, such as private or travel vaccines, can be added here.';

  @override
  String get addOtherVaccine => 'Add a vaccine';

  @override
  String get numAll => 'Ambulance, fire and police';

  @override
  String get numAmbulance => 'Ambulance';

  @override
  String get numNhs111 => 'NHS 111: urgent medical advice';

  @override
  String get numPoison => 'Poison Control';

  @override
  String get numNurseLine => 'Nurse advice line (most provinces)';

  @override
  String get numUnified => 'Unified emergency number';

  @override
  String emergencyNumbersIn(String country) {
    return 'Emergency numbers ($country)';
  }

  @override
  String get noEmergencyNumbers =>
      'We don\'t have the numbers for this country yet. Save your local emergency number and your nearest children\'s hospital in your phone.';

  @override
  String get localEmergencyNumber => 'your local emergency number';

  @override
  String get weightGainTitle => 'Weight gain over the last month';

  @override
  String weightGainSummary(String gain, int days) {
    return 'About $gain g a month (from two weights $days days apart).';
  }

  @override
  String weightGainRange(String low, String high, String median) {
    return 'Usual at this age (WHO): $low to $high g a month; the middle is $median g.';
  }

  @override
  String get weightGainUsual => 'Within the usual range for babies this age.';

  @override
  String get weightGainSlow =>
      'Slower than most babies this age. One reading on its own isn\'t a diagnosis; mention it at the next check-up, and see a doctor sooner if your baby is feeding poorly, has few wet diapers or seems unwell.';

  @override
  String get weightGainFast =>
      'Faster than most babies this age. This is usually nothing to worry about; your doctor can look at it with the whole growth chart.';

  @override
  String get tabPhotos => 'Photos';

  @override
  String photosIntro(String name) {
    return 'One photo for each month: watch $name grow. Tap a month to add its photo.';
  }

  @override
  String get photoNewborn => 'Newborn';

  @override
  String photoMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String get addPhoto => 'Add photo';

  @override
  String get takePhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get photoCaptionLabel => 'Caption (optional)';

  @override
  String get editCaption => 'Edit caption';

  @override
  String get replacePhoto => 'Replace';

  @override
  String get photoMonthTaken =>
      'This month already has a photo. Open it and tap Replace.';

  @override
  String get diaperBoth => 'Both';

  @override
  String get diaperTapToSave => 'Tap one to save.';

  @override
  String get addPastSleep => 'Add a past sleep';

  @override
  String sleepUsualShort(String usual) {
    return 'Usually about $usual a day';
  }

  @override
  String get addPastFeed => 'Add a past feed';

  @override
  String get addPastDiaper => 'Add a past diaper';

  @override
  String nextFeedAround(String time) {
    return 'Next feed may be around $time';
  }

  @override
  String get pastFeedShort => 'Past feed';

  @override
  String get pastSleepShort => 'Past sleep';

  @override
  String get pastDiaperShort => 'Past diaper';

  @override
  String get startSleepTitle => 'Start a sleep';

  @override
  String get chartFeedsPerDay => 'Feeds each day';

  @override
  String get chartFeedTimes => 'When feeds happen';

  @override
  String get chartBottleMl => 'Bottle milk each day (ml)';

  @override
  String get chartSleepPerDay => 'Sleep each day';

  @override
  String get chartSleepPattern => 'Sleep pattern';

  @override
  String get chartLongestSleep => 'Longest sleep each day';

  @override
  String get chartDiapersPerDay => 'Diapers each day';

  @override
  String get chartDiaperTimes => 'When diapers happen';

  @override
  String get nightFeedsPerDay => 'Night feeds (10 pm–6 am)';

  @override
  String get legendBottle => 'Bottle';

  @override
  String get legendNight => 'Night (7 pm–6 am)';

  @override
  String get solidsTabGuides => 'Guides';

  @override
  String get solidsTabRecipes => 'Recipes';

  @override
  String solidsFoodsProgress(int tried, int total) {
    return '$tried of $total foods tried';
  }

  @override
  String solidsAllergensProgress(int introduced, int total) {
    return '$introduced of $total allergens introduced';
  }

  @override
  String get foodsTried => 'Tried';

  @override
  String get growthCheckTitle => 'Growth check';

  @override
  String get growthCheckDoctorTitle => 'Talk to your doctor';

  @override
  String get growthCheckMentionTitle => 'Mention it at the next check-up';

  @override
  String get growthCheckOkTitle => 'Growing as expected';

  @override
  String get growthCheckOkBody =>
      'The measurements you\'ve entered are within the usual range for babies this age.';

  @override
  String get growthCheckDoctorBody =>
      'This is often nothing serious, but a doctor should look at the whole chart. Book a visit in the next few days. Go today if your baby is feeding poorly, has few wet diapers or seems unwell.';

  @override
  String get growthCheckMentionBody =>
      'Usually nothing to worry about. Show the chart to your doctor at the next visit.';

  @override
  String get growthCheckTypo =>
      'If a number looks wrong, tap it in the list below to check it was entered correctly.';

  @override
  String get growthMeasureWeight => 'Weight';

  @override
  String get growthMeasureLength => 'Length';

  @override
  String get growthMeasureHead => 'Head size';

  @override
  String growthFlagBelowRange(String measure) {
    return '$measure is below the lowest grey line (under the 3rd percentile).';
  }

  @override
  String growthFlagAboveRange(String measure) {
    return '$measure is above the highest grey line (over the 97th percentile).';
  }

  @override
  String growthFlagFallingAcross(String measure) {
    return '$measure has dropped across two grey lines in the last few months.';
  }

  @override
  String growthFlagRisingAcross(String measure) {
    return '$measure has climbed across two grey lines in the last few months.';
  }

  @override
  String get growthFlagBelowBirthWeight =>
      'Weight is still below the birth weight after two weeks. Most babies are back to their birth weight by then.';

  @override
  String get growthFlagSlowGain =>
      'Weight gain over the last month is slower than most babies this age.';

  @override
  String percentileMeaningWeight(String percentile) {
    return 'Heavier than about $percentile in 100 babies of the same age and sex.';
  }

  @override
  String percentileMeaningLength(String percentile) {
    return 'Longer than about $percentile in 100 babies of the same age and sex.';
  }

  @override
  String percentileMeaningHead(String percentile) {
    return 'Bigger head than about $percentile in 100 babies of the same age and sex.';
  }

  @override
  String get percentileExplainTitle => 'What do percentiles mean?';

  @override
  String get legendYourBaby => 'Your baby';

  @override
  String get legendWhoCurves => 'WHO curves, 3rd to 97th percentile';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSettingsHelp =>
      'When someone else logs a feed, sleep or medicine';

  @override
  String get pushIntro =>
      'Get a notification on this phone when someone else in your family logs:';

  @override
  String get pushFeedsHelp => 'Feeds, and when breastfeeding starts and ends';

  @override
  String get pushSleepHelp => 'Fell asleep and woke up';

  @override
  String get pushMedicines => 'Medicine doses';

  @override
  String get pushMedicinesHelp =>
      'When a dose is given, so nobody gives it twice';

  @override
  String get quietHours => 'Quiet hours';

  @override
  String quietHoursOn(String from, String to) {
    return 'No family notifications from $from to $to';
  }

  @override
  String get quietHoursOff => 'Off: notifications come at any time';

  @override
  String get quietFrom => 'From';

  @override
  String get quietTo => 'To';

  @override
  String get pushFooter =>
      'You never get notified about what you log yourself. Vaccine and medicine reminders on this phone don\'t change.';

  @override
  String get pushUnavailable =>
      'Notifications from your family aren\'t available on this phone yet. Your choices below are saved for when they are.';

  @override
  String get numOutOfHoursDoctor => 'Out-of-hours doctor';

  @override
  String get numHealthAdvice => 'Health advice line (24 hours)';

  @override
  String get optionalVaccinesTitle => 'Optional – ask your doctor';

  @override
  String optionalVaccinesHelp(String country) {
    return 'Offered to all babies in $country, but not part of the routine schedule. Ask your doctor or clinic whether your baby should have them.';
  }

  @override
  String get optionalVaccinesHide => 'Hide';

  @override
  String get optionalVaccinesHidden =>
      'Optional RSV and flu reminders are hidden.';

  @override
  String get optionalVaccinesShow => 'Show';

  @override
  String get rsvName => 'RSV protection (antibody injection)';

  @override
  String get rsvNote =>
      'Protects against RSV, a common chest infection that is most serious in young babies. If the mother had the RSV vaccine in pregnancy, the baby may not need it.';

  @override
  String fluName(String season) {
    return 'Flu vaccine $season';
  }

  @override
  String get fluNote => 'Given once a year, before and during the flu season.';

  @override
  String fluNoteFirst(int age) {
    return 'The first time, children under $age years usually need 2 doses, 4 weeks apart.';
  }

  @override
  String get fluNoteNasal =>
      'Usually given as a nasal spray, which contains pork gelatine. You can ask for an injection instead.';

  @override
  String optionalReminderTitle(String name, String vaccine) {
    return '$name: $vaccine (optional)';
  }

  @override
  String get optionalReminderBody =>
      'Ask your doctor or clinic whether to have it.';

  @override
  String get proTitle => 'Palna Pro';

  @override
  String get proIntro => 'Everything in Free, plus:';

  @override
  String get proFeatureBabies => 'Twins, siblings: add every baby';

  @override
  String get proFeaturePhotos =>
      'Up to 10 photos a month for each baby (Free: 1)';

  @override
  String get proFeatureReports =>
      '30-day reports, and the PDF summary for the doctor';

  @override
  String get proFeaturePredictions =>
      'Next nap and bedtime, from your baby\'s own pattern';

  @override
  String get proReasonPredictions =>
      'Next nap and bedtime times are part of Palna Pro';

  @override
  String get proFeatureThemes =>
      'Colour themes, and today\'s totals on the home-screen widget';

  @override
  String get proFamilyNote =>
      'One subscription covers the whole family: everyone you share the baby with gets Pro too.';

  @override
  String get proYearly => 'Yearly';

  @override
  String get proMonthly => 'Monthly';

  @override
  String proPricePerYear(String price) {
    return '$price / year';
  }

  @override
  String proPricePerMonth(String price) {
    return '$price / month';
  }

  @override
  String proPricePerDay(String price) {
    return 'That\'s about $price a day';
  }

  @override
  String proSave(int percent) {
    return 'Save $percent%';
  }

  @override
  String proTrialDays(int days) {
    return '$days days free';
  }

  @override
  String get proStartTrial => 'Start free trial';

  @override
  String get proSubscribe => 'Subscribe';

  @override
  String get proRestore => 'Restore purchases';

  @override
  String get proLegalApple =>
      'Payment is charged to your Apple ID. The subscription renews automatically unless you cancel it at least 24 hours before the period ends; manage or cancel it in your Apple ID settings. After a free trial, the price above is charged.';

  @override
  String get proLegalGoogle =>
      'Payment is charged to your Google Play account. The subscription renews automatically unless you cancel it before the period ends; manage or cancel it in Google Play > Payments and subscriptions. After a free trial, the price above is charged.';

  @override
  String get proTerms => 'Terms of use';

  @override
  String get proPrivacy => 'Privacy policy';

  @override
  String get proUnavailable =>
      'Palna Pro can\'t be bought on this phone yet. Everything else works as usual.';

  @override
  String get proActive => 'Your family has Palna Pro';

  @override
  String proActiveUntil(String date) {
    return 'Until $date';
  }

  @override
  String get proThanks => 'Thank you for supporting Palna!';

  @override
  String get proManage => 'Manage subscription';

  @override
  String get proLifetime => 'Lifetime';

  @override
  String proPriceOnce(String price) {
    return '$price once';
  }

  @override
  String get proLifetimeNote => 'Pay once: Pro for your whole family, for good';

  @override
  String get proNoSubscription => 'No subscription';

  @override
  String get proBuyOnce => 'Buy once';

  @override
  String get proActiveForLife => 'For life, no subscription';

  @override
  String get proLegalLifetime =>
      'Lifetime is a one-time purchase: it is charged once and never renews.';

  @override
  String get proRestoreNone =>
      'No Palna Pro purchase was found for this store account.';

  @override
  String get proError => 'The purchase didn\'t go through. Please try again.';

  @override
  String get proReasonBabies => 'Add more than one baby with Palna Pro';

  @override
  String get proReasonPhotos => 'Add more photos for this month with Palna Pro';

  @override
  String get proReasonReports => 'See 30 days at a time with Palna Pro';

  @override
  String get proReasonPdf =>
      'The PDF summary for the doctor is part of Palna Pro';

  @override
  String get proReasonThemes => 'Colour themes are part of Palna Pro';

  @override
  String get proBadge => 'PRO';

  @override
  String get settingsProFree => 'Free plan · see what Pro adds';

  @override
  String get settingsProActive => 'Pro, for your whole family';

  @override
  String get photoAddAnother => 'Add another';

  @override
  String get photoMonthFull =>
      'This month has 10 photos, the most for one month.';

  @override
  String get themeColour => 'Colour';

  @override
  String get themeNavy => 'Navy';

  @override
  String get themeRose => 'Rose';

  @override
  String get themeSage => 'Sage';

  @override
  String get themeLavender => 'Lavender';

  @override
  String widgetToday(int feeds, int diapers, String sleep) {
    return 'Today: $feeds feeds · $diapers diapers · $sleep sleep';
  }
}
