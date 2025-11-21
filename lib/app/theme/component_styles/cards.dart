import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../color_scheme.dart';

/// Card styles from uıprompt.json - surface + shadowSmall
class AppCardStyles {
  static CardThemeData cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppDesignTokens.borderRadius.cardRadius,
      ),
      margin: EdgeInsets.zero,
    );
  }
  
  /// Helper to create a card container with shadow
  static BoxDecoration cardDecoration(ColorScheme colorScheme, {bool isDark = false}) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: AppDesignTokens.borderRadius.cardRadius,
      boxShadow: isDark 
          ? AppDesignTokens.shadows.medium // Dark için medium shadow
          : AppDesignTokens.shadows.soft, // Light için soft shadow
    );
  }
}
