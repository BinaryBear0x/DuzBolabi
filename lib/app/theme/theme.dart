import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

/// Main theme class - exports light and dark themes
class AppTheme {
  static ThemeData get lightTheme => LightTheme.theme;
  static ThemeData get darkTheme => DarkTheme.theme;
}
