import '../../core/constants/enums.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/transaction_repository.dart';

/// Suggestion for budget allocation.
class BudgetSuggestion {
  final TransactionCategory category;
  final double suggestedLimit;
  final double averageSpending;
  final String reason;
  final SuggestionType type;

  const BudgetSuggestion({
    required this.category,
    required this.suggestedLimit,
    required this.averageSpending,
    required this.reason,
    required this.type,
  });
}

enum SuggestionType {
  reduce('Reduce Spending'),
  maintain('On Track'),
  increase('Needs More Budget'),
  newBudget('New Budget');

  const SuggestionType(this.label);
  final String label;
}

/// Service that analyzes spending patterns and suggests budget allocations.
class BudgetSuggestionService {
  final TransactionRepository _transactionRepo = TransactionRepository();

  /// Generate budget suggestions based on spending history and available funds.
  Future<List<BudgetSuggestion>> generateSuggestions({
    required String userId,
    required double availableFunds,
    required double monthlyBudget,
    required List<BudgetModel> currentBudgets,
  }) async {
    final now = DateTime.now();
    final suggestions = <BudgetSuggestion>[];

    // Get last 3 months of spending data
    final threeMonthsAgo = DateTime(now.year, now.month - 3, 1);
    final categorySpending = await _transactionRepo.getSpendingByCategory(
      userId,
      threeMonthsAgo,
      now,
    );

    // Calculate monthly averages
    final monthsSpanned = now.difference(threeMonthsAgo).inDays / 30;
    final monthlyAverages = <TransactionCategory, double>{};
    for (final entry in categorySpending.entries) {
      monthlyAverages[entry.key] = entry.value / monthsSpanned;
    }

    // Get current month spending
    final monthStart = DateTime(now.year, now.month, 1);
    final currentMonthSpending = await _transactionRepo.getSpendingByCategory(
      userId,
      monthStart,
      now,
    );

    final existingBudgetCategories = currentBudgets.map((b) => b.category).toSet();

    for (final category in TransactionCategory.values) {
      if (category == TransactionCategory.income) continue;

      final avgSpending = monthlyAverages[category] ?? 0.0;
      final currentSpending = currentMonthSpending[category] ?? 0.0;
      final existingBudget = currentBudgets
          .where((b) => b.category == category)
          .firstOrNull;

      if (existingBudget != null) {
        // Existing budget - check if it needs adjustment
        if (avgSpending > existingBudget.limit * 1.2) {
          suggestions.add(BudgetSuggestion(
            category: category,
            suggestedLimit: (avgSpending * 1.1).roundToDouble(),
            averageSpending: avgSpending,
            reason: 'You consistently spend more than your ${category.label} budget. '
                'Consider increasing it to avoid overspending stress.',
            type: SuggestionType.increase,
          ));
        } else if (avgSpending < existingBudget.limit * 0.5 && avgSpending > 0) {
          suggestions.add(BudgetSuggestion(
            category: category,
            suggestedLimit: (avgSpending * 1.3).roundToDouble(),
            averageSpending: avgSpending,
            reason: 'You\'re using less than half your ${category.label} budget. '
                'Reallocate the extra to savings or other categories.',
            type: SuggestionType.reduce,
          ));
        } else if (avgSpending > 0) {
          suggestions.add(BudgetSuggestion(
            category: category,
            suggestedLimit: existingBudget.limit,
            averageSpending: avgSpending,
            reason: 'Your ${category.label} spending is well within budget.',
            type: SuggestionType.maintain,
          ));
        }
      } else if (avgSpending > 20) {
        // No budget set but has spending - suggest creating one
        suggestions.add(BudgetSuggestion(
          category: category,
          suggestedLimit: (avgSpending * 1.15).roundToDouble(),
          averageSpending: avgSpending,
          reason: 'You spend an average of \$${avgSpending.toStringAsFixed(0)}/month '
              'on ${category.label}. Setting a budget helps control spending.',
          type: SuggestionType.newBudget,
        ));
      }
    }

    // Add overall savings suggestion if total spending is close to budget
    final totalAvgSpending = monthlyAverages.values.fold(0.0, (a, b) => a + b);
    if (monthlyBudget > 0 && totalAvgSpending > monthlyBudget * 0.9) {
      suggestions.insert(
        0,
        BudgetSuggestion(
          category: TransactionCategory.other,
          suggestedLimit: monthlyBudget * 0.85,
          averageSpending: totalAvgSpending,
          reason: 'Your spending is ${((totalAvgSpending / monthlyBudget) * 100).toStringAsFixed(0)}% '
              'of your monthly budget. Consider reducing non-essential spending.',
          type: SuggestionType.reduce,
        ),
      );
    }

    // Sort: actionable items first
    suggestions.sort((a, b) {
      const priority = {
        SuggestionType.reduce: 0,
        SuggestionType.increase: 1,
        SuggestionType.newBudget: 2,
        SuggestionType.maintain: 3,
      };
      return (priority[a.type] ?? 4).compareTo(priority[b.type] ?? 4);
    });

    return suggestions;
  }

  /// Calculate recommended budget distribution for available funds.
  Map<String, double> recommendDistribution(double availableFunds) {
    return {
      'Needs (50%)': availableFunds * 0.50,
      'Wants (30%)': availableFunds * 0.30,
      'Savings (20%)': availableFunds * 0.20,
    };
  }
}
