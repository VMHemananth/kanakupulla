import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/salary_provider.dart';
import '../screens/income_list_screen.dart';

class SalaryCard extends ConsumerWidget {
  const SalaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final salaryAsync = ref.watch(salaryProvider);

    final totalExpenses = expensesAsync.value
            ?.where((e) => e.paymentMethod != 'Credit Card' || e.isCreditCardBill)
            .fold(0.0, (sum, item) => sum! + item.amount) ?? 0.0;
    final totalIncome = salaryAsync.value?.fold(0.0, (sum, item) => sum! + item.amount) ?? 0.0;
    final balance = totalIncome - totalExpenses;
    final progress = totalIncome > 0 ? (totalExpenses / totalIncome).clamp(0.0, 1.0) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Income', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const IncomeListScreen()),
                    );
                  },
                ),
              ],
            ),
            Text('₹${totalIncome.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses: ₹${totalExpenses.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red)),
                Text('Balance: ₹${balance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], color: progress > 0.8 ? Colors.red : Colors.blue),
          ],
        ),
      ),
    );
  }
}
