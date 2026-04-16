import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/constants/enums.dart';
import '../widgets/spending_overview_card.dart';
import '../widgets/spending_chart.dart';
import '../widgets/category_breakdown_card.dart';
import '../widgets/recent_transactions_card.dart';
import '../widgets/budget_progress_card.dart';
import '../widgets/period_selector.dart';
import '../../../widgets/common/op_avatar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final period = ref.watch(selectedPeriodProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.base,
        title: Row(
          children: [
            OpAvatar(
              name: user?.displayName ?? 'User',
              imageUrl: user?.avatarUrl,
              size: 36,
            ),
            AppSpacing.hGapMd,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.zinc400,
                      ),
                ),
                Text(
                  user?.displayName ?? 'User',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => context.push('/add-transaction'),
          ),
          AppSpacing.hGapSm,
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(totalSpendingProvider);
          ref.invalidate(totalIncomeProvider);
          ref.invalidate(categorySpendingProvider);
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(budgetsProvider);
        },
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            // Period Selector
            const PeriodSelector()
                .animate()
                .fadeIn(duration: 300.ms),

            AppSpacing.vGapBase,

            // Spending Overview
            const SpendingOverviewCard()
                .animate()
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.03, end: 0, curve: Curves.easeOutCubic),

            AppSpacing.vGapBase,

            // Spending Chart
            const SpendingChart()
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.03, end: 0, curve: Curves.easeOutCubic),

            AppSpacing.vGapBase,

            // Category Breakdown
            const CategoryBreakdownCard()
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.03, end: 0, curve: Curves.easeOutCubic),

            AppSpacing.vGapBase,

            // Budget Progress
            const BudgetProgressCard()
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.03, end: 0, curve: Curves.easeOutCubic),

            AppSpacing.vGapBase,

            // Recent Transactions
            const RecentTransactionsCard()
                .animate()
                .fadeIn(delay: 500.ms, duration: 400.ms)
                .slideY(begin: 0.03, end: 0, curve: Curves.easeOutCubic),

            AppSpacing.vGapXxl,
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
