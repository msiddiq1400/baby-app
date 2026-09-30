// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'پالنا';

  @override
  String get errorGeneric => 'کچھ غلط ہو گیا۔ دوبارہ کوشش کریں۔';

  @override
  String get fieldRequired => 'ضروری ہے';

  @override
  String get saveButton => 'محفوظ کریں';

  @override
  String get cancelButton => 'منسوخ';

  @override
  String get language => 'زبان';

  @override
  String get signOut => 'سائن آؤٹ';

  @override
  String get signInTitle => 'خوش آمدید';

  @override
  String get signInSubtitle =>
      'اپنے بچے کی خوراک، نیند اور بہت کچھ ریکارڈ کریں';

  @override
  String get nameLabel => 'آپ کا نام';

  @override
  String get emailLabel => 'ای میل';

  @override
  String get passwordLabel => 'پاس ورڈ';

  @override
  String get invalidEmail => 'درست ای میل درج کریں';

  @override
  String get passwordTooShort => 'پاس ورڈ کم از کم 6 حروف کا ہونا چاہیے';

  @override
  String get signInButton => 'سائن ان';

  @override
  String get signUpButton => 'اکاؤنٹ بنائیں';

  @override
  String get switchToSignUp => 'نئے ہیں؟ اکاؤنٹ بنائیں';

  @override
  String get verifyTitle => 'اپنا کوڈ درج کریں';

  @override
  String verifySubtitle(String email) {
    return 'ہم نے $email پر 6 ہندسوں کا کوڈ بھیجا ہے';
  }

  @override
  String get codeLabel => '6 ہندسوں کا کوڈ';

  @override
  String get verifyButton => 'تصدیق کریں';

  @override
  String get resendCode => 'نیا کوڈ بھیجیں';

  @override
  String resendIn(int seconds) {
    return '$seconds سیکنڈ میں نیا کوڈ بھیجیں';
  }

  @override
  String get codeSent => 'نیا کوڈ بھیج دیا گیا ہے';

  @override
  String get invalidCode => 'یہ کوڈ غلط ہے یا اس کی میعاد ختم ہو گئی ہے';

  @override
  String get continueWithGoogle => 'گوگل کے ساتھ جاری رکھیں';

  @override
  String get orDivider => 'یا';

  @override
  String get switchToSignIn => 'پہلے سے اکاؤنٹ ہے؟ سائن ان کریں';

  @override
  String get addBabyTitle => 'اپنے بچے کو شامل کریں';

  @override
  String get babyNameLabel => 'بچے کا نام';

  @override
  String get birthDateLabel => 'تاریخ پیدائش';

  @override
  String get sexLabel => 'جنس (اختیاری)';

  @override
  String get sexFemale => 'لڑکی';

  @override
  String get sexMale => 'لڑکا';

  @override
  String get birthWeightLabel => 'پیدائش کا وزن کلو میں (اختیاری)';

  @override
  String get invalidWeight => '0.3 سے 7 کلو کے درمیان وزن درج کریں';

  @override
  String ageMonths(int count) {
    return '$count ماہ';
  }

  @override
  String ageDays(int count) {
    return '$count دن';
  }

  @override
  String durationHm(int hours, int minutes) {
    return '$hours گھنٹے $minutes منٹ';
  }

  @override
  String durationM(int minutes) {
    return '$minutes منٹ';
  }

  @override
  String agoLabel(String duration) {
    return '$duration پہلے';
  }

  @override
  String get feeds => 'خوراک';

  @override
  String get diapers => 'ڈائپر';

  @override
  String get sleep => 'نیند';

  @override
  String bottleTotal(int ml) {
    return 'بوتل سے $ml ملی لیٹر';
  }

  @override
  String lastFeed(String ago) {
    return 'آخری: $ago';
  }

  @override
  String diaperCounts(int wet, int dirty) {
    return '$wet گیلے · $dirty گندے';
  }

  @override
  String sleepingSince(String time) {
    return '$time سے سو رہا ہے';
  }

  @override
  String get sleptToday => 'آج کی نیند';

  @override
  String get logFeed => 'خوراک';

  @override
  String get logDiaper => 'ڈائپر';

  @override
  String get startSleep => 'نیند';

  @override
  String get endSleep => 'جاگ گیا';

  @override
  String get feedTypeBreast => 'ماں کا دودھ';

  @override
  String get feedTypeBottleBreastMilk => 'نکالا ہوا دودھ';

  @override
  String get feedTypeFormula => 'فارمولا دودھ';

  @override
  String get sideLeft => 'بائیں';

  @override
  String get sideRight => 'دائیں';

  @override
  String get sideBoth => 'دونوں';

  @override
  String get amountMl => 'مقدار (ملی لیٹر)';

  @override
  String get feedMinutes => 'دورانیہ منٹوں میں (اختیاری)';

  @override
  String get invalidAmount => '1 سے 1000 ملی لیٹر کے درمیان مقدار درج کریں';

  @override
  String get invalidMinutes => '1 سے 180 منٹ کے درمیان درج کریں';

  @override
  String get diaperWet => 'گیلا';

  @override
  String get diaperDirty => 'گندا';

  @override
  String get chooseDiaper => 'گیلا، گندا یا دونوں منتخب کریں';

  @override
  String get timeLabel => 'وقت';

  @override
  String get sleepNap => 'قیلولہ';

  @override
  String get sleepNight => 'رات کی نیند';

  @override
  String get sleepingNow => 'سو رہا ہے';

  @override
  String get todayTimeline => 'آج';

  @override
  String get nothingLoggedToday => 'آج ابھی تک کچھ درج نہیں کیا گیا';

  @override
  String get tabToday => 'آج';

  @override
  String get tabGrowth => 'نشوونما';

  @override
  String get deleteButton => 'حذف کریں';

  @override
  String get deleteConfirmTitle => 'یہ اندراج حذف کریں؟';

  @override
  String get editFeed => 'خوراک میں ترمیم';

  @override
  String get editDiaper => 'ڈائپر میں ترمیم';

  @override
  String get editSleep => 'نیند میں ترمیم';

  @override
  String get sleepStartLabel => 'سو گیا';

  @override
  String get sleepEndLabel => 'جاگ گیا';

  @override
  String get stillAsleep => 'ابھی سو رہا ہے';

  @override
  String get invalidSleepTimes => 'جاگنے کا وقت سونے کے بعد ہونا چاہیے';

  @override
  String get growthTitle => 'نشوونما';

  @override
  String get addMeasurement => 'پیمائش شامل کریں';

  @override
  String get editMeasurement => 'پیمائش میں ترمیم';

  @override
  String get dateLabel => 'تاریخ';

  @override
  String get weightKgLabel => 'وزن (کلو)';

  @override
  String get lengthCmLabel => 'قد (سینٹی میٹر)';

  @override
  String get headCmLabel => 'سر کا گھیر (سینٹی میٹر)';

  @override
  String get enterOneMeasurement => 'کم از کم ایک پیمائش درج کریں';

  @override
  String get invalidWeightKg => '0.3 سے 40 کلو کے درمیان وزن درج کریں';

  @override
  String get invalidLengthCm => '20 سے 130 سینٹی میٹر کے درمیان قد درج کریں';

  @override
  String get invalidHeadCm => '20 سے 60 سینٹی میٹر کے درمیان درج کریں';

  @override
  String get metricWeight => 'وزن';

  @override
  String get metricLength => 'قد';

  @override
  String get metricHead => 'سر';

  @override
  String percentileValue(String percentile) {
    return 'پرسنٹائل: $percentile';
  }

  @override
  String changeSince(String change, String date) {
    return '$date سے اب تک $change';
  }

  @override
  String get atBirth => 'پیدائش کے وقت';

  @override
  String get noMeasurements =>
      'ابھی کوئی پیمائش نہیں۔ اگلی بار وزن کرانے کے بعد شامل کریں۔';

  @override
  String get chooseSexForChart =>
      'WHO کے نشوونما چارٹ سے موازنے کے لیے منتخب کریں:';

  @override
  String get curvesLegend =>
      'سرمئی لکیریں: WHO کے معیار، 3 سے 97 پرسنٹائل تک۔ آپ کا بچہ: رنگین لکیر۔';

  @override
  String get percentileExplain =>
      'پرسنٹائل آپ کے بچے کا موازنہ اسی عمر اور جنس کے دوسرے بچوں سے کرتا ہے؛ 50 درمیان ہے۔ کسی ایک عدد سے زیادہ اہم یہ ہے کہ لکیر وقت کے ساتھ ہموار رہے۔ اگر لکیر دو سرمئی لکیریں پار کرے یا سیدھی ہو جائے تو اپنے ڈاکٹر سے بات کریں۔';

  @override
  String get whoAgeLimit => 'ایپ میں WHO چارٹ پیدائش سے 24 ماہ تک ہیں۔';

  @override
  String get tabHealth => 'صحت';

  @override
  String get vaccinesTitle => 'ٹیکے';

  @override
  String get vaccineScheduleNote =>
      'پاکستان EPI شیڈول (سرکاری حفاظتی ٹیکوں کا پروگرام)۔ تاریخوں کی تصدیق ہمیشہ اپنے ویکسینیٹر یا بچوں کے ڈاکٹر سے کریں۔';

  @override
  String get visitAtBirth => 'پیدائش پر';

  @override
  String visitWeeks(int count) {
    return '$count ہفتے';
  }

  @override
  String visitMonths(int count) {
    return '$count ماہ';
  }

  @override
  String dueOn(String date) {
    return 'مقررہ تاریخ: $date';
  }

  @override
  String get statusDone => 'سب لگ گئے';

  @override
  String get statusOverdue => 'تاخیر';

  @override
  String get statusDueSoon => 'جلد';

  @override
  String get statusUpcoming => 'آنے والے';

  @override
  String givenOn(String date) {
    return '$date کو لگا';
  }

  @override
  String get markGiven => 'لگ گیا';

  @override
  String get markVisitGiven => 'سب لگ گئے';

  @override
  String get recordVaccination => 'ٹیکہ درج کریں';

  @override
  String get editVaccination => 'ٹیکے میں ترمیم';

  @override
  String get dateGivenLabel => 'لگنے کی تاریخ';

  @override
  String get batchLabel => 'بیچ نمبر (اختیاری)';

  @override
  String get clinicLabel => 'کلینک یا ڈاکٹر (اختیاری)';

  @override
  String get notesLabel => 'نوٹس (اختیاری)';

  @override
  String nextVisit(String visit, String date) {
    return 'اگلا: $visit، $date';
  }

  @override
  String get allVaccinesDone => 'شیڈول کے تمام ٹیکے درج ہیں۔';

  @override
  String get catchUpNote =>
      'کوئی ٹیکہ رہ گیا؟ زیادہ تر ٹیکے بعد میں بھی لگ سکتے ہیں اور عام طور پر شروع سے دوبارہ لگوانے کی ضرورت نہیں ہوتی۔ اپنے ویکسینیٹر یا بچوں کے ڈاکٹر سے کیچ اپ پلان کے بارے میں پوچھیں۔';

  @override
  String vaccinesDueTomorrow(String name) {
    return '$name کے ٹیکے کل لگنے ہیں';
  }

  @override
  String vaccinesDueToday(String name) {
    return '$name کے ٹیکے آج لگنے ہیں';
  }

  @override
  String vaccinesOverdueReminder(String name) {
    return '$name کے ٹیکوں میں تاخیر ہو گئی ہے';
  }

  @override
  String get healthTitle => 'صحت';

  @override
  String get tabVaccines => 'ٹیکے';

  @override
  String get tabMedicines => 'دوائیں';

  @override
  String get addMedicine => 'دوا شامل کریں';

  @override
  String get editMedicine => 'دوا میں ترمیم';

  @override
  String get medicineNameLabel => 'دوا کا نام';

  @override
  String get prescribedDoseLabel =>
      'ڈاکٹر کی بتائی ہوئی خوراک (مثلاً 2.5 ملی لیٹر)';

  @override
  String get scheduleAtTimes => 'مقررہ اوقات پر';

  @override
  String get scheduleAsNeeded => 'ضرورت کے وقت';

  @override
  String get doseTimesLabel => 'خوراک کے اوقات';

  @override
  String get addTime => 'وقت شامل کریں';

  @override
  String get presetOnce => 'دن میں ایک بار';

  @override
  String get presetTwice => 'دن میں 2 بار';

  @override
  String get presetThrice => 'دن میں 3 بار';

  @override
  String get presetEvery6h => 'ہر 6 گھنٹے بعد';

  @override
  String get chooseTimes => 'کم از کم ایک وقت شامل کریں';

  @override
  String get startDateLabel => 'شروع کرنے کی تاریخ';

  @override
  String get durationDaysLabel => 'کتنے دن؟ (جاری رہے تو خالی چھوڑ دیں)';

  @override
  String get invalidDays => '1 سے 365 دن کے درمیان درج کریں';

  @override
  String get prescribedByLabel => 'تجویز کرنے والا ڈاکٹر (اختیاری)';

  @override
  String get medicineSafetyNote =>
      'دوا صرف ڈاکٹر کی ہدایت کے مطابق دیں۔ یہ ایپ نسخہ محفوظ کرتی اور یاد دلاتی ہے؛ یہ کبھی خوراک کا حساب نہیں لگاتی نہ تجویز کرتی ہے۔';

  @override
  String get noMedicines => 'کوئی دوا شامل نہیں۔';

  @override
  String get finishedMedicines => 'مکمل';

  @override
  String untilDate(String date) {
    return '$date تک';
  }

  @override
  String get ongoing => 'جاری';

  @override
  String get doseGiven => 'دے دی';

  @override
  String get doseSkipped => 'چھوڑ دی';

  @override
  String get doseMissed => 'رہ گئی';

  @override
  String get markDoseGiven => 'دے دی';

  @override
  String get skipDose => 'چھوڑیں';

  @override
  String get undoDose => 'واپس';

  @override
  String get recordDoseNow => 'ابھی خوراک درج کریں';

  @override
  String lastGiven(String time) {
    return 'آخری بار: $time';
  }

  @override
  String medicineReminderTitle(String name) {
    return '$name کی دوا کا وقت';
  }

  @override
  String medicineReminderBody(String medicine, String dose) {
    return '$medicine: $dose';
  }

  @override
  String get tabMilk => 'دودھ';

  @override
  String get milkTitle => 'ماں کا دودھ';

  @override
  String get logPumping => 'پمپنگ درج کریں';

  @override
  String get editPumping => 'پمپنگ میں ترمیم';

  @override
  String get addStoredMilk => 'محفوظ دودھ شامل کریں';

  @override
  String pumpedToday(int ml, int count) {
    return 'آج پمپ کیا: $ml ملی لیٹر ($count بار)';
  }

  @override
  String get storeMilkIn => 'یہ دودھ اب کہاں ہے؟';

  @override
  String get notStored => 'فوراً پلا دیا';

  @override
  String get locationRoom => 'کمرہ';

  @override
  String get locationCooler => 'برف والا کولر';

  @override
  String get locationFridge => 'فریج';

  @override
  String get locationFreezer => 'فریزر';

  @override
  String get locationThawed => 'پگھلا ہوا، فریج میں';

  @override
  String get pumpedAtLabel => 'پمپ کرنے کا وقت';

  @override
  String pumpedOn(String date) {
    return '$date کو پمپ کیا';
  }

  @override
  String useBy(String time) {
    return '$time تک استعمال کریں';
  }

  @override
  String get milkExpired => 'میعاد ختم: ضائع کر دیں';

  @override
  String milkNeedsAttention(int count) {
    return '$count محفوظ دودھ کی میعاد جلد ختم ہو رہی ہے یا ختم ہو چکی ہے۔';
  }

  @override
  String get useForFeed => 'خوراک کے لیے استعمال کریں';

  @override
  String get moveToFridge => 'فریج میں رکھیں';

  @override
  String get moveToCooler => 'کولر میں رکھیں';

  @override
  String get moveToFreezer => 'فریز کریں';

  @override
  String get thawMilk => 'فریج میں پگھلائیں';

  @override
  String get throwAway => 'ضائع کریں';

  @override
  String get noStoredMilk => 'کوئی محفوظ دودھ نہیں۔';

  @override
  String get noRefreeze => 'دوبارہ فریز نہ کریں';

  @override
  String get storageGuideTitle => 'دودھ کتنی دیر محفوظ رہتا ہے';

  @override
  String get storageGuide =>
      'تازہ پمپ کیا ہوا دودھ (CDC کی ہدایات):\n• کمرہ، 25°C یا اس سے کم: 4 گھنٹے تک\n• برف کے پیک والا کولر بیگ: 24 گھنٹے تک\n• فریج: 4 دن تک\n• فریزر: 6 ماہ کے اندر بہتر، 12 ماہ تک\n\nپگھلا ہوا دودھ: فریج میں 24 گھنٹے کے اندر، یا گرم کرنے کے بعد 2 گھنٹے کے اندر استعمال کریں۔ پگھلا ہوا دودھ کبھی دوبارہ فریز نہ کریں۔\nپلانے کے بعد بچا ہوا دودھ: 2 گھنٹے کے اندر استعمال کریں، پھر ضائع کر دیں۔\n\nپاکستان کی گرمیوں میں کمرے اکثر 25°C سے زیادہ گرم ہوتے ہیں، اس لیے پمپ کرنے کے فوراً بعد دودھ فریج یا برف والے کولر میں رکھیں۔';

  @override
  String get loadSheddingTitle => 'لوڈ شیڈنگ کے دوران';

  @override
  String get loadSheddingGuide =>
      '• فریج اور فریزر بند رکھیں۔ بند فریج تقریباً 4 گھنٹے ٹھنڈا رہتا ہے؛ بھرا ہوا فریزر تقریباً 48 گھنٹے (آدھا بھرا ہو تو 24)۔\n• لمبی بجلی بندش میں دودھ برف یا جمے ہوئے جیل پیک والے کولر بیگ میں رکھیں۔ اس کے لیے چند پیک ہمیشہ جما کر رکھیں۔\n• اگر جما ہوا دودھ پگھل جائے تو دوبارہ فریز نہ کریں: ٹھنڈا رکھیں اور 24 گھنٹے کے اندر استعمال کریں۔';

  @override
  String get milkExpiresTitle => 'محفوظ دودھ کی میعاد جلد ختم ہو گی';

  @override
  String milkExpiresBody(int ml, String location, String time) {
    return '$ml ملی لیٹر ($location): $time تک استعمال کریں';
  }

  @override
  String storedMilkTotal(int ml) {
    return '$ml ملی لیٹر';
  }

  @override
  String get tabSymptoms => 'علامات';

  @override
  String get logSymptom => 'علامت درج کریں';

  @override
  String get editSymptom => 'علامت میں ترمیم';

  @override
  String get symptomFever => 'بخار';

  @override
  String get symptomCough => 'کھانسی';

  @override
  String get symptomRunnyNose => 'ناک بہنا';

  @override
  String get symptomVomiting => 'الٹی';

  @override
  String get symptomDiarrhea => 'دست';

  @override
  String get symptomConstipation => 'قبض';

  @override
  String get symptomRash => 'دانے';

  @override
  String get symptomTeething => 'دانت نکلنا';

  @override
  String get symptomFeedingRefusal => 'دودھ نہ پینا';

  @override
  String get symptomCrying => 'غیر معمولی رونا';

  @override
  String get symptomCongestion => 'بند ناک';

  @override
  String get symptomOther => 'دیگر';

  @override
  String get temperatureLabel => 'درجہ حرارت (اختیاری)';

  @override
  String get invalidTemperature => '30 سے 45 °C یا 86 سے 113 °F درج کریں';

  @override
  String get severityLabel => 'کتنی شدید؟';

  @override
  String get severityMild => 'ہلکی';

  @override
  String get severityModerate => 'درمیانی';

  @override
  String get severitySevere => 'شدید';

  @override
  String get youngFeverWarning =>
      '3 ماہ سے کم عمر بچے میں 38°C (100.4°F) یا اس سے زیادہ درجہ حرارت ہو تو فوراً ڈاکٹر کو دکھائیں۔';

  @override
  String get noSymptoms => 'پچھلے 14 دنوں میں کوئی علامت درج نہیں۔';

  @override
  String get doctorSummary => 'ڈاکٹر کے لیے خلاصہ';

  @override
  String get summarySinceStart => 'علامات شروع ہونے سے';

  @override
  String lastNDays(int count) {
    return 'پچھلے $count دن';
  }

  @override
  String get showInEnglish => 'انگریزی میں (ڈاکٹر کے لیے)';

  @override
  String get shareButton => 'شیئر کریں';

  @override
  String get copyButton => 'کاپی کریں';

  @override
  String get copied => 'کاپی ہو گیا';

  @override
  String sumTitle(String name) {
    return 'صحت کا خلاصہ: $name';
  }

  @override
  String sumAge(String age) {
    return 'عمر: $age';
  }

  @override
  String sumPeriod(String from, String to) {
    return 'مدت: $from سے $to تک';
  }

  @override
  String sumWeight(String weight, String date) {
    return 'تازہ ترین وزن: $weight ($date)';
  }

  @override
  String get sumSymptoms => 'علامات';

  @override
  String sumSymptomLine(String symptom, String first, String last, int count) {
    return '$symptom: $first سے $last تک ($count اندراج)';
  }

  @override
  String sumHighestTemp(String temp, String when) {
    return 'سب سے زیادہ $temp، $when';
  }

  @override
  String sumFeedsPerDay(String days) {
    return 'روزانہ خوراک: $days';
  }

  @override
  String sumWetPerDay(String days) {
    return 'روزانہ گیلے ڈائپر: $days';
  }

  @override
  String sumDirtyPerDay(String days) {
    return 'روزانہ گندے ڈائپر: $days';
  }

  @override
  String sumUsually(String count) {
    return 'عام طور پر تقریباً $count';
  }

  @override
  String sumTodaySoFar(int count) {
    return 'آج اب تک $count';
  }

  @override
  String get sumMedicines => 'دی گئی دوائیں';

  @override
  String sumMedicineLine(String name, String dose, int count, String when) {
    return '$name ($dose): $count خوراکیں، آخری $when';
  }

  @override
  String get sumEntries => 'تمام اندراجات';

  @override
  String get sumFooter => 'والدین نے پالنا میں درج کیا۔';

  @override
  String get firstSyncLoading => 'آپ کے خاندان کا ڈیٹا لوڈ ہو رہا ہے…';

  @override
  String get firstSyncNeedsInternet =>
      'پہلی بار اس کے لیے انٹرنیٹ ضروری ہے۔ اس کے بعد ایپ انٹرنیٹ کے بغیر بھی چلتی ہے۔';

  @override
  String get offlineBanner =>
      'آف لائن: تبدیلیاں محفوظ ہیں اور انٹرنیٹ آنے پر سنک ہو جائیں گی۔';

  @override
  String get unsyncedSignOutTitle => 'کچھ تبدیلیاں ابھی سنک نہیں ہوئیں';

  @override
  String get unsyncedSignOutBody =>
      'اگر آپ ابھی سائن آؤٹ کریں تو آف لائن کیے گئے اندراجات ضائع ہو جائیں گے۔ انہیں محفوظ رکھنے کے لیے پہلے انٹرنیٹ سے جڑیں۔';

  @override
  String get signOutAnyway => 'پھر بھی سائن آؤٹ کریں';

  @override
  String get editBabyTitle => 'بچے کی معلومات میں ترمیم';

  @override
  String get birthLengthLabel => 'پیدائش کے وقت قد سینٹی میٹر میں (اختیاری)';

  @override
  String get birthHeadLabel =>
      'پیدائش کے وقت سر کا گھیر سینٹی میٹر میں (اختیاری)';

  @override
  String get invalidBirthLength => '20 سے 70 سینٹی میٹر کے درمیان قد درج کریں';

  @override
  String get invalidBirthHead => '20 سے 50 سینٹی میٹر کے درمیان درج کریں';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get babiesSection => 'بچے';

  @override
  String get addAnotherBaby => 'ایک اور بچہ شامل کریں';

  @override
  String get familySection => 'خاندان اور دیکھ بھال کرنے والے';

  @override
  String get familyOffline =>
      'خاندان کے افراد دیکھنے اور مدعو کرنے کے لیے انٹرنیٹ سے جڑیں۔';

  @override
  String get ownerLabel => 'مالک';

  @override
  String get caregiverLabel => 'دیکھ بھال کرنے والا';

  @override
  String get youLabel => 'آپ';

  @override
  String get inviteCaregiver => 'دیکھ بھال کرنے والے کو مدعو کریں';

  @override
  String get inviteCodeTitle => 'دعوتی کوڈ';

  @override
  String get inviteCodeHelp =>
      'ان سے کہیں کہ ایپ انسٹال کریں، اکاؤنٹ بنائیں اور یہ کوڈ درج کریں۔ یہ ایک بار کام کرتا ہے اور 7 دن میں ختم ہو جاتا ہے۔';

  @override
  String inviteShareText(String name, String code) {
    return 'پالنا میں $name کے خاندان میں شامل ہونے کے لیے یہ کوڈ استعمال کریں: $code (7 دن کے لیے)';
  }

  @override
  String get joinFamily => 'کوڈ سے خاندان میں شامل ہوں';

  @override
  String get joinFamilyPrompt =>
      'خاندان میں شامل ہو رہے ہیں؟ دعوتی کوڈ درج کریں';

  @override
  String get inviteCodeLabel => '6 حروف کا کوڈ';

  @override
  String get joinButton => 'شامل ہوں';

  @override
  String get joinedFamily =>
      'آپ خاندان میں شامل ہو گئے۔ ان کا ڈیٹا ابھی نظر آئے گا۔';

  @override
  String get invalidInvite =>
      'یہ کوڈ غلط ہے، استعمال ہو چکا ہے یا ختم ہو گیا ہے۔';

  @override
  String get removeMember => 'ہٹائیں';

  @override
  String get leaveFamily => 'خاندان چھوڑیں';

  @override
  String removeMemberConfirm(String name) {
    return '$name کو خاندان سے ہٹائیں؟';
  }

  @override
  String get leaveFamilyConfirm =>
      'یہ خاندان چھوڑیں؟ آپ کو اس کے بچے نظر آنا بند ہو جائیں گے۔';

  @override
  String get switchBaby => 'بچہ بدلیں';

  @override
  String get atAGlance => 'ایک نظر میں';

  @override
  String hungerEstimate(String interval, String time) {
    return 'عام طور پر تقریباً ہر $interval بعد دودھ پیتا ہے، اس لیے اگلی خوراک تقریباً $time کے قریب ہو سکتی ہے۔';
  }

  @override
  String get hungerDisclaimer =>
      'یہ حالیہ خوراکوں سے ایک اندازہ ہے؛ ہمیشہ بچے کی بھوک کے اشاروں پر عمل کریں۔';

  @override
  String sleepUsual(String usual, String today) {
    return 'عام طور پر دن میں تقریباً $usual سوتا ہے۔ آج اب تک: $today۔';
  }

  @override
  String awakeFor(String duration) {
    return '$duration سے جاگ رہا ہے';
  }

  @override
  String usuallyAwake(String duration) {
    return 'عام طور پر نیندوں کے درمیان تقریباً $duration';
  }

  @override
  String vaccinesOverdueLine(String visit) {
    return 'ٹیکوں میں تاخیر: $visit';
  }

  @override
  String medsTodayLine(int given, int total) {
    return 'آج کی دوائیں: $total میں سے $given خوراکیں درج';
  }

  @override
  String get tabSolids => 'ٹھوس غذا';

  @override
  String get solidsTitle => 'ٹھوس غذا کا آغاز';

  @override
  String get solidsTooYoung =>
      'زیادہ تر بچے تقریباً 6 ماہ پر ٹھوس غذا شروع کرتے ہیں۔ تب تک آپ پہلے سے پڑھ سکتے ہیں۔';

  @override
  String get readinessTitle => 'کیا میرا بچہ تیار ہے؟';

  @override
  String get texturesTitle => 'غذا کی ساخت کیسے بدلتی ہے';

  @override
  String get foodRulesTitle => 'اہم اصول';

  @override
  String get allergensTitle => 'الرجی والی غذائیں';

  @override
  String get allergenNotYet => 'ابھی نہیں';

  @override
  String get allergenIntroduced => 'شروع ہو گئی';

  @override
  String get allergenReaction => 'ردِعمل';

  @override
  String get reactionSignsTitle => 'الرجی ردِعمل کی نشانیاں';

  @override
  String get beliefsTitle => 'عام باتیں بمقابلہ ثبوت';

  @override
  String get beliefLabel => 'اکثر کہا جاتا ہے';

  @override
  String get evidenceLabel => 'ثبوت کیا کہتے ہیں';

  @override
  String get foodsTitle => 'غذائیں';

  @override
  String get searchFoods => 'غذا تلاش کریں';

  @override
  String get categoryAll => 'سب';

  @override
  String get categoryFruit => 'پھل';

  @override
  String get categoryVegetable => 'سبزیاں';

  @override
  String get categoryGrain => 'اناج';

  @override
  String get categoryLegume => 'دالیں';

  @override
  String get categoryProtein => 'گوشت، مچھلی اور انڈا';

  @override
  String get categoryDairy => 'دودھ سے بنی چیزیں';

  @override
  String get categoryNut => 'میوے اور بیج';

  @override
  String get categoryOther => 'ابھی نہیں';

  @override
  String fromMonths(int count) {
    return '$count ماہ سے';
  }

  @override
  String get chokingRisk =>
      'گلے میں پھنسنے کا خطرہ: بتائے گئے طریقے سے تیار کریں';

  @override
  String allergenLabel(String name) {
    return 'الرجی والی غذا: $name';
  }

  @override
  String get logTry => 'آزمائش درج کریں';

  @override
  String get editTry => 'آزمائش میں ترمیم';

  @override
  String get notTried => 'ابھی نہیں آزمایا';

  @override
  String triedTimes(int count) {
    return '$count بار آزمایا';
  }

  @override
  String get opinionLabel => 'کیا پسند آیا؟';

  @override
  String get opinionLiked => 'پسند آیا';

  @override
  String get opinionNeutral => 'ٹھیک';

  @override
  String get opinionDisliked => 'پسند نہیں آیا';

  @override
  String get reactionLabel => 'کوئی ردِعمل؟';

  @override
  String get reactionNone => 'کوئی نہیں';

  @override
  String get reactionMild => 'ہلکا';

  @override
  String get reactionSevere => 'شدید';

  @override
  String get reactionWarning =>
      'ردِعمل ہوا تھا: دوبارہ دینے سے پہلے ڈاکٹر سے بات کریں۔';

  @override
  String get severeReactionNow =>
      'اگر بچے کو سانس لینے میں مشکل ہو، زبان یا گلے میں سوجن ہو، یا وہ ڈھیلا یا زرد پڑ جائے تو ابھی 1122 یا 115 پر کال کریں۔';

  @override
  String sourcesLabel(String sources) {
    return 'ماخذ: $sources';
  }

  @override
  String get tabCharts => 'چارٹ';

  @override
  String get tabMilestones => 'سنگِ میل';

  @override
  String byMonths(int count) {
    return '$count ماہ تک';
  }

  @override
  String get areaSocial => 'سماجی و جذباتی';

  @override
  String get areaLanguage => 'زبان اور بات چیت';

  @override
  String get areaCognitive => 'سیکھنا اور سوچنا';

  @override
  String get areaMovement => 'حرکت';

  @override
  String get waysToHelp => 'مدد کے طریقے';

  @override
  String get actEarlyTitle => 'ڈاکٹر سے کب بات کریں';

  @override
  String milestonesProgress(int done, int total) {
    return '$total میں سے $done';
  }

  @override
  String reachedOn(String date) {
    return '$date کو';
  }

  @override
  String get helpTitle => 'ایمرجنسی اور مدد';

  @override
  String get emergencyNumbers => 'ایمرجنسی نمبر (پاکستان)';

  @override
  String get emergencyNumbersNote =>
      'کال کرنے کے لیے ٹیپ کریں۔ سہولیات ہر شہر میں مختلف ہیں؛ قریبی بچوں کے ہسپتال کا نمبر بھی محفوظ رکھیں۔';

  @override
  String get numRescue => 'ریسکیو 1122: ایمبولینس اور ایمرجنسی';

  @override
  String get numEdhi => 'ایدھی ایمبولینس';

  @override
  String get numChhipa => 'چھیپا ایمبولینس (کراچی)';

  @override
  String get numPolice => 'پولیس';

  @override
  String get numFire => 'فائر بریگیڈ';

  @override
  String get callEmergencyWhen => 'فوراً مدد کے لیے کال کریں اگر آپ کا بچہ';

  @override
  String get emergencySigns =>
      '• سانس لینے میں مشکل ہو یا سانس رک رک کر آئے\n• ڈھیلا، بہت غنودہ ہو یا مشکل سے جاگے\n• جلد، ہونٹ یا زبان نیلی، سرمئی، زرد یا دھبے دار ہو، یا جسم ٹھنڈا لگے\n• دورہ (جھٹکے) پڑے\n• کسی غذا یا دوا کے بعد زبان یا گلے میں سوجن ہو';

  @override
  String get heatTitle => 'گرمی اور لوڈ شیڈنگ';

  @override
  String get heatGuide =>
      '• بچوں کو دھوپ سے بچائیں، خاص طور پر صبح 11 سے دوپہر 3 بجے تک، اور کبھی کھڑی گاڑی میں اکیلا نہ چھوڑیں۔\n• ایک ہلکا سوتی کپڑا پہنائیں؛ سایہ اور پنکھا استعمال کریں۔\n• زیادہ بار دودھ پلائیں۔ صرف ماں کا دودھ پینے والے 6 ماہ سے کم بچوں کو پانی کی ضرورت نہیں؛ فارمولا پینے والے بچوں کے لیے اضافی پانی کا ڈاکٹر سے پوچھیں۔\n• لوڈ شیڈنگ میں سب سے ٹھنڈے کمرے میں جائیں اور بچے کو نیم گرم (ٹھنڈے یا برف والے نہیں) پانی میں بھیگے کپڑے سے پونچھیں۔';

  @override
  String get dehydrationTitle =>
      'پانی کی کمی کی نشانیاں: آج ہی ڈاکٹر کو دکھائیں';

  @override
  String get dehydrationSigns =>
      '• معمول سے کم گیلے ڈائپر\n• روتے وقت آنسو کم یا بالکل نہ ہوں، یا منہ خشک ہو\n• سر کا نرم حصہ (تالو) یا آنکھیں دھنسی ہوئی ہوں\n• غیر معمولی طور پر غنودہ یا چڑچڑا ہو';

  @override
  String get helpSources =>
      'یہ NHS اور عالمی ادارہ صحت کی ہدایات پر مبنی ہے۔ یہ عمومی معلومات ہیں، تشخیص نہیں؛ فکر ہو تو ڈاکٹر سے رابطہ کریں۔';

  @override
  String get accountSection => 'اکاؤنٹ';

  @override
  String get deleteAccount => 'میرا اکاؤنٹ حذف کریں';

  @override
  String get deleteAccountBody =>
      'اس سے آپ کا لاگ اِن ہمیشہ کے لیے حذف ہو جائے گا۔ جن خاندانوں میں صرف آپ ہیں، ان کے بچے اور تمام اندراجات بھی حذف ہو جائیں گے۔ جن خاندانوں میں دوسرے لوگ بھی ہیں، ان کے پاس سب کچھ رہے گا، اور اگر آپ مالک ہیں تو اگلا فرد مالک بن جائے گا۔ یہ واپس نہیں ہو سکتا۔';

  @override
  String get deleteAccountTypeHint => 'تصدیق کے لیے DELETE لکھیں';

  @override
  String get deleteAccountButton => 'ہمیشہ کے لیے حذف کریں';

  @override
  String appVersion(String version, String build) {
    return 'ورژن $version (بلڈ $build)';
  }

  @override
  String get deleteAccountFailed =>
      'اکاؤنٹ حذف نہیں ہو سکا۔ انٹرنیٹ چیک کر کے دوبارہ کوشش کریں۔';

  @override
  String get startFeedTimer => 'ٹائمر شروع کریں';

  @override
  String lastSide(String side) {
    return 'پچھلی بار: $side طرف';
  }

  @override
  String get orEnterMinutes => 'یا منٹ لکھیں';

  @override
  String get leftMinutes => 'بائیں (منٹ)';

  @override
  String get rightMinutes => 'دائیں (منٹ)';

  @override
  String get feedTimerAlreadyRunning =>
      'دودھ پلانے کا ٹائمر پہلے سے چل رہا ہے۔ یہ آج والی اسکرین کے اوپر ہے۔';

  @override
  String get feedingNowTitle => 'ابھی دودھ پی رہا ہے';

  @override
  String get feedingNow => 'ابھی جاری ہے';

  @override
  String get feedTimerPaused => 'رکا ہوا';

  @override
  String get feedTimerHelp =>
      'طرف بدلنے کے لیے اسے دبائیں۔ روکنے کے لیے چلتی طرف کو دبائیں۔';

  @override
  String get finishFeed => 'ختم کریں';

  @override
  String get discardButton => 'ضائع کریں';

  @override
  String get discardFeedConfirm =>
      'یہ خوراک ضائع کریں؟ ٹائمر اور اس کا وقت حذف ہو جائے گا۔';

  @override
  String get asleepNap => 'جھپکی لے رہا ہے';

  @override
  String get asleepNight => 'رات کی نیند';

  @override
  String feedingNotificationTitle(String name) {
    return '$name دودھ پی رہا ہے';
  }

  @override
  String sleepNotificationTitle(String name) {
    return '$name سو رہا ہے';
  }

  @override
  String get reportsTitle => 'رپورٹیں';

  @override
  String get seeReports => 'رپورٹیں اور رجحانات';

  @override
  String periodDays(int count) {
    return '$count دن';
  }

  @override
  String get feedsPerDay => 'روزانہ خوراکیں';

  @override
  String get timeBetweenFeeds => 'خوراکوں کا عام وقفہ';

  @override
  String get nursingPerDay => 'روزانہ ماں کا دودھ';

  @override
  String get perBreastfeed => 'فی بار ماں کا دودھ';

  @override
  String get sideSplit => 'بائیں / دائیں';

  @override
  String get bottlePerDay => 'روزانہ بوتل کا دودھ';

  @override
  String get perBottle => 'فی بوتل';

  @override
  String get sleepPerDay => 'روزانہ نیند';

  @override
  String get nightSleepPerDay => 'رات کی نیند';

  @override
  String get napsPerDay => 'روزانہ جھپکیاں';

  @override
  String get napTimePerDay => 'روزانہ جھپکی کا وقت';

  @override
  String get longestSleep => 'سب سے لمبی نیند';

  @override
  String get awakeBetweenSleeps => 'نیندوں کے درمیان جاگنا';

  @override
  String get usualBedtime => 'سونے کا عام وقت';

  @override
  String get usualWakeUp => 'جاگنے کا عام وقت';

  @override
  String get wetPerDay => 'روزانہ گیلے';

  @override
  String get dirtyPerDay => 'روزانہ گندے';

  @override
  String hoursShort(int hours) {
    return '$hours گ';
  }

  @override
  String hoursRange(int from, int to) {
    return '$from سے $to گھنٹے';
  }

  @override
  String typicalRange(String range) {
    return 'اس عمر میں عام: $range';
  }

  @override
  String get newbornFeedsGuide =>
      'ماں کا دودھ پینے والے نومولود عموماً دن میں 8 سے 12 بار دودھ پیتے ہیں۔';

  @override
  String get wetGuide =>
      'پانچویں دن سے، دن میں 6 یا زیادہ گیلے ڈائپر کافی دودھ کی نشانی ہیں۔';

  @override
  String get dirtyGuide =>
      'پہلے 6 ہفتوں میں ماں کا دودھ پینے والے زیادہ تر بچوں کے دن میں 2 یا زیادہ گندے ڈائپر ہوتے ہیں۔';

  @override
  String get reportNotEnough =>
      'ابھی کافی اندراجات نہیں۔ اندراج کرتے رہیں، یہ حصہ بھر جائے گا۔';

  @override
  String get reportAveragesNote =>
      'اوسط میں صرف وہ پورے دن شامل ہیں جن میں آپ نے یہ اندراج کیا؛ آج ابھی شامل نہیں۔';

  @override
  String get reportSources =>
      'عام حدود: نیشنل سلیپ فاؤنڈیشن (4 ماہ سے کم)، امریکن اکیڈمی آف سلیپ میڈیسن (4 ماہ اور زیادہ)، این ایچ ایس (خوراک اور ڈائپر)۔ نیند کے چارٹ پر ہلکی پٹی عام حد ہے۔ ہر بچہ مختلف ہوتا ہے؛ فکر ہو تو ڈاکٹر سے بات کریں۔';

  @override
  String get journalTitle => 'روزنامچہ';

  @override
  String get pastDays => 'پچھلے دن';

  @override
  String get yesterday => 'کل';

  @override
  String get pickDate => 'تاریخ چنیں';

  @override
  String get olderDay => 'پچھلا دن';

  @override
  String get newerDay => 'اگلا دن';

  @override
  String get onThisDay => 'اس دن';

  @override
  String get pumpingEntry => 'دودھ نکالا';

  @override
  String get nothingOnDay => 'اس دن کچھ درج نہیں کیا گیا۔';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get resetTitle => 'نیا پاس ورڈ بنائیں';

  @override
  String get resetHelp =>
      'اپنا ای میل لکھیں، ہم آپ کو 6 ہندسوں کا کوڈ بھیجیں گے۔';

  @override
  String get resetCodeSentHelp =>
      'اگر اس ای میل کا اکاؤنٹ ہے تو کوڈ بھیج دیا گیا ہے۔ اسے نئے پاس ورڈ کے ساتھ لکھیں۔';

  @override
  String get sendCodeButton => 'کوڈ بھیجیں';

  @override
  String get setPasswordButton => 'نیا پاس ورڈ محفوظ کریں';

  @override
  String get newPasswordLabel => 'نیا پاس ورڈ';

  @override
  String get repeatPasswordLabel => 'نیا پاس ورڈ دوبارہ';

  @override
  String get passwordsDontMatch => 'پاس ورڈ ایک جیسے نہیں';

  @override
  String get passwordChanged => 'آپ کا پاس ورڈ بدل دیا گیا ہے۔';

  @override
  String get passwordNotChanged =>
      'آپ سائن اِن ہیں، لیکن نیا پاس ورڈ محفوظ نہیں ہوا۔ سیٹنگز سے دوبارہ کوشش کریں۔';

  @override
  String get changePassword => 'پاس ورڈ بدلیں';

  @override
  String get illnessCold => 'نزلہ زکام';

  @override
  String get illnessFever => 'بخار';

  @override
  String get illnessCough => 'کھانسی';

  @override
  String get illnessTummy => 'پیٹ کی خرابی';

  @override
  String get illnessEar => 'کان کا انفیکشن';

  @override
  String get illnessRash => 'دانے';

  @override
  String get illnessUnnamed => 'طبیعت خراب';

  @override
  String get startIllness => 'بیماری کا ریکارڈ شروع کریں';

  @override
  String get startIllnessButton =>
      'بچے کی طبیعت خراب ہے؟ بیماری کا ریکارڈ شروع کریں';

  @override
  String get startIllnessHelp =>
      'اب سے علامات، بخار، دوا کی خوراکیں اور ڈاکٹر کے پاس جانا دن بہ دن ایک جگہ نظر آئیں گے، جب تک آپ بچے کو ٹھیک نہ لکھ دیں۔';

  @override
  String get editIllness => 'بیماری میں ترمیم';

  @override
  String get illnessNameLabel => 'کیا مسئلہ ہے؟ (اختیاری)';

  @override
  String get illnessStartedLabel => 'کب شروع ہوئی';

  @override
  String get recoveredLabel => 'ٹھیک ہو گیا';

  @override
  String get recoveredOnLabel => 'ٹھیک ہونے کی تاریخ';

  @override
  String get markRecovered => 'ٹھیک ہو گیا';

  @override
  String get stillUnwell => 'ابھی بھی بیمار';

  @override
  String get doctorVisit => 'ڈاکٹر کے پاس';

  @override
  String get doctorLabel => 'ڈاکٹر یا کلینک (اختیاری)';

  @override
  String get diagnosisLabel => 'ڈاکٹر نے کیا بتایا (اختیاری)';

  @override
  String get adviceLabel => 'مشورہ اور دوائیں (اختیاری)';

  @override
  String get nothingThisDay => 'اس دن کچھ درج نہیں۔';

  @override
  String illnessDay(int day) {
    return 'دن $day';
  }

  @override
  String illnessLasted(int days) {
    return '$days دن';
  }

  @override
  String illnessStartedOn(String date) {
    return 'شروع: $date';
  }

  @override
  String lastTemperature(String temp, String time) {
    return 'آخری بخار: $temp، $time بجے';
  }

  @override
  String highestTemperature(String temp) {
    return 'سب سے زیادہ بخار: $temp';
  }

  @override
  String dosesToday(int count) {
    return 'آج دوا کی $count خوراکیں';
  }

  @override
  String doctorVisitsCount(int count) {
    return 'ڈاکٹر کے پاس $count بار';
  }

  @override
  String get appearanceSection => 'ظاہری شکل';

  @override
  String get themeSystem => 'فون';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'گہرا';

  @override
  String get vegFirstTitle => 'سبزیوں سے شروع کریں';

  @override
  String get recipesTitle => 'بچوں کی ترکیبیں';

  @override
  String recipesSubtitle(int count) {
    return '6 سے 12 ماہ کے لیے $count گھریلو ترکیبیں';
  }

  @override
  String get recipesRules =>
      'بچوں کے لیے: نمک، چینی، شہد یا اسٹاک کیوب نہیں۔ انڈا اچھی طرح پکائیں، مچھلی کا ہر کانٹا نکالیں، اور کھانا ٹھنڈا کر کے دیں۔ گھر والوں کے لیے نمک مرچ ڈالنے سے پہلے بچے کا حصہ نکال لیں۔';

  @override
  String recipesFromMonths(int months) {
    return '$months ماہ سے';
  }

  @override
  String get recipesNotYet => 'ابھی آپ کے بچے کے لیے نہیں';

  @override
  String recipeContains(String allergens) {
    return 'شامل ہے: $allergens';
  }

  @override
  String get recipeIngredients => 'اجزا';

  @override
  String get recipeSteps => 'بنانے کا طریقہ';

  @override
  String get recipeLogTry => 'کھلانے کا اندراج کریں:';

  @override
  String get recipesSource =>
      'ٹھوس غذا شروع کرنے کے بارے میں NHS اور WHO کی رہنمائی پر مبنی۔ یہ عمومی رہنمائی ہے، طبی مشورہ نہیں؛ اگر بچے کو الرجی یا ایگزیما ہو تو ڈاکٹر سے پوچھیں۔';

  @override
  String get pdfButton => 'پی ڈی ایف';

  @override
  String get widgetLastFeed => 'آخری خوراک';

  @override
  String get widgetAsleep => 'سو رہا ہے';

  @override
  String get widgetAwake => 'جاگ رہا ہے';

  @override
  String get widgetEmpty => 'پالنا کھولنے کے لیے ٹیپ کریں';

  @override
  String widgetNextVaccine(String when, String date) {
    return 'اگلے ٹیکے ($when): $date';
  }

  @override
  String get continueWithApple => 'ایپل کے ساتھ جاری رکھیں';
}

