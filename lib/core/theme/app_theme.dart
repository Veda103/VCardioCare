import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.pageBg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.coral,
          secondary: AppColors.forest,
          surface: AppColors.warmWhite,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.ink,
        ),

        // ── Text Theme ──
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          displayLarge: GoogleFonts.dmSerifDisplay(
              fontSize: 36, color: AppColors.ink),
          displayMedium: GoogleFonts.dmSerifDisplay(
              fontSize: 26, color: AppColors.ink),
          displaySmall: GoogleFonts.dmSerifDisplay(
              fontSize: 20, color: AppColors.ink),
          headlineMedium: GoogleFonts.dmSerifDisplay(
              fontSize: 18, color: AppColors.ink),
          bodyLarge: GoogleFonts.dmSans(
              fontSize: 14, color: AppColors.inkLight),
          bodyMedium: GoogleFonts.dmSans(
              fontSize: 12, color: AppColors.inkLight),
          bodySmall: GoogleFonts.dmSans(
              fontSize: 11, color: AppColors.muted),
          labelSmall: GoogleFonts.jetBrainsMono(
              fontSize: 10, color: AppColors.muted),
        ),

        // ── AppBar ──
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.cream,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.ink),
          titleTextStyle: GoogleFonts.dmSerifDisplay(
            fontSize: 18,
            color: AppColors.ink,
          ),
        ),

        // ── Elevated Button ──
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.coral,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
          ),
        ),

        // ── Outlined Button ──
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.muted,
            side: const BorderSide(color: AppColors.border, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 13),
            textStyle: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        // ── Input Decoration ──
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.highRed, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
          labelStyle: GoogleFonts.dmSans(
            fontSize: 11, color: AppColors.muted),
        ),

        // ── Checkbox ──
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.coral;
            return Colors.transparent;
          }),
          side: const BorderSide(color: AppColors.coral, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)),
        ),

        // ── Bottom Nav ──
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.warmWhite,
          selectedItemColor: AppColors.coral,
          unselectedItemColor: AppColors.muted,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // ── Divider ──
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 0,
        ),
      );
}