// Shared setup for the screen and form tests: the real theme and the real
// bundled fonts, so text is measured as on a phone (Nastaliq Urdu is much
// taller than the test default and is where overflows would appear).

import 'dart:io';

import 'package:baby_app/app/theme.dart';
import 'package:baby_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:baby_app/app/localization_delegates.dart';
import 'package:flutter/services.dart';

Future<void> loadAppFonts() async {
  const families = {
    'Lora': ['Lora-Regular', 'Lora-SemiBold', 'Lora-Bold'],
    'Nunito': ['Nunito-Regular', 'Nunito-SemiBold', 'Nunito-Bold'],
    'NotoNastaliqUrdu': ['NotoNastaliqUrdu-Regular', 'NotoNastaliqUrdu-Bold'],
  };
  for (final MapEntry(key: family, value: files) in families.entries) {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File('assets/fonts/$f.ttf').readAsBytesSync();
      loader.addFont(
        Future.value(ByteData.view(Uint8List.fromList(bytes).buffer)),
      );
    }
    await loader.load();
  }
  // Material icons, so icon sizes are real too.
  final icons = File(
    '${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.view(Uint8List.fromList(icons.readAsBytesSync()).buffer),
        ),
      );
    await loader.load();
  }
}

/// MaterialApp set up like the real app (theme per language, Roman Urdu LTR).
Widget testApp({required Locale locale, required Widget home, Brightness brightness = Brightness.light}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: locale,
  theme: buildTheme(const Locale('en')),
  localizationsDelegates: appLocalizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) {
    final l = Localizations.localeOf(context);
    Widget themed = Theme(data: buildTheme(l, brightness: brightness), child: child!);
    if (l.languageCode == 'ur' && l.scriptCode == 'Latn') {
      themed = Directionality(textDirection: TextDirection.ltr, child: themed);
    }
    return themed;
  },
  home: home,
);
