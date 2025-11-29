import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../models/fixed_expense_model.dart';
import '../services/database_service.dart';

final fixedExpenseRepositoryProvider = Provider<FixedExpenseRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return FixedExpenseRepository(dbService);
});

class FixedExpenseRepository {
  final DatabaseService _dbService;

  FixedExpenseRepository(this._dbService);

  Future<List<FixedExpenseModel>> getFixedExpenses() async {
    final db = await _dbService.database;
    final result = await db.query('fixed_expenses');
    return result.map((e) => FixedExpenseModel.fromJson(e)).toList();
  }

  Future<void> addFixedExpense(FixedExpenseModel expense) async {
    final db = await _dbService.database;
    await db.insert(
      'fixed_expenses',
      expense.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFixedExpense(FixedExpenseModel expense) async {
    final db = await _dbService.database;
    await db.update(
      'fixed_expenses',
      expense.toJson(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteFixedExpense(String id) async {
    final db = await _dbService.database;
    await db.delete('fixed_expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isExpenseAddedForMonth(String title, double amount, DateTime date) async {
    // Legacy check (fuzzy match) - kept for backward compatibility if needed, 
    // but we primarily want to check by ID now.
    // Actually, let's add a new method for ID check and keep this for legacy or specific use cases.
    final db = await _dbService.database;
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);
    
    final result = await db.query(
      'expenses',
      where: 'title = ? AND amount = ? AND date >= ? AND date <= ?',
      whereArgs: [title, amount, startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
    );
    return result.isNotEmpty;
  }

  Future<bool> isFixedExpenseAddedForMonthById(String fixedId, DateTime date) async {
    final db = await _dbService.database;
    final deterministicId = '${fixedId}_${date.year}_${date.month}';
    
    final result = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [deterministicId],
    );
    return result.isNotEmpty;
  }
}
