import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _ink = Color(0xFF17213B);
  static const _coral = Color(0xFFFF6B5E);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _coral,
      primary: _coral,
      secondary: const Color(0xFF00A896),
      surface: const Color(0xFFFFFBF8),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF8F7F4),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.w800,
          color: _ink,
          letterSpacing: -1.2,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          color: _ink,
          letterSpacing: -0.7,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: _ink),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: _ink),
        bodyLarge: TextStyle(height: 1.45, color: Color(0xFF3F4961)),
        bodyMedium: TextStyle(height: 1.4, color: Color(0xFF5C6475)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE7E3DE)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _coral,
      primary: const Color(0xFFFF8A7E),
      secondary: const Color(0xFF5CD6C7),
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF11131A),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1B1E27),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B1E27),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF343845)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
