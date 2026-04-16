import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/common/op_card.dart';
import '../../../widgets/common/category_icon.dart';

class BudgetProgressCard extends ConsumerWidget {
  const BudgetProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);

    return OpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget Overview',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton(
                onPressed: () => context.go('/budgets'),
                child: const Text('Manage'),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          budgetsAsync.when(
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Text('Error'),
            data: (budgets) {
              if (budgets.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.zinc50,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.zinc200),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.pieChart, color: AppColors.zinc400),
                      AppSpacing.hGapMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No budgets set',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Text(
                              'Create budgets to track your spending',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.zinc400,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/create-budget'),
                        child: const Text('Create'),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                children: budgets.take(3).map((budget) {
                  final color = budget.isOverBudget
                      ? AppColors.error
                      : budget.isNearLimit
                          ? AppColors.warning
                          : AppColors.success;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CategoryIcon(category: budget.category, size: 28),
                            AppSpacing.hGapSm,
                            Expanded(
                              child: Text(
                                budget.category.label,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            Text(
                              '${CurrencyFormatter.format(budget.spent)} / ${CurrencyFormatter.format(budget.limit)}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.zinc500,
                                  ),
                            ),
                          ],
                        ),
                        AppSpacing.vGapXs,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: budget.percentage.clamp(0.0, 1.0)),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: AppColors.zinc100,
                                valueColor: AlwaysStoppedAnimation(color),
                                minHeight: 6,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
