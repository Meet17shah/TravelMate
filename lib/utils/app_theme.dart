import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF1A1A2E);
  static const Color secondary = Color(0xFF16213E);
  static const Color accent = Color(0xFF0F3460);
  static const Color highlight = Color(0xFFE94560);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color cardBg = Color(0xFF1E1E3A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0C8);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: highlight,
        secondary: accent,
        surface: cardBg,
        onPrimary: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.playfairDisplay(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: GoogleFonts.playfairDisplay(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.dmSans(color: textPrimary, fontSize: 16),
        bodyMedium: GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
        labelLarge: GoogleFonts.jetBrainsMono(color: highlight, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: secondary,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: highlight,
      ),
    );
  }
}
