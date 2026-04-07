import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Palette ──
  static const Color ink = Color(0xFF1C1A18);
  static const Color inkLight = Color(0xFF3D3A36);
  static const Color coral = Color(0xFFE07055);
  static const Color roseDeep = Color(0xFFC96B5A);
  static const Color roseMid = Color(0xFFE8A99A);
  static const Color roseSoft = Color(0xFFF2D4CC);
  static const Color amber = Color(0xFFD4914A);
  static const Color forest = Color(0xFF3D5A4C);
  static const Color sage = Color(0xFF7A9E8A);
  static const Color muted = Color(0xFF8A8480);

  // ── Backgrounds ──
  static const Color cream = Color(0xFFFAF7F2);
  static const Color warmWhite = Color(0xFFFEFCF9);
  static const Color pageBg = Color(0xFFF0EDE8);
  static const Color border = Color(0xFFE8E2D9);

  // ── Risk Level Colors ──
  static const Color lowGreen = Color(0xFF4A8C6A);
  static const Color lowGreenLight = Color(0xFF7ACA9A);
  static const Color midAmber = Color(0xFFC4872A);
  static const Color midAmberLight = Color(0xFFE4AA5A);
  static const Color highRed = Color(0xFFC05040);
  static const Color highRedLight = Color(0xFFE88070);

  // ── Notification Icon Backgrounds ──
  static const Color waterBg = Color(0xFFEAF4FB);
  static const Color medBg = Color(0xFFFFF0F0);
  static const Color lifeBg = Color(0xFFF0F7EF);

  // ── Helpers ──
  static Color riskColor(double riskPercent) {
    if (riskPercent < 30) return lowGreen;
    if (riskPercent < 60) return midAmber;
    return highRed;
  }

  static Color riskBadgeBg(double riskPercent) {
    if (riskPercent < 30) return lowGreen.withOpacity(0.18);
    if (riskPercent < 60) return midAmber.withOpacity(0.18);
    return highRed.withOpacity(0.18);
  }

  static Color riskBadgeText(double riskPercent) {
    if (riskPercent < 30) return lowGreenLight;
    if (riskPercent < 60) return midAmberLight;
    return highRedLight;
  }
}