import 'package:flutter/material.dart';
import 'models.dart';

class ExpenseListScreen extends StatelessWidget {
  final List<Expense> expenses;
  final User user;
  final double currentMonthSalary;
  final void Function(String) onEdit;
  final void Function(String) onDelete;

  const ExpenseListScreen({
    Key? key,
    required this.expenses,
    required this.user,
    required this.currentMonthSalary,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Expenses')),
      body: expenses.isEmpty
          ? const Center(child: Text('No expenses yet.'))
          : ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final totalHours = user.workingDaysPerMonth * user.workingHoursPerDay;
                final salary = currentMonthSalary > 0 ? currentMonthSalary : 1;
                final timeSpentHours = expense.amount / salary * totalHours;
                final timeSpentStr = timeSpentHours < 1
                    ? '${(timeSpentHours * 60).toStringAsFixed(0)} min'
                    : '${timeSpentHours.toStringAsFixed(1)} hr';
                return Card(
                  child: ListTile(
                    title: Text(expense.title),
                    subtitle: Text('${expense.category} • ${expense.date.toLocal().toString().split(' ')[0]}\nTime spent for this: $timeSpentStr'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('₹${expense.amount.toStringAsFixed(2)}'),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => onEdit(expense.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => onDelete(expense.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
