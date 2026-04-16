import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class BudgetModel extends Equatable {
  final String id;
  final String userId;
  final TransactionCategory category;
  final double limit;
  final double spent;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final bool alertEnabled;
  final double alertThreshold; // 0.0 - 1.0 (percentage)

  const BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.limit,
    this.spent = 0.0,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.alertEnabled = true,
    this.alertThreshold = 0.8,
  });

  double get remaining => limit - spent;
  double get percentage => limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0.0;
  bool get isOverBudget => spent > limit;
  bool get isNearLimit => percentage >= alertThreshold && !isOverBudget;

  BudgetModel copyWith({
    String? id,
    String? userId,
    TransactionCategory? category,
    double? limit,
    double? spent,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? alertEnabled,
    double? alertThreshold,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      limit: limit ?? this.limit,
      spent: spent ?? this.spent,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertEnabled: alertEnabled ?? this.alertEnabled,
      alertThreshold: alertThreshold ?? this.alertThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category.name,
      'budgetLimit': limit,
      'spent': spent,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'alertEnabled': alertEnabled ? 1 : 0,
      'alertThreshold': alertThreshold,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      category: TransactionCategory.values.byName(map['category'] as String),
      limit: (map['budgetLimit'] as num).toDouble(),
      spent: (map['spent'] as num?)?.toDouble() ?? 0.0,
      period: BudgetPeriod.values.byName(map['period'] as String),
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      alertEnabled: (map['alertEnabled'] as int?) == 1,
      alertThreshold: (map['alertThreshold'] as num?)?.toDouble() ?? 0.8,
    );
  }

  @override
  List<Object?> get props => [id, userId, category, period];
}
