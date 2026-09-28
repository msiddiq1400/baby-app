import 'dart:ui';

import '../l10n/app_localizations.dart';

/// Translations outside the widget tree (e.g. notification text): the
/// language chosen in the app, else the phone's, else English.
AppLocalizations appL10n(Locale? chosen) {
  final locale = chosen ?? PlatformDispatcher.instance.locale;
  if (locale.languageCode == 'ur') {
    return lookupAppLocalizations(
      locale.scriptCode == 'Latn' ? const Locale.fromSubtags(languageCode: 'ur', scriptCode: 'Latn') : const Locale('ur'),
    );
  }
  return lookupAppLocalizations(const Locale('en'));
}

/// Locale for intl date formats: Urdu script uses Urdu month names; Roman
/// Urdu has no format of its own, and English month names read fine there.
String dateLocale(AppLocalizations l10n) => l10n.localeName == 'ur' ? 'ur' : 'en';
