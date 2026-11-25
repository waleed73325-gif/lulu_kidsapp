import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// نظام الخطوط والطباعة لتطبيق لولو للأطفال
/// يعتمد على خط تجوال (Tajawal) العربي ذو الحواف المنحنية اللطيفة
class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
        height: 1.3,
      );

  static TextStyle get displayMedium => GoogleFonts.tajawal(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.3,
      );

  static TextStyle get titleLarge => GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.4,
      );

  static TextStyle get titleMedium => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textMedium,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMedium,
        height: 1.5,
      );

  static TextStyle get displaySmall => GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        height: 1.3,
      );

  static TextStyle get bodySmall => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMedium,
        height: 1.4,
      );

  static TextStyle get buttonText => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  static TextStyle get starCounterText => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      );
}
