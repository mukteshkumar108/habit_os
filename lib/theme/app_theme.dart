import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF121712) : const Color(0xFFF9F9F9);
    final surfaceContainer = isDark
        ? const Color(0xFF1B211B)
        : const Color(0xFFEEEEEE);
    final surfaceContainerHighest = isDark
        ? const Color(0xFF303830)
        : const Color(0xFFE2E2E2);
    final onSurface = isDark
        ? const Color(0xFFF1F5EF)
        : const Color(0xFF1A1C1C);
    final onSurfaceVariant = isDark
        ? const Color(0xFFCDD6C9)
        : const Color(0xFF3F4A36);
    final outline = isDark ? const Color(0xFF899685) : const Color(0xFF6F7B64);
    final outlineVariant = isDark
        ? const Color(0xFF3C493A)
        : const Color(0xFFBECBB1);
    final primary = isDark ? const Color(0xFF78E43A) : AppColors.primaryLight;

    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryContainer,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          primaryContainer: AppColors.primaryContainer,
          secondary: isDark ? const Color(0xFFFFD24A) : AppColors.secondary,
          secondaryContainer: AppColors.secondaryContainer,
          error: isDark ? const Color(0xFFFF6B6B) : AppColors.error,
          errorContainer: isDark
              ? const Color(0xFF5C1F20)
              : AppColors.errorContainer,
          surface: surface,
          surfaceContainer: surfaceContainer,
          surfaceContainerHighest: surfaceContainerHighest,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          outline: outline,
          outlineVariant: outlineVariant,
          inversePrimary: AppColors.inversePrimary,
          surfaceTint: primary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: surface,
      canvasColor: surface,
      cardColor: surfaceContainer,
      dividerColor: surfaceContainerHighest,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceContainer,
        surfaceTintColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryContainer
              : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryContainer.withAlpha(90)
              : null,
        ),
      ),
    );
  }
}
