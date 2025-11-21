import 'package:flutter/material.dart';
import '../../app/theme/design_tokens.dart';

/// Spacing constants - Uses AppDesignTokens from prompt.json
/// This file is kept for backward compatibility but delegates to AppDesignTokens
class AppSpacing {
  // Spacing values from prompt.json (via AppDesignTokens)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;  // horizontal, component
  static const double xl = 28;  // between_sections
  static const double xxl = 32;
  static const double xxxl = 48;
  
  // Top padding from prompt.json
  static const double top = 24;
  
  // Padding shortcuts
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  
  // Screen padding from prompt.json
  static EdgeInsets get screenPadding => AppDesignTokens.spacing.screenPadding;
  static EdgeInsets get screenTop => AppDesignTokens.spacing.screenTop;
  static EdgeInsets get screenHorizontal => AppDesignTokens.spacing.screenHorizontal;
  
  // Component spacing
  static SizedBox get gapComponent => AppDesignTokens.spacing.gapComponent;
  static SizedBox get gapSection => AppDesignTokens.spacing.gapSection;
  static const SizedBox gapXS = SizedBox(width: xs, height: xs);
  static const SizedBox gapSM = SizedBox(width: sm, height: sm);
  static const SizedBox gapMD = SizedBox(width: md, height: md);
  static const SizedBox gapLG = SizedBox(width: lg, height: lg);
  static const SizedBox gapXL = SizedBox(width: xl, height: xl);
  
  // Border radius from prompt.json
  static const double radiusSM = 12.0;
  static const double radiusMD = 16.0;
  static const double radiusLG = 18.0; // button/input
  static const double radiusXL = 24.0; // card
  static const double radiusXXL = 26.0;
  static const double radiusRound = 999.0;
  
  static const BorderRadius borderRadiusSM = BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD = BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG = BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusXL = BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderRadiusXXL = BorderRadius.all(Radius.circular(radiusXXL));
  static const BorderRadius borderRadiusRound = BorderRadius.all(Radius.circular(radiusRound));
  
  // Shadow from prompt.json
  static List<BoxShadow> get softShadow => AppDesignTokens.shadows.soft;
  static List<BoxShadow> get softShadowMD => AppDesignTokens.shadows.medium;
  
  // Dark mode shadow
  static List<BoxShadow> get softShadowDark => [
    BoxShadow(
      color: Colors.black.withOpacity(0.50),
      offset: const Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
    ),
  ];
  
  // Card padding (16-20px from prompt.json)
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets cardPaddingLG = EdgeInsets.all(lg);
}
