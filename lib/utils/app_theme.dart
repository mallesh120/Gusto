import 'package:flutter/material.dart';

class AppTheme {
  static const Color terracotta = Color(0xFFE07A5F);
  static const Color cream = Color(0xFFF4F1DE);
  static const Color sage = Color(0xFF81B29A);
  static const Color brown = Color(0xFF3D405B);

  static const TextStyle headingStyle = TextStyle(
    color: brown,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyStyle = TextStyle(
    color: brown,
  );

  static ThemeData get theme {
    return ThemeData(
      primaryColor: terracotta,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.light(
        primary: terracotta,
        secondary: sage,
        surface: cream,
      ),
      textTheme: TextTheme(
        displayLarge: headingStyle.copyWith(fontSize: 32),
        displayMedium: headingStyle.copyWith(fontSize: 28),
        displaySmall: headingStyle.copyWith(fontSize: 24),
        bodyLarge: bodyStyle.copyWith(fontSize: 16),
        bodyMedium: bodyStyle.copyWith(fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: terracotta,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}