/// The translations for Urdu, using the Latin script (`ur_Latn`).
class AppLocalizationsUrLatn extends AppLocalizationsUr {
  AppLocalizationsUrLatn() : super('ur_Latn');

  @override
  String get appTitle => 'Palna';

  @override
  String get errorGeneric => 'Kuch ghalat ho gaya. Dobara koshish karein.';

  @override
  String get fieldRequired => 'Zaroori hai';

  @override
  String get saveButton => 'Save karein';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get language => 'Zabaan';

  @override
  String get signOut => 'Sign out';

  @override
  String get signInTitle => 'Khush aamdeed';

  @override
  String get signInSubtitle =>
      'Apne baby ki feeding, neend aur bohat kuch track karein';

  @override
  String get nameLabel => 'Aap ka naam';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get invalidEmail => 'Sahi email likhein';

  @override
  String get passwordTooShort =>
      'Password kam az kam 6 characters ka hona chahiye';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signUpButton => 'Account banayein';

  @override
  String get switchToSignUp => 'Naye hain? Account banayein';

  @override
  String get verifyTitle => 'Apna code likhein';

  @override
  String verifySubtitle(String email) {
    return 'Hum ne $email par 6 digit ka code bheja hai';
  }

  @override
  String get codeLabel => '6 digit code';

