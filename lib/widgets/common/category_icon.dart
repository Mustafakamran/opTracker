import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Returns the icon and color for a transaction category.
class CategoryIcon extends StatelessWidget {
  final TransactionCategory category;
  final double size;

  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 40,
  });

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
      TransactionCategory.food => (Icons.restaurant_rounded, AppColors.categoryFood),
      TransactionCategory.shopping => (Icons.shopping_bag_rounded, AppColors.categoryShopping),
      TransactionCategory.bills => (Icons.receipt_rounded, AppColors.categoryBills),
      TransactionCategory.transfer => (Icons.swap_horiz_rounded, AppColors.categoryTransfer),
      TransactionCategory.entertainment => (Icons.movie_rounded, AppColors.categoryEntertainment),
      TransactionCategory.transport => (Icons.directions_car_rounded, AppColors.categoryTransport),
      TransactionCategory.health => (Icons.local_hospital_rounded, AppColors.categoryHealth),
      TransactionCategory.education => (Icons.school_rounded, AppColors.categoryEducation),
      TransactionCategory.subscription => (Icons.autorenew_rounded, AppColors.categorySubscription),
      TransactionCategory.income => (Icons.trending_up_rounded, AppColors.success),
      TransactionCategory.other => (Icons.more_horiz_rounded, AppColors.categoryOther),
    };
  }

  static Color colorFor(TransactionCategory category) => _iconAndColor(category).$2;
}
