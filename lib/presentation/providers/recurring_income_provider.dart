import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/recurring_income_model.dart';
import '../../data/models/salary_model.dart';
import '../../data/repositories/recurring_income_repository.dart';
import '../../data/repositories/salary_repository.dart';
import 'date_provider.dart';

final recurringIncomeProvider = StateNotifierProvider<RecurringIncomeNotifier, AsyncValue<List<RecurringIncomeModel>>>((ref) {
  final repository = ref.watch(recurringIncomeRepositoryProvider);
  final salaryRepository = ref.watch(salaryRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return RecurringIncomeNotifier(repository, salaryRepository, date);
});

class RecurringIncomeNotifier extends StateNotifier<AsyncValue<List<RecurringIncomeModel>>> {
  final RecurringIncomeRepository _repository;
  final SalaryRepository _salaryRepository;
  final DateTime _date;

  RecurringIncomeNotifier(this._repository, this._salaryRepository, this._date) : super(const AsyncValue.loading()) {
    loadRecurringIncomes();
  }

  Future<void> loadRecurringIncomes() async {
    try {
      state = const AsyncValue.loading();
      final incomes = await _repository.getRecurringIncomes();
      state = AsyncValue.data(incomes);
      await checkAndAddRecurringIncomes(incomes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRecurringIncome(RecurringIncomeModel income) async {
    try {
      await _repository.addRecurringIncome(income);
      await loadRecurringIncomes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateRecurringIncome(RecurringIncomeModel income) async {
    try {
      await _repository.updateRecurringIncome(income);
      await loadRecurringIncomes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteRecurringIncome(String id) async {
    try {
      await _repository.deleteRecurringIncome(id);
      await loadRecurringIncomes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> checkAndAddRecurringIncomes(List<RecurringIncomeModel> incomes) async {
    final now = DateTime.now();
    // Only auto-add for current month or past months if viewed
    // But typically we only care about current month for automation trigger
    // Let's stick to the viewed month logic if it's not in future
    if (_date.year > now.year || (_date.year == now.year && _date.month > now.month)) {
      return;
    }

    for (final income in incomes) {
      if (income.isAutoAdd) {
        final isAdded = await _repository.isIncomeAddedForMonth(income.id, _date);
        if (!isAdded) {
           // Create deterministic ID
           final newId = '${income.id}_${_date.year}_${_date.month}';
           final salary = SalaryModel(
             id: newId,
             amount: income.amount,
             date: DateTime(_date.year, _date.month, income.dayOfMonth > 28 ? 28 : income.dayOfMonth), // Simple clamp
             source: income.source,
             title: 'Recurring: ${income.source}',
           );
           await _salaryRepository.addSalary(salary);
        }
      }
    }
  }
}
