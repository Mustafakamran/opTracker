import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/budget_model.dart';
import '../../core/constants/enums.dart';

class BudgetRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  Future<void> insert(BudgetModel budget) async {
    final db = await _db;
    await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(BudgetModel budget) async {
    final db = await _db;
    await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BudgetModel>> getByUserId(String userId) async {
    final db = await _db;
    final maps = await db.query(
      'budgets',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'category ASC',
    );
    return maps.map((m) => BudgetModel.fromMap(m)).toList();
  }

  Future<BudgetModel?> getByCategory(
    String userId,
    TransactionCategory category,
    BudgetPeriod period,
  ) async {
    final db = await _db;
    final maps = await db.query(
      'budgets',
      where: 'userId = ? AND category = ? AND period = ?',
      whereArgs: [userId, category.name, period.name],
    );
    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  Future<List<BudgetModel>> getActiveBudgets(String userId) async {
    final db = await _db;
    final now = DateTime.now().toIso8601String();
    final maps = await db.query(
      'budgets',
      where: 'userId = ? AND startDate <= ? AND endDate >= ?',
      whereArgs: [userId, now, now],
    );
    return maps.map((m) => BudgetModel.fromMap(m)).toList();
  }

  Future<void> updateSpent(String id, double spent) async {
    final db = await _db;
    await db.update(
      'budgets',
      {'spent': spent},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
