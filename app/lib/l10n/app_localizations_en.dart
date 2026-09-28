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
}
