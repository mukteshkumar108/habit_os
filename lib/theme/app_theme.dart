import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          primaryContainer: AppColors.primaryContainer,
          secondary: AppColors.secondary,
          secondaryContainer: AppColors.secondaryContainer,
          tertiary: AppColors.tertiary,
          tertiaryContainer: AppColors.tertiaryContainer,
          error: AppColors.error,
          errorContainer: AppColors.errorContainer,
          surface: AppColors.surface,
          surfaceContainerHighest: AppColors.surfaceContainerHighest,
          onPrimary: AppColors.onPrimary,
          onPrimaryContainer: AppColors.onPrimaryContainer,
          onSecondary: AppColors.onSecondary,
          onSecondaryContainer: AppColors.onSecondaryContainer,
          onTertiary: AppColors.onTertiary,
          onTertiaryContainer: AppColors.onTertiaryContainer,
          onError: AppColors.onError,
          onErrorContainer: AppColors.onErrorContainer,
          onSurface: AppColors.onSurface,
          onSurfaceVariant: AppColors.onSurfaceVariant,
          outline: AppColors.outline,
          outlineVariant: AppColors.outlineVariant,
          inverseSurface: AppColors.inverseSurface,
          onInverseSurface: AppColors.inverseOnSurface,
          inversePrimary: AppColors.inversePrimary,
          surfaceTint: AppColors.surfaceTint,
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      );
}
