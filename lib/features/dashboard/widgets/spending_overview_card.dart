import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../widgets/common/op_card.dart';
import '../../../widgets/common/op_shimmer.dart';

class SpendingOverviewCard extends ConsumerWidget {
  const SpendingOverviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendingAsync = ref.watch(totalSpendingProvider);
    final incomeAsync = ref.watch(totalIncomeProvider);
    final user = ref.watch(currentUserProvider);

    return OpCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: spendingAsync.when(
        loading: () => const _ShimmerContent(),
        error: (_, __) => const Text('Error loading data'),
        data: (spending) {
          final income = incomeAsync.valueOrNull ?? 0.0;
          final balance = income - spending;
          final available = user?.availableFunds ?? 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Spending',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.zinc500,
                    ),
              ),
              AppSpacing.vGapSm,
              Text(
                CurrencyFormatter.format(spending),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  letterSpacing: -1,
                ),
              ),
              AppSpacing.vGapBase,
              const Divider(),
              AppSpacing.vGapBase,
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: 'Income',
                      value: CurrencyFormatter.format(income),
                      color: AppColors.success,
                      icon: Icons.trending_up_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Balance',
                      value: CurrencyFormatter.format(balance.abs()),
                      color: balance >= 0 ? AppColors.success : AppColors.error,
                      icon: balance >= 0
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Theme.of(context).dividerColor,
                  ),
                  Expanded(
                    child: _StatItem(
                      label: 'Available',
                      value: CurrencyFormatter.compact(available),
                      color: AppColors.info,
                      icon: Icons.account_balance_wallet_rounded,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        AppSpacing.vGapXs,
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.zinc400,
              ),
        ),
      ],
    );
  }
}

class _ShimmerContent extends StatelessWidget {
  const _ShimmerContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OpShimmer(height: 14, width: 100),
        AppSpacing.vGapSm,
        const OpShimmer(height: 36, width: 180),
        AppSpacing.vGapBase,
        const Divider(),
        AppSpacing.vGapBase,
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            OpShimmer(height: 40, width: 80),
            OpShimmer(height: 40, width: 80),
            OpShimmer(height: 40, width: 80),
          ],
        ),
      ],
    );
  }
}
