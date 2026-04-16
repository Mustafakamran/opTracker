import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../core/constants/enums.dart';
import '../../../widgets/common/op_card.dart';
import '../../../widgets/common/category_icon.dart';

class RecentTransactionsCard extends ConsumerWidget {
  const RecentTransactionsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    return OpCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextButton(
                  onPressed: () => context.go('/transactions'),
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
          AppSpacing.vGapSm,
          transactionsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text('Error loading transactions'),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.receipt,
                          size: 32,
                          color: AppColors.zinc300,
                        ),
                        AppSpacing.vGapSm,
                        Text(
                          'No transactions yet',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.zinc400,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: transactions.map((tx) {
                  return ListTile(
                    onTap: () => context.push('/transactions/${tx.id}'),
                    leading: CategoryIcon(category: tx.category),
                    title: Text(
                      tx.merchant ?? tx.description ?? tx.category.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      DateHelpers.relative(tx.transactionDate),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.zinc400,
                          ),
                    ),
                    trailing: Text(
                      '${tx.type == TransactionType.expense ? '-' : '+'}${CurrencyFormatter.format(tx.amount)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: tx.type == TransactionType.expense
                                ? AppColors.error
                                : AppColors.success,
                          ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                    ),
                    dense: true,
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
