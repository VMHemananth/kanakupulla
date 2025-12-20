import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Color Palette
  static const Color primaryColor = Color(0xFF4F46E5); // Electric Indigo
  static const Color secondaryColor = Color(0xFF14B8A6); // Teal
  static const Color tertiaryColor = Color(0xFFF43F5E); // Rose
  
  static const Color _lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color _darkBackground = Color(0xFF0F172A); // Slate 900
  
  static const Color _lightSurface = Colors.white;
  static const Color _darkSurface = Color(0xFF1E293B); // Slate 800

  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.outfit(
        textStyle: base.displayLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      displayMedium: GoogleFonts.outfit(
        textStyle: base.displayMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      displaySmall: GoogleFonts.outfit(
        textStyle: base.displaySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      headlineLarge: GoogleFonts.outfit(
        textStyle: base.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      headlineMedium: GoogleFonts.outfit(
        textStyle: base.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      headlineSmall: GoogleFonts.outfit(
        textStyle: base.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      titleLarge: GoogleFonts.outfit(
        textStyle: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  static ThemeData lightTheme(Color? seedColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor ?? primaryColor,
        brightness: Brightness.light,
        primary: seedColor ?? primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        background: _lightBackground,
        surface: _lightSurface,
      ),
      scaffoldBackgroundColor: _lightBackground,
      textTheme: _buildTextTheme(ThemeData.light().textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: _lightSurface,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: seedColor ?? primaryColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: seedColor ?? primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  static ThemeData darkTheme(Color? seedColor) {
    final baseDarkTextTheme = ThemeData.dark().textTheme;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor ?? primaryColor,
        brightness: Brightness.dark,
        primary: seedColor ?? primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        background: _darkBackground,
        surface: _darkSurface,
      ),
      scaffoldBackgroundColor: _darkBackground,
      textTheme: _buildTextTheme(baseDarkTextTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        color: _darkSurface,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: seedColor ?? primaryColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: seedColor ?? primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
