import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../color_scheme.dart';

/// Navigation styles from uıprompt.json
class AppNavigationStyles {
  /// AppBar: background = background, icon/text = onSurface
  static AppBarTheme appBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      backgroundColor: colorScheme.background,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    );
  }
  
  /// BottomNav: active = primary, inactive = onSurface 60% opacity
  static BottomNavigationBarThemeData bottomNavTheme(ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    );
  }
  
  /// FAB: background=primary, foreground=onPrimary
  static FloatingActionButtonThemeData fabTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppDesignTokens.borderRadius.buttonRadius,
      ),
    );
  }
  
  /// SnackBar: background=surface, text=onSurface
  static SnackBarThemeData snackBarTheme(ColorScheme colorScheme) {
    return SnackBarThemeData(
      backgroundColor: colorScheme.surface,
      contentTextStyle: TextStyle(color: colorScheme.onSurface),
      shape: RoundedRectangleBorder(
        borderRadius: AppDesignTokens.borderRadius.cardRadius,
      ),
    );
  }
}
