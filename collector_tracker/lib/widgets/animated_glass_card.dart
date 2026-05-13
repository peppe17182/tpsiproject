import 'package:flutter/material.dart';
import 'glass_panel.dart';

class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? glowColor;

  const AnimatedGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = 20.0,
    this.padding = EdgeInsets.zero,
    this.glowColor,
  });

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.025,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _glow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.glowColor ?? Theme.of(context).colorScheme.primary;

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Transform.scale(
              scale: _scale.value,
              child: GlassPanel(
                borderRadius: widget.borderRadius,
                padding: widget.padding,
                borderColor: Color.lerp(
                  Colors.white.withValues(alpha: 0.06),
                  accent.withValues(alpha: 0.5),
                  _glow.value,
                ),
                boxShadow: _glow.value > 0.01
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.15 * _glow.value),
                          blurRadius: 32 * _glow.value,
                          spreadRadius: 2 * _glow.value,
                        ),
                      ]
                    : null,
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}
