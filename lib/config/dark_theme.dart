import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

/// Dark theme configuration.
/// WHY A SEPARATE FILE (not just a function in light_theme.dart):
/// As themes grow, each can easily reach 200+ lines. Keeping them
/// separate makes diffs cleaner and avoids merge conflicts when two
/// developers are tweaking light vs dark simultaneously.
ThemeData buildDarkTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.dark,

    // Primary — lighter tint for visibility on dark surfaces
    primary: AppColors.primaryDark,
    onPrimary: AppColors.surfaceDark,
    primaryContainer: AppColors.primaryDark.withValues(alpha: 0.15),
    onPrimaryContainer: AppColors.primaryDark,

    // Secondary
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.surfaceDark,
    secondaryContainer: AppColors.secondaryDark.withValues(alpha: 0.15),
    onSecondaryContainer: AppColors.secondaryDark,

    // Tertiary
    tertiary: AppColors.tertiaryDark,
    onTertiary: AppColors.surfaceDark,
    tertiaryContainer: AppColors.tertiaryDark.withValues(alpha: 0.15),
    onTertiaryContainer: AppColors.tertiaryDark,

    // Error
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: AppColors.error.withValues(alpha: 0.15),
    onErrorContainer: AppColors.error,

    // Surface — dark backgrounds
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,

    // Outline — more visible borders for dark mode
    outline: AppColors.borderDark,
    outlineVariant: AppColors.borderDark.withValues(alpha: 0.5),

    // Inverse
    inverseSurface: AppColors.surfaceLight,
    onInverseSurface: AppColors.textPrimaryLight,
    inversePrimary: AppColors.primaryLight,

    // Shadow
    shadow: Colors.black.withValues(alpha: 0.3),
    scrim: Colors.black.withValues(alpha: 0.5),
  );

  return _buildDarkThemeData(colorScheme);
}

/// Builds ThemeData for dark mode.
/// This is nearly identical to light theme's builder, but with
/// subtle differences:
/// - Cards use slightly lighter borders (more visible on dark)
/// - Input fills are more opaque (better contrast)
/// - Shadows are stronger (compensate for dark background)
ThemeData _buildDarkThemeData(ColorScheme colorScheme) {
  final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
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
    brightness: Brightness.dark,
    scaffoldBackgroundColor: colorScheme.surface,

    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0.5,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),

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

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: textTheme.labelLarge,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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

    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        side: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurfaceVariant,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      labelStyle: textTheme.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      side: BorderSide.none,
    ),

    dividerTheme: DividerThemeData(
      color: colorScheme.outline.withValues(alpha: 0.3),
      thickness: 1,
      space: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
    ),

    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      elevation: 3,
    ),

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
