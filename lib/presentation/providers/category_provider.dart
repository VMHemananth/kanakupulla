import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<CategoryModel>>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return CategoryNotifier(repository);
});

class CategoryNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final categories = await _repository.getCategories();
      state = AsyncValue.data(categories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _repository.addCategory(category);
      // Reload to ensure consistency
      await loadCategories();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateCategory(String oldName, CategoryModel newCategory) async {
    try {
      await _repository.updateCategory(oldName, newCategory);
      await loadCategories();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteCategory(String name) async {
    try {
      await _repository.deleteCategory(name);
      await loadCategories();
    } catch (e) {
      // Handle error
    }
  }
}
