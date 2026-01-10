import 'package:flutter/material.dart';

class AppPalette {
  // Brand gradients (blue → cyan)
  static const Gradient brandGradient = LinearGradient(
    colors: [Color(0xFF04173B), Color.fromARGB(255, 6, 80, 121)],
    begin: Alignment(-0.9, -0.8),
    end: Alignment(0.9, 0.8),
  );

  // Alternate gradient for cards / accents
  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFF4C80FF), Color(0xFF2CE8E8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Static fallback colors
  static const Color primary = Color(0xFF0066FF);
  static const Color secondary = Color(0xFF00E5FF);
  static const Color danger = Color(0xFFEE5566);
}

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F9FF),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontSize: 16),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 8,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPalette.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0B1220),
    fontFamily: 'Inter',
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontSize: 16),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0E1724),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF0E1724),
      elevation: 6,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      ),
    ),
  );
}
