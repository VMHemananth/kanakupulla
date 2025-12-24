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

  Future<void> copyBudgetsFromPreviousMonth() async {
    try {
      state = const AsyncValue.loading();
      
      // Calculate previous month
      var prevYear = _date.year;
      var prevMonth = _date.month - 1;
      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear--;
      }
      
      final prevMonthId = '${prevYear}_$prevMonth';
      final currentMonthId = '${_date.year}_${_date.month}';

      // Get budgets from previous month
      final prevBudgets = await _repository.getCategoryBudgets(prevMonthId);
      
      if (prevBudgets.isEmpty) {
        // Nothing to copy
        await loadBudgets();
        return;
      }

      // Create new budgets for current month
      for (var prevBudget in prevBudgets) {
        if (prevBudget.category != null) {
          final newBudget = BudgetModel(
            id: '${currentMonthId}_${prevBudget.category}',
            month: currentMonthId,
            amount: prevBudget.amount,
            category: prevBudget.category,
          );
          await _repository.setBudget(newBudget);
        }
      }
      
      await loadBudgets();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> batchSetCategoryBudgets(Map<String, double> budgets) async {
    try {
      // Optimistically update state? Or just wait for reload? 
      // Given we are saving, let's just do the writes and reload.
      final monthId = '${_date.year}_${_date.month}';
      
      for (var entry in budgets.entries) {
        final category = entry.key;
        final amount = entry.value;
        final budget = BudgetModel(
          id: '${monthId}_$category',
          month: monthId,
          amount: amount,
          category: category,
        );
        await _repository.setBudget(budget);
      }
      await loadBudgets();
    } catch (e) {
      // Handle error
    }
  }
}
