import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool _darkMode = false;

  static void setDarkMode(bool enabled) {
    _darkMode = enabled;
  }

  static bool get isDarkMode => _darkMode;

  // Primary
  static const Color primaryLight = Color(0xFF2B6C00);
  static Color get primary =>
      _darkMode ? const Color(0xFF78E43A) : primaryLight;
  static const Color primaryContainer = Color(0xFF58CC02);
  static const Color primaryFixed = Color(0xFF87FE45);
  static const Color primaryFixedDim = Color(0xFF6BE026);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1E5000);
  static const Color onPrimaryFixed = Color(0xFF082100);
  static const Color onPrimaryFixedVariant = Color(0xFF1F5100);
  static const Color inversePrimary = Color(0xFF6BE026);

  // Secondary
  static const Color secondary = Color(0xFF755B00);
  static const Color secondaryContainer = Color(0xFFFEC700);
  static const Color secondaryFixed = Color(0xFFFFDF92);
  static const Color secondaryFixedDim = Color(0xFFF4BF00);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF6E5400);
  static const Color onSecondaryFixed = Color(0xFF241A00);
  static const Color onSecondaryFixedVariant = Color(0xFF594400);

  // Tertiary
  static const Color tertiary = Color(0xFF006590);
  static const Color tertiaryContainer = Color(0xFF4ABDFF);
  static const Color tertiaryFixed = Color(0xFFC8E6FF);
  static const Color tertiaryFixedDim = Color(0xFF88CEFF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF004A6B);
  static const Color onTertiaryFixed = Color(0xFF001E2E);
  static const Color onTertiaryFixedVariant = Color(0xFF004C6E);

  // Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Theme-aware surfaces
  static Color get surface =>
      _darkMode ? const Color(0xFF121712) : const Color(0xFFF9F9F9);
  static Color get surfaceBright =>
      _darkMode ? const Color(0xFF1B211B) : const Color(0xFFF9F9F9);
  static Color get surfaceDim =>
      _darkMode ? const Color(0xFF0C100C) : const Color(0xFFDADADA);
  static Color get surfaceVariant =>
      _darkMode ? const Color(0xFF303830) : const Color(0xFFE2E2E2);
  static Color get surfaceContainer =>
      _darkMode ? const Color(0xFF1B211B) : const Color(0xFFEEEEEE);
  static Color get surfaceContainerLow =>
      _darkMode ? const Color(0xFF171C17) : const Color(0xFFF3F3F3);
  static Color get surfaceContainerHigh =>
      _darkMode ? const Color(0xFF242B24) : const Color(0xFFE8E8E8);
  static Color get surfaceContainerHighest =>
      _darkMode ? const Color(0xFF303830) : const Color(0xFFE2E2E2);
  static Color get surfaceContainerLowest =>
      _darkMode ? const Color(0xFF151A15) : const Color(0xFFFFFFFF);
  static const Color surfaceTint = primaryLight;
  static Color get onSurface =>
      _darkMode ? const Color(0xFFF1F5EF) : const Color(0xFF1A1C1C);
  static Color get onSurfaceVariant =>
      _darkMode ? const Color(0xFFCDD6C9) : const Color(0xFF3F4A36);
  static Color get inverseSurface =>
      _darkMode ? const Color(0xFFE8ECE6) : const Color(0xFF2F3131);
  static Color get inverseOnSurface =>
      _darkMode ? const Color(0xFF202520) : const Color(0xFFF1F1F1);

  // Background
  static Color get background => surface;
  static Color get onBackground => onSurface;

  // Outline
  static Color get outline =>
      _darkMode ? const Color(0xFF899685) : const Color(0xFF6F7B64);
  static Color get outlineVariant =>
      _darkMode ? const Color(0xFF3C493A) : const Color(0xFFBECBB1);

  // Semantic / Custom
  static const Color successGreen = Color(0xFF58CC02);
  static const Color warningYellow = Color(0xFFFFC800);
  static const Color lateOrange = Color(0xFFFF9600);
  static const Color errorRed = Color(0xFFFF4B4B);
  static const Color infoBlue = Color(0xFF1CB0F6);
  static const Color borderDepth = Color(0xFF46A302);
  static Color get textMain =>
      _darkMode ? const Color(0xFFE9EDE7) : const Color(0xFF4B4B4B);
  static Color get textMuted =>
      _darkMode ? const Color(0xFF9CA79A) : const Color(0xFFAFAFAF);
}
