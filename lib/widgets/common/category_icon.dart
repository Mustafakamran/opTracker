import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class CategoryIcon extends StatelessWidget {
  final TransactionCategory category;
  final double size;

  const CategoryIcon({super.key, required this.category, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _iconAndColor(category);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }

  static (IconData, Color) _iconAndColor(TransactionCategory category) {
    return switch (category) {
      TransactionCategory.food => (LucideIcons.utensils, AppColors.categoryFood),
      TransactionCategory.shopping => (LucideIcons.shoppingBag, AppColors.categoryShopping),
      TransactionCategory.bills => (LucideIcons.fileText, AppColors.categoryBills),
      TransactionCategory.transfer => (LucideIcons.arrowLeftRight, AppColors.categoryTransfer),
      TransactionCategory.entertainment => (LucideIcons.film, AppColors.categoryEntertainment),
      TransactionCategory.transport => (LucideIcons.car, AppColors.categoryTransport),
      TransactionCategory.health => (LucideIcons.heartPulse, AppColors.categoryHealth),
      TransactionCategory.education => (LucideIcons.graduationCap, AppColors.categoryEducation),
      TransactionCategory.subscription => (LucideIcons.repeat, AppColors.categorySubscription),
      TransactionCategory.income => (LucideIcons.trendingUp, AppColors.success),
      TransactionCategory.other => (LucideIcons.moreHorizontal, AppColors.categoryOther),
    };
  }

  static Color colorFor(TransactionCategory category) => _iconAndColor(category).$2;
}
