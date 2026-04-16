import '../../data/models/budget_model.dart';
import 'gemma_service.dart';

/// AI budget advisor using on-device Gemma 3 1B.
/// Falls back to rule-based suggestions when model is unavailable.
class AiBudgetService {
  final GemmaService _gemma = GemmaService();

  bool get isAiAvailable => _gemma.isInitialized;

  Future<bool> isModelDownloaded() => _gemma.isModelAvailable();
  Future<String> getModelPath() => _gemma.getModelPath();

  /// Try to initialize the local Gemma model.
  Future<bool> initializeAi() async {
    if (await _gemma.isModelAvailable()) {
      return await _gemma.initialize();
    }
    return false;
  }

  /// Get budget advice - uses Gemma if available, otherwise rule-based.
  Future<String> getAdvice({
    required double availableFunds,
    required double monthlyBudget,
    required double totalSpent,
    required Map<String, double> categorySpending,
    required List<BudgetModel> budgets,
  }) async {
    if (_gemma.isInitialized) {
      return await _getAiAdvice(
        availableFunds, monthlyBudget, totalSpent, categorySpending, budgets,
      );
    }
    return _getRuleBasedAdvice(availableFunds, monthlyBudget, totalSpent, categorySpending);
  }

  Future<String> _getAiAdvice(
    double availableFunds,
    double monthlyBudget,
    double totalSpent,
    Map<String, double> categorySpending,
    List<BudgetModel> budgets,
  ) async {
    final spendingLines = categorySpending.entries
        .map((e) => '${e.key}: \$${e.value.toStringAsFixed(0)}')
        .join(', ');

    final budgetLines = budgets
        .map((b) => '${b.category.label}: \$${b.spent.toStringAsFixed(0)}/\$${b.limit.toStringAsFixed(0)}')
        .join(', ');

    final prompt = '''<start_of_turn>user
You are a concise personal finance advisor. Given this data, give exactly 3 short actionable tips (one sentence each, as bullet points).

Funds: \$${availableFunds.toStringAsFixed(0)}
Budget: \$${monthlyBudget.toStringAsFixed(0)}/month
Spent: \$${totalSpent.toStringAsFixed(0)} this month
Categories: $spendingLines
${budgetLines.isNotEmpty ? 'Budgets: $budgetLines' : 'No budgets set.'}
<end_of_turn>
<start_of_turn>model
''';

    try {
      final response = await _gemma.generate(prompt);
      if (response.isNotEmpty && !response.startsWith('Error')) {
        return response.trim();
      }
    } catch (_) {}

    return _getRuleBasedAdvice(availableFunds, monthlyBudget, totalSpent, categorySpending);
  }

  String _getRuleBasedAdvice(
    double availableFunds,
    double monthlyBudget,
    double totalSpent,
    Map<String, double> categorySpending,
  ) {
    final tips = <String>[];

    if (monthlyBudget > 0) {
      final pct = totalSpent / monthlyBudget;
      if (pct > 0.9) {
        tips.add("You've used ${(pct * 100).toStringAsFixed(0)}% of your monthly budget. Cut non-essential spending for the rest of the month.");
      } else if (pct > 0.7) {
        tips.add("You're at ${(pct * 100).toStringAsFixed(0)}% of your budget. Stay mindful of spending to finish under budget.");
      } else {
        tips.add("Good pace - only ${(pct * 100).toStringAsFixed(0)}% of your budget used so far this month.");
      }
    }

    if (availableFunds > 0) {
      final needs = availableFunds * 0.50;
      final wants = availableFunds * 0.30;
      final savings = availableFunds * 0.20;
      tips.add("Recommended 50/30/20 split: \$${needs.toStringAsFixed(0)} needs, \$${wants.toStringAsFixed(0)} wants, \$${savings.toStringAsFixed(0)} savings.");
    }

    if (categorySpending.isNotEmpty) {
      final sorted = categorySpending.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      tips.add("Top spending: ${sorted.first.key} at \$${sorted.first.value.toStringAsFixed(0)}. Consider setting a budget limit for this category.");
    }

    if (tips.isEmpty) {
      tips.add("Start tracking spending to get personalized suggestions.");
    }

    return tips.map((t) => '• $t').join('\n');
  }
}
