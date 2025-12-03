import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_service.dart';
import '../models/debt_model.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return DebtRepository(dbService);
});

class DebtRepository {
  final DatabaseService _dbService;

  DebtRepository(this._dbService);

  Future<List<DebtModel>> getDebts() async {
    final db = await _dbService.database;
    final maps = await db.query('debts', orderBy: 'date DESC');
    return maps.map((e) => DebtModel.fromJson(e)).toList();
  }

  Future<void> addDebt(DebtModel debt) async {
    final db = await _dbService.database;
    await db.insert('debts', debt.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDebt(DebtModel debt) async {
    final db = await _dbService.database;
    await db.update('debts', debt.toJson(), where: 'id = ?', whereArgs: [debt.id]);
  }

  Future<void> deleteDebt(String id) async {
    final db = await _dbService.database;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }
}
