import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get _baseFont => GoogleFonts.plusJakartaSans();

  static TextStyle get displayLg => _baseFont.copyWith(
    fontSize: 40,
    height: 1.2,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8, // -0.02em
    color: AppColors.onSurface,
  );

  static TextStyle get headlineLg => _baseFont.copyWith(
    fontSize: 32,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle get headlineLgMobile => _baseFont.copyWith(
    fontSize: 24,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle get headlineMd => _baseFont.copyWith(
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyLg => _baseFont.copyWith(
    fontSize: 18,
    height: 1.6,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyMd => _baseFont.copyWith(
    fontSize: 16,
    height: 1.6,
    fontWeight: FontWeight.w500,
    color: AppColors.textMain,
  );

  static TextStyle get labelLg => _baseFont.copyWith(
    fontSize: 14,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7, // 0.05em
    color: AppColors.textMuted,
  );

  static TextStyle get labelMd => _baseFont.copyWith(
    fontSize: 12,
    height: 1.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );
}
