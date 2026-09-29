import 'package:flutter/material.dart';

/// Palna's palette: a calm night-time navy, warm sand and soft rose on cream,
/// the same colours as the app icon.
abstract final class PalnaColors {
  static const navy = Color(0xFF34496E);
  static const navyDeep = Color(0xFF1F2D4A);
  static const sand = Color(0xFFE3B778);
  static const sandLight = Color(0xFFF5E6C8);
  static const rose = Color(0xFFB9676E);
  static const roseLight = Color(0xFFF6DADA);
  static const cream = Color(0xFFFBF7F0);
  static const line = Color(0xFFE8DFD0);
  static const ink = Color(0xFF1E2433);
}

/// Modern classic: a serif (Lora) for headings, a rounded sans (Nunito) for
/// everything else, and Nastaliq (Noto Nastaliq Urdu) for Urdu script.
/// Fonts are bundled, so they work offline.
ThemeData buildTheme(Locale locale) {
  final urduScript = locale.languageCode == 'ur' && locale.scriptCode != 'Latn';
  final bodyFont = urduScript ? 'NotoNastaliqUrdu' : 'Nunito';
  final headingFont = urduScript ? 'NotoNastaliqUrdu' : 'Lora';

  final scheme = ColorScheme.fromSeed(seedColor: PalnaColors.navy).copyWith(
    primary: PalnaColors.navy,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFDCE4F2),
    onPrimaryContainer: PalnaColors.navyDeep,
    secondary: const Color(0xFF8A6327),
    onSecondary: Colors.white,
    secondaryContainer: PalnaColors.sandLight,
    onSecondaryContainer: const Color(0xFF4A3510),
    tertiary: PalnaColors.rose,
    onTertiary: Colors.white,
    tertiaryContainer: PalnaColors.roseLight,
    onTertiaryContainer: const Color(0xFF4F1F24),
    surface: PalnaColors.cream,
    onSurface: PalnaColors.ink,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFFFFCF7),
    surfaceContainer: const Color(0xFFF6F0E6),
    surfaceContainerHigh: const Color(0xFFF1EADF),
    surfaceContainerHighest: const Color(0xFFEBE3D6),
    outlineVariant: PalnaColors.line,
  );

  final base = ThemeData(useMaterial3: true, colorScheme: scheme).textTheme.apply(
        fontFamily: bodyFont,
        bodyColor: PalnaColors.ink,
        displayColor: PalnaColors.ink,
      );
  TextStyle? heading(TextStyle? s) => s?.copyWith(fontFamily: headingFont, fontWeight: FontWeight.w600);
  final text = base.copyWith(
    displayLarge: heading(base.displayLarge),
    displayMedium: heading(base.displayMedium),
    displaySmall: heading(base.displaySmall),
    headlineLarge: heading(base.headlineLarge),
    headlineMedium: heading(base.headlineMedium),
    headlineSmall: heading(base.headlineSmall),
    titleLarge: heading(base.titleLarge),
    titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
  );

  const radius = 18.0;
  final roundedField = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: PalnaColors.line),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: bodyFont,
    textTheme: text,
    scaffoldBackgroundColor: PalnaColors.cream,
    appBarTheme: AppBarTheme(
      backgroundColor: PalnaColors.cream,
      foregroundColor: PalnaColors.navyDeep,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleTextStyle: text.titleLarge?.copyWith(color: PalnaColors.navyDeep),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: const BorderSide(color: PalnaColors.line),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: text.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        side: const BorderSide(color: PalnaColors.line),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(textStyle: text.labelLarge)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: PalnaColors.navy,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: roundedField,
      enabledBorder: roundedField,
      focusedBorder: roundedField.copyWith(borderSide: const BorderSide(color: PalnaColors.navy, width: 1.6)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: PalnaColors.sandLight,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: PalnaColors.navyDeep,
      unselectedLabelColor: PalnaColors.ink.withValues(alpha: 0.6),
      indicatorColor: PalnaColors.sand,
      labelStyle: text.titleSmall,
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(side: BorderSide(color: PalnaColors.line)),
      backgroundColor: Colors.white,
      selectedColor: PalnaColors.sandLight,
    ),
    listTileTheme: const ListTileThemeData(iconColor: PalnaColors.navy),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: PalnaColors.cream,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: PalnaColors.cream,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dividerTheme: const DividerThemeData(color: PalnaColors.line),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: PalnaColors.navyDeep,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
