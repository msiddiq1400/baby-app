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
  String get homeTitle => 'آج';

  @override
  String get homeEmpty => 'ابھی تک کوئی بچہ شامل نہیں کیا گیا';
}

/// The translations for Urdu, using the Latin script (`ur_Latn`).
class AppLocalizationsUrLatn extends AppLocalizationsUr {
  AppLocalizationsUrLatn() : super('ur_Latn');

  @override
  String get appTitle => 'Baby App';

  @override
  String get homeTitle => 'Aaj';

  @override
  String get homeEmpty => 'Abhi tak koi baby add nahi kiya gaya';
}
