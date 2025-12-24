import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/salary_repository.dart';
import '../../core/utils/financial_calculator.dart';

final yearlyStatsProvider = StateNotifierProvider.family<YearlyStatsNotifier, AsyncValue<List<MonthlyStat>>, int>((ref, year) {
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final salaryRepo = ref.watch(salaryRepositoryProvider);
  return YearlyStatsNotifier(expenseRepo, salaryRepo, year);
});

class MonthlyStat {
  final int month;
  final double income;
  final double expense;

  MonthlyStat({
    required this.month,
    required this.income,
    required this.expense,
  });

  double get balance => income - expense;
}

class YearlyStatsNotifier extends StateNotifier<AsyncValue<List<MonthlyStat>>> {
  final ExpenseRepository _expenseRepo;
  final SalaryRepository _salaryRepo;
  final int _year;

  YearlyStatsNotifier(this._expenseRepo, this._salaryRepo, this._year) : super(const AsyncValue.loading()) {
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      state = const AsyncValue.loading();

      final allExpenses = await _expenseRepo.getExpenses();
      final allSalaries = await _salaryRepo.getSalaries();

      final List<MonthlyStat> stats = [];

      for (int month = 1; month <= 12; month++) {
 

        // Filter expenses for this month and year
        final monthlyExpenses = allExpenses.where((e) => 
          e.date.year == _year && e.date.month == month
        ).toList();
        
        // Calculate total expense using standardized logic
        final totalExpense = FinancialCalculator.calculateTotalExpense(monthlyExpenses);

        // Filter income for this month and year
        final monthlyIncome = allSalaries.where((e) => 
          e.date.year == _year && e.date.month == month
        ).toList();
        
        final totalIncome = FinancialCalculator.calculateTotalIncome(monthlyIncome);

        stats.add(MonthlyStat(
          month: month,
          income: totalIncome,
          expense: totalExpense,
        ));
      }

      state = AsyncValue.data(stats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> refresh() async {
    await loadStats();
  }
}
