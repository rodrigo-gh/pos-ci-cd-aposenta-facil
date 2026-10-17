import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Obsidian Theme Palette from Stitch
  static const Color background = Color(0xFF09090B);
  static const Color surface = Color(0xFF0C0C0F);
  static const Color surfaceContainerLowest = Color(0xFF09090B);
  static const Color surfaceContainerLow = Color(0xFF0F0F12);
  static const Color surfaceContainer = Color(0xFF121215);
  static const Color surfaceContainerHigh = Color(0xFF18181B);
  static const Color surfaceContainerHighest = Color(0xFF1E1E22);

  static const Color primary = Color(0xFFA78BFA); // Soft Violet
  static const Color primaryContainer = Color(0xFF7C3AED);
  static const Color onPrimary = Color(0xFF0A0012);

  static const Color tertiary = Color(0xFF34D399); // Emerald Mint
  static const Color tertiaryContainer = Color(0xFF065F46);
  static const Color onTertiary = Color(0xFF001A12);
  static const Color onTertiaryContainer = Color(0xFFBBF7D0);

  static const Color outline = Color(0xFF52525B);
  static const Color outlineVariant = Color(0xFF27272A);

  static const Color onSurface = Color(0xFFFAFAFA);
  static const Color onSurfaceVariant = Color(0xFFA1A1AA);
  static const Color secondary = Color(0xFF71717A);
  
  static const Color amberAccent = Color(0xFFFCD34D);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
    );
  }
}
