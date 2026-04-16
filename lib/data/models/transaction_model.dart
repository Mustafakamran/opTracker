import 'package:equatable/equatable.dart';
import '../../core/constants/enums.dart';

class TransactionModel extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String? description;
  final String? merchant;
  final TransactionCategory category;
  final TransactionType type;
  final PaymentSource source;
  final ParseStatus parseStatus;
  final String? rawNotification;
  final String? sourceApp;
  final DateTime transactionDate;
  final DateTime createdAt;
  final String? note;
  final List<String> tags;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    this.description,
    this.merchant,
    required this.category,
    required this.type,
    this.source = PaymentSource.unknown,
    this.parseStatus = ParseStatus.manual,
    this.rawNotification,
    this.sourceApp,
    required this.transactionDate,
    required this.createdAt,
    this.note,
    this.tags = const [],
  });

  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    String? merchant,
    TransactionCategory? category,
    TransactionType? type,
    PaymentSource? source,
    ParseStatus? parseStatus,
    String? rawNotification,
    String? sourceApp,
    DateTime? transactionDate,
    DateTime? createdAt,
    String? note,
    List<String>? tags,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      category: category ?? this.category,
      type: type ?? this.type,
      source: source ?? this.source,
      parseStatus: parseStatus ?? this.parseStatus,
      rawNotification: rawNotification ?? this.rawNotification,
      sourceApp: sourceApp ?? this.sourceApp,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'merchant': merchant,
      'category': category.name,
      'type': type.name,
      'source': source.name,
      'parseStatus': parseStatus.name,
      'rawNotification': rawNotification,
      'sourceApp': sourceApp,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'note': note,
      'tags': tags.join(','),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      merchant: map['merchant'] as String?,
      category: TransactionCategory.values.byName(map['category'] as String),
      type: TransactionType.values.byName(map['type'] as String),
      source: PaymentSource.values.byName(
        map['source'] as String? ?? 'unknown',
      ),
      parseStatus: ParseStatus.values.byName(
        map['parseStatus'] as String? ?? 'manual',
      ),
      rawNotification: map['rawNotification'] as String?,
      sourceApp: map['sourceApp'] as String?,
      transactionDate: DateTime.parse(map['transactionDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      note: map['note'] as String?,
      tags: (map['tags'] as String?)?.split(',').where((t) => t.isNotEmpty).toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [id, userId, amount, transactionDate];
}
