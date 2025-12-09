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
      
      // Self-healing: Ensure 'Savings' exists
      if (!categories.any((c) => c.name.toLowerCase() == 'savings')) {
        final savingsCat = CategoryModel(name: 'Savings', type: 'Savings');
        await _repository.addCategory(savingsCat);
        // Add to local list immediately
        final updatedList = [...categories, savingsCat];
        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.data(categories);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      final currentCategories = state.value ?? [];
      final exists = currentCategories.any(
        (c) => c.name.trim().toLowerCase() == category.name.trim().toLowerCase()
      );

      if (exists) {
        throw Exception('Category "${category.name}" already exists.');
      }

      await _repository.addCategory(category);
      // Reload to ensure consistency
      await loadCategories();
    } catch (e) {
      rethrow; // Rethrow to let UI handle it
    }
  }

  Future<void> updateCategory(String oldName, CategoryModel newCategory) async {
    try {
      // If name is changing, check for duplicates (excluding self)
      if (oldName.toLowerCase() != newCategory.name.toLowerCase()) {
         final currentCategories = state.value ?? [];
         final exists = currentCategories.any(
          (c) => c.name.trim().toLowerCase() == newCategory.name.trim().toLowerCase()
        );
        if (exists) {
          throw Exception('Category "${newCategory.name}" already exists.');
        }
      }

      await _repository.updateCategory(oldName, newCategory);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCategory(String name) async {
    try {
      if (name.toLowerCase() == 'savings') {
        throw Exception('The "Savings" category cannot be deleted.');
      }
      await _repository.deleteCategory(name);
      await loadCategories();
    } catch (e) {
      rethrow;
    }
  }
}
