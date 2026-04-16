import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/enums.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../widgets/common/category_icon.dart';
import '../../../widgets/common/op_empty_state.dart';
import '../widgets/transaction_list_item.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  TransactionCategory? _selectedCategory;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final transactionsAsync = user != null
        ? ref.watch(transactionsProvider(user.id))
        : const AsyncValue<List<dynamic>>.data([]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => context.push('/add-transaction'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(LucideIcons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Category Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...TransactionCategory.values
                    .where((c) => c != TransactionCategory.income)
                    .map((category) {
                  return _FilterChip(
                    label: category.label,
                    isSelected: _selectedCategory == category,
                    onTap: () => setState(() => _selectedCategory = category),
                  );
                }),
              ],
            ),
          ),

          AppSpacing.vGapSm,

          // Transaction List
          Expanded(
            child: transactionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error loading transactions')),
              data: (transactions) {
                var filtered = transactions.where((tx) {
                  if (_selectedCategory != null && tx.category != _selectedCategory) {
                    return false;
                  }
                  if (_searchQuery.isNotEmpty) {
                    final searchable = '${tx.merchant ?? ''} ${tx.description ?? ''} ${tx.category.label}'.toLowerCase();
                    return searchable.contains(_searchQuery);
                  }
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return OpEmptyState(
                    icon: LucideIcons.receipt,
                    title: _searchQuery.isNotEmpty
                        ? 'No matching transactions'
                        : 'No transactions yet',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Try a different search term'
                        : 'Your transactions will appear here when detected',
                    actionLabel: 'Add Manually',
                    onAction: () => context.push('/add-transaction'),
                  );
                }

                // Group by date
                final grouped = <String, List<dynamic>>{};
                for (final tx in filtered) {
                  final label = DateHelpers.groupLabel(tx.transactionDate);
                  grouped.putIfAbsent(label, () => []).add(tx);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  itemCount: grouped.length,
                  itemBuilder: (context, sectionIndex) {
                    final label = grouped.keys.elementAt(sectionIndex);
                    final items = grouped[label]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.zinc400,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        ...items.asMap().entries.map((entry) {
                          final d = Duration(milliseconds: entry.key * 40);
                          return TransactionListItem(
                            transaction: entry.value,
                            onTap: () => context.push('/transactions/${entry.value.id}'),
                          )
                              .animate()
                              .scaleXY(begin: 0.95, end: 1, delay: d, duration: 350.ms, curve: Curves.elasticOut)
                              .slideX(begin: 0.06, end: 0, delay: d, duration: 280.ms, curve: Curves.easeOutQuart)
                              .fadeIn(duration: 120.ms, delay: d);
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.zinc200,
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? Colors.white : AppColors.zinc600,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ),
    );
  }
}