  @override
  String get verifyButton => 'Confirm karein';

  @override
  String get resendCode => 'Naya code bhejein';

  @override
  String resendIn(int seconds) {
    return '$seconds second mein naya code bhejein';
  }

  @override
  String get codeSent => 'Naya code bhej diya gaya hai';

  @override
  String get invalidCode => 'Yeh code ghalat hai ya expire ho gaya hai';

  @override
  String get continueWithGoogle => 'Google ke saath jaari rakhein';

  @override
  String get orDivider => 'ya';

  @override
  String get switchToSignIn => 'Pehle se account hai? Sign in karein';

  @override
  String get addBabyTitle => 'Apne baby ko add karein';

  @override
  String get babyNameLabel => 'Baby ka naam';

  @override
  String get birthDateLabel => 'Tareekh-e-paidaish';

  @override
  String get sexLabel => 'Jins (optional)';

  @override
  String get sexFemale => 'Larki';

  @override
  String get sexMale => 'Larka';

  @override
  String get birthWeightLabel => 'Paidaish ka wazan kg mein (optional)';

  @override
  String get invalidWeight => '0.3 se 7 kg ke darmiyan wazan likhein';

  @override
  String ageMonths(int count) {
    return '$count mahine';
  }

  @override
  String ageDays(int count) {
    return '$count din';
  }

