import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
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
    return maps.map((e) {
      final mutableMap = Map<String, dynamic>.from(e);
      if (mutableMap['payments'] != null && mutableMap['payments'] is String) {
        try {
           mutableMap['payments'] = jsonDecode(mutableMap['payments'] as String);
        } catch (_) {
           mutableMap['payments'] = [];
        }
      }
      return DebtModel.fromJson(mutableMap);
    }).toList();
  }

  Future<void> addDebt(DebtModel debt) async {
    final db = await _dbService.database;
    final json = debt.toJson();
    if (json['payments'] != null) {
      json['payments'] = jsonEncode(json['payments']);
    }
    await db.insert('debts', json, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDebt(DebtModel debt) async {
    final db = await _dbService.database;
    final json = debt.toJson();
    if (json['payments'] != null) {
      json['payments'] = jsonEncode(json['payments']);
    }
    await db.update('debts', json, where: 'id = ?', whereArgs: [debt.id]);
  }

  Future<void> deleteDebt(String id) async {
    final db = await _dbService.database;
    await db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }
}
