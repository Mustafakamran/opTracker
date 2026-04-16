import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/models/transaction_model.dart';
import '../../../widgets/common/category_icon.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _noteController = TextEditingController();
  TransactionCategory _category = TransactionCategory.other;
  TransactionType _type = TransactionType.expense;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
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

    final transaction = TransactionModel(
      id: const Uuid().v4(),
      userId: user.id,
      amount: amount,
      description: _noteController.text.isNotEmpty ? _noteController.text : null,
      merchant: _merchantController.text.isNotEmpty ? _merchantController.text : null,
      category: _category,
      type: _type,
      source: PaymentSource.unknown,
      parseStatus: ParseStatus.manual,
      transactionDate: _date,
      createdAt: DateTime.now(),
    );

    final repo = ref.read(transactionRepoProvider);
    await repo.insert(transaction);

    if (mounted) {
      ref.invalidate(recentTransactionsProvider);
      ref.invalidate(totalSpendingProvider);
      ref.invalidate(categorySpendingProvider);
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Transaction'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.zinc100,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: TransactionType.values.map((type) {
                  final isSelected = _type == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Center(
                          child: Text(
                            type.label,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: isSelected ? Colors.white : AppColors.zinc500,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(duration: 300.ms),

            AppSpacing.vGapXl,

            // Amount Input
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
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.zinc300,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              autofocus: true,
            ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

            AppSpacing.vGapBase,

            // Merchant
            TextField(
              controller: _merchantController,
              decoration: const InputDecoration(
                labelText: 'Merchant / Recipient',
                prefixIcon: Icon(Icons.store_rounded, size: 20),
              ),
              textCapitalization: TextCapitalization.words,
            ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

            AppSpacing.vGapBase,

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
                                color: isSelected
                                    ? CategoryIcon.colorFor(category)
                                    : AppColors.zinc600,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

            AppSpacing.vGapXl,

            // Date Picker
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_rounded, size: 20),
              title: Text(
                '${_date.day}/${_date.month}/${_date.year}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ).animate().fadeIn(delay: 400.ms, duration: 300.ms),

            AppSpacing.vGapBase,

            // Note
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (optional)',
                prefixIcon: Icon(Icons.note_rounded, size: 20),
              ),
              maxLines: 2,
            ).animate().fadeIn(delay: 500.ms, duration: 300.ms),

            AppSpacing.vGapXxl,

            // Save Button
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
                    : const Text('Save Transaction'),
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 300.ms),

            AppSpacing.vGapXxl,
          ],
        ),
      ),
    );
  }
}
