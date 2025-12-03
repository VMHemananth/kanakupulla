import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/savings_goal_model.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return SavingsRepository(dbService);
});

class SavingsRepository {
  final DatabaseService _dbService;

  SavingsRepository(this._dbService);

  Future<List<SavingsGoalModel>> getGoals() async {
    final db = await _dbService.database;
    final maps = await db.query('savings_goals');
    return maps.map((e) => SavingsGoalModel.fromJson(e)).toList();
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    final db = await _dbService.database;
    await db.insert('savings_goals', goal.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    final db = await _dbService.database;
    await db.update('savings_goals', goal.toJson(), where: 'id = ?', whereArgs: [goal.id]);
  }

  Future<void> deleteGoal(String id) async {
    final db = await _dbService.database;
    await db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }
}
