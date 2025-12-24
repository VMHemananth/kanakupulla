import '../../data/models/expense_model.dart';
import '../../data/models/salary_model.dart';

class FinancialCalculator {
  /// Calculates total expense based on "Consumption Logic".
  /// Returns the sum of amounts for all expenses that are NOT credit card bill payments.
  /// This ensures that purchases are counted when they happen, and bill payments (which duplicate the cash flow) are ignored.
  static double calculateTotalExpense(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (sum, e) {
      if (e.isCreditCardBill) return sum;
      return sum + e.amount;
    });
  }

  /// Calculates total income.
  static double calculateTotalIncome(List<SalaryModel> income) {
    return income.fold(0.0, (sum, i) => sum + i.amount);
  }

  /// Calculates net savings (Income - Expense).
  static double calculateNetSavings(double income, double expense) {
    return income - expense;
  }
}
