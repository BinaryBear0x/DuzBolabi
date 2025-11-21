import 'package:flutter/material.dart';
import '../design_tokens.dart';

/// Button styles from uıprompt.json
class AppButtonStyles {
  /// Primary button style - 18px radius
  static ButtonStyle primaryButtonStyle(ColorScheme colorScheme) {
    return ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing.l,
        vertical: AppDesignTokens.spacing.m,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.button),
      ),
      elevation: 0,
    );
  }

  /// Secondary button style
  static ButtonStyle secondaryButtonStyle(ColorScheme colorScheme) {
    return ElevatedButton.styleFrom(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing.l,
        vertical: AppDesignTokens.spacing.m,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.button),
      ),
      elevation: 0,
    );
  }

  /// Outline button style
  static ButtonStyle outlineButtonStyle(ColorScheme colorScheme) {
    return OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary,
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing.l,
        vertical: AppDesignTokens.spacing.m,
      ),
      side: BorderSide(color: colorScheme.outline, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.button),
      ),
    );
  }

  /// Text button style
  static ButtonStyle textButtonStyle(ColorScheme colorScheme) {
    return TextButton.styleFrom(
      foregroundColor: colorScheme.primary,
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing.m,
        vertical: AppDesignTokens.spacing.s,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.button),
      ),
    );
  }

  /// Tükettim button style - mint-outline + mint-icon + mint-text (primary)
  static ButtonStyle consumedButtonStyle(ColorScheme colorScheme) {
    return OutlinedButton.styleFrom(
      foregroundColor: colorScheme.primary, // mint-text
      side: BorderSide(color: colorScheme.primary, width: 1.5), // mint-outline
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing.l,
        vertical: AppDesignTokens.spacing.m,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.button), // 18px
      ),
    );
  }

  /// Çöpe Gitti button style - error-outline + error-icon + error-text
  static ButtonStyle trashedButtonStyle(ColorScheme colorScheme) {
    return OutlinedButton.styleFrom(
      foregroundColor: colorScheme.error, // error-text
      side: BorderSide(color: colorScheme.error, width: 1.5), // error-outline
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing.l,
        vertical: AppDesignTokens.spacing.m,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.button), // 18px
      ),
    );
  }

  /// Save button style - aktif: primary, pasif: primary %20 opacity + text primary
  static ButtonStyle saveButtonStyle(ColorScheme colorScheme, {required bool isEnabled}) {
    return ElevatedButton.styleFrom(
      backgroundColor: isEnabled 
          ? colorScheme.primary // Aktif: primary (#4BCB8B)
          : colorScheme.primary.withOpacity(0.2), // Pasif: primary %20 opacity
      foregroundColor: isEnabled 
          ? colorScheme.onPrimary // Aktif: onPrimary
          : colorScheme.primary, // Pasif: text primary
      padding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing.l,
        vertical: AppDesignTokens.spacing.m,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.button), // 18px
      ),
      elevation: 0,
    );
  }
}
