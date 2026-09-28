import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

class BabyApp extends ConsumerWidget {
  const BabyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF6BA3BE)),
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
        if (locale.languageCode == 'ur' && locale.scriptCode == 'Latn') {
          return Directionality(textDirection: TextDirection.ltr, child: child!);
        }
        return child!;
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
