import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/budget_model.dart';
import '../../data/repositories/budget_repository.dart';
import 'date_provider.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, AsyncValue<BudgetModel?>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return BudgetNotifier(repository, date);
});

class BudgetNotifier extends StateNotifier<AsyncValue<BudgetModel?>> {
  final BudgetRepository _repository;
  final DateTime _date;

  BudgetNotifier(this._repository, this._date) : super(const AsyncValue.loading()) {
    loadBudget();
  }

  Future<void> loadBudget() async {
    try {
      state = const AsyncValue.loading();
      final monthId = '${_date.year}_${_date.month}';
      final budget = await _repository.getBudget(monthId);
      state = AsyncValue.data(budget);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setBudget(double amount) async {
    try {
      final monthId = '${_date.year}_${_date.month}';
      final budget = BudgetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        month: monthId,
        amount: amount,
      );
      await _repository.setBudget(budget);
      state = AsyncValue.data(budget);
    } catch (e) {
      // Handle error
    }
  }
}

final categoryBudgetsProvider = StateNotifierProvider<CategoryBudgetNotifier, AsyncValue<List<BudgetModel>>>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return CategoryBudgetNotifier(repository, date);
});

class CategoryBudgetNotifier extends StateNotifier<AsyncValue<List<BudgetModel>>> {
  final BudgetRepository _repository;
  final DateTime _date;

  CategoryBudgetNotifier(this._repository, this._date) : super(const AsyncValue.loading()) {
    loadBudgets();
  }

  Future<void> loadBudgets() async {
    try {
      final monthId = '${_date.year}_${_date.month}';
      final budgets = await _repository.getCategoryBudgets(monthId);
      state = AsyncValue.data(budgets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setCategoryBudget(String category, double amount) async {
    try {
      final monthId = '${_date.year}_${_date.month}';
      final budget = BudgetModel(
        id: '${monthId}_$category', // Unique ID per month per category
        month: monthId,
        amount: amount,
        category: category,
      );
      await _repository.setBudget(budget);
      await loadBudgets();
    } catch (e) {
      // Handle error
    }
  }
}
