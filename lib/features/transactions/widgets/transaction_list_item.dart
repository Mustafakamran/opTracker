import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../data/models/transaction_model.dart';
import '../../../widgets/common/category_icon.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.xs,
          ),
          child: Row(
            children: [
              CategoryIcon(category: transaction.category),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.merchant ??
                          transaction.description ??
                          transaction.category.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.vGapXs,
                    Row(
                      children: [
                        Text(
                          transaction.category.label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.zinc400,
                              ),
                        ),
                        if (transaction.source != PaymentSource.unknown) ...[
                          Text(
                            '  ·  ',
                            style: TextStyle(color: AppColors.zinc300),
                          ),
                          Text(
                            transaction.source.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.zinc400,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isExpense ? AppColors.error : AppColors.success,
                        ),
                  ),
                  Text(
                    DateHelpers.time(transaction.transactionDate),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.zinc400,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
