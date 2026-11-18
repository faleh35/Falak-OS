import 'package:flutter/material.dart';

/// FalakOS colors: night sky, teal planet, gold orbit.
class FalakColors {
  static const night = Color(0xFF0A0E26);
  static const nightDeep = Color(0xFF181039);
  static const panel = Color(0xFF141A3A);
  static const panelBorder = Color(0xFF2A3263);
  static const teal = Color(0xFF3EE0C8);
  static const blue = Color(0xFF1D3B8F);
  static const gold = Color(0xFFF5B942);
  static const text = Color(0xFFF2F4FF);
  static const muted = Color(0xFFA9B0D6);
  static const danger = Color(0xFFFF7A7A);
}

ThemeData buildFalakTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: FalakColors.teal,
    brightness: Brightness.dark,
  ).copyWith(
    primary: FalakColors.teal,
    onPrimary: FalakColors.night,
    secondary: FalakColors.gold,
    onSecondary: FalakColors.night,
    surface: FalakColors.panel,
    onSurface: FalakColors.text,
    error: FalakColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: FalakColors.night,
    fontFamily: 'Inter',
    fontFamilyFallback: const ['IBM Plex Sans Arabic', 'Cairo', 'Noto Sans Arabic', 'Noto Sans'],
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1B2250),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: FalakColors.panelBorder),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        textStyle: const TextStyle(fontSize: 15),
      ),
    ),
  );
}
