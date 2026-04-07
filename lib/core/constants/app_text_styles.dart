import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // ── DM Serif Display — headings, hero, display ──
  static TextStyle dmSerif({
    double fontSize = 18,
    Color color = AppColors.ink,
    FontStyle fontStyle = FontStyle.normal,
  }) =>
      GoogleFonts.dmSerifDisplay(
        fontSize: fontSize,
        color: color,
        fontStyle: fontStyle,
      );

  // ── DM Sans — body, labels, buttons ──
  static TextStyle dmSans({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.ink,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  // ── JetBrains Mono — timestamps, data, codes ──
  static TextStyle mono({
    double fontSize = 10,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.muted,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  // ── Pre-built styles ──
  static TextStyle get splashLogo => dmSerif(fontSize: 26, color: AppColors.cream);
  static TextStyle get splashTagline => dmSans(fontSize: 11, color: AppColors.roseSoft);

  static TextStyle get screenTitle => dmSerif(fontSize: 18, color: AppColors.ink);
  static TextStyle get heroScore => dmSerif(fontSize: 36, color: Colors.white);
  static TextStyle get bigPercent => dmSerif(fontSize: 40, color: Colors.white);

  static TextStyle get bodyLg => dmSans(fontSize: 14, color: AppColors.inkLight);
  static TextStyle get body => dmSans(fontSize: 12, color: AppColors.inkLight);
  static TextStyle get bodySm => dmSans(fontSize: 11, color: AppColors.inkLight);
  static TextStyle get caption => dmSans(fontSize: 10, color: AppColors.muted);

  static TextStyle get labelMono => mono(fontSize: 10, color: AppColors.muted);
  static TextStyle get dataMono => mono(fontSize: 12, color: AppColors.ink);

  static TextStyle get sectionLabel => mono(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.muted,
      );

  static TextStyle get btnPrimary => dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get btnSecondary => dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.muted,
      );
}