  @override
  String durationHm(int hours, int minutes) {
    return '$hours ghante $minutes minute';
  }

  @override
  String durationM(int minutes) {
    return '$minutes minute';
  }

  @override
  String agoLabel(String duration) {
    return '$duration pehle';
  }

  @override
  String get feeds => 'Feeding';

  @override
  String get diapers => 'Diapers';

  @override
  String get sleep => 'Neend';

  @override
  String bottleTotal(int ml) {
    return 'Bottle se $ml ml';
  }

  @override
  String lastFeed(String ago) {
    return 'Aakhri: $ago';
  }

  @override
  String diaperCounts(int wet, int dirty) {
    return '$wet geelay · $dirty gandey';
  }

  @override
  String sleepingSince(String time) {
    return '$time se so raha hai';
  }

  @override
  String get sleptToday => 'Aaj ki neend';

  @override
  String get logFeed => 'Feed';

  @override
  String get logDiaper => 'Diaper';

  @override
  String get startSleep => 'Neend';

  @override
  String get endSleep => 'Jaag gaya';

  @override
  String get feedTypeBreast => 'Maa ka doodh';

  @override
  String get feedTypeBottleBreastMilk => 'Nikala hua doodh';

  @override
  String get feedTypeFormula => 'Formula';

  @override
  String get sideLeft => 'Baayan';

