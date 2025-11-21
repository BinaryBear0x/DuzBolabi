import 'package:flutter/material.dart';

/// Design tokens from prompt.json
class AppDesignTokens {
  /// Border radius tokens
  static const BorderRadiusTokens borderRadius = BorderRadiusTokens();
  
  /// Spacing tokens - prompt.json values
  static const SpacingTokens spacing = SpacingTokens();
  
  /// Shadow tokens - prompt.json values
  static const ShadowTokens shadows = ShadowTokens();
  
  /// Typography tokens
  static const TypographyTokens typography = TypographyTokens();
  
  /// Icon sizes - prompt.json values
  static const IconSizes iconSizes = IconSizes();
}

class BorderRadiusTokens {
  const BorderRadiusTokens();
  
  double get card => 24;
  double get button => 18;
  double get input => 18;
  double get chip => 14;
  
  BorderRadius get cardRadius => BorderRadius.circular(card);
  BorderRadius get buttonRadius => BorderRadius.circular(button);
  BorderRadius get inputRadius => BorderRadius.circular(input);
  BorderRadius get chipRadius => BorderRadius.circular(chip);
}

class SpacingTokens {
  const SpacingTokens();
  
  // prompt.json spacing values
  double get top => 24;              // Top padding for all screens
  double get horizontal => 20;       // Horizontal padding
  double get component => 20;        // Between components
  double get betweenSections => 28;  // Between sections
  
  // Additional spacing
  double get xs => 4;
  double get s => 8;
  double get m => 12;
  double get l => 20;
  double get xl => 28;
  
  // Screen padding
  EdgeInsets get screenTop => EdgeInsets.only(top: top);
  EdgeInsets get screenHorizontal => EdgeInsets.symmetric(horizontal: horizontal);
  EdgeInsets get screenPadding => EdgeInsets.only(
    top: top,
    left: horizontal,
    right: horizontal,
  );
  
  // Component spacing
  SizedBox get gapComponent => SizedBox(height: component);
  SizedBox get gapSection => SizedBox(height: betweenSections);
  
  SizedBox get gapXS => SizedBox(width: xs, height: xs);
  SizedBox get gapS => SizedBox(width: s, height: s);
  SizedBox get gapM => SizedBox(width: m, height: m);
  SizedBox get gapL => SizedBox(width: l, height: l);
  SizedBox get gapXL => SizedBox(width: xl, height: xl);
}

class ShadowTokens {
  const ShadowTokens();
  
  /// Soft shadow: 0 4 12 rgba(0,0,0,0.06)
  List<BoxShadow> get soft => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      offset: const Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];
  
  /// Medium shadow: 0 6 18 rgba(0,0,0,0.10)
  List<BoxShadow> get medium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      offset: const Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
    ),
  ];
}

class TypographyTokens {
  const TypographyTokens();
  
  String get fontFamily => 'Inter';
  
  double get titleLargeSize => 26;
  FontWeight get titleLargeWeight => FontWeight.w700;
  
  double get titleMediumSize => 22;
  FontWeight get titleMediumWeight => FontWeight.w700;
  
  double get bodySize => 15;
  FontWeight get bodyWeight => FontWeight.w500;
  
  double get captionSize => 13;
  FontWeight get captionWeight => FontWeight.w400;
}

class IconSizes {
  const IconSizes();
  
  double get categoryIcon => 24;
  double get productIcon => 24;
  double get largeIcon => 72;
}
