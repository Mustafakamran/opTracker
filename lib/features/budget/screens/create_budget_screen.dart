import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/budget_model.dart';
import '../../../widgets/common/category_icon.dart';

class CreateBudgetScreen extends ConsumerStatefulWidget {
  const CreateBudgetScreen({super.key});

  @override
  ConsumerState<CreateBudgetScreen> createState() => _CreateBudgetScreenState();
}

class _CreateBudgetScreenState extends ConsumerState<CreateBudgetScreen> {
  final _amountController = TextEditingController();
  TransactionCategory _category = TransactionCategory.food;
  BudgetPeriod _period = BudgetPeriod.monthly;
  double _alertThreshold = 0.8;
  bool _alertEnabled = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final (startDate, endDate) = _periodDates(now, _period);

    final budget = BudgetModel(
      id: const Uuid().v4(),
      userId: user.id,
      category: _category,
      limit: amount,
      period: _period,
      startDate: startDate,
      endDate: endDate,
      alertEnabled: _alertEnabled,
      alertThreshold: _alertThreshold,
    );

    final repo = ref.read(budgetRepoProvider);
    await repo.insert(budget);

    if (mounted) {
      ref.invalidate(budgetsProvider);
      context.pop();
    }
  }

  (DateTime, DateTime) _periodDates(DateTime now, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.weekly:
        final start = now.subtract(Duration(days: now.weekday - 1));
        return (
          DateTime(start.year, start.month, start.day),
          DateTime(start.year, start.month, start.day + 6, 23, 59, 59),
        );
      case BudgetPeriod.monthly:
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case BudgetPeriod.yearly:
        return (
          DateTime(now.year, 1, 1),
          DateTime(now.year, 12, 31, 23, 59, 59),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Budget'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Amount
            Text(
              'Budget Amount',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.zinc500,
                  ),
            ),
            AppSpacing.vGapSm,
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '\$ ',
                border: InputBorder.none,
                hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.zinc300,
                    ),
              ),
              autofocus: true,
            ).animate().fadeIn(duration: 300.ms),

            AppSpacing.vGapXl,

            // Category
            Text(
              'Category',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.zinc500,
                  ),
            ),
            AppSpacing.vGapSm,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TransactionCategory.values
                  .where((c) => c != TransactionCategory.income)
                  .map((category) {
                final isSelected = _category == category;
                return GestureDetector(
                  onTap: () => setState(() => _category = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? CategoryIcon.colorFor(category).withOpacity(0.12)
                          : AppColors.zinc50,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      border: Border.all(
                        color: isSelected
                            ? CategoryIcon.colorFor(category)
                            : AppColors.zinc200,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(category.emoji, style: const TextStyle(fontSize: 14)),
                        AppSpacing.hGapXs,
                        Text(
                          category.label,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

            AppSpacing.vGapXl,

            // Period
            Text(
              'Budget Period',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.zinc500,
                  ),
            ),
            AppSpacing.vGapSm,
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: BudgetPeriod.values.map((period) {
                  final isSelected = _period == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _period = period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Center(
                          child: Text(
                            period.label,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: isSelected ? Colors.white : AppColors.zinc500,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

            AppSpacing.vGapXl,

            // Alert Settings
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Spending Alert',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Switch(
                          value: _alertEnabled,
                          onChanged: (v) => setState(() => _alertEnabled = v),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    if (_alertEnabled) ...[
                      AppSpacing.vGapSm,
                      Text(
                        'Alert when spending reaches ${(_alertThreshold * 100).toStringAsFixed(0)}% of budget',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.zinc500,
                            ),
                      ),
                      Slider(
                        value: _alertThreshold,
                        min: 0.5,
                        max: 1.0,
                        divisions: 10,
                        label: '${(_alertThreshold * 100).toStringAsFixed(0)}%',
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _alertThreshold = v),
                      ),
                    ],
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

            AppSpacing.vGapXxl,

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Budget'),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

            AppSpacing.vGapXxl,
          ],
        ),
      ),
    );
  }
}
