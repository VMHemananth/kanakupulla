import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../models/salary_model.dart';
import '../services/database_service.dart';

final salaryRepositoryProvider = Provider<SalaryRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return SalaryRepository(dbService);
});

class SalaryRepository {
  final DatabaseService _dbService;

  SalaryRepository(this._dbService);

  Future<List<SalaryModel>> getSalaries() async {
    final db = await _dbService.database;
    final maps = await db.query('salaries');
    return maps.map((e) => SalaryModel.fromJson(e)).toList();
  }

  Future<void> addSalary(SalaryModel salary) async {
    final db = await _dbService.database;
    await db.insert(
      'salaries',
      salary.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteSalary(String id) async {
    final db = await _dbService.database;
    await db.delete('salaries', where: 'id = ?', whereArgs: [id]);
  }
}
