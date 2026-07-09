/// ═══════════════════════════════════════════════════
/// QiblaHub — Tema (Material 3, Emerald & Gold)
/// ═══════════════════════════════════════════════════
library;

import 'package:flutter/material.dart';

class QhColors {
  static const primary = Color(0xFF0F9D58);
  static const primaryDark = Color(0xFF0B7A44);
  static const primaryBright = Color(0xFF16A862);
  static const gold = Color(0xFFD4AF37);
  static const goldLight = Color(0xFFFBF4DC);
  static const goldDark = Color(0xFF4A3A08);

  static const bgLight = Color(0xFFF4F6F5);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textLight = Color(0xFF1B2A24);
  static const text2Light = Color(0xFF5C6B64);

  static const bgDark = Color(0xFF0D1512);
  static const surfaceDark = Color(0xFF16211C);
  static const textDark = Color(0xFFE8F0EC);
  static const text2Dark = Color(0xFF9FB3AA);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, primaryBright],
  );
}

ThemeData qhTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: QhColors.primary,
    brightness: brightness,
    primary: QhColors.primary,
    secondary: QhColors.gold,
    surface: dark ? QhColors.surfaceDark : QhColors.surfaceLight,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? QhColors.bgDark : QhColors.bgLight,
    fontFamily: 'Roboto',
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardThemeData(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: dark ? const Color(0xFF24332C) : const Color(0xFFE4EAE7),
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: QhColors.primary.withValues(alpha: 0.14),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: dark ? QhColors.text2Dark : QhColors.text2Light,
        ),
      ),
      height: 68,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      foregroundColor: dark ? QhColors.textDark : QhColors.textLight,
      titleTextStyle: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: dark ? QhColors.textDark : QhColors.textLight,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: QhColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: QhColors.primary,
        side: const BorderSide(color: QhColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      hintStyle: TextStyle(color: dark ? QhColors.text2Dark : QhColors.text2Light),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(
          color: dark ? const Color(0xFF24332C) : const Color(0xFFE4EAE7),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: BorderSide(
          color: dark ? const Color(0xFF24332C) : const Color(0xFFE4EAE7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(999),
        borderSide: const BorderSide(color: QhColors.primary, width: 1.5),
      ),
    ),
  );
}
