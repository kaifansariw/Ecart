import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Assembles the complete theme from design tokens.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.textOnPrimary,
          onSecondary: AppColors.textOnAccent,
          onSurface: AppColors.textPrimary,
          onError: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.displayLarge,
          displayMedium: AppTypography.displayMedium,
          displaySmall: AppTypography.displaySmall,
          headlineLarge: AppTypography.headingLarge,
          headlineMedium: AppTypography.headingMedium,
          headlineSmall: AppTypography.headingSmall,
          bodyLarge: AppTypography.bodyLarge,
          bodyMedium: AppTypography.bodyMedium,
          bodySmall: AppTypography.bodySmall,
          labelLarge: AppTypography.labelLarge,
          labelMedium: AppTypography.labelMedium,
          labelSmall: AppTypography.labelSmall,
        ),
        dividerColor: AppColors.divider,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accentLight,
          surface: AppColors.surfaceDark,
          error: AppColors.error,
          onPrimary: AppColors.textOnAccent,
          onSecondary: AppColors.textOnAccent,
          onSurface: AppColors.textPrimaryDark,
          onError: Colors.white,
        ),
        textTheme: TextTheme(
          displayLarge:
              AppTypography.displayLarge.copyWith(color: AppColors.textPrimaryDark),
          displayMedium:
              AppTypography.displayMedium.copyWith(color: AppColors.textPrimaryDark),
          displaySmall:
              AppTypography.displaySmall.copyWith(color: AppColors.textPrimaryDark),
          headlineLarge:
              AppTypography.headingLarge.copyWith(color: AppColors.textPrimaryDark),
          headlineMedium:
              AppTypography.headingMedium.copyWith(color: AppColors.textPrimaryDark),
          headlineSmall:
              AppTypography.headingSmall.copyWith(color: AppColors.textPrimaryDark),
          bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
          bodyMedium:
              AppTypography.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
          bodySmall:
              AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryDark),
          labelLarge:
              AppTypography.labelLarge.copyWith(color: AppColors.textPrimaryDark),
          labelMedium:
              AppTypography.labelMedium.copyWith(color: AppColors.textSecondaryDark),
          labelSmall:
              AppTypography.labelSmall.copyWith(color: AppColors.textTertiaryDark),
        ),
        dividerColor: AppColors.dividerDark,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      );
}
