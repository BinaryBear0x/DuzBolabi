import 'package:flutter/material.dart';

/// Accessibility utilities
/// Semantics, tooltip, color contrast kontrolü
class Accessibility {
  // Color contrast helpers
  static double getLuminance(Color color) {
    return color.computeLuminance();
  }

  static bool isDarkColor(Color color) {
    return getLuminance(color) < 0.5;
  }

  static Color getContrastColor(Color backgroundColor) {
    return isDarkColor(backgroundColor) ? Colors.white : Colors.black;
  }

  // Minimum contrast ratio (WCAG AA standard)
  static bool hasGoodContrast(Color foreground, Color background) {
    final fgLum = getLuminance(foreground);
    final bgLum = getLuminance(background);
    
    final lighter = fgLum > bgLum ? fgLum : bgLum;
    final darker = fgLum > bgLum ? bgLum : fgLum;
    
    final contrast = (lighter + 0.05) / (darker + 0.05);
    return contrast >= 4.5; // WCAG AA standard
  }
}

/// Accessible button widget
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? label;
  final String? hint;
  final bool isButton;
  final bool isEnabled;

  const AccessibleButton({
    super.key,
    required this.child,
    this.onPressed,
    this.label,
    this.hint,
    this.isButton = true,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: isButton,
      enabled: isEnabled,
      child: child,
    );
  }
}

/// Accessible icon button
class AccessibleIconButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback? onPressed;
  final String label;
  final String? hint;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? iconSize;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.hint,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: onPressed != null,
      child: IconButton(
        icon: icon,
        onPressed: onPressed,
        style: backgroundColor != null || foregroundColor != null
            ? IconButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
              )
            : null,
        iconSize: iconSize,
        tooltip: label, // Tooltip for visual users
      ),
    );
  }
}

/// Accessible text field
class AccessibleTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;

  const AccessibleTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.controller,
    this.onChanged,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
        ),
      ),
    );
  }
}

/// Accessible card
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? label;
  final String? hint;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AccessibleCard({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardColor,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return Semantics(
        label: label,
        hint: hint,
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: card,
        ),
      );
    }

    return Semantics(
      label: label,
      hint: hint,
      child: card,
    );
  }
}

