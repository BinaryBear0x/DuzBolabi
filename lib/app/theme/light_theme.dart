import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_scheme.dart';
import 'design_tokens.dart';
import 'component_styles/buttons.dart';
import 'component_styles/inputs.dart';
import 'component_styles/cards.dart';
import 'component_styles/navigation.dart';

/// Light theme from uıprompt.json
class LightTheme {
  static ThemeData get theme {
    final colorScheme = AppColorScheme.lightScheme;
    final textTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardColor: colorScheme.surface,
      
      // Typography from JSON
      textTheme: textTheme.copyWith(
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: AppDesignTokens.typography.titleLargeSize,
          fontWeight: AppDesignTokens.typography.titleLargeWeight,
          color: colorScheme.onSurface,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: AppDesignTokens.typography.titleMediumSize,
          fontWeight: AppDesignTokens.typography.titleMediumWeight,
          color: colorScheme.onSurface,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          fontSize: AppDesignTokens.typography.bodySize,
          fontWeight: AppDesignTokens.typography.bodyWeight,
          color: colorScheme.onSurface,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          fontSize: AppDesignTokens.typography.bodySize,
          fontWeight: AppDesignTokens.typography.bodyWeight,
          color: colorScheme.onSurface,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          fontSize: AppDesignTokens.typography.captionSize,
          fontWeight: AppDesignTokens.typography.captionWeight,
          color: colorScheme.onSurface,
        ),
      ),
      
      // Component themes
      cardTheme: AppCardStyles.cardTheme(colorScheme),
      appBarTheme: AppNavigationStyles.appBarTheme(colorScheme),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: AppButtonStyles.primaryButtonStyle(colorScheme),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonStyles.outlineButtonStyle(colorScheme),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonStyles.textButtonStyle(colorScheme),
      ),
      inputDecorationTheme: AppInputStyles.inputDecorationTheme(colorScheme),
      floatingActionButtonTheme: AppNavigationStyles.fabTheme(colorScheme),
      bottomNavigationBarTheme: AppNavigationStyles.bottomNavTheme(colorScheme),
      snackBarTheme: AppNavigationStyles.snackBarTheme(colorScheme),
    );
  }
}
