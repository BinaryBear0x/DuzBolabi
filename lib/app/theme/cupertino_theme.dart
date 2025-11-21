import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

/// Cupertino Adaptive Theme - iOS cihazlarda Cupertino look
class CupertinoThemeHelper {
  /// Platform kontrolü
  static bool isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  /// CupertinoColors mapping - uses colorScheme
  static Color cupertinoPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color cupertinoSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color cupertinoBackground(BuildContext context) {
    return Theme.of(context).colorScheme.background;
  }

  static Color cupertinoSurface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  /// Haptic Feedback helper
  static void lightImpact() {
    // HapticFeedback.lightImpact(); // Flutter'da HapticFeedback import edilmeli
  }

  static void mediumImpact() {
    // HapticFeedback.mediumImpact();
  }

  static void heavyImpact() {
    // HapticFeedback.heavyImpact();
  }
}

