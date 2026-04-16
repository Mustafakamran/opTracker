import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_spacing.dart';

/// Shadcn-style card with optional press effect and animation.
class OpCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    Widget card = Card(
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: padding ?? AppSpacing.cardPadding,
          child: child,
        ),
      ),
    );

    if (animate) {
      card = card
          .animate()
          .fadeIn(
            duration: 400.ms,
            delay: Duration(milliseconds: animationDelay),
          )
          .slideY(
            begin: 0.05,
            end: 0,
            duration: 400.ms,
            delay: Duration(milliseconds: animationDelay),
            curve: Curves.easeOutCubic,
          );
    }

    return card;
  }
}
