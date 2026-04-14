import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/transaction.dart' as model;
import '../models/budget.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        UNIQUE(category_id, month, year),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await _seedCategories(db);
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          month INTEGER NOT NULL,
          year INTEGER NOT NULL,
          UNIQUE(category_id, month, year),
          FOREIGN KEY (category_id) REFERENCES categories(id)
        )
      ''');
    }
  }

  Future _seedCategories(Database db) async {
    final categories = [
      {'name': 'Gaji', 'type': 'income', 'icon': 'salary'},
      {'name': 'Freelance', 'type': 'income', 'icon': 'freelance'},
      {'name': 'Lainnya', 'type': 'income', 'icon': 'other'},
      {'name': 'Makan', 'type': 'expense', 'icon': 'food'},
      {'name': 'Transport', 'type': 'expense', 'icon': 'transport'},
      {'name': 'Belanja', 'type': 'expense', 'icon': 'shopping'},
      {'name': 'Tagihan', 'type': 'expense', 'icon': 'bill'},
      {'name': 'Hiburan', 'type': 'expense', 'icon': 'entertainment'},
      {'name': 'Lainnya', 'type': 'expense', 'icon': 'other'},
    ];

    for (final cat in categories) {
      await db.insert('categories', cat);
    }
  }

  // ── CATEGORIES ──────────────────────────────────────

  Future<List<Category>> getCategories({String? type}) async {
    final db = await database;
    final result = type != null
        ? await db.query('categories', where: 'type = ?', whereArgs: [type])
        : await db.query('categories');

    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  // ── TRANSACTIONS ─────────────────────────────────────

  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<model.Transaction>> getTransactions() async {
    final db = await database;
    final result = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return result.map((e) => model.Transaction.fromMap(e)).toList();
  }

  Future<int> updateTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ── BUDGETS ──────────────────────────────────────────

  Future<List<Budget>> getBudgets(int month, int year) async {
    final db = await database;
    final result = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    return result.map((e) => Budget.fromMap(e)).toList();
  }

  Future<int> upsertBudget(Budget budget) async {
    final db = await database;
    final existing = await db.query(
      'budgets',
      where: 'category_id = ? AND month = ? AND year = ?',
      whereArgs: [budget.categoryId, budget.month, budget.year],
    );
    if (existing.isNotEmpty) {
      return await db.update(
        'budgets',
        budget.toMap(),
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    }
    return await db.insert('budgets', budget.toMap());
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // ── SUMMARY ──────────────────────────────────────────

  Future<Map<String, double>> getSummary() async {
    final db = await database;

    final incomeResult = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = 'income'",
    );
    final expenseResult = await db.rawQuery(
      "SELECT COALESCE(SUM(amount), 0) as total FROM transactions WHERE type = 'expense'",
    );

    final income = (incomeResult.first['total'] as num).toDouble();
    final expense = (expenseResult.first['total'] as num).toDouble();

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }

  // ── BACKUP & RESTORE ─────────────────────────────────

  Future<String> exportToJson() async {
    final db = await database;
    final categories = await db.query('categories');
    final transactions = await db.query('transactions');
    final budgets = await db.query('budgets');

    final data = {
      'version': 2,
      'exportDate': DateTime.now().toIso8601String(),
      'categories': categories,
      'transactions': transactions,
      'budgets': budgets,
    };

    return jsonEncode(data);
  }

  Future<void> importFromJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final db = await database;

    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('transactions');
      await txn.delete('budgets');
      await txn.delete('categories');

      // Import categories
      for (final cat in (data['categories'] as List)) {
        await txn.insert('categories', Map<String, dynamic>.from(cat));
      }

      // Import transactions
      for (final t in (data['transactions'] as List)) {
        await txn.insert('transactions', Map<String, dynamic>.from(t));
      }

      // Import budgets
      if (data['budgets'] != null) {
        for (final b in (data['budgets'] as List)) {
          await txn.insert('budgets', Map<String, dynamic>.from(b));
        }
      }
    });
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}