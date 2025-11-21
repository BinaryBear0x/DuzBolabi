import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../color_scheme.dart';

/// Input styles from uıprompt.json - surfaceVariant + 18px radius
class AppInputStyles {
  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.input),
        borderSide: BorderSide(color: colorScheme.outline, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.input),
        borderSide: BorderSide(color: colorScheme.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.input),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.input),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.borderRadius.input),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppDesignTokens.spacing.l,
        vertical: AppDesignTokens.spacing.m,
      ),
    );
  }
}
