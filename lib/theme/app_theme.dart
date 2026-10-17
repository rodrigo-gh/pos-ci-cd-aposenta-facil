import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialPalette {
  final bool isDark;
  final Color background;
  final Color surface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color outline;
  final Color outlineVariant;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color secondary;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;
  final Color tertiary; // Growth & Compound Interest
  final Color tertiaryContainer;
  final Color onTertiary;
  final Color onTertiaryContainer;
  final Color amberAccent;
  final Color chartGrid;
  final Color chartHoverLine;
  final List<BoxShadow> cardShadow;

  const FinancialPalette({
    required this.isDark,
    required this.background,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.outline,
    required this.outlineVariant,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.secondary,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.onTertiary,
    required this.onTertiaryContainer,
    required this.amberAccent,
    required this.chartGrid,
    required this.chartHoverLine,
    required this.cardShadow,
  });
}

class AppColors {
  // Institutional Fintech Light Mode (Wealthfront / Stripe / BTG Digital)
  static const FinancialPalette lightPalette = FinancialPalette(
    isDark: false,
    background: Color(0xFFF8FAFC), // Slate 50: clean, paper-feel institutional canvas
    surface: Color(0xFFFFFFFF), // Pure white
    surfaceContainerLowest: Color(0xFFF1F5F9), // Slate 100: inputs & recessed elements
    surfaceContainerLow: Color(0xFFF8FAFC),
    surfaceContainer: Color(0xFFFFFFFF), // Elevated card surface
    surfaceContainerHigh: Color(0xFFF1F5F9), // Chips, pills, hover backgrounds
    surfaceContainerHighest: Color(0xFFE2E8F0), // Active tracks & borders
    outline: Color(0xFFCBD5E1), // Slate 300
    outlineVariant: Color(0xFFE2E8F0), // Slate 200: subtle hairline card borders
    onSurface: Color(0xFF0F172A), // Slate 900: deep authoritative ink
    onSurfaceVariant: Color(0xFF475569), // Slate 600: crisp secondary labels
    secondary: Color(0xFF64748B), // Slate 500: muted timestamps & captions
    primary: Color(0xFF4F46E5), // Indigo 600: personal contributions / investment anchor
    primaryContainer: Color(0xFFEEF2FF), // Indigo 50: soft tint
    onPrimary: Color(0xFFFFFFFF),
    tertiary: Color(0xFF059669), // Emerald 600: wealth accumulation & safe retirement growth
    tertiaryContainer: Color(0xFFD1FAE5), // Emerald 100
    onTertiary: Color(0xFFFFFFFF),
    onTertiaryContainer: Color(0xFF065F46), // Emerald 800
    amberAccent: Color(0xFFD97706), // Amber 600
    chartGrid: Color(0xFFE2E8F0),
    chartHoverLine: Color(0xFF94A3B8),
    cardShadow: [
      BoxShadow(
        color: Color(0x0A0F172A),
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );

  // Modern Fintech Dark Mode (Bloomberg / Nubank Ultravioleta / Obsidian Slate)
  static const FinancialPalette darkPalette = FinancialPalette(
    isDark: true,
    background: Color(0xFF0A0F1D), // Deep Navy Charcoal (not harsh pitch black)
    surface: Color(0xFF10172A), // Slate Navy
    surfaceContainerLowest: Color(0xFF070B16), // Recessed inputs
    surfaceContainerLow: Color(0xFF0E1424),
    surfaceContainer: Color(0xFF11192C), // Elevated card surface
    surfaceContainerHigh: Color(0xFF18233C), // Chips & elevation
    surfaceContainerHighest: Color(0xFF243354), // Active slider tracks
    outline: Color(0xFF334155), // Slate 700
    outlineVariant: Color(0xFF1E293B), // Slate 800: subtle card borders
    onSurface: Color(0xFFF8FAFC), // Slate 50: high-contrast legible text
    onSurfaceVariant: Color(0xFF94A3B8), // Slate 400: secondary text
    secondary: Color(0xFF64748B), // Slate 500: muted captions
    primary: Color(0xFF818CF8), // Indigo 400: personal contributions
    primaryContainer: Color(0xFF3730A3), // Indigo 800
    onPrimary: Color(0xFF0A0F1D),
    tertiary: Color(0xFF10B981), // Emerald 500: compound growth
    tertiaryContainer: Color(0xFF064E3B), // Emerald 900
    onTertiary: Color(0xFF022C22),
    onTertiaryContainer: Color(0xFF6EE7B7), // Emerald 300
    amberAccent: Color(0xFFF59E0B), // Amber 500
    chartGrid: Color(0xFF1E293B),
    chartHoverLine: Color(0xFF64748B),
    cardShadow: [],
  );

  // Resolves the active theme palette from the Widget tree
  static FinancialPalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? darkPalette : lightPalette;
  }

  // Backwards compatibility static getters (default to darkPalette)
  static Color get background => darkPalette.background;
  static Color get surface => darkPalette.surface;
  static Color get surfaceContainerLowest => darkPalette.surfaceContainerLowest;
  static Color get surfaceContainerLow => darkPalette.surfaceContainerLow;
  static Color get surfaceContainer => darkPalette.surfaceContainer;
  static Color get surfaceContainerHigh => darkPalette.surfaceContainerHigh;
  static Color get surfaceContainerHighest => darkPalette.surfaceContainerHighest;
  static Color get primary => darkPalette.primary;
  static Color get primaryContainer => darkPalette.primaryContainer;
  static Color get onPrimary => darkPalette.onPrimary;
  static Color get tertiary => darkPalette.tertiary;
  static Color get tertiaryContainer => darkPalette.tertiaryContainer;
  static Color get onTertiary => darkPalette.onTertiary;
  static Color get onTertiaryContainer => darkPalette.onTertiaryContainer;
  static Color get outline => darkPalette.outline;
  static Color get outlineVariant => darkPalette.outlineVariant;
  static Color get onSurface => darkPalette.onSurface;
  static Color get onSurfaceVariant => darkPalette.onSurfaceVariant;
  static Color get secondary => darkPalette.secondary;
  static Color get amberAccent => darkPalette.amberAccent;
}

class AppTheme {
  static ThemeData get lightTheme {
    final palette = AppColors.lightPalette;
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: palette.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: ColorScheme.light(
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        primaryContainer: palette.primaryContainer,
        secondary: palette.secondary,
        tertiary: palette.tertiary,
        onTertiary: palette.onTertiary,
        tertiaryContainer: palette.tertiaryContainer,
        onTertiaryContainer: palette.onTertiaryContainer,
        surface: palette.surface,
        onSurface: palette.onSurface,
        onSurfaceVariant: palette.onSurfaceVariant,
        outline: palette.outline,
        outlineVariant: palette.outlineVariant,
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.outlineVariant, width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.tertiary,
        thumbColor: palette.tertiary,
        inactiveTrackColor: palette.surfaceContainerHighest,
        overlayColor: palette.tertiary.withValues(alpha: 0.15),
      ),
    );
  }

  static ThemeData get darkTheme {
    final palette = AppColors.darkPalette;
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: palette.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: ColorScheme.dark(
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        primaryContainer: palette.primaryContainer,
        secondary: palette.secondary,
        tertiary: palette.tertiary,
        onTertiary: palette.onTertiary,
        tertiaryContainer: palette.tertiaryContainer,
        onTertiaryContainer: palette.onTertiaryContainer,
        surface: palette.surface,
        onSurface: palette.onSurface,
        onSurfaceVariant: palette.onSurfaceVariant,
        outline: palette.outline,
        outlineVariant: palette.outlineVariant,
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.outlineVariant, width: 1),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.tertiary,
        thumbColor: palette.tertiary,
        inactiveTrackColor: palette.surfaceContainerHighest,
        overlayColor: palette.tertiary.withValues(alpha: 0.15),
      ),
    );
  }
}
