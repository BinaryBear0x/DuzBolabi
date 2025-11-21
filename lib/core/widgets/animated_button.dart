import 'package:flutter/material.dart';
import '../constants/spacing.dart';

/// Micro-interaction button - 90ms scale down + 120ms easeOut
/// Optimize edilmiş, performans odaklı
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Duration pressDuration;
  final Duration releaseDuration;
  final double scaleDownValue;
  
  const AnimatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.pressDuration = const Duration(milliseconds: 90),
    this.releaseDuration = const Duration(milliseconds: 120),
    this.scaleDownValue = 0.95,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.pressDuration,
      reverseDuration: widget.releaseDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDownValue,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.stop(); // Önce durdur
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && mounted) {
      setState(() => _isPressed = true);
      try {
        _controller.forward().catchError((e) {
          // Animation hatası olsa bile devam et
        });
      } catch (e) {
        // Animation başlatılamazsa sessizce geç
      }
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null && mounted) {
      setState(() => _isPressed = false);
      try {
        _controller.reverse().then((_) {
          if (mounted && widget.onPressed != null) {
            widget.onPressed!();
          }
        }).catchError((e) {
          // Animation hatası olsa bile callback'i çağır
          if (mounted && widget.onPressed != null) {
            widget.onPressed!();
          }
        });
      } catch (e) {
        // Animation tersine çevrilemezse direkt callback'i çağır
        if (mounted && widget.onPressed != null) {
          widget.onPressed!();
        }
      }
    }
  }

  void _handleTapCancel() {
    if (mounted) {
      setState(() => _isPressed = false);
      try {
        _controller.reverse().catchError((e) {
          // Animation hatası olsa bile devam et
        });
      } catch (e) {
        // Animation tersine çevrilemezse sessizce geç
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          // Animation value'yu clamp et
          double scaleValue;
          try {
            final rawValue = _scaleAnimation.value;
            if (!rawValue.isFinite || rawValue.isNaN) {
              scaleValue = 1.0; // Geçersiz değer için varsayılan
            } else {
              scaleValue = rawValue.clamp(0.5, 1.5); // Scale değerini clamp et
            }
          } catch (e) {
            scaleValue = 1.0; // Hata durumunda varsayılan
          }
          
          return Transform.scale(
            scale: scaleValue,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Animated ElevatedButton wrapper
class AnimatedElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  
  const AnimatedElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      child: ElevatedButton(
        onPressed: null, // GestureDetector handles this
        style: style,
        child: child,
      ),
    );
  }
}

/// Animated TextButton wrapper
class AnimatedTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  
  const AnimatedTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      child: TextButton(
        onPressed: null, // GestureDetector handles this
        style: style,
        child: child,
      ),
    );
  }
}

/// Animated IconButton wrapper
class AnimatedIconButton extends StatelessWidget {
  final Icon icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? iconSize;
  
  const AnimatedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      onPressed: onPressed,
      child: IconButton(
        icon: icon,
        onPressed: null, // GestureDetector handles this
        style: backgroundColor != null || foregroundColor != null
            ? IconButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
              )
            : null,
        iconSize: iconSize,
      ),
    );
  }
}

