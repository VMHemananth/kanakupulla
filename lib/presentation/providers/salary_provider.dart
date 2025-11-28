import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/salary_model.dart';
import '../../data/repositories/salary_repository.dart';
import 'date_provider.dart';

final salaryProvider = StateNotifierProvider<SalaryNotifier, AsyncValue<List<SalaryModel>>>((ref) {
  final repository = ref.watch(salaryRepositoryProvider);
  final date = ref.watch(selectedDateProvider);
  return SalaryNotifier(repository, date);
});

class SalaryNotifier extends StateNotifier<AsyncValue<List<SalaryModel>>> {
  final SalaryRepository _repository;
  final DateTime _date;

  SalaryNotifier(this._repository, this._date) : super(const AsyncValue.loading()) {
    loadSalaries();
  }

  Future<void> loadSalaries() async {
    try {
      state = const AsyncValue.loading();
      final allSalaries = await _repository.getSalaries();
      // Filter by selected month/year
      final filtered = allSalaries.where((e) => 
        e.date.year == _date.year && e.date.month == _date.month
      ).toList();
      state = AsyncValue.data(filtered);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addIncome(SalaryModel income) async {
    try {
      await _repository.addSalary(income);
      await loadSalaries();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteIncome(String id) async {
    try {
      await _repository.deleteSalary(id);
      await loadSalaries();
    } catch (e) {
      // Handle error
    }
  }
}
