import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/budget_suggestion_service.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/common/op_card.dart';
import '../../../widgets/common/category_icon.dart';

final suggestionsProvider = FutureProvider<List<BudgetSuggestion>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final budgets = await ref.watch(budgetsProvider.future);
  final service = ref.read(budgetSuggestionServiceProvider);
  return service.generateSuggestions(
    userId: user.id,
    availableFunds: user.availableFunds,
    monthlyBudget: user.monthlyBudget,
    currentBudgets: budgets,
  );
});

class BudgetSuggestionsScreen extends ConsumerWidget {
  const BudgetSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(suggestionsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Budget Suggestions'),
      ),
      body: suggestionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error generating suggestions')),
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lightbulb_outline_rounded,
                        size: 48, color: AppColors.zinc300),
                    AppSpacing.vGapBase,
                    Text(
                      'No Suggestions Yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    AppSpacing.vGapSm,
                    Text(
                      'Keep tracking your spending and we\'ll suggest optimized budgets based on your habits.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.zinc400,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          // 50/30/20 Distribution
          final distribution = BudgetSuggestionService()
              .recommendDistribution(user?.availableFunds ?? 0);

          return ListView(
            padding: AppSpacing.pagePadding,
            children: [
              // 50/30/20 Rule Card
              if (user != null && user.availableFunds > 0)
                OpCard(
                  animate: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              size: 18, color: AppColors.primary),
                          AppSpacing.hGapSm,
                          Text(
                            'Recommended Distribution',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  color: AppColors.primary,
                                ),
                          ),
                        ],
                      ),
                      AppSpacing.vGapSm,
                      Text(
                        'Based on your available funds of ${CurrencyFormatter.format(user.availableFunds)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.zinc500,
                            ),
                      ),
                      AppSpacing.vGapBase,
                      ...distribution.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                CurrencyFormatter.format(entry.value),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              AppSpacing.vGapBase,

              Text(
                'Category Suggestions',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              AppSpacing.vGapSm,

              ...suggestions.asMap().entries.map((entry) {
                final suggestion = entry.value;
                final (color, icon, bgColor) = _typeStyle(suggestion.type);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: OpCard(
                    animate: true,
                    animationDelay: (entry.key + 1) * 80,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CategoryIcon(category: suggestion.category, size: 36),
                            AppSpacing.hGapMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    suggestion.category.label,
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(
                                          AppSpacing.radiusFull),
                                    ),
                                    child: Text(
                                      suggestion.type.label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(color: color),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(
                                      suggestion.suggestedLimit),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'suggested',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppColors.zinc400),
                                ),
                              ],
                            ),
                          ],
                        ),
                        AppSpacing.vGapMd,
                        Text(
                          suggestion.reason,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.zinc500,
                                height: 1.4,
                              ),
                        ),
                        AppSpacing.vGapMd,
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Dismiss'),
                              ),
                            ),
                            AppSpacing.hGapSm,
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text('Apply'),
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
            ],
          );
        },
      ),
    );
  }

  (Color, IconData, Color) _typeStyle(SuggestionType type) {
    return switch (type) {
      SuggestionType.reduce => (AppColors.warning, Icons.trending_down_rounded, AppColors.warningLight),
      SuggestionType.increase => (AppColors.error, Icons.trending_up_rounded, AppColors.errorLight),
      SuggestionType.maintain => (AppColors.success, Icons.check_circle_rounded, AppColors.successLight),
      SuggestionType.newBudget => (AppColors.info, Icons.add_circle_rounded, AppColors.infoLight),
    };
  }
}