  @override
  String get sideRight => 'Daayan';

  @override
  String get sideBoth => 'Dono';

  @override
  String get amountMl => 'Miqdaar (ml)';

  @override
  String get feedMinutes => 'Dauraniya minutes mein (optional)';

  @override
  String get invalidAmount => '1 se 1000 ml ke darmiyan miqdaar likhein';

  @override
  String get invalidMinutes => '1 se 180 minute ke darmiyan likhein';

  @override
  String get diaperWet => 'Geela';

  @override
  String get diaperDirty => 'Ganda';

  @override
  String get chooseDiaper => 'Geela, ganda ya dono chunein';

  @override
  String get timeLabel => 'Waqt';

  @override
  String get sleepNap => 'Nap';

  @override
  String get sleepNight => 'Raat ki neend';

  @override
  String get sleepingNow => 'so raha hai';

  @override
  String get todayTimeline => 'Aaj';

  @override
  String get nothingLoggedToday => 'Aaj abhi tak kuch record nahi kiya';

  @override
  String get tabToday => 'Aaj';

  @override
  String get tabGrowth => 'Growth';

  @override
  String get deleteButton => 'Delete karein';

  @override
  String get deleteConfirmTitle => 'Yeh entry delete karein?';

  @override
  String get editFeed => 'Feed edit karein';

  @override
  String get editDiaper => 'Diaper edit karein';

  @override
  String get editSleep => 'Neend edit karein';

  @override
  String get sleepStartLabel => 'So gaya';

  @override
  String get sleepEndLabel => 'Jaag gaya';

  @override
  String get stillAsleep => 'Abhi so raha hai';

  @override
  String get invalidSleepTimes => 'Jaagne ka waqt sone ke baad hona chahiye';

  @override
  String get growthTitle => 'Growth';

  @override
  String get addMeasurement => 'Measurement add karein';

  @override
  String get editMeasurement => 'Measurement edit karein';

  @override
  String get dateLabel => 'Tareekh';

  @override
  String get weightKgLabel => 'Wazan (kg)';

  @override
  String get lengthCmLabel => 'Qad (cm)';

  @override
  String get headCmLabel => 'Sar ka gher (cm)';

  @override
  String get enterOneMeasurement => 'Kam az kam ek measurement likhein';

  @override
  String get invalidWeightKg => '0.3 se 40 kg ke darmiyan wazan likhein';

  @override
  String get invalidLengthCm => '20 se 130 cm ke darmiyan qad likhein';

  @override
  String get invalidHeadCm => '20 se 60 cm ke darmiyan likhein';

  @override
  String get metricWeight => 'Wazan';

  @override
  String get metricLength => 'Qad';

  @override
  String get metricHead => 'Sar';

  @override
  String percentileValue(String percentile) {
    return 'Percentile: $percentile';
  }

  @override
  String changeSince(String change, String date) {
    return '$date se ab tak $change';
  }

  @override
  String get atBirth => 'Paidaish ke waqt';

  @override
  String get noMeasurements =>
      'Abhi koi measurement nahi. Agli dafa wazan karwane ke baad add karein.';

  @override
  String get chooseSexForChart =>
      'WHO growth curves se muqabla karne ke liye chunein:';

  @override
  String get curvesLegend =>
      'Grey lines: WHO Child Growth Standards, 3rd se 97th percentile tak. Aap ka baby: rangeen line.';

  @override
  String get percentileExplain =>
      'Percentile aap ke baby ka muqabla usi umar aur jins ke doosre bachon se karta hai; 50 darmiyan hai. Kisi ek number se zyada ahem yeh hai ke line waqt ke saath hamwar rahe. Agar line do grey lines paar kare ya seedhi ho jaye to apne doctor se baat karein.';

  @override
  String get whoAgeLimit =>
      'App mein WHO charts paidaish se 24 mahine tak hain.';

  @override
  String get tabHealth => 'Sehat';

  @override
  String get vaccinesTitle => 'Teekay';

