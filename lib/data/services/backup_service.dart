import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class BackupService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> createBackup() async {
    final db = await _dbService.database;

    // 1. Fetch all data from tables
    final expenses = await db.query('expenses');
    final budgets = await db.query('budgets');
    final salaries = await db.query('salaries');
    final categories = await db.query('categories');
    final fixedExpenses = await db.query('fixed_expenses');
    final recurringIncome = await db.query('recurring_income');

    // 2. Create JSON map
    final backupData = {
      'version': 1,
      'timestamp': DateTime.now().toIso8601String(),
      'expenses': expenses,
      'budgets': budgets,
      'salaries': salaries,
      'categories': categories,
      'fixed_expenses': fixedExpenses,
      'recurring_income': recurringIncome,
    };

    // 3. Convert to JSON string
    final jsonString = jsonEncode(backupData);

    // 4. Write to temporary file
    final directory = await getTemporaryDirectory();
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/kanakupulla_backup_$dateStr.json');
    await file.writeAsString(jsonString);

    // 5. Share file
    await Share.shareXFiles([XFile(file.path)], text: 'Kanakupulla Backup');
  }

  Future<bool> restoreBackup() async {
    try {
      // 1. Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return false;

      final file = File(result.files.single.path!);
      return await restoreFromFile(file);
    } catch (e) {
      print('Restore failed: $e');
      return false;
    }
  }

  Future<bool> restoreFromFile(File file) async {
    try {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // 2. Validate data
      if (!data.containsKey('expenses') || !data.containsKey('categories')) {
        throw Exception('Invalid backup file format');
      }

      final db = await _dbService.database;
      
      await db.transaction((txn) async {
        // 3. Clear existing tables
        await txn.delete('expenses');
        await txn.delete('budgets');
        await txn.delete('salaries');
        await txn.delete('categories');
        await txn.delete('fixed_expenses');
        await txn.delete('recurring_income');

        // 4. Insert new data
        final expenses = List<Map<String, dynamic>>.from(data['expenses']);
        for (var item in expenses) {
          await txn.insert('expenses', item);
        }

        final budgets = List<Map<String, dynamic>>.from(data['budgets']);
        for (var item in budgets) {
          await txn.insert('budgets', item);
        }

        final salaries = List<Map<String, dynamic>>.from(data['salaries']);
        for (var item in salaries) {
          await txn.insert('salaries', item);
        }

        final categories = List<Map<String, dynamic>>.from(data['categories']);
        for (var item in categories) {
          await txn.insert('categories', item);
        }

        if (data.containsKey('fixed_expenses')) {
          final fixedExpenses = List<Map<String, dynamic>>.from(data['fixed_expenses']);
          for (var item in fixedExpenses) {
            await txn.insert('fixed_expenses', item);
          }
        }

        if (data.containsKey('recurring_income')) {
          final recurringIncome = List<Map<String, dynamic>>.from(data['recurring_income']);
          for (var item in recurringIncome) {
            await txn.insert('recurring_income', item);
          }
        }
      });

      return true;
    } catch (e) {
       print('Restore From File failed: $e');
       rethrow;
    }
  }
}
