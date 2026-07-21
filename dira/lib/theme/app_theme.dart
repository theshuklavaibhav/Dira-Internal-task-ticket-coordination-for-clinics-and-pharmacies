import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light — exact tokens from your Stitch DESIGN.md
  static const _lightPrimary = Color(0xFF3525CD);
  static const _lightOnPrimary = Color(0xFFFFFFFF);
  static const _lightPrimaryContainer = Color(0xFF4F46E5);
  static const _lightOnPrimaryContainer = Color(0xFFDAD7FF);
  static const _lightSecondary = Color(0xFFA93349);
  static const _lightOnSecondary = Color(0xFFFFFFFF);
  static const _lightSecondaryContainer = Color(0xFFFE7488);
  static const _lightOnSecondaryContainer = Color(0xFF730425);
  static const _lightTertiary = Color(0xFF3130C0);
  static const _lightError = Color(0xFFBA1A1A);
  static const _lightErrorContainer = Color(0xFFFFDAD6);
  static const _lightOnErrorContainer = Color(0xFF93000A);
  static const _lightSurface = Color(0xFFF8F9FF);
  static const _lightOnSurface = Color(0xFF0B1C30);
  static const _lightOnSurfaceVariant = Color(0xFF464555);
  static const _lightOutline = Color(0xFF777587);
  static const _lightOutlineVariant = Color(0xFFC7C4D8);
  static const _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const _lightSurfaceContainerLow = Color(0xFFEFF4FF);
  static const _lightSurfaceContainer = Color(0xFFE5EEFF);
  static const _lightSurfaceContainerHigh = Color(0xFFDCE9FF);
  static const _lightSurfaceContainerHighest = Color(0xFFD3E4FE);

  // Dark — crafted from your dark-mode mockup (bg #0b1c30, lavender accent #c3c0ff)
  static const _darkPrimary = Color(0xFFC3C0FF);
  static const _darkOnPrimary = Color(0xFF0F0069);
  static const _darkPrimaryContainer = Color(0xFF4F46E5);
  static const _darkOnPrimaryContainer = Color(0xFFDAD7FF);
  static const _darkSecondary = Color(0xFFFFB2B9);
  static const _darkOnSecondary = Color(0xFF400010);
  static const _darkSecondaryContainer = Color(0xFFA93349);
  static const _darkOnSecondaryContainer = Color(0xFFFFDADC);
  static const _darkTertiary = Color(0xFFC0C1FF);
  static const _darkError = Color(0xFFFFB4AB);
  static const _darkErrorContainer = Color(0xFF93000A);
  static const _darkOnErrorContainer = Color(0xFFFFDAD6);
  static const _darkSurface = Color(0xFF0B1C30);
  static const _darkOnSurface = Color(0xFFEAF1FF);
  static const _darkOnSurfaceVariant = Color(0xFFC7C4D8);
  static const _darkOutline = Color(0xFF8D8A9E);
  static const _darkOutlineVariant = Color(0xFF464555);
  static const _darkSurfaceContainerLowest = Color(0xFF060F1C);
  static const _darkSurfaceContainerLow = Color(0xFF11223A);
  static const _darkSurfaceContainer = Color(0xFF152840);
  static const _darkSurfaceContainerHigh = Color(0xFF1D3049);
  static const _darkSurfaceContainerHighest = Color(0xFF283C57);

  static ThemeData get light => _build(
        Brightness.light,
        ColorScheme(
          brightness: Brightness.light,
          primary: _lightPrimary,
          onPrimary: _lightOnPrimary,
          primaryContainer: _lightPrimaryContainer,
          onPrimaryContainer: _lightOnPrimaryContainer,
          secondary: _lightSecondary,
          onSecondary: _lightOnSecondary,
          secondaryContainer: _lightSecondaryContainer,
          onSecondaryContainer: _lightOnSecondaryContainer,
          tertiary: _lightTertiary,
          onTertiary: Colors.white,
          error: _lightError,
          onError: Colors.white,
          errorContainer: _lightErrorContainer,
          onErrorContainer: _lightOnErrorContainer,
          surface: _lightSurface,
          onSurface: _lightOnSurface,
          onSurfaceVariant: _lightOnSurfaceVariant,
          outline: _lightOutline,
          outlineVariant: _lightOutlineVariant,
          surfaceContainerLowest: _lightSurfaceContainerLowest,
          surfaceContainerLow: _lightSurfaceContainerLow,
          surfaceContainer: _lightSurfaceContainer,
          surfaceContainerHigh: _lightSurfaceContainerHigh,
          surfaceContainerHighest: _lightSurfaceContainerHighest,
          inverseSurface: const Color(0xFF213145),
          onInverseSurface: const Color(0xFFEAF1FF),
          inversePrimary: const Color(0xFFC3C0FF),
        ),
      );

  static ThemeData get dark => _build(
        Brightness.dark,
        ColorScheme(
          brightness: Brightness.dark,
          primary: _darkPrimary,
          onPrimary: _darkOnPrimary,
          primaryContainer: _darkPrimaryContainer,
          onPrimaryContainer: _darkOnPrimaryContainer,
          secondary: _darkSecondary,
          onSecondary: _darkOnSecondary,
          secondaryContainer: _darkSecondaryContainer,
          onSecondaryContainer: _darkOnSecondaryContainer,
          tertiary: _darkTertiary,
          onTertiary: const Color(0xFF07006C),
          error: _darkError,
          onError: const Color(0xFF690005),
          errorContainer: _darkErrorContainer,
          onErrorContainer: _darkOnErrorContainer,
          surface: _darkSurface,
          onSurface: _darkOnSurface,
          onSurfaceVariant: _darkOnSurfaceVariant,
          outline: _darkOutline,
          outlineVariant: _darkOutlineVariant,
          surfaceContainerLowest: _darkSurfaceContainerLowest,
          surfaceContainerLow: _darkSurfaceContainerLow,
          surfaceContainer: _darkSurfaceContainer,
          surfaceContainerHigh: _darkSurfaceContainerHigh,
          surfaceContainerHighest: _darkSurfaceContainerHighest,
          inverseSurface: const Color(0xFFEAF1FF),
          onInverseSurface: const Color(0xFF0B1C30),
          inversePrimary: const Color(0xFF3525CD),
        ),
      );

  static ThemeData _build(Brightness brightness, ColorScheme scheme) {
    final textTheme = GoogleFonts.manropeTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme.copyWith(
        headlineMedium: GoogleFonts.manrope(
            fontSize: 24, fontWeight: FontWeight.w600, color: scheme.onSurface),
        headlineSmall: GoogleFonts.manrope(
            fontSize: 20, fontWeight: FontWeight.w600, color: scheme.onSurface),
        titleLarge: GoogleFonts.manrope(
            fontSize: 18, fontWeight: FontWeight.w600, color: scheme.onSurface),
        bodyLarge: GoogleFonts.manrope(fontSize: 16, color: scheme.onSurface),
        bodyMedium: GoogleFonts.manrope(fontSize: 14, color: scheme.onSurfaceVariant),
        labelLarge: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle:
            GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w600, color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
            color: scheme.surfaceContainerLowest,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: scheme.outlineVariant.withOpacity(0.4)),
            ),
            margin: const EdgeInsets.symmetric(vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline.withOpacity(0.5)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant.withOpacity(0.3)),
    );
  }
}