  @override
  String get vaccineScheduleNote =>
      'Pakistan EPI schedule (sarkari hifazati teekon ka program). Tareekhon ki tasdeeq hamesha apne vaccinator ya bachon ke doctor se karein.';

  @override
  String get visitAtBirth => 'Paidaish par';

  @override
  String visitWeeks(int count) {
    return '$count hafte';
  }

  @override
  String visitMonths(int count) {
    return '$count mahine';
  }

  @override
  String dueOn(String date) {
    return 'Tareekh: $date';
  }

  @override
  String get statusDone => 'Sab lag gaye';

  @override
  String get statusOverdue => 'Der ho gayi';

  @override
  String get statusDueSoon => 'Jald';

  @override
  String get statusUpcoming => 'Aane wale';

  @override
  String givenOn(String date) {
    return '$date ko laga';
  }

  @override
  String get markGiven => 'Lag gaya';

  @override
  String get markVisitGiven => 'Sab lag gaye';

  @override
  String get recordVaccination => 'Teeka record karein';

  @override
  String get editVaccination => 'Teeka edit karein';

  @override
  String get dateGivenLabel => 'Lagne ki tareekh';

  @override
  String get batchLabel => 'Batch number (optional)';

  @override
  String get clinicLabel => 'Clinic ya doctor (optional)';

  @override
  String get notesLabel => 'Notes (optional)';

  @override
  String nextVisit(String visit, String date) {
    return 'Agla: $visit, $date';
  }

  @override
  String get allVaccinesDone => 'Schedule ke tamam teekay record hain.';

  @override
  String get catchUpNote =>
      'Koi teeka reh gaya? Zyada tar teekay baad mein bhi lag sakte hain aur aam taur par shuru se dobara lagwane ki zaroorat nahi hoti. Apne vaccinator ya bachon ke doctor se catch-up plan ke baare mein poochein.';

  @override
  String vaccinesDueTomorrow(String name) {
    return '$name ke teekay kal lagne hain';
  }

  @override
  String vaccinesDueToday(String name) {
    return '$name ke teekay aaj lagne hain';
  }

  @override
  String vaccinesOverdueReminder(String name) {
    return '$name ke teekon mein der ho gayi hai';
  }

  @override
  String get healthTitle => 'Sehat';

  @override
  String get tabVaccines => 'Teekay';

  @override
  String get tabMedicines => 'Dawaiyan';

  @override
  String get addMedicine => 'Dawa add karein';

  @override
  String get editMedicine => 'Dawa edit karein';

  @override
  String get medicineNameLabel => 'Dawa ka naam';

  @override
  String get prescribedDoseLabel =>
      'Doctor ki batayi hui khurak (maslan 2.5 ml)';

  @override
  String get scheduleAtTimes => 'Muqarrara auqaat par';

  @override
  String get scheduleAsNeeded => 'Zaroorat ke waqt';

  @override
  String get doseTimesLabel => 'Khurak ke auqaat';

  @override
  String get addTime => 'Waqt add karein';

  @override
  String get presetOnce => 'Din mein ek baar';

  @override
  String get presetTwice => 'Din mein 2 baar';

  @override
  String get presetThrice => 'Din mein 3 baar';

  @override
  String get presetEvery6h => 'Har 6 ghante baad';

  @override
  String get chooseTimes => 'Kam az kam ek waqt add karein';

  @override
  String get startDateLabel => 'Shuru karne ki tareekh';

  @override
  String get durationDaysLabel =>
      'Kitne din? (jaari rahe to khaali chhor dein)';

  @override
  String get invalidDays => '1 se 365 din ke darmiyan likhein';

  @override
  String get prescribedByLabel => 'Tajweez karne wala doctor (optional)';

  @override
  String get medicineSafetyNote =>
      'Dawa sirf doctor ki hidayat ke mutabiq dein. Yeh app nuskha save karti aur yaad dilati hai; yeh kabhi khurak ka hisaab nahi lagati na tajweez karti hai.';

  @override
  String get noMedicines => 'Koi dawa add nahi.';

  @override
  String get finishedMedicines => 'Mukammal';

  @override
  String untilDate(String date) {
    return '$date tak';
  }

  @override
  String get ongoing => 'Jaari';

  @override
  String get doseGiven => 'De di';

  @override
  String get doseSkipped => 'Chhor di';

  @override
  String get doseMissed => 'Reh gayi';

  @override
  String get markDoseGiven => 'De di';

  @override
  String get skipDose => 'Chhorein';

  @override
  String get undoDose => 'Wapas';

  @override
  String get recordDoseNow => 'Abhi khurak record karein';

  @override
  String lastGiven(String time) {
    return 'Aakhri baar: $time';
  }

  @override
  String medicineReminderTitle(String name) {
    return '$name ki dawa ka waqt';
  }

  @override
  String medicineReminderBody(String medicine, String dose) {
    return '$medicine: $dose';
  }

  @override
  String get tabMilk => 'Doodh';

  @override
  String get milkTitle => 'Maa ka doodh';

  @override
  String get logPumping => 'Pumping record karein';

  @override
  String get editPumping => 'Pumping edit karein';

  @override
  String get addStoredMilk => 'Stored doodh add karein';

  @override
  String pumpedToday(int ml, int count) {
    return 'Aaj pump kiya: $ml ml ($count baar)';
  }

  @override
  String get storeMilkIn => 'Yeh doodh ab kahan hai?';

  @override
  String get notStored => 'Foran pila diya';

  @override
  String get locationRoom => 'Kamra';

  @override
  String get locationCooler => 'Barf wala cooler';

  @override
  String get locationFridge => 'Fridge';

  @override
  String get locationFreezer => 'Freezer';

  @override
  String get locationThawed => 'Pighla hua, fridge mein';

  @override
  String get pumpedAtLabel => 'Pump karne ka waqt';

  @override
  String pumpedOn(String date) {
    return '$date ko pump kiya';
  }

  @override
  String useBy(String time) {
    return '$time tak istemal karein';
  }

  @override
  String get milkExpired => 'Expire ho gaya: zaaya kar dein';

  @override
  String milkNeedsAttention(int count) {
    return '$count stored doodh jald expire ho raha hai ya ho chuka hai.';
  }

  @override
  String get useForFeed => 'Feed ke liye istemal karein';

  @override
  String get moveToFridge => 'Fridge mein rakhein';

  @override
  String get moveToCooler => 'Cooler mein rakhein';

  @override
  String get moveToFreezer => 'Freeze karein';

  @override
  String get thawMilk => 'Fridge mein pighlayein';

  @override
  String get throwAway => 'Zaaya karein';

  @override
  String get noStoredMilk => 'Koi stored doodh nahi.';

  @override
  String get noRefreeze => 'Dobara freeze na karein';

  @override
  String get storageGuideTitle => 'Doodh kitni der mehfooz rehta hai';

  @override
  String get storageGuide =>
      'Taaza pump kiya hua doodh (CDC ki hidayat):\n• Kamra, 25°C ya kam: 4 ghante tak\n• Barf ke pack wala cooler bag: 24 ghante tak\n• Fridge: 4 din tak\n• Freezer: 6 mahine ke andar behtar, 12 mahine tak\n\nPighla hua doodh: fridge mein 24 ghante ke andar, ya garam karne ke baad 2 ghante ke andar istemal karein. Pighla hua doodh kabhi dobara freeze na karein.\nPilane ke baad bacha hua doodh: 2 ghante ke andar istemal karein, phir zaaya kar dein.\n\nPakistan ki garmiyon mein kamre aksar 25°C se zyada garam hote hain, is liye pump karne ke foran baad doodh fridge ya barf wale cooler mein rakhein.';

  @override
  String get loadSheddingTitle => 'Load-shedding ke dauran';

  @override
  String get loadSheddingGuide =>
      '• Fridge aur freezer band rakhein. Band fridge taqreeban 4 ghante thanda rehta hai; bhara hua freezer taqreeban 48 ghante (aadha bhara ho to 24).\n• Lambi bijli bandish mein doodh barf ya jame hue gel pack wale cooler bag mein rakhein. Is ke liye chand pack hamesha jama kar rakhein.\n• Agar jama hua doodh pighal jaye to dobara freeze na karein: thanda rakhein aur 24 ghante ke andar istemal karein.';

  @override
  String get milkExpiresTitle => 'Stored doodh jald expire hoga';

  @override
  String milkExpiresBody(int ml, String location, String time) {
    return '$ml ml ($location): $time tak istemal karein';
  }

  @override
  String storedMilkTotal(int ml) {
    return '$ml ml';
  }

  @override
  String get tabSymptoms => 'Alamaat';

  @override
  String get logSymptom => 'Alamat record karein';

  @override
  String get editSymptom => 'Alamat edit karein';

  @override
  String get symptomFever => 'Bukhar';

  @override
  String get symptomCough => 'Khansi';

  @override
  String get symptomRunnyNose => 'Naak behna';

  @override
  String get symptomVomiting => 'Ulti';

  @override
  String get symptomDiarrhea => 'Dast';

  @override
  String get symptomConstipation => 'Qabz';

  @override
  String get symptomRash => 'Daane';

  @override
  String get symptomTeething => 'Daant nikalna';

  @override
  String get symptomFeedingRefusal => 'Doodh na peena';

  @override
  String get symptomCrying => 'Ghair mamooli rona';

  @override
  String get symptomCongestion => 'Band naak';

  @override
  String get symptomOther => 'Deegar';

  @override
  String get temperatureLabel => 'Temperature (optional)';

  @override
  String get invalidTemperature => '30–45 °C ya 86–113 °F likhein';

  @override
  String get severityLabel => 'Kitni shadeed?';

  @override
  String get severityMild => 'Halki';

  @override
  String get severityModerate => 'Darmiyani';

  @override
  String get severitySevere => 'Shadeed';

  @override
  String get youngFeverWarning =>
      '3 mahine se kam umar ke bache mein 38°C (100.4°F) ya zyada temperature ho to foran doctor ko dikhayein.';

  @override
  String get noSymptoms => 'Pichhle 14 din mein koi alamat record nahi.';

  @override
  String get doctorSummary => 'Doctor ke liye khulasa';

  @override
  String get summarySinceStart => 'Alamaat shuru hone se';

  @override
  String lastNDays(int count) {
    return 'Pichhle $count din';
  }

  @override
  String get showInEnglish => 'English mein (doctor ke liye)';

  @override
  String get shareButton => 'Share karein';

  @override
  String get copyButton => 'Copy karein';

  @override
  String get copied => 'Copy ho gaya';

  @override
  String sumTitle(String name) {
    return 'Sehat ka khulasa: $name';
  }

  @override
  String sumAge(String age) {
    return 'Umar: $age';
  }

  @override
  String sumPeriod(String from, String to) {
    return 'Muddat: $from se $to tak';
  }

  @override
  String sumWeight(String weight, String date) {
    return 'Taaza tareen wazan: $weight ($date)';
  }

  @override
  String get sumSymptoms => 'Alamaat';

  @override
  String sumSymptomLine(String symptom, String first, String last, int count) {
    return '$symptom: $first se $last tak ($count entries)';
  }

  @override
  String sumHighestTemp(String temp, String when) {
    return 'sab se zyada $temp, $when';
  }

