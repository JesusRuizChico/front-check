import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppPalette {
  oceano(
    nombre: 'Océano Azul',
    primary: Color(0xFF2563EB),
    primaryLight: Color(0xFF60A5FA),
    secondary: Color(0xFF6366F1),
    icon: Icons.water_drop_rounded,
  ),
  esmeralda(
    nombre: 'Verde Esmeralda',
    primary: Color(0xFF059669),
    primaryLight: Color(0xFF34D399),
    secondary: Color(0xFF10B981),
    icon: Icons.eco_rounded,
  ),
  purpura(
    nombre: 'Amatista Neón',
    primary: Color(0xFF7C3AED),
    primaryLight: Color(0xFFA78BFA),
    secondary: Color(0xFFD946EF),
    icon: Icons.auto_awesome_rounded,
  ),
  atardecer(
    nombre: 'Atardecer Coral',
    primary: Color(0xFFEA580C),
    primaryLight: Color(0xFFFB923C),
    secondary: Color(0xFFF59E0B),
    icon: Icons.local_fire_department_rounded,
  );

  final String nombre;
  final Color primary;
  final Color primaryLight;
  final Color secondary;
  final IconData icon;

  const AppPalette({
    required this.nombre,
    required this.primary,
    required this.primaryLight,
    required this.secondary,
    required this.icon,
  });
}

class ThemeState {
  final ThemeMode mode;
  final AppPalette palette;

  const ThemeState({
    this.mode = ThemeMode.dark,
    this.palette = AppPalette.oceano,
  });

  bool get isDark => mode == ThemeMode.dark;

  ThemeState copyWith({
    ThemeMode? mode,
    AppPalette? palette,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      palette: palette ?? this.palette,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return const ThemeState();
  }

  void toggleThemeMode() {
    state = state.copyWith(
      mode: state.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setPalette(AppPalette palette) {
    state = state.copyWith(palette: palette);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(mode: mode);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});

class DynamicAppTheme {
  static ThemeData buildTheme({
    required bool isDark,
    required AppPalette palette,
  }) {
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final surface = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final cardBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);
    final text = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.08);

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: palette.primary,
            secondary: palette.secondary,
            surface: surface,
            error: const Color(0xFFEF4444),
            onPrimary: Colors.white,
            onSurface: text,
          )
        : ColorScheme.light(
            primary: palette.primary,
            secondary: palette.secondary,
            surface: surface,
            error: const Color(0xFFEF4444),
            onPrimary: Colors.white,
            onSurface: text,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bg,
      cardColor: cardBg,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.outfitTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: text),
        displayMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: text),
        headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: text),
        headlineMedium: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: text),
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: text),
        bodyLarge: GoogleFonts.outfit(color: text),
        bodyMedium: GoogleFonts.outfit(color: textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: GoogleFonts.outfit(
          color: text,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: palette.primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0x22FFFFFF) : const Color(0x0A000000),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        hintStyle: TextStyle(color: textMuted),
        prefixIconColor: palette.primary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        selectedColor: palette.primary.withOpacity(0.2),
        secondarySelectedColor: palette.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(color: text),
      ),
    );
  }
}

