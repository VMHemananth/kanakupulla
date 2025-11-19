import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'kanakupulla.db');
    return await openDatabase(
      fullPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id TEXT PRIMARY KEY,
            title TEXT,
            amount REAL,
            date TEXT,
            category TEXT,
            paymentMethod TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE budgets (
            id TEXT PRIMARY KEY,
            month TEXT,
            amount REAL
          )
        ''');
        await db.execute('''
          CREATE TABLE salaries (
            id TEXT PRIMARY KEY,
            amount REAL,
            date TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            name TEXT PRIMARY KEY
          )
        ''');
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            amount REAL,
            date TEXT,
            description TEXT,
            category TEXT,
            isImported INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add paymentMethod column if not exists
          await db.execute("ALTER TABLE expenses ADD COLUMN paymentMethod TEXT");
        }
      },
    );
  }

  // Expense CRUD
  static Future<void> updateExpense(Expense e) async {
    final db = await database;
    await db.update(
      'expenses',
      {
        'title': e.title,
        'amount': e.amount,
        'date': e.date.toIso8601String(),
        'category': e.category,
        'paymentMethod': e.paymentMethod,
      },
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }
  static Future<void> insertExpense(Expense e) async {
    final db = await database;
    await db.insert('expenses', {
      'id': e.id,
      'title': e.title,
      'amount': e.amount,
      'date': e.date.toIso8601String(),
      'category': e.category,
      'paymentMethod': e.paymentMethod,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<List<Expense>> getExpenses() async {
    final db = await database;
    final maps = await db.query('expenses');
    return maps.map((m) => Expense(
      id: m['id'] as String,
      title: m['title'] as String,
      amount: m['amount'] is int ? (m['amount'] as int).toDouble() : m['amount'] as double,
      date: DateTime.parse(m['date'] as String),
      category: m['category'] as String,
      paymentMethod: m['paymentMethod'] as String?,
    )).toList();
  }
  static Future<void> deleteExpense(String id) async {
    final db = await database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id.toString()]);
  }

  // Budget CRUD
  static Future<void> insertBudget(Budget b) async {
    final db = await database;
    await db.insert('budgets', {
      'id': b.id,
      'month': b.month,
      'amount': b.amount,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<List<Budget>> getBudgets() async {
    final db = await database;
    final maps = await db.query('budgets');
    return maps.map((m) => Budget(
      id: m['id'] as String,
      month: m['month'] as String,
      amount: m['amount'] is int ? (m['amount'] as int).toDouble() : m['amount'] as double,
    )).toList();
  }
  static Future<void> deleteBudget(String id) async {
    final db = await database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Salary CRUD
  static Future<void> insertSalary(Salary s) async {
    final db = await database;
    await db.insert('salaries', {
      'id': s.id,
      'amount': s.amount,
      'date': s.date.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<List<Salary>> getSalaries() async {
    final db = await database;
    final maps = await db.query('salaries');
    return maps.map((m) => Salary(
      id: m['id'] as String,
      amount: m['amount'] is int ? (m['amount'] as int).toDouble() : m['amount'] as double,
      date: DateTime.parse(m['date'] as String),
    )).toList();
  }
  static Future<void> deleteSalary(String id) async {
    final db = await database;
    await db.delete('salaries', where: 'id = ?', whereArgs: [id]);
  }

  // Category CRUD
  static Future<void> insertCategory(String name) async {
    final db = await database;
    await db.insert('categories', {'name': name}, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<List<String>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories');
    return maps.map((m) => m['name'] as String).toList();
  }
  static Future<void> deleteCategory(String name) async {
    final db = await database;
    await db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }

  // Transaction CRUD
  static Future<void> insertTransaction(TransactionModel t) async {
    final db = await database;
    await db.insert('transactions', {
      'id': t.id,
      'amount': t.amount,
      'date': t.date.toIso8601String(),
      'description': t.description,
      'category': t.category,
      'isImported': t.isImported ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions');
    return maps.map((m) => TransactionModel(
      id: m['id'] as String,
      amount: m['amount'] is int ? (m['amount'] as int).toDouble() : m['amount'] as double,
      date: DateTime.parse(m['date'] as String),
      description: m['description'] as String,
      category: m['category'] as String,
      isImported: (m['isImported'] as int) == 1,
    )).toList();
  }
  static Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
