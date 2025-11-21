import 'package:flutter/material.dart';

/// Strict color palette from uıprompt.json - NO dynamic contrast calculation
class AppColorScheme {
  // Light Theme Colors - EXACT from JSON
  static const Color lightPrimary = Color(0xFF4BCB8B);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFFFFCA6C);
  static const Color lightOnSecondary = Color(0xFF2C2C2C);
  static const Color lightBackground = Color(0xFFF6F7F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFECEDEE);
  static const Color lightOnSurface = Color(0xFF1F2022);
  static const Color lightTertiary = Color(0xFF6AB8FF);
  static const Color lightError = Color(0xFFFF6B6B);
  static const Color lightOutline = Color(0xFFD4D6D8);
  static const Color lightShadow = Color(0x14000000); // rgba(0,0,0,0.08)

  // Dark Theme Colors - EXACT from JSON
  static const Color darkPrimary = Color(0xFF5FE3A1);
  static const Color darkOnPrimary = Color(0xFF0E0F0F);
  static const Color darkSecondary = Color(0xFFFFD68A);
  static const Color darkOnSecondary = Color(0xFF1B1B1B);
  static const Color darkBackground = Color(0xFF101113);
  static const Color darkSurface = Color(0xFF1A1B1D);
  static const Color darkSurfaceVariant = Color(0xFF2B2D30);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkTertiary = Color(0xFF79C3FF);
  static const Color darkError = Color(0xFFFF7B7B);
  static const Color darkOutline = Color(0xFF3C3F45);
  static const Color darkShadow = Color(0x80000000); // rgba(0,0,0,0.50)

  /// Light ColorScheme
  static ColorScheme get lightScheme => ColorScheme.light(
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        secondary: lightSecondary,
        onSecondary: lightOnSecondary,
        tertiary: lightTertiary,
        error: lightError,
        background: lightBackground,
        surface: lightSurface,
        surfaceVariant: lightSurfaceVariant,
        onSurface: lightOnSurface,
        outline: lightOutline,
      );

  /// Dark ColorScheme
  static ColorScheme get darkScheme => ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        secondary: darkSecondary,
        onSecondary: darkOnSecondary,
        tertiary: darkTertiary,
        error: darkError,
        background: darkBackground,
        surface: darkSurface,
        surfaceVariant: darkSurfaceVariant,
        onSurface: darkOnSurface,
        outline: darkOutline,
      );
}
