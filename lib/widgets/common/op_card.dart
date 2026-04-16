import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_spacing.dart';

/// Card with optional spring entrance animation + press scale effect.
class OpCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool animate;
  final int animationDelay;

  const OpCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.animate = false,
    this.animationDelay = 0,
  });

  @override
  State<OpCard> createState() => _OpCardState();
}

class _OpCardState extends State<OpCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    Widget card = GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _scale = 0.97) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _scale = 1.0) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _scale = 1.0) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Card(
          color: widget.color,
          child: Padding(
            padding: widget.padding ?? AppSpacing.cardPadding,
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.animate) {
      final delay = Duration(milliseconds: widget.animationDelay);
      card = card
          .animate()
          .scaleXY(begin: 0.93, end: 1, duration: 450.ms, delay: delay, curve: Curves.elasticOut)
          .slideY(begin: 0.03, end: 0, duration: 300.ms, delay: delay, curve: Curves.easeOutQuart)
          .fadeIn(duration: 150.ms, delay: delay);
    }

    return card;
  }
}
