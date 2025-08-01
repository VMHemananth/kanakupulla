import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';

class CategoryHelper {
  static const _key = 'categories_list';

  static Future<void> insertCategory(String name) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      if (!list.contains(name)) {
        list.add(name);
        await prefs.setStringList(_key, list);
      }
    } else {
      await DBHelper.insertCategory(name);
    }
  }

  static Future<List<String>> getCategories() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_key) ?? [];
    } else {
      return await DBHelper.getCategories();
    }
  }

  static Future<void> deleteCategory(String name) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? [];
      list.remove(name);
      await prefs.setStringList(_key, list);
    } else {
      await DBHelper.deleteCategory(name);
    }
  }
}
