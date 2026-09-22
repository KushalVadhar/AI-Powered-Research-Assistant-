import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

/// Light theme configuration.
ThemeData buildLightTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.light,

    // Primary — main brand actions
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryLight.withValues(alpha: 0.1),
    onPrimaryContainer: AppColors.primaryLight,

    // Secondary — supporting actions
    secondary: AppColors.secondaryLight,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryLight.withValues(alpha: 0.1),
    onSecondaryContainer: AppColors.secondaryLight,

    // Tertiary — complementary accents
    tertiary: AppColors.tertiaryLight,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.tertiaryLight.withValues(alpha: 0.1),
    onTertiaryContainer: AppColors.tertiaryLight,

    // Error
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.error.withValues(alpha: 0.1),
    onErrorContainer: AppColors.error,

    // Surface — cards, sheets, backgrounds
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.textSecondaryLight,

    // Outline — borders, dividers
    outline: AppColors.borderLight,
    outlineVariant: AppColors.borderLight.withValues(alpha: 0.5),

    // Inverse
    inverseSurface: AppColors.surfaceDark,
    onInverseSurface: AppColors.textPrimaryDark,
    inversePrimary: AppColors.primaryDark,

    // Shadow
    shadow: Colors.black.withValues(alpha: 0.08),
    scrim: Colors.black.withValues(alpha: 0.3),
  );

  return _buildThemeData(colorScheme);
}

/// Builds ThemeData from a ColorScheme.
/// WHY A SHARED BUILDER:
/// Light and dark themes share 90% of their widget styling — the same
/// border radius, the same font sizes, the same button heights. Only
/// colors differ. This function handles the shared 90%.
ThemeData _buildThemeData(ColorScheme colorScheme) {
  // Base text theme using Inter font
  final textTheme = GoogleFonts.interTextTheme().copyWith(
    // Display styles — hero text, large numbers
    displayLarge: GoogleFonts.inter(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: colorScheme.onSurface,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: colorScheme.onSurface,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),

    // Headline styles — section headers
    headlineLarge: GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),

    // Title styles — card titles, list headers
    titleLarge: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: colorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: colorScheme.onSurface,
    ),

    // Body styles — paragraph text
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurface,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: colorScheme.onSurfaceVariant,
    ),

    // Label styles — buttons, chips, badges
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: colorScheme.onSurface,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: colorScheme.onSurfaceVariant,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: colorScheme.onSurfaceVariant,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: textTheme,
    brightness: colorScheme.brightness,

    // ── Scaffold ──────────────────────────────────────────────
    scaffoldBackgroundColor: colorScheme.surface,

    // ── App Bar ───────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),

    // ── Elevated Button ──────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: const Size(
          double.infinity,
          AppDimensions.buttonHeightLg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: textTheme.labelLarge,
      ),
    ),

    // ── Outlined Button ──────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          AppDimensions.buttonHeightLg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        side: BorderSide(color: colorScheme.outline),
        foregroundColor: colorScheme.primary,
        textStyle: textTheme.labelLarge,
      ),
    ),

    // ── Text Button ──────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: textTheme.labelLarge,
      ),
    ),

    // ── Input Decoration ─────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLg,
        vertical: AppDimensions.spacingMd,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: AppDimensions.inputBorderWidth,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.5),
          width: AppDimensions.inputBorderWidth,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: AppDimensions.inputBorderWidth,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: AppDimensions.inputBorderWidth,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2,
        ),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
      ),
      errorStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.error,
      ),
    ),

    // ── Card ─────────────────────────────────────────────────
    cardTheme: CardThemeData(
      elevation: AppDimensions.cardElevation,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      color: colorScheme.surface,
    ),

    // ── Bottom Navigation ────────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // ── Floating Action Button ───────────────────────────────
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
    ),

    // ── Chip ─────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      labelStyle: textTheme.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      side: BorderSide.none,
    ),

    // ── Divider ──────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: colorScheme.outline.withValues(alpha: 0.3),
      thickness: 1,
      space: 1,
    ),

    // ── Snackbar ─────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    ),

    // ── Dialog ───────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      elevation: 3,
    ),

    // ── Bottom Sheet ─────────────────────────────────────────
    bottomSheetTheme: BottomSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXxl),
        ),
      ),
      backgroundColor: colorScheme.surface,
    ),
  );
}
