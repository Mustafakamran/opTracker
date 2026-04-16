import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../widgets/common/category_icon.dart';
import '../../../widgets/common/op_card.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final transactionsAsync = user != null
        ? ref.watch(transactionsProvider(user.id))
        : const AsyncValue.loading();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error')),
        data: (transactions) {
          final tx = transactions.where((t) => t.id == transactionId).firstOrNull;
          if (tx == null) {
            return const Center(child: Text('Transaction not found'));
          }

          final isExpense = tx.type == TransactionType.expense;

          return SingleChildScrollView(
            padding: AppSpacing.pagePadding,
            child: Column(
              children: [
                // Amount Hero
                OpCard(
                  animate: true,
                  child: Column(
                    children: [
                      CategoryIcon(category: tx.category, size: 56),
                      AppSpacing.vGapMd,
                      Text(
                        '${isExpense ? '-' : '+'}${CurrencyFormatter.format(tx.amount)}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: isExpense ? AppColors.error : AppColors.success,
                        ),
                      ),
                      AppSpacing.vGapXs,
                      Text(
                        tx.merchant ?? tx.description ?? tx.category.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      AppSpacing.vGapXs,
                      Text(
                        DateHelpers.full(tx.transactionDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.zinc400,
                            ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.vGapBase,

                // Details
                OpCard(
                  animate: true,
                  animationDelay: 100,
                  child: Column(
                    children: [
                      _DetailRow(label: 'Category', value: tx.category.label),
                      const Divider(height: 24),
                      _DetailRow(label: 'Type', value: tx.type.label),
                      const Divider(height: 24),
                      _DetailRow(label: 'Source', value: tx.source.label),
                      if (tx.note != null) ...[
                        const Divider(height: 24),
                        _DetailRow(label: 'Note', value: tx.note!),
                      ],
                      if (tx.tags.isNotEmpty) ...[
                        const Divider(height: 24),
                        _DetailRow(label: 'Tags', value: tx.tags.join(', ')),
                      ],
                    ],
                  ),
                ),

                if (tx.parseStatus == ParseStatus.parsed) ...[
                  AppSpacing.vGapBase,
                  OpCard(
                    animate: true,
                    animationDelay: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                size: 18, color: AppColors.primary),
                            AppSpacing.hGapSm,
                            Text(
                              'Auto-Detected',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        if (tx.rawNotification != null) ...[
                          AppSpacing.vGapMd,
                          Text(
                            'From notification:',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.zinc400,
                                ),
                          ),
                          AppSpacing.vGapXs,
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.zinc50,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(
                              tx.rawNotification!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.zinc600,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                AppSpacing.vGapXxl,
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(transactionRepoProvider);
              await repo.delete(transactionId);
              if (context.mounted) context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.zinc500,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
