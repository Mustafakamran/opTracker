import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/user_model.dart';

class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Database> get _db => _dbHelper.database;

  Future<void> insert(UserModel user) async {
    final db = await _db;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(UserModel user) async {
    final db = await _db;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<UserModel?> getById(String id) async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getByUsername(String username) async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getByEmail(String email) async {
    final db = await _db;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await _db;
    final maps = await db.query('users', orderBy: 'lastLoginAt DESC');
    return maps.map((m) => UserModel.fromMap(m)).toList();
  }

  Future<void> updateAvailableFunds(String userId, double funds) async {
    final db = await _db;
    await db.update(
      'users',
      {'availableFunds': funds},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateMonthlyBudget(String userId, double budget) async {
    final db = await _db;
    await db.update(
      'users',
      {'monthlyBudget': budget},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}
