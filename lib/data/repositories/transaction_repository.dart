import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';
import '../../core/constants/enums.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  Future<void> insert(TransactionModel transaction) async {
    final db = await _db;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(TransactionModel transaction) async {
    final db = await _db;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<TransactionModel?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TransactionModel.fromMap(maps.first);
  }

  Future<List<TransactionModel>> getByUserId(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    final db = await _db;
    final maps = await db.query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'transactionDate DESC',
      limit: limit,
      offset: offset,
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final maps = await db.query(
      'transactions',
      where: 'userId = ? AND transactionDate >= ? AND transactionDate <= ?',
      whereArgs: [userId, start.toIso8601String(), end.toIso8601String()],
      orderBy: 'transactionDate DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getByCategory(
    String userId,
    TransactionCategory category, {
    DateTime? start,
    DateTime? end,
  }) async {
    final db = await _db;
    String where = 'userId = ? AND category = ?';
    List<dynamic> args = [userId, category.name];

    if (start != null && end != null) {
      where += ' AND transactionDate >= ? AND transactionDate <= ?';
      args.addAll([start.toIso8601String(), end.toIso8601String()]);
    }

    final maps = await db.query(
      'transactions',
      where: where,
      whereArgs: args,
      orderBy: 'transactionDate DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<double> getTotalSpending(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions '
      'WHERE userId = ? AND type = ? AND transactionDate >= ? AND transactionDate <= ?',
      [userId, TransactionType.expense.name, start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTotalIncome(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) as total FROM transactions '
      'WHERE userId = ? AND type = ? AND transactionDate >= ? AND transactionDate <= ?',
      [userId, TransactionType.income.name, start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<TransactionCategory, double>> getSpendingByCategory(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT category, SUM(amount) as total FROM transactions '
      'WHERE userId = ? AND type = ? AND transactionDate >= ? AND transactionDate <= ? '
      'GROUP BY category ORDER BY total DESC',
      [userId, TransactionType.expense.name, start.toIso8601String(), end.toIso8601String()],
    );

    final map = <TransactionCategory, double>{};
    for (final row in result) {
      final category = TransactionCategory.values.byName(row['category'] as String);
      map[category] = (row['total'] as num).toDouble();
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> getDailySpending(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await _db;
    return await db.rawQuery(
      'SELECT DATE(transactionDate) as date, SUM(amount) as total '
      'FROM transactions '
      'WHERE userId = ? AND type = ? AND transactionDate >= ? AND transactionDate <= ? '
      'GROUP BY DATE(transactionDate) ORDER BY date ASC',
      [userId, TransactionType.expense.name, start.toIso8601String(), end.toIso8601String()],
    );
  }

  Future<int> getTransactionCount(String userId) async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM transactions WHERE userId = ?',
      [userId],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
