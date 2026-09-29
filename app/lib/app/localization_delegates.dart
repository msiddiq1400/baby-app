import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';

/// Flutter's built-in texts and date formats (month names in the date
/// picker, "Sep 16" and so on) for Roman Urdu come out in Urdu script,
/// because Flutter only knows "ur". Roman Urdu readers read Latin script,
/// so they get the English ones instead.
class _RomanUrduAsEnglish<T> extends LocalizationsDelegate<T> {
  const _RomanUrduAsEnglish(this._english);

  final LocalizationsDelegate<T> _english;

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ur' && locale.scriptCode == 'Latn';

  @override
  Future<T> load(Locale locale) => _english.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<T> old) => false;

  @override
  Type get type => T;
}

/// The app's localization delegates. The Roman Urdu ones come first, so they
/// win over Flutter's Urdu ones for Roman Urdu.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  _RomanUrduAsEnglish<MaterialLocalizations>(GlobalMaterialLocalizations.delegate),
  _RomanUrduAsEnglish<CupertinoLocalizations>(GlobalCupertinoLocalizations.delegate),
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
