import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'optracker.db';
  static const _databaseVersion = 1;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL UNIQUE,
        displayName TEXT,
        email TEXT,
        avatarUrl TEXT,
        authMethod TEXT NOT NULL,
        pinHash TEXT,
        patternHash TEXT,
        monthlyBudget REAL DEFAULT 0.0,
        availableFunds REAL DEFAULT 0.0,
        currency TEXT DEFAULT 'USD',
        createdAt TEXT NOT NULL,
        lastLoginAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        merchant TEXT,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        source TEXT DEFAULT 'unknown',
        parseStatus TEXT DEFAULT 'manual',
        rawNotification TEXT,
        sourceApp TEXT,
        transactionDate TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        note TEXT,
        tags TEXT DEFAULT '',
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        category TEXT NOT NULL,
        budgetLimit REAL NOT NULL,
        spent REAL DEFAULT 0.0,
        period TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        alertEnabled INTEGER DEFAULT 1,
        alertThreshold REAL DEFAULT 0.8,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notification_logs (
        id TEXT PRIMARY KEY,
        packageName TEXT NOT NULL,
        title TEXT,
        text TEXT,
        bigText TEXT,
        receivedAt TEXT NOT NULL,
        processed INTEGER DEFAULT 0,
        linkedTransactionId TEXT,
        FOREIGN KEY (linkedTransactionId) REFERENCES transactions (id)
      )
    ''');

    // Indices for performance
    await db.execute(
      'CREATE INDEX idx_transactions_userId ON transactions (userId)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_date ON transactions (transactionDate)',
    );
    await db.execute(
      'CREATE INDEX idx_transactions_category ON transactions (category)',
    );
    await db.execute(
      'CREATE INDEX idx_budgets_userId ON budgets (userId)',
    );
    await db.execute(
      'CREATE INDEX idx_notification_logs_processed ON notification_logs (processed)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
