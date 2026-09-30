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

  // Night: the same family of colours, dimmed for 3 am feeds.
  static const night = Color(0xFF121722);
  static const nightCard = Color(0xFF1B2230);
  static const nightLine = Color(0xFF2C3547);
  static const nightInk = Color(0xFFECE7DF);
  static const nightNavy = Color(0xFF8FA6D1);

  /// Chart colour for night sleep / wet diapers, readable on either background.
  static Color chartNavy(Brightness b) => b == Brightness.dark ? nightNavy : navy;
}

/// The colours that differ between light and dark.
class _Palette {
  const _Palette({
    required this.background,
    required this.card,
    required this.ink,
    required this.line,
    required this.heading,
    required this.primary,
    required this.onPrimary,
    required this.chipSelected,
    required this.snack,
  });

  final Color background;
  final Color card;
  final Color ink;
  final Color line;
  final Color heading;
  final Color primary;
  final Color onPrimary;
  final Color chipSelected;
  final Color snack;

  static const light = _Palette(
    background: PalnaColors.cream,
    card: Colors.white,
    ink: PalnaColors.ink,
    line: PalnaColors.line,
    heading: PalnaColors.navyDeep,
    primary: PalnaColors.navy,
    onPrimary: Colors.white,
    chipSelected: PalnaColors.sandLight,
    snack: PalnaColors.navyDeep,
  );

  static const dark = _Palette(
    background: PalnaColors.night,
    card: PalnaColors.nightCard,
    ink: PalnaColors.nightInk,
    line: PalnaColors.nightLine,
    heading: PalnaColors.nightInk,
    // Warm sand buttons: easy on the eyes in the dark.
    primary: PalnaColors.sand,
    onPrimary: Color(0xFF2B1F08),
    chipSelected: Color(0xFF3A3326),
    snack: Color(0xFF2C3547),
  );
}

/// Modern classic: a serif (Lora) for headings, a rounded sans (Nunito) for
/// everything else, and Nastaliq (Noto Nastaliq Urdu) for Urdu script.
/// Fonts are bundled, so they work offline.
ThemeData buildTheme(Locale locale, {Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final p = dark ? _Palette.dark : _Palette.light;
  final urduScript = locale.languageCode == 'ur' && locale.scriptCode != 'Latn';
  final bodyFont = urduScript ? 'NotoNastaliqUrdu' : 'Nunito';
  final headingFont = urduScript ? 'NotoNastaliqUrdu' : 'Lora';

  final scheme = dark
      ? ColorScheme.fromSeed(seedColor: PalnaColors.navy, brightness: Brightness.dark).copyWith(
          primary: p.primary,
          onPrimary: p.onPrimary,
          primaryContainer: const Color(0xFF2D3B57),
          onPrimaryContainer: const Color(0xFFDCE4F2),
          secondary: PalnaColors.sand,
          onSecondary: const Color(0xFF2B1F08),
          secondaryContainer: const Color(0xFF3A3326),
          onSecondaryContainer: const Color(0xFFF3E3C6),
          tertiary: const Color(0xFFE0959B),
          onTertiary: const Color(0xFF3A1519),
          tertiaryContainer: const Color(0xFF4A2A2E),
          onTertiaryContainer: const Color(0xFFF6DADA),
          surface: p.background,
          onSurface: p.ink,
          surfaceContainerLowest: const Color(0xFF0E121B),
          surfaceContainerLow: const Color(0xFF171D29),
          surfaceContainer: p.card,
          surfaceContainerHigh: const Color(0xFF222A3A),
          surfaceContainerHighest: const Color(0xFF2A3344),
          outlineVariant: p.line,
        )
      : ColorScheme.fromSeed(seedColor: PalnaColors.navy).copyWith(
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
        bodyColor: p.ink,
        displayColor: p.ink,
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
    borderSide: BorderSide(color: p.line),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: bodyFont,
    textTheme: text,
    scaffoldBackgroundColor: p.background,
    appBarTheme: AppBarTheme(
      backgroundColor: p.background,
      foregroundColor: p.heading,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleTextStyle: text.titleLarge?.copyWith(color: p.heading),
    ),
    cardTheme: CardThemeData(
      color: p.card,
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: p.line),
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
        side: BorderSide(color: p.line),
        textStyle: text.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(textStyle: text.labelLarge)),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: p.primary,
      foregroundColor: p.onPrimary,
      shape: const StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      border: roundedField,
      enabledBorder: roundedField,
      focusedBorder: roundedField.copyWith(borderSide: BorderSide(color: p.primary, width: 1.6)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: p.chipSelected,
      labelTextStyle: WidgetStatePropertyAll(text.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: p.heading,
      unselectedLabelColor: p.ink.withValues(alpha: 0.6),
      indicatorColor: PalnaColors.sand,
      labelStyle: text.titleSmall,
    ),
    chipTheme: ChipThemeData(
      shape: StadiumBorder(side: BorderSide(color: p.line)),
      backgroundColor: p.card,
      selectedColor: p.chipSelected,
    ),
    listTileTheme: ListTileThemeData(iconColor: dark ? PalnaColors.nightNavy : PalnaColors.navy),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.background,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dividerTheme: DividerThemeData(color: p.line),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: p.snack,
      contentTextStyle: text.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
