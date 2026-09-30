import 'package:flutter/material.dart';
import 'localization_delegates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme.dart';

class BabyApp extends ConsumerWidget {
  const BabyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildTheme(const Locale('en')),
      darkTheme: buildTheme(const Locale('en'), brightness: Brightness.dark),
      themeMode: ref.watch(themeModeProvider),
      locale: ref.watch(localeProvider),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Flutter makes every 'ur' locale right-to-left, but Roman Urdu is
      // written in Latin script, so force left-to-right for it.
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        // Urdu script gets the Nastaliq font; English and Roman Urdu the
        // Latin fonts.
        // Theme.of already reflects light or dark (themeMode above).
        final brightness = Theme.of(context).brightness;
        Widget themed = Theme(data: buildTheme(locale, brightness: brightness), child: child!);
        if (locale.languageCode == 'ur' && locale.scriptCode == 'Latn') {
          themed = Directionality(textDirection: TextDirection.ltr, child: themed);
        }
        return themed;
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
