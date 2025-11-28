import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../services/database_service.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return CategoryRepository(dbService);
});

class CategoryRepository {
  final DatabaseService _dbService;

  CategoryRepository(this._dbService);

  Future<List<CategoryModel>> getCategories() async {
    final db = await _dbService.database;
    final result = await db.query('categories');
    return result.map((e) => CategoryModel.fromJson(e)).toList();
  }

  Future<void> addCategory(CategoryModel category) async {
    final db = await _dbService.database;
    await db.insert(
      'categories',
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCategory(String oldName, CategoryModel newCategory) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      // 1. Update category
      await txn.update(
        'categories',
        newCategory.toJson(),
        where: 'name = ?',
        whereArgs: [oldName],
      );

      // 2. Update related tables if name changed
      if (oldName != newCategory.name) {
        await txn.update(
          'expenses',
          {'category': newCategory.name},
          where: 'category = ?',
          whereArgs: [oldName],
        );
        await txn.update(
          'budgets',
          {'category': newCategory.name},
          where: 'category = ?',
          whereArgs: [oldName],
        );
        await txn.update(
          'fixed_expenses',
          {'category': newCategory.name},
          where: 'category = ?',
          whereArgs: [oldName],
        );
      }
    });
  }

  Future<void> deleteCategory(String name) async {
    final db = await _dbService.database;
    await db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }
}
