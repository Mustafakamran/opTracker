import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/app_providers.dart';

class PeriodSelector extends ConsumerWidget {
  const PeriodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedPeriodProvider);
    final periods = [TimePeriod.daily, TimePeriod.weekly, TimePeriod.monthly];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.zinc800
            : AppColors.zinc100,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: periods.map((period) {
          final isSelected = selected == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => ref.read(selectedPeriodProvider.notifier).state = period,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Center(
                  child: Text(
                    period.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected ? Colors.white : AppColors.zinc500,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
