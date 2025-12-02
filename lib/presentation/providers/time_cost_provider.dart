import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/salary_repository.dart';
import 'user_provider.dart';

final timeCostProvider = Provider((ref) {
  final salaryRepo = ref.watch(salaryRepositoryProvider);
  final user = ref.watch(userProvider);
  
  return TimeCostService(salaryRepo, user.workingDaysPerMonth, user.workingHoursPerDay);
});

class TimeCostService {
  final SalaryRepository _salaryRepository;
  final int _workingDays;
  final int _workingHours;

  TimeCostService(this._salaryRepository, this._workingDays, this._workingHours);

  Future<String> calculateTimeCost(ExpenseModel expense) async {
    try {
      final allSalaries = await _salaryRepository.getSalaries();
      
      // Filter salaries for the expense's month and year
      final monthlySalaries = allSalaries.where((s) => 
        s.date.year == expense.date.year && s.date.month == expense.date.month
      ).toList();

      if (monthlySalaries.isEmpty) return '';

      final totalIncome = monthlySalaries.fold(0.0, (sum, s) => sum + s.amount);
      
      if (totalIncome <= 0) return '';

      // Determine working days and hours for this month
      // Strategy: If any salary entry has working days/hours, use the first one found.
      // Otherwise, fall back to global user settings.
      int workingDays = _workingDays;
      int workingHours = _workingHours;

      for (var s in monthlySalaries) {
        if (s.workingDays != null && s.workingDays! > 0) {
          workingDays = s.workingDays!;
        }
        if (s.workingHours != null && s.workingHours! > 0) {
          workingHours = s.workingHours!;
        }
        // If we found both, break (or just prioritize the last one? Let's stick to "any valid value overrides default")
        if (s.workingDays != null && s.workingHours != null) break;
      }

      final totalWorkingHours = workingDays * workingHours;
      if (totalWorkingHours <= 0) return '';

      final hourlyRate = totalIncome / totalWorkingHours;
      
      final hoursNeeded = expense.amount / hourlyRate;
      
      return _formatDuration(hoursNeeded);
    } catch (e) {
      return '';
    }
  }

  String _formatDuration(double totalHours) {
    final int hours = totalHours.floor();
    final int minutes = ((totalHours - hours) * 60).round();
    
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }
}
