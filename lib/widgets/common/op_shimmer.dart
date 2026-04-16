import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Shimmer loading placeholder for cards and list items.
class OpShimmer extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const OpShimmer({
    super.key,
    this.height = 20,
    this.width,
    this.borderRadius = AppSpacing.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.zinc800 : AppColors.zinc100,
      highlightColor: isDark ? AppColors.zinc700 : AppColors.zinc50,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class OpCardShimmer extends StatelessWidget {
  final double height;

  const OpCardShimmer({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const OpShimmer(height: 14, width: 100),
            AppSpacing.vGapMd,
            const OpShimmer(height: 28, width: 160),
            AppSpacing.vGapSm,
            const OpShimmer(height: 12, width: 200),
          ],
        ),
      ),
    );
  }
}

class OpListItemShimmer extends StatelessWidget {
  const OpListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const OpShimmer(height: 44, width: 44, borderRadius: 22),
          AppSpacing.hGapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OpShimmer(height: 14, width: 140),
                AppSpacing.vGapXs,
                const OpShimmer(height: 12, width: 100),
              ],
            ),
          ),
          const OpShimmer(height: 16, width: 70),
        ],
      ),
    );
  }
}
