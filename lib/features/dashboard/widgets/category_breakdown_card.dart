import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/common/op_card.dart';
import '../../../widgets/common/category_icon.dart';

class CategoryBreakdownCard extends ConsumerWidget {
  const CategoryBreakdownCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categorySpendingProvider);

    return OpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'By Category',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          AppSpacing.vGapBase,
          categoryAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Text('Error'),
            data: (categories) {
              if (categories.isEmpty) {
                return SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'No spending data yet',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.zinc400,
                          ),
                    ),
                  ),
                );
              }

              final total = categories.values.fold(0.0, (a, b) => a + b);
              final entries = categories.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return Column(
                children: [
                  // Pie Chart
                  SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: entries.map((entry) {
                          final percent = entry.value / total;
                          return PieChartSectionData(
                            color: CategoryIcon.colorFor(entry.key),
                            value: entry.value,
                            title: '${(percent * 100).toStringAsFixed(0)}%',
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            radius: 36,
                          );
                        }).toList(),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 500),
                    ),
                  ),
                  AppSpacing.vGapBase,
                  // Legend
                  ...entries.take(5).map((entry) {
                    final percent = (entry.value / total * 100).toStringAsFixed(1);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: CategoryIcon.colorFor(entry.key),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          AppSpacing.hGapSm,
                          Expanded(
                            child: Text(
                              entry.key.label,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(entry.value),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          AppSpacing.hGapSm,
                          Text(
                            '$percent%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.zinc400,
                                ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
