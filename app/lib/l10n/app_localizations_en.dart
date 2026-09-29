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
      'Freshly pumped milk (CDC guidance):\n• Room, 25°C or cooler: up to 4 hours\n• Cooler bag with ice packs: up to 24 hours\n• Fridge: up to 4 days\n• Freezer: best within 6 months, up to 12 months\n\nThawed milk: use within 24 hours in the fridge, or within 2 hours once warmed. Never refreeze thawed milk.\nLeftover milk after a feed: use within 2 hours, then throw away.\n\nIn Pakistani summers rooms are often hotter than 25°C, so put milk in the fridge or a cooler with ice right after pumping.';

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
  String get offlineBanner =>
      'Offline: changes are saved and will sync when you\'re back online.';

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
  String get atAGlance => 'At a glance';

  @override
  String hungerEstimate(String interval, String time) {
    return 'Usually feeds about every $interval, so the next feed may be around $time.';
  }

  @override
  String get hungerDisclaimer =>
      'A rough guide from recent feeds; always follow your baby\'s hunger cues.';

  @override
  String sleepUsual(String usual, String today) {
    return 'Usually sleeps about $usual a day. Today so far: $today.';
  }

  @override
  String awakeFor(String duration) {
    return 'Awake for $duration';
  }

  @override
  String usuallyAwake(String duration) {
    return 'usually about $duration between sleeps';
  }

  @override
  String vaccinesOverdueLine(String visit) {
    return 'Vaccines overdue: $visit';
  }

  @override
  String medsTodayLine(int given, int total) {
    return 'Medicines today: $given of $total doses recorded';
  }

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
  String get severeReactionNow =>
      'If your baby has trouble breathing, swelling of the tongue or throat, or becomes floppy or pale, call 1122 or 115 now.';

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
  String get emergencyNumbers => 'Emergency numbers (Pakistan)';

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
  String get deleteAccount => 'Delete my account';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your login. Babies and entries in families that only you belong to are deleted too. In families you share, the other members keep everything, and if you\'re the owner, the next member becomes the owner. This can\'t be undone.';

  @override
  String get deleteAccountTypeHint => 'Type DELETE to confirm';

  @override
  String get deleteAccountButton => 'Delete forever';

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
  String get seeReports => 'Reports and trends';

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
}
