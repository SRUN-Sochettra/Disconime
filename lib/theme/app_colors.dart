import 'package:flutter/material.dart';

class AppColors {
  // Private constructor — prevents instantiation.
  // This is a pure constants class.
  AppColors._();

  // ── Common ───────────────────────────────────────────────────
  static const Color accent = Color(0xFFE8C547); // Premium Gold

  // ── Light Theme ──────────────────────────────────────────────
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightPrimary = Color(0xFF1A1A1A);
  static const Color lightMuted = Color(0xFF9E9E9E);
  static const Color lightBorder = Color(0xFFEEEEEE);

  // ── Dark Theme ───────────────────────────────────────────────
  static const Color darkBg = Color(0xFF0E0E0E);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkPrimary = Color(0xFFF5F5F5);
  static const Color darkMuted = Color(0xFF757575);
  static const Color darkBorder = Color(0xFF2A2A2A);
}