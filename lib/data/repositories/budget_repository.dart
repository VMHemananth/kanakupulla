import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../models/budget_model.dart';
import '../services/database_service.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return BudgetRepository(dbService);
});

class BudgetRepository {
  final DatabaseService _dbService;

  BudgetRepository(this._dbService);

  Future<BudgetModel?> getBudget(String month) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'budgets',
      where: 'month = ? AND category IS NULL',
      whereArgs: [month],
    );
    if (maps.isNotEmpty) {
      return BudgetModel.fromJson(maps.first);
    }
    return null;
  }

  Future<List<BudgetModel>> getCategoryBudgets(String month) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'budgets',
      where: 'month = ? AND category IS NOT NULL',
      whereArgs: [month],
    );
    return maps.map((e) => BudgetModel.fromJson(e)).toList();
  }

  Future<void> setBudget(BudgetModel budget) async {
    final db = await _dbService.database;
    await db.insert(
      'budgets',
      budget.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
