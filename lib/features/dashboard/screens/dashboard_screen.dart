import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  // Snappy spring curve — fast in, slight overshoot, quick settle
  static const _spring = Curves.elasticOut;
  // Quick ease for secondary motion
  static const _ease = Curves.easeOutQuart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

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
          IconButton(icon: const Icon(LucideIcons.bell, size: 20), onPressed: () {}),
          IconButton(
            icon: const Icon(LucideIcons.plusCircle, size: 20),
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
            const PeriodSelector()
                .animate()
                .scaleXY(begin: 0.95, end: 1, duration: 350.ms, curve: _ease)
                .fadeIn(duration: 200.ms),

            AppSpacing.vGapBase,

            // Cards enter with scale-up spring + slide, feels physical
            _springCard(const SpendingOverviewCard(), 0),

            AppSpacing.vGapBase,

            _springCard(const SpendingChart(), 1),

            AppSpacing.vGapBase,

            _springCard(const CategoryBreakdownCard(), 2),

            AppSpacing.vGapBase,

            _springCard(const BudgetProgressCard(), 3),

            AppSpacing.vGapBase,

            _springCard(const RecentTransactionsCard(), 4),

            AppSpacing.vGapXxl,
          ],
        ),
      ),
    );
  }

  /// Each card scales up from 0.92 with a spring overshoot + slight upward slide.
  /// Staggered by index so they cascade in.
  Widget _springCard(Widget child, int index) {
    final delay = Duration(milliseconds: 60 + index * 70);
    return child
        .animate()
        .scaleXY(begin: 0.92, end: 1, duration: 500.ms, delay: delay, curve: _spring)
        .slideY(begin: 0.04, end: 0, duration: 350.ms, delay: delay, curve: _ease)
        .fadeIn(duration: 180.ms, delay: delay);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
