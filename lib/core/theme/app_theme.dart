import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundDarker,
        background: AppColors.backgroundDark,
        error: AppColors.danger,
        onSurfaceVariant: AppColors.glassBorderDark, // Usado para bordes de cristal
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textLight),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textLight),
        headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textLight),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textLight),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textLight),
        bodyLarge: GoogleFonts.outfit(color: AppColors.textLight),
        bodyMedium: GoogleFonts.outfit(color: AppColors.textMutedDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textLight),
        titleTextStyle: TextStyle(color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.textLight),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(AppColors.surfaceDark, AppColors.glassBorderDark, AppColors.textMutedDark, AppColors.textLight),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        secondary: AppColors.secondary,
        surface: AppColors.backgroundLighter,
        background: AppColors.backgroundLight,
        error: AppColors.danger,
        onSurfaceVariant: AppColors.glassBorderLight, // Usado para bordes de cristal
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textDark),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textDark),
        headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textDark),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textDark),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge: GoogleFonts.outfit(color: AppColors.textDark),
        bodyMedium: GoogleFonts.outfit(color: AppColors.textMutedLight),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDark),
        titleTextStyle: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: _elevatedButtonTheme(AppColors.textLight),
      textButtonTheme: _textButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(AppColors.surfaceLight, AppColors.glassBorderLight, AppColors.textMutedLight, AppColors.textDark),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Color textColor) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: textColor,
        elevation: 8,
        shadowColor: AppColors.accent.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Color fill, Color border, Color hint, Color icon) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.danger, width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.danger, width: 2)),
      hintStyle: TextStyle(color: hint),
      prefixIconColor: icon,
      suffixIconColor: icon,
    );
  }
}
