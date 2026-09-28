// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'بے بی ایپ';

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
}

/// The translations for Urdu, using the Latin script (`ur_Latn`).
class AppLocalizationsUrLatn extends AppLocalizationsUr {
  AppLocalizationsUrLatn() : super('ur_Latn');

  @override
  String get appTitle => 'Baby App';

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
}
