import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../widgets/common/op_card.dart';

class SpendingChart extends ConsumerWidget {
  const SpendingChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(periodTransactionsProvider);

    return OpCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Trend',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          AppSpacing.vGapBase,
          SizedBox(
            height: 180,
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error')),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No data yet',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.zinc400,
                          ),
                    ),
                  );
                }

                // Group by day for bar chart
                final dailyTotals = <int, double>{};
                for (final tx in transactions) {
                  if (tx.type.name == 'expense') {
                    final day = tx.transactionDate.day;
                    dailyTotals[day] = (dailyTotals[day] ?? 0) + tx.amount;
                  }
                }

                if (dailyTotals.isEmpty) {
                  return Center(
                    child: Text(
                      'No expenses this period',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.zinc400,
                          ),
                    ),
                  );
                }

                final sortedDays = dailyTotals.keys.toList()..sort();
                final maxVal = dailyTotals.values.reduce(
                  (a, b) => a > b ? a : b,
                );

                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxVal * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '\$${rod.toY.toStringAsFixed(0)}',
                            TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${value.toInt()}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.zinc400,
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: sortedDays.map((day) {
                      return BarChartGroupData(
                        x: day,
                        barRods: [
                          BarChartRodData(
                            toY: dailyTotals[day] ?? 0,
                            color: AppColors.primary,
                            width: 12,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 500),
                  swapAnimationCurve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
