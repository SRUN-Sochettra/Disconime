import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Private constructor — use static getters only.
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final mutedColor = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,

      // ── Color Scheme ─────────────────────────────────────────
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.accent,
        onPrimary: Colors.black,
        secondary: AppColors.accent,
        onSecondary: Colors.black,
        surface: surfaceColor,
        onSurface: primaryColor,
        // FIX: Added surfaceContainerHighest and onSurfaceVariant
        // so Material 3 widgets (Dialog, BottomSheet, etc.) do not
        // fall back to unexpected generated colors.
        surfaceContainerHighest: isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder,
        onSurfaceVariant: mutedColor,
        error: const Color(0xFFB00020),
        onError: Colors.white,
        outline: borderColor,
      ),

      // ── AppBar ───────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: GoogleFonts.inter(
          color: primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),

      // ── Bottom Navigation ────────────────────────────────────
      // bottomNavigationBarTheme: BottomNavigationBarThemeData(
      //   backgroundColor: bgColor,
      //   selectedItemColor: AppColors.accent,
      //   unselectedItemColor: mutedColor,
      //   type: BottomNavigationBarType.fixed,
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   elevation: 0,
      // ),

      // ── Divider ──────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),

      // ── Card ─────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),

      // ── Typography ───────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme(
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: GoogleFonts.inter(
          color: primaryColor,
          fontWeight: FontWeight.w800,
          fontSize: 32,
          letterSpacing: 1.5,
        ),
        titleLarge: GoogleFonts.inter(
          color: primaryColor,
          fontWeight: FontWeight.w700,
          fontSize: 24,
          height: 1.2,
          letterSpacing: 0.3,
        ),
        titleMedium: GoogleFonts.inter(
          color: primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0.1,
        ),
        bodyMedium: GoogleFonts.inter(
          color: primaryColor.withAlpha(200),
          fontSize: 14,
          height: 1.65,
          letterSpacing: 0.1,
        ),
        bodySmall: GoogleFonts.inter(
          color: mutedColor,
          fontSize: 12,
          height: 1.5,
        ),
        labelSmall: GoogleFonts.inter(
          color: mutedColor,
          fontSize: 11,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}