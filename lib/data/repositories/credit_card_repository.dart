import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../models/credit_card_model.dart';
import '../services/database_service.dart';

final creditCardRepositoryProvider = Provider<CreditCardRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return CreditCardRepository(dbService);
});

class CreditCardRepository {
  final DatabaseService _dbService;

  CreditCardRepository(this._dbService);

  Future<List<CreditCardModel>> getCreditCards() async {
    final db = await _dbService.database;
    final maps = await db.query('credit_cards');
    return maps.map((e) => CreditCardModel.fromJson(e)).toList();
  }

  Future<void> addCreditCard(CreditCardModel card) async {
    final db = await _dbService.database;
    await db.insert('credit_cards', card.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCreditCard(CreditCardModel card) async {
    final db = await _dbService.database;
    await db.update(
      'credit_cards',
      card.toJson(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCreditCard(String id) async {
    final db = await _dbService.database;
    await db.delete(
      'credit_cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
