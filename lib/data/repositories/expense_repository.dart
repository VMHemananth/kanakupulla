import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../models/expense_model.dart';
import '../services/database_service.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return ExpenseRepository(dbService);
});

class ExpenseRepository {
  final DatabaseService _dbService;

  ExpenseRepository(this._dbService);

  Future<List<ExpenseModel>> getExpenses() async {
    final db = await _dbService.database;
    final maps = await db.query('expenses', orderBy: 'date DESC');
    return maps.map((e) {
      final mutableMap = Map<String, dynamic>.from(e);
      // Manually convert int to bool for isCreditCardBill
      if (mutableMap['isCreditCardBill'] is int) {
        mutableMap['isCreditCardBill'] = (mutableMap['isCreditCardBill'] as int) == 1;
      }
      if (mutableMap['isNeed'] is int) {
        mutableMap['isNeed'] = (mutableMap['isNeed'] as int) == 1;
      }
      return ExpenseModel.fromJson(mutableMap);
    }).toList();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    final db = await _dbService.database;
    await db.insert(
      'expenses',
      expense.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    final db = await _dbService.database;
    await db.update(
      'expenses',
      expense.toJson(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
