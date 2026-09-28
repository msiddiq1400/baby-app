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
}
