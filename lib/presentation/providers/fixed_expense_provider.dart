import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/fixed_expense_model.dart';
import '../../data/repositories/fixed_expense_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/models/expense_model.dart';

final fixedExpensesProvider = StateNotifierProvider<FixedExpenseNotifier, AsyncValue<List<FixedExpenseModel>>>((ref) {
  final repository = ref.watch(fixedExpenseRepositoryProvider);
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  return FixedExpenseNotifier(repository, expenseRepository);
});

class FixedExpenseNotifier extends StateNotifier<AsyncValue<List<FixedExpenseModel>>> {
  final FixedExpenseRepository _repository;
  final ExpenseRepository _expenseRepository;

  FixedExpenseNotifier(this._repository, this._expenseRepository) : super(const AsyncValue.loading()) {
    loadFixedExpenses();
  }

  Future<void> loadFixedExpenses() async {
    try {
      final expenses = await _repository.getFixedExpenses();
      state = AsyncValue.data(expenses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFixedExpense(FixedExpenseModel expense) async {
    try {
      await _repository.addFixedExpense(expense);
      
      // Sync with current month if auto-add is enabled
      if (expense.isAutoAdd) {
        await _syncToCurrentMonth(expense);
      }

      await loadFixedExpenses();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateFixedExpense(FixedExpenseModel expense) async {
    try {
      await _repository.updateFixedExpense(expense);
      
      // Sync with current month if auto-add is enabled
      if (expense.isAutoAdd) {
        await _syncToCurrentMonth(expense);
      }

      await loadFixedExpenses();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteFixedExpense(String id) async {
    try {
      await _repository.deleteFixedExpense(id);
      
      // Delete from current month
      final now = DateTime.now();
      final deterministicId = '${id}_${now.year}_${now.month}';
      await _expenseRepository.deleteExpense(deterministicId);

      await loadFixedExpenses();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _syncToCurrentMonth(FixedExpenseModel fixed) async {
    final now = DateTime.now();
    final deterministicId = '${fixed.id}_${now.year}_${now.month}';
    
    final expense = ExpenseModel(
      id: deterministicId,
      title: fixed.title,
      amount: fixed.amount,
      date: DateTime(now.year, now.month, fixed.dayOfMonth > 0 ? fixed.dayOfMonth : 1),
      category: fixed.category,
      paymentMethod: 'Cash', // Default
    );

    await _expenseRepository.addExpense(expense); // Uses replace conflict algorithm
  }

  Future<List<FixedExpenseModel>> getMissingFixedExpenses(DateTime currentMonth) async {
    final missing = <FixedExpenseModel>[];
    try {
      final fixedExpenses = await _repository.getFixedExpenses();
      // We can now check existence by ID directly instead of fuzzy matching title/amount
      // But to be safe and support legacy (if any), we can stick to the repo check OR check by ID.
      // Since we are moving to deterministic IDs, checking by ID in the expenses table is better.
      // However, `isExpenseAddedForMonth` in repo currently checks by title/amount.
      // Let's stick to the repo check for now, but we should probably update it to check by ID if we want to be strict.
      // Actually, for the new deterministic ID approach, we should check if an expense with that ID exists.
      // But `ExpenseRepository` doesn't expose `exists(id)`.
      // Let's rely on `isExpenseAddedForMonth` for now, but update Dashboard to use the deterministic ID when adding.
      
      for (var fixed in fixedExpenses) {
        if (!fixed.isAutoAdd) continue;
        
        // Check by deterministic ID first (Robust)
        bool isAdded = await _repository.isFixedExpenseAddedForMonthById(fixed.id, currentMonth);
        
        // Fallback to fuzzy check if not found by ID (Backward compatibility for manually added ones)
        if (!isAdded) {
           isAdded = await _repository.isExpenseAddedForMonth(fixed.title, fixed.amount, currentMonth);
        }

        if (!isAdded) {
          missing.add(fixed);
        }
      }
    } catch (e) {
      print('Error checking fixed expenses: $e');
    }
    return missing;
  }
}
