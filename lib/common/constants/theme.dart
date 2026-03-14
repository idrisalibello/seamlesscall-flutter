import 'package:flutter/material.dart';

enum AppThemePreset { seamlessBlue, oceanTeal, royalPurple, emeraldGlow }

class AppThemeSpec {
  final String id;
  final String label;
  final Color seed;
  final Gradient backgroundGradient;
  final Gradient accentGradient;

  const AppThemeSpec({
    required this.id,
    required this.label,
    required this.seed,
    required this.backgroundGradient,
    required this.accentGradient,
  });
}

class AppThemeCatalog {
  /// Default Seamless dark blue
  static const darkBlue = AppThemeSpec(
    id: 'dark_blue',
    label: 'Dark Blue',
    seed: Color.fromARGB(255, 7, 43, 105),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF06152E), Color(0xFF0B3D91)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    accentGradient: LinearGradient(
      colors: [Color.fromARGB(255, 5, 34, 91), Color.fromARGB(219, 95, 136, 248)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// Dark blue + teal accent
  static const darkBlueTeal = AppThemeSpec(
    id: 'dark_blue_teal',
    label: 'Dark Blue Teal',
    seed: Color(0xFF0B63F6),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF06152E), Color(0xFF0A4C5C)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFF17C3B2), Color(0xFF4CE0D2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// Dark blue + purple accent
  static const darkBluePurple = AppThemeSpec(
    id: 'dark_blue_purple',
    label: 'Dark Blue Purple',
    seed: Color(0xFF0B63F6),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF06152E), Color(0xFF35206D)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFF8E6BFF), Color(0xFFFF78C4)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// Dark blue + emerald accent
  static const darkBlueEmerald = AppThemeSpec(
    id: 'dark_blue_emerald',
    label: 'Dark Blue Emerald',
    seed: Color(0xFF0B63F6),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF06152E), Color(0xFF0C5E3E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFF00D084), Color(0xFF66F7B1)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// Deep fintech navy
  static const midnightNavy = AppThemeSpec(
    id: 'midnight_navy',
    label: 'Midnight Navy',
    seed: Color(0xFF0A1F44),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF020B1F), Color(0xFF0A1F44)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFF1C7CFF), Color(0xFF00D4FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  /// Tech / cyber style
  static const cyberBlue = AppThemeSpec(
    id: 'cyber_blue',
    label: 'Cyber Blue',
    seed: Color(0xFF0B63F6),
    backgroundGradient: LinearGradient(
      colors: [Color(0xFF040E2A), Color(0xFF0046B8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    accentGradient: LinearGradient(
      colors: [Color(0xFF00C2FF), Color(0xFF4B9CFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
  static const List<AppThemeSpec> all = [
    darkBlue,
    darkBlueTeal,
    darkBluePurple,
    darkBlueEmerald,
    midnightNavy,
    cyberBlue,
  ];
  static AppThemeSpec byId(String id) {
    return all.firstWhere((e) => e.id == id, orElse: () => darkBlue);
  }
}

class AppPalette {
  static const Color danger = Color(0xFFEE5566);
}

class AppTheme {
  static ThemeData lightTheme(AppThemeSpec preset) {
    final scheme = ColorScheme.fromSeed(
      seedColor: preset.seed,
      brightness: Brightness.light,
    );

    final textTheme = ThemeData.light().textTheme
        .apply(
          bodyColor: const Color(0xFF152033),
          displayColor: const Color(0xFF152033),
          fontFamily: 'Inter',
        )
        .copyWith(
          headlineSmall: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF152033),
          ),
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF152033),
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF152033),
          ),
          bodyMedium: const TextStyle(fontSize: 16, color: Color(0xFF31405E)),
          bodySmall: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        );

    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF6F9FF),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: const Color(0xFFE5ECF6),
      iconTheme: const IconThemeData(color: Color(0xFF4B5565)),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF152033),
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xFF7A8699)),
        labelStyle: const TextStyle(color: Color(0xFF475569)),
        prefixIconColor: const Color(0xFF556070),
        suffixIconColor: const Color(0xFF556070),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withOpacity(0.35)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 8,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFF556070),
        textColor: Color(0xFF152033),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          backgroundColor:
              (preset.accentGradient as LinearGradient).colors.first,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withOpacity(0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary.withOpacity(0.45)
              : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  static ThemeData darkTheme(AppThemeSpec preset) {
    final scheme = ColorScheme.fromSeed(
      seedColor: preset.seed,
      brightness: Brightness.dark,
    );

    final textTheme = ThemeData.dark().textTheme
        .apply(
          bodyColor: const Color(0xFFE6EEF8),
          displayColor: const Color(0xFFE6EEF8),
          fontFamily: 'Inter',
        )
        .copyWith(
          headlineSmall: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF4F8FF),
          ),
          titleLarge: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF4F8FF),
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE6EEF8),
          ),
          bodyMedium: const TextStyle(fontSize: 16, color: Color(0xFFD9E2F2)),
          bodySmall: const TextStyle(fontSize: 13, color: Color(0xFF9FB0C7)),
          labelLarge: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF0B1220),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: const Color(0xFF233047),
      iconTheme: const IconThemeData(color: Color(0xFFCBD5E1)),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFF4F8FF),
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF111B2E),
        hintStyle: const TextStyle(color: Color(0xFF9FB0C7)),
        labelStyle: const TextStyle(color: Color(0xFFC9D6EA)),
        prefixIconColor: const Color(0xFFC9D6EA),
        suffixIconColor: const Color(0xFFC9D6EA),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary.withOpacity(0.60)),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF101A2C),
        elevation: 6,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withOpacity(0.30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: Color(0xFFD9E2F2),
        textColor: Color(0xFFF4F8FF),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: const Color(0xFF101A2C),
        textStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 6,
          backgroundColor:
              (preset.accentGradient as LinearGradient).colors.first,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE6EEF8),
          side: BorderSide(color: scheme.primary.withOpacity(0.50)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : const Color(0xFFE2E8F0),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary.withOpacity(0.45)
              : const Color(0xFF334155),
        ),
      ),
    );
  }
}
