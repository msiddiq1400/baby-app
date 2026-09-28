import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';

class BabyApp extends StatelessWidget {
  const BabyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF6BA3BE)),
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
        if (locale.languageCode == 'ur' && locale.scriptCode == 'Latn') {
          return Directionality(textDirection: TextDirection.ltr, child: child!);
        }
        return child!;
      },
      routerConfig: router,
    );
  }
}
