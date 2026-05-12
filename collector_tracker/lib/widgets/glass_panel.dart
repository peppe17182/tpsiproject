import 'dart:ui';
import 'package:flutter/material.dart';


class GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final Color? backgroundColor;

  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 16.0, // Large Container default
    this.padding = const EdgeInsets.all(16.0),
    this.blur = 12.0,
    this.opacity = 0.1,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
