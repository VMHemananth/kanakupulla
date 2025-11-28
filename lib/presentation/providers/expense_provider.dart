import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import 'date_provider.dart';

final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<List<ExpenseModel>>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return ExpensesNotifier(repository, date);
});

class ExpensesNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final ExpenseRepository _repository;
  final DateTime _date;

  ExpensesNotifier(this._repository, this._date) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      state = const AsyncValue.loading();
      final allExpenses = await _repository.getExpenses();
      // Filter by selected month/year
      final filtered = allExpenses.where((e) => 
        e.date.year == _date.year && e.date.month == _date.month
      ).toList();
      state = AsyncValue.data(filtered);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _repository.addExpense(expense);
      await loadExpenses();
    } catch (e) {
      // Handle error (maybe show snackbar via listener in UI)
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _repository.updateExpense(expense);
      await loadExpenses();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
    } catch (e) {
      // Handle error
    }
  }
}
final allExpensesProvider = StateNotifierProvider<AllExpensesNotifier, AsyncValue<List<ExpenseModel>>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return AllExpensesNotifier(repository);
});

class AllExpensesNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final ExpenseRepository _repository;

  AllExpensesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      state = const AsyncValue.loading();
      final allExpenses = await _repository.getExpenses();
      state = AsyncValue.data(allExpenses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
