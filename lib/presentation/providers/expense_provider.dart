import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import 'date_provider.dart';
import 'budget_provider.dart';
import '../../data/services/notification_service.dart';

final expensesProvider = StateNotifierProvider<ExpensesNotifier, AsyncValue<List<ExpenseModel>>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return ExpensesNotifier(repository, date, ref);
});

class ExpensesNotifier extends StateNotifier<AsyncValue<List<ExpenseModel>>> {
  final ExpenseRepository _repository;
  final DateTime _date;
  final Ref _ref;

  ExpensesNotifier(this._repository, this._date, this._ref) : super(const AsyncValue.loading()) {
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      state = const AsyncValue.loading();
      final allExpenses = await _repository.getExpenses();
      // Filter by selected month/year
      final filtered = allExpenses.where((e) => 
        e.date.year == _date.year && 
        e.date.month == _date.month &&
        !((e.paymentMethod == 'Credit Card') && !e.isCreditCardBill)
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
      
      // Check budget
      final budget = _ref.read(budgetProvider).value;
      if (budget != null) {
        final totalExpenses = state.value?.fold(0.0, (sum, e) => sum! + e.amount) ?? 0.0;
        final percentage = totalExpenses / budget.amount;
        
        if (percentage >= 1.0) {
          _ref.read(notificationServiceProvider).showBudgetAlert(
            'Budget Exceeded!',
            'You have exceeded your monthly budget of ₹${budget.amount.toStringAsFixed(0)}.',
          );
        } else if (percentage >= 0.9) {
          _ref.read(notificationServiceProvider).showBudgetAlert(
            'Budget Alert',
            'You have used ${(percentage * 100).toStringAsFixed(0)}% of your monthly budget.',
          );
        }
      }
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
