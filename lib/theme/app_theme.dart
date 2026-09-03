import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // TEMPLATE 6 — INK WASH → MIST BLUE
  // ============================================================

  static const Color ink = Color(0xFF4A4A4A);
  static const Color lightGrey = Color(0xFFCBCBCB);
  static const Color cream = Color(0xFFFFFFE3);
  static const Color mistBlue = Color(0xFF6D8196);

  // Main colors
  static const Color background = Color(0xFFF7F8F7);
  static const Color sidebar = Color(0xFFE9ECEE);
  static const Color surface = Color(0xFFFBFBF8);

  static const Color border = Color(0xFFD9DDDF);

  static const Color textPrimary = Color(0xFF26323A);
  static const Color textSecondary = Color(0xFF66727B);
  static const Color textMuted = Color(0xFF8B949B);

  static const Color primary = mistBlue;
  static const Color purple = mistBlue;
  static const Color cyan = Color(0xFF8096AA);

  static const Color success = Color(0xFF4F9A72);
  static const Color warning = Color(0xFFC28A42);
  static const Color danger = Color(0xFFB85C5C);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,

      colorScheme: const ColorScheme.light(
        primary: mistBlue,
        secondary: ink,
        surface: surface,
        error: danger,
      ),

      fontFamily: 'Arial',

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(color: border, thickness: 1),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
      ),
    );
  }

  // Keep this so your existing app.dart does not break.
  static ThemeData get darkTheme {
    return lightTheme;
  }
}
