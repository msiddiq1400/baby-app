import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      locale: ref.watch(localeProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // Flutter makes every 'ur' locale right-to-left, but Roman Urdu is
      // written in Latin script, so force left-to-right for it.
      builder: (context, child) {
        final locale = Localizations.localeOf(context);
        // Urdu script gets the Nastaliq font; English and Roman Urdu the
        // Latin fonts.
        Widget themed = Theme(data: buildTheme(locale), child: child!);
        if (locale.languageCode == 'ur' && locale.scriptCode == 'Latn') {
          themed = Directionality(textDirection: TextDirection.ltr, child: themed);
        }
        return themed;
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
