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
      version: 13,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE expenses (
            id TEXT PRIMARY KEY,
            title TEXT,
            amount REAL,
            date TEXT,
            category TEXT,
            paymentMethod TEXT,
            creditCardId TEXT,
            isCreditCardBill INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE budgets (
            id TEXT PRIMARY KEY,
            amount REAL,
            month INTEGER,
            year INTEGER,
            category TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE salaries (
            id TEXT PRIMARY KEY,
            amount REAL,
            date TEXT,
            source TEXT,
            title TEXT,
            workingDays INTEGER,
            workingHours INTEGER
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
        await db.execute('''
          CREATE TABLE credit_cards (
            id TEXT PRIMARY KEY,
            name TEXT,
            billingDay INTEGER,
            lastBillGeneratedMonth TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE debts (
            id TEXT PRIMARY KEY,
            personName TEXT,
            amount REAL,
            type TEXT,
            date TEXT,
            dueDate TEXT,
            description TEXT,
            isSettled INTEGER DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE savings_goals (
            id TEXT PRIMARY KEY,
            name TEXT,
            targetAmount REAL,
            currentAmount REAL,
            deadline TEXT,
            icon TEXT,
            color INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE groups (
            id TEXT PRIMARY KEY,
            name TEXT,
            created_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE group_members (
            id TEXT PRIMARY KEY,
            group_id TEXT,
            name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE split_expenses (
            id TEXT PRIMARY KEY,
            group_id TEXT,
            title TEXT,
            amount REAL,
            paid_by_member_id TEXT,
            date TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE expense_shares (
            id TEXT PRIMARY KEY,
            expense_id TEXT,
            member_id TEXT,
            amount REAL
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
          await db.execute("ALTER TABLE expenses ADD COLUMN paymentMethod TEXT");
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
        if (oldVersion < 6) {
          await db.execute("ALTER TABLE salaries ADD COLUMN workingDays INTEGER");
          await db.execute("ALTER TABLE salaries ADD COLUMN workingHours INTEGER");
        }
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE credit_cards (
              id TEXT PRIMARY KEY,
              name TEXT,
              billingDay INTEGER,
              lastBillGeneratedMonth TEXT
            )
          ''');
          try {
            await db.execute("ALTER TABLE expenses ADD COLUMN creditCardId TEXT");
            await db.execute("ALTER TABLE expenses ADD COLUMN isCreditCardBill INTEGER DEFAULT 0");
          } catch (e) {
            // Ignore
          }
        }
        if (oldVersion < 8) {
          await db.execute('''
            CREATE TABLE debts (
              id TEXT PRIMARY KEY,
              personName TEXT,
              amount REAL,
              type TEXT,
              date TEXT,
              dueDate TEXT,
              description TEXT,
              isSettled INTEGER DEFAULT 0
            )
          ''');
        }
        if (oldVersion < 9) {
          await db.execute('''
            CREATE TABLE savings_goals (
              id TEXT PRIMARY KEY,
              name TEXT,
              targetAmount REAL,
              currentAmount REAL,
              deadline TEXT,
              icon TEXT,
              color INTEGER
            )
          ''');
        }

        if (oldVersion < 10) {
          await db.execute('''
            CREATE TABLE groups (
              id TEXT PRIMARY KEY,
              name TEXT,
              created_at TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE group_members (
              id TEXT PRIMARY KEY,
              group_id TEXT,
              name TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE split_expenses (
              id TEXT PRIMARY KEY,
              group_id TEXT,
              title TEXT,
              amount REAL,
              paid_by_member_id TEXT,
              date TEXT
            )
          ''');
        }
        if (oldVersion < 11) {
          await db.execute('''
            CREATE TABLE expense_shares (
              id TEXT PRIMARY KEY,
              expense_id TEXT,
              member_id TEXT,
              amount REAL
            )
          ''');
        }
        if (oldVersion < 12) {
          try {
            await db.execute("ALTER TABLE debts ADD COLUMN roi REAL DEFAULT 0");
            await db.execute("ALTER TABLE debts ADD COLUMN interestType TEXT DEFAULT 'Fixed'");
            await db.execute("ALTER TABLE debts ADD COLUMN tenureMonths INTEGER DEFAULT 0");
            await db.execute("ALTER TABLE debts ADD COLUMN principalAmount REAL DEFAULT 0");
            await db.execute("ALTER TABLE debts ADD COLUMN payments TEXT DEFAULT '[]'");
          } catch (e) {
            // Ignore if columns exist
          }
        }
        if (oldVersion < 13) {
          try {
            // Ensure 'Savings' category exists
            await db.insert('categories', {'name': 'Savings', 'type': 'Savings'}, conflictAlgorithm: ConflictAlgorithm.ignore);
          } catch (e) {
            // Ignore
          }
        }
      },
    );
    return _db!;
  }
}