  @override
  String sumFeedsPerDay(String days) {
    return 'Rozana feeds: $days';
  }

  @override
  String sumWetPerDay(String days) {
    return 'Rozana geelay diapers: $days';
  }

  @override
  String sumDirtyPerDay(String days) {
    return 'Rozana gandey diapers: $days';
  }

  @override
  String sumUsually(String count) {
    return 'aam taur par taqreeban $count';
  }

  @override
  String sumTodaySoFar(int count) {
    return 'aaj ab tak $count';
  }

  @override
  String get sumMedicines => 'Di gayi dawaiyan';

  @override
  String sumMedicineLine(String name, String dose, int count, String when) {
    return '$name ($dose): $count khurakein, aakhri $when';
  }

  @override
  String get sumEntries => 'Tamam indrajaat';

  @override
  String get sumFooter => 'Walidain ne Palna mein record kiya.';

  @override
  String get firstSyncLoading => 'Aap ki family ka data load ho raha hai…';

  @override
  String get firstSyncNeedsInternet =>
      'Pehli baar is ke liye internet zaroori hai. Us ke baad app internet ke baghair bhi chalti hai.';

  @override
  String get offlineBanner =>
      'Offline: tabdeeliyan save hain aur internet aane par sync ho jayengi.';

  @override
  String get unsyncedSignOutTitle => 'Kuch tabdeeliyan abhi sync nahi hui';

  @override
  String get unsyncedSignOutBody =>
      'Agar aap abhi sign out karein to offline kiye gaye indrajaat zaaya ho jayenge. Unhein mehfooz rakhne ke liye pehle internet se judein.';

  @override
  String get signOutAnyway => 'Phir bhi sign out karein';

  @override
  String get editBabyTitle => 'Baby edit karein';

  @override
  String get birthLengthLabel => 'Paidaish ke waqt qad cm mein (optional)';

  @override
  String get birthHeadLabel =>
      'Paidaish ke waqt sar ka gher cm mein (optional)';

  @override
  String get invalidBirthLength => '20 se 70 cm ke darmiyan qad likhein';

  @override
  String get invalidBirthHead => '20 se 50 cm ke darmiyan likhein';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get babiesSection => 'Bachay';

  @override
  String get addAnotherBaby => 'Ek aur baby add karein';

  @override
  String get familySection => 'Family aur dekh bhaal karne wale';

  @override
  String get familyOffline =>
      'Family members dekhne aur invite karne ke liye internet se judein.';

  @override
  String get ownerLabel => 'Owner';

  @override
  String get caregiverLabel => 'Caregiver';

  @override
  String get youLabel => 'Aap';

  @override
  String get inviteCaregiver => 'Caregiver ko invite karein';

  @override
  String get inviteCodeTitle => 'Invite code';

  @override
  String get inviteCodeHelp =>
      'Un se kahein ke app install karein, account banayein aur yeh code likhein. Yeh ek baar kaam karta hai aur 7 din mein khatam ho jata hai.';

  @override
  String inviteShareText(String name, String code) {
    return 'Palna mein $name ki family join karne ke liye yeh code use karein: $code (7 din ke liye)';
  }

  @override
  String get joinFamily => 'Code se family join karein';

  @override
  String get joinFamilyPrompt =>
      'Family join kar rahe hain? Invite code likhein';

  @override
  String get inviteCodeLabel => '6 characters ka code';

  @override
  String get joinButton => 'Join karein';

  @override
  String get joinedFamily =>
      'Aap family mein shamil ho gaye. Un ka data abhi nazar aayega.';

  @override
  String get invalidInvite =>
      'Yeh code ghalat hai, use ho chuka hai ya expire ho gaya hai.';

  @override
  String get removeMember => 'Hatayein';

  @override
  String get leaveFamily => 'Family chhorein';

  @override
  String removeMemberConfirm(String name) {
    return '$name ko family se hatayein?';
  }

  @override
  String get leaveFamilyConfirm =>
      'Yeh family chhorein? Aap ko is ke bachay nazar aana band ho jayenge.';

  @override
  String get switchBaby => 'Baby badlein';

  @override
  String get atAGlance => 'Ek nazar mein';

  @override
  String hungerEstimate(String interval, String time) {
    return 'Aam taur par taqreeban har $interval baad doodh peeta hai, is liye agli feed taqreeban $time ke qareeb ho sakti hai.';
  }

  @override
  String get hungerDisclaimer =>
      'Yeh haaliya feeds se ek andaaza hai; hamesha baby ki bhook ke isharon par amal karein.';

  @override
  String sleepUsual(String usual, String today) {
    return 'Aam taur par din mein taqreeban $usual sota hai. Aaj ab tak: $today.';
  }

  @override
  String awakeFor(String duration) {
    return '$duration se jaag raha hai';
  }

  @override
  String usuallyAwake(String duration) {
    return 'aam taur par neendon ke darmiyan taqreeban $duration';
  }

  @override
  String vaccinesOverdueLine(String visit) {
    return 'Teekon mein der: $visit';
  }

  @override
  String medsTodayLine(int given, int total) {
    return 'Aaj ki dawaiyan: $total mein se $given khurakein record';
  }

  @override
  String get tabSolids => 'Thos ghiza';

  @override
  String get solidsTitle => 'Thos ghiza ka aaghaz';

  @override
  String get solidsTooYoung =>
      'Zyada tar bachay taqreeban 6 mahine par thos ghiza shuru karte hain. Tab tak aap pehle se parh sakte hain.';

  @override
  String get readinessTitle => 'Kya mera bacha tayyar hai?';

  @override
  String get texturesTitle => 'Ghiza ki saakht kaise badalti hai';

  @override
  String get foodRulesTitle => 'Ahem usool';

  @override
  String get allergensTitle => 'Allergy wali ghizayein';

  @override
  String get allergenNotYet => 'Abhi nahi';

  @override
  String get allergenIntroduced => 'Shuru ho gayi';

  @override
  String get allergenReaction => 'Rad-e-amal';

  @override
  String get reactionSignsTitle => 'Allergy rad-e-amal ki nishaniyan';

  @override
  String get beliefsTitle => 'Aam baatein bamuqabla saboot';

  @override
  String get beliefLabel => 'Aksar kaha jata hai';

  @override
  String get evidenceLabel => 'Saboot kya kehte hain';

  @override
  String get foodsTitle => 'Ghizayein';

  @override
  String get searchFoods => 'Ghiza talash karein';

  @override
  String get categoryAll => 'Sab';

  @override
  String get categoryFruit => 'Phal';

  @override
  String get categoryVegetable => 'Sabziyan';

  @override
  String get categoryGrain => 'Anaaj';

  @override
  String get categoryLegume => 'Daalein';

  @override
  String get categoryProtein => 'Gosht, machli aur anda';

  @override
  String get categoryDairy => 'Doodh se bani cheezein';

  @override
  String get categoryNut => 'Mewe aur beej';

  @override
  String get categoryOther => 'Abhi nahi';

  @override
  String fromMonths(int count) {
    return '$count mahine se';
  }

  @override
  String get chokingRisk =>
      'Gale mein phansne ka khatra: bataye gaye tareeqe se tayyar karein';

  @override
  String allergenLabel(String name) {
    return 'Allergy wali ghiza: $name';
  }

  @override
  String get logTry => 'Try record karein';

  @override
  String get editTry => 'Try edit karein';

  @override
  String get notTried => 'Abhi nahi aazmaya';

  @override
  String triedTimes(int count) {
    return '$count baar aazmaya';
  }

  @override
  String get opinionLabel => 'Kya pasand aaya?';

  @override
  String get opinionLiked => 'Pasand aaya';

  @override
  String get opinionNeutral => 'Theek';

  @override
  String get opinionDisliked => 'Pasand nahi aaya';

  @override
  String get reactionLabel => 'Koi rad-e-amal?';

  @override
  String get reactionNone => 'Koi nahi';

  @override
  String get reactionMild => 'Halka';

  @override
  String get reactionSevere => 'Shadeed';

  @override
  String get reactionWarning =>
      'Rad-e-amal hua tha: dobara dene se pehle doctor se baat karein.';

  @override
  String get severeReactionNow =>
      'Agar bache ko saans lene mein mushkil ho, zabaan ya gale mein soojan ho, ya woh dheela ya zard par jaye to abhi 1122 ya 115 par call karein.';

  @override
  String sourcesLabel(String sources) {
    return 'Maakhaz: $sources';
  }

  @override
  String get tabCharts => 'Charts';

  @override
  String get tabMilestones => 'Milestones';

  @override
  String byMonths(int count) {
    return '$count mahine tak';
  }

  @override
  String get areaSocial => 'Samaji o jazbati';

  @override
  String get areaLanguage => 'Zabaan aur baat cheet';

  @override
  String get areaCognitive => 'Seekhna aur sochna';

  @override
  String get areaMovement => 'Harkat';

  @override
  String get waysToHelp => 'Madad ke tareeqe';

  @override
  String get actEarlyTitle => 'Doctor se kab baat karein';

  @override
  String milestonesProgress(int done, int total) {
    return '$total mein se $done';
  }

  @override
  String reachedOn(String date) {
    return '$date ko';
  }

  @override
  String get helpTitle => 'Emergency aur madad';

  @override
  String get emergencyNumbers => 'Emergency numbers (Pakistan)';

  @override
  String get emergencyNumbersNote =>
      'Call karne ke liye tap karein. Sahooliyat har shehar mein mukhtalif hain; qareebi bachon ke hospital ka number bhi save rakhein.';

  @override
  String get numRescue => 'Rescue 1122: ambulance aur emergency';

  @override
  String get numEdhi => 'Edhi ambulance';

  @override
  String get numChhipa => 'Chhipa ambulance (Karachi)';

  @override
  String get numPolice => 'Police';

  @override
  String get numFire => 'Fire brigade';

  @override
  String get callEmergencyWhen =>
      'Foran madad ke liye call karein agar aap ka bacha';

  @override
  String get emergencySigns =>
      '• saans lene mein mushkil ho ya saans ruk ruk kar aaye\n• dheela, bohat ghunooda ho ya mushkil se jaage\n• jild, hont ya zabaan neeli, surmai, zard ya dhabbe daar ho, ya jism thanda lage\n• daura (jhatke) pare\n• kisi ghiza ya dawa ke baad zabaan ya gale mein soojan ho';

  @override
  String get heatTitle => 'Garmi aur load-shedding';

  @override
  String get heatGuide =>
      '• Bachon ko dhoop se bachayein, khaas taur par subah 11 se dopahar 3 baje tak, aur kabhi khari gaari mein akela na chhorein.\n• Ek halka sooti kapra pehnayein; saya aur pankha istemal karein.\n• Zyada baar doodh pilayein. Sirf maa ka doodh peene wale 6 mahine se kam bachon ko paani ki zaroorat nahi; formula peene wale bachon ke liye izafi paani ka doctor se poochein.\n• Load-shedding mein sab se thande kamre mein jaayein aur bache ko neem garam (thande ya barf wale nahi) paani mein bheege kapre se ponchhein.';

  @override
  String get dehydrationTitle =>
      'Paani ki kami ki nishaniyan: aaj hi doctor ko dikhayein';

