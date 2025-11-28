import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

class DatabaseService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'kanakupulla_v2.db'); // New DB for v2
    
    _db = await openDatabase(
      fullPath,
      version: 5,
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
            amount REAL,
            category TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE salaries (
            id TEXT PRIMARY KEY,
            amount REAL,
            date TEXT,
            source TEXT,
            title TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE categories (
            name TEXT PRIMARY KEY,
            type TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE fixed_expenses (
            id TEXT PRIMARY KEY,
            title TEXT,
            amount REAL,
            category TEXT,
            dayOfMonth INTEGER,
            isAutoAdd INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE recurring_income (
            id TEXT PRIMARY KEY,
            source TEXT,
            amount REAL,
            dayOfMonth INTEGER,
            isAutoAdd INTEGER
          )
        ''');
        // Default categories
        await db.insert('categories', {'name': 'Food', 'type': 'Need'});
        await db.insert('categories', {'name': 'Transport', 'type': 'Need'});
        await db.insert('categories', {'name': 'Shopping', 'type': 'Want'});
        await db.insert('categories', {'name': 'Bills', 'type': 'Need'});
        await db.insert('categories', {'name': 'Entertainment', 'type': 'Want'});
        await db.insert('categories', {'name': 'Health', 'type': 'Need'});
        await db.insert('categories', {'name': 'Education', 'type': 'Need'});
        await db.insert('categories', {'name': 'Others', 'type': 'Want'});
        await db.insert('categories', {'name': 'Investments', 'type': 'Savings'});
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute("ALTER TABLE salaries ADD COLUMN source TEXT DEFAULT 'Salary'");
          await db.execute("ALTER TABLE salaries ADD COLUMN title TEXT");
        }
        if (oldVersion < 3) {
          try {
            await db.execute("ALTER TABLE categories ADD COLUMN type TEXT DEFAULT 'Want'");
            await db.update('categories', {'type': 'Need'}, where: "name IN ('Food', 'Transport', 'Bills', 'Health', 'Education')");
            await db.update('categories', {'type': 'Savings'}, where: "name IN ('Investments')");
          } catch (e) {
            // Ignore
          }
        }
        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE fixed_expenses (
              id TEXT PRIMARY KEY,
              title TEXT,
              amount REAL,
              category TEXT,
              dayOfMonth INTEGER,
              isAutoAdd INTEGER
            )
          ''');
          try {
            await db.execute("ALTER TABLE budgets ADD COLUMN category TEXT");
          } catch (e) {
            // Ignore
          }
        }
        if (oldVersion < 5) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS recurring_income (
              id TEXT PRIMARY KEY,
              source TEXT,
              amount REAL,
              dayOfMonth INTEGER,
              isAutoAdd INTEGER
            )
          ''');
        }
      },
    );
    return _db!;
  }
}
