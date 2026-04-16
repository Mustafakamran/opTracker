import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/common/op_card.dart';
import '../../../widgets/common/op_empty_state.dart';
import '../../../widgets/common/category_icon.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/budget-suggestions'),
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: const Text('Suggestions'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-budget'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Budget'),
      ),
      body: budgetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading budgets')),
        data: (budgets) {
          if (budgets.isEmpty) {
            return OpEmptyState(
              icon: Icons.pie_chart_rounded,
              title: 'No Budgets Yet',
              subtitle: 'Create budgets to control your spending across categories',
              actionLabel: 'Get AI Suggestions',
              onAction: () => context.push('/budget-suggestions'),
            );
          }

          // Summary header
          final totalBudget = budgets.fold(0.0, (sum, b) => sum + b.limit);
          final totalSpent = budgets.fold(0.0, (sum, b) => sum + b.spent);

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              // Overall Summary
              OpCard(
                animate: true,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Budgeted',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.zinc400,
                                  ),
                            ),
                            Text(
                              CurrencyFormatter.format(totalBudget),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Spent',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.zinc400,
                                  ),
                            ),
                            Text(
                              CurrencyFormatter.format(totalSpent),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: totalSpent > totalBudget
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    AppSpacing.vGapMd,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0,
                          end: totalBudget > 0
                              ? (totalSpent / totalBudget).clamp(0.0, 1.0)
                              : 0.0,
                        ),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) {
                          return LinearProgressIndicator(
                            value: value,
                            backgroundColor: AppColors.zinc100,
                            valueColor: AlwaysStoppedAnimation(
                              totalSpent > totalBudget
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                            minHeight: 8,
                          );
                        },
                      ),
                    ),
                    AppSpacing.vGapSm,
                    Text(
                      '${CurrencyFormatter.format(totalBudget - totalSpent)} remaining',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.zinc400,
                          ),
                    ),
                  ],
                ),
              ),

              AppSpacing.vGapBase,

              // Budget Cards
              ...budgets.asMap().entries.map((entry) {
                final budget = entry.value;
                final color = budget.isOverBudget
                    ? AppColors.error
                    : budget.isNearLimit
                        ? AppColors.warning
                        : AppColors.success;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: OpCard(
                    animate: true,
                    animationDelay: (entry.key + 1) * 100,
                    onTap: () {},
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CategoryIcon(category: budget.category, size: 44),
                            AppSpacing.hGapMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    budget.category.label,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    '${budget.period.label} budget',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.zinc400,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(budget.spent),
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                Text(
                                  'of ${CurrencyFormatter.format(budget.limit)}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppColors.zinc400,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        AppSpacing.vGapMd,
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: budget.percentage.clamp(0.0, 1.0),
                            ),
                            duration: Duration(
                              milliseconds: 600 + (entry.key * 100),
                            ),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) {
                              return LinearProgressIndicator(
                                value: value,
                                backgroundColor: AppColors.zinc100,
                                valueColor: AlwaysStoppedAnimation(color),
                                minHeight: 8,
                              );
                            },
                          ),
                        ),
                        AppSpacing.vGapSm,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (budget.isOverBudget)
                              Row(
                                children: [
                                  const Icon(Icons.warning_rounded,
                                      size: 14, color: AppColors.error),
                                  AppSpacing.hGapXs,
                                  Text(
                                    'Over by ${CurrencyFormatter.format(budget.spent - budget.limit)}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: AppColors.error,
                                        ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                '${CurrencyFormatter.format(budget.remaining)} left',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.zinc400,
                                    ),
                              ),
                            Text(
                              '${(budget.percentage * 100).toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              AppSpacing.vGapXxl,
              AppSpacing.vGapXxl,
            ],
          );
        },
      ),
    );
  }
}