  @override
  String get dehydrationSigns =>
      '• maamool se kam geelay diapers\n• rote waqt aansu kam ya bilkul na hon, ya munh khushk ho\n• sar ka naram hissa (taalu) ya aankhein dhansi hui hon\n• ghair mamooli taur par ghunooda ya chirchira ho';

  @override
  String get helpSources =>
      'Yeh NHS aur aalmi idara-e-sehat ki hidayat par mabni hai. Yeh umoomi maloomat hain, tashkhees nahi; fikr ho to doctor se rabta karein.';

  @override
  String get accountSection => 'Account';

  @override
  String get deleteAccount => 'Mera account delete karein';

  @override
  String get deleteAccountBody =>
      'Is se aap ka login hamesha ke liye delete ho jayega. Jin families mein sirf aap hain, un ke bachay aur saari entries bhi delete ho jayengi. Jin families mein doosre log bhi hain, un ke paas sab kuch rahega, aur agar aap owner hain to agla member owner ban jayega. Yeh wapas nahi ho sakta.';

  @override
  String get deleteAccountTypeHint => 'Confirm karne ke liye DELETE likhein';

  @override
  String get deleteAccountButton => 'Hamesha ke liye delete karein';

  @override
  String appVersion(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get deleteAccountFailed =>
      'Account delete nahi ho saka. Internet check kar ke dobara koshish karein.';

  @override
  String get startFeedTimer => 'Timer shuru karein';

  @override
  String lastSide(String side) {
    return 'Pichli dafa: $side side';
  }

  @override
  String get orEnterMinutes => 'Ya minute likhein';

  @override
  String get leftMinutes => 'Left (minute)';

  @override
  String get rightMinutes => 'Right (minute)';

  @override
  String get feedTimerAlreadyRunning =>
      'Feed ka timer pehle se chal raha hai. Yeh Aaj wali screen ke upar hai.';

  @override
  String get feedingNowTitle => 'Abhi doodh pee raha hai';

  @override
  String get feedingNow => 'abhi jaari hai';

  @override
  String get feedTimerPaused => 'Ruka hua';

  @override
  String get feedTimerHelp =>
      'Side badalne ke liye usay dabayein. Rokne ke liye chalti side ko dabayein.';

  @override
  String get finishFeed => 'Khatam karein';

  @override
  String get discardButton => 'Discard karein';

  @override
  String get discardFeedConfirm =>
      'Yeh feed discard karein? Timer aur us ka waqt delete ho jayega.';

  @override
  String get asleepNap => 'Nap le raha hai';

  @override
  String get asleepNight => 'Raat ki neend';

  @override
  String feedingNotificationTitle(String name) {
    return '$name doodh pee raha hai';
  }

  @override
  String sleepNotificationTitle(String name) {
    return '$name so raha hai';
  }

  @override
  String get reportsTitle => 'Reports';

  @override
  String get seeReports => 'Reports aur trends';

  @override
  String periodDays(int count) {
    return '$count din';
  }

  @override
  String get feedsPerDay => 'Roz ki feeds';

  @override
  String get timeBetweenFeeds => 'Feeds ke darmiyan aam waqfa';

  @override
  String get nursingPerDay => 'Roz breastfeeding';

  @override
  String get perBreastfeed => 'Har breastfeed';

  @override
  String get sideSplit => 'Left / right';

  @override
  String get bottlePerDay => 'Roz bottle ka doodh';

  @override
  String get perBottle => 'Har bottle';

  @override
  String get sleepPerDay => 'Roz ki neend';

  @override
  String get nightSleepPerDay => 'Raat ki neend';

  @override
  String get napsPerDay => 'Roz ki naps';

  @override
  String get napTimePerDay => 'Roz nap ka waqt';

  @override
  String get longestSleep => 'Sab se lambi neend';

  @override
  String get awakeBetweenSleeps => 'Neendon ke darmiyan jaagna';

  @override
  String get usualBedtime => 'Sone ka aam waqt';

  @override
  String get usualWakeUp => 'Jaagne ka aam waqt';

  @override
  String get wetPerDay => 'Roz geelay';

  @override
  String get dirtyPerDay => 'Roz gande';

  @override
  String hoursShort(int hours) {
    return '${hours}h';
  }

  @override
  String hoursRange(int from, int to) {
    return '$from se $to ghante';
  }

  @override
  String typicalRange(String range) {
    return 'Is umar mein aam: $range';
  }

  @override
  String get newbornFeedsGuide =>
      'Breastfeed karne wale naumolood aam taur par din mein 8 se 12 baar doodh peete hain.';

  @override
  String get wetGuide =>
      'Paanchwein din se, din mein 6 ya zyada geelay diaper kaafi doodh ki nishani hain.';

  @override
  String get dirtyGuide =>
      'Pehle 6 hafton mein breastfeed karne wale zyada tar bachon ke din mein 2 ya zyada gande diaper hote hain.';

  @override
  String get reportNotEnough =>
      'Abhi kaafi entries nahi. Entries karte rahein, yeh hissa bhar jayega.';

  @override
  String get reportAveragesNote =>
      'Average mein sirf woh poore din shamil hain jin mein aap ne yeh entry ki; aaj abhi shamil nahi.';

  @override
  String get reportSources =>
      'Aam hudood: National Sleep Foundation (4 maah se kam), American Academy of Sleep Medicine (4 maah aur zyada), NHS (feeds aur diapers). Neend ke chart par halki patti aam hadd hai. Har bacha mukhtalif hota hai; fikr ho to doctor se baat karein.';

  @override
  String get journalTitle => 'Journal';

  @override
  String get pastDays => 'Pichle din';

  @override
  String get yesterday => 'Kal';

  @override
  String get pickDate => 'Tareekh chunein';

  @override
  String get olderDay => 'Pichla din';

  @override
  String get newerDay => 'Agla din';

  @override
  String get onThisDay => 'Is din';

  @override
  String get pumpingEntry => 'Pumping';

  @override
  String get nothingOnDay => 'Is din kuch darj nahi kiya gaya.';

  @override
  String get forgotPassword => 'Password bhool gaye?';

  @override
  String get resetTitle => 'Naya password banayein';

  @override
  String get resetHelp =>
      'Apna email likhein, hum aap ko 6 hindson ka code bhejenge.';

  @override
  String get resetCodeSentHelp =>
      'Agar is email ka account hai to code bhej diya gaya hai. Usay naye password ke saath likhein.';

  @override
  String get sendCodeButton => 'Code bhejein';

  @override
  String get setPasswordButton => 'Naya password save karein';

  @override
  String get newPasswordLabel => 'Naya password';

  @override
  String get repeatPasswordLabel => 'Naya password dobara';

  @override
  String get passwordsDontMatch => 'Passwords ek jaise nahi';

  @override
  String get passwordChanged => 'Aap ka password badal diya gaya hai.';

  @override
  String get passwordNotChanged =>
      'Aap sign in hain, lekin naya password save nahi hua. Settings se dobara koshish karein.';

  @override
  String get changePassword => 'Password badlein';

  @override
  String get illnessCold => 'Nazla zukaam';

  @override
  String get illnessFever => 'Bukhar';

  @override
  String get illnessCough => 'Khansi';

  @override
  String get illnessTummy => 'Pait ki kharabi';

  @override
  String get illnessEar => 'Kaan ka infection';

  @override
  String get illnessRash => 'Daane';

  @override
  String get illnessUnnamed => 'Tabiyat kharab';

  @override
  String get startIllness => 'Bimari ka record shuru karein';

  @override
  String get startIllnessButton =>
      'Bachay ki tabiyat kharab hai? Bimari ka record shuru karein';

  @override
  String get startIllnessHelp =>
      'Ab se alamaat, bukhar, dawa ki doses aur doctor ke paas jana din ba din ek jagah nazar aayenge, jab tak aap bachay ko theek na likh dein.';

  @override
  String get editIllness => 'Bimari edit karein';

  @override
  String get illnessNameLabel => 'Kya masla hai? (optional)';

  @override
  String get illnessStartedLabel => 'Kab shuru hui';

  @override
  String get recoveredLabel => 'Theek ho gaya';

  @override
  String get recoveredOnLabel => 'Theek hone ki tareekh';

  @override
  String get markRecovered => 'Theek ho gaya';

  @override
  String get stillUnwell => 'Abhi bhi bemaar';

  @override
  String get doctorVisit => 'Doctor ke paas';

  @override
  String get doctorLabel => 'Doctor ya clinic (optional)';

  @override
  String get diagnosisLabel => 'Doctor ne kya bataya (optional)';

  @override
  String get adviceLabel => 'Mashwara aur dawaiyan (optional)';

  @override
  String get nothingThisDay => 'Is din kuch darj nahi.';

  @override
  String illnessDay(int day) {
    return 'Din $day';
  }

  @override
  String illnessLasted(int days) {
    return '$days din';
  }

  @override
  String illnessStartedOn(String date) {
    return 'Shuru: $date';
  }

  @override
  String lastTemperature(String temp, String time) {
    return 'Aakhri temperature: $temp, $time';
  }

  @override
  String highestTemperature(String temp) {
    return 'Sab se zyada temperature: $temp';
  }

  @override
  String dosesToday(int count) {
    return 'Aaj dawa ki $count doses';
  }

  @override
  String doctorVisitsCount(int count) {
    return 'Doctor ke paas $count baar';
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
  String get vegFirstTitle => 'Sabziyon se shuru karein';

  @override
  String get recipesTitle => 'Bachon ki tarkeebein';

  @override
  String recipesSubtitle(int count) {
    return '6 se 12 mahine ke liye $count gharelu tarkeebein';
  }

  @override
  String get recipesRules =>
      'Bachon ke liye: namak, cheeni, shehad ya stock cube nahi. Anda achhi tarah pakayein, machli ka har kaanta nikalein, aur khana thanda kar ke dein. Ghar walon ke liye namak mirch daalne se pehle bachay ka hissa nikaal lein.';

  @override
  String recipesFromMonths(int months) {
    return '$months mahine se';
  }

  @override
  String get recipesNotYet => 'Abhi aap ke bachay ke liye nahi';

  @override
  String recipeContains(String allergens) {
    return 'Shamil hai: $allergens';
  }

  @override
  String get recipeIngredients => 'Ajza';

  @override
  String get recipeSteps => 'Banane ka tareeqa';

  @override
  String get recipeLogTry => 'Khilane ka indraaj karein:';

  @override
  String get recipesSource =>
      'Solids shuru karne ke baare mein NHS aur WHO ki rehnumai par mabni. Yeh aam rehnumai hai, medical mashwara nahi; agar bachay ko allergy ya eczema ho to doctor se poochein.';

  @override
  String get pdfButton => 'PDF';

  @override
  String get widgetLastFeed => 'Aakhri feed';

  @override
  String get widgetAsleep => 'So raha hai';

  @override
  String get widgetAwake => 'Jaag raha hai';

  @override
  String get widgetEmpty => 'Palna kholne ke liye tap karein';

  @override
  String widgetNextVaccine(String when, String date) {
    return 'Agle teekay ($when): $date';
  }

  @override
  String get continueWithApple => 'Apple ke saath jaari rakhein';
}
