import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../models/recurring_income_model.dart';
import '../services/database_service.dart';

final recurringIncomeRepositoryProvider = Provider<RecurringIncomeRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return RecurringIncomeRepository(dbService);
});

class RecurringIncomeRepository {
  final DatabaseService _dbService;

  RecurringIncomeRepository(this._dbService);

  Future<List<RecurringIncomeModel>> getRecurringIncomes() async {
    final db = await _dbService.database;
    final maps = await db.query('recurring_income');
    return maps.map((e) => RecurringIncomeModel.fromJson(e)).toList();
  }

  Future<void> addRecurringIncome(RecurringIncomeModel income) async {
    final db = await _dbService.database;
    await db.insert(
      'recurring_income',
      income.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateRecurringIncome(RecurringIncomeModel income) async {
    final db = await _dbService.database;
    await db.update(
      'recurring_income',
      income.toJson(),
      where: 'id = ?',
      whereArgs: [income.id],
    );
  }

  Future<void> deleteRecurringIncome(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'recurring_income',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> isIncomeAddedForMonth(String recurringId, DateTime month) async {
    final db = await _dbService.database;
    final idToCheck = '${recurringId}_${month.year}_${month.month}';
    final result = await db.query(
      'salaries',
      where: 'id = ?',
      whereArgs: [idToCheck],
    );
    return result.isNotEmpty;
  }
}
