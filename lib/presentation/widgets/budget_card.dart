import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';

class BudgetCard extends ConsumerWidget {
  const BudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetProvider);
    final expensesAsync = ref.watch(expensesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: budgetAsync.when(
          data: (budget) {
            final budgetAmount = budget?.amount ?? 0;
            return expensesAsync.when(
              data: (expenses) {
                final totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);
                final progress = budgetAmount > 0 ? (totalExpense / budgetAmount).clamp(0.0, 1.0) : 0.0;
                
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monthly Budget', style: TextStyle(fontWeight: FontWeight.bold)),
                        if (budgetAmount > 0)
                          Text('${(progress * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                      color: progress > 1.0 ? Colors.red : Colors.blueAccent,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budget: ₹${budgetAmount.toStringAsFixed(0)}'),
                        Text('Spent: ₹${totalExpense.toStringAsFixed(0)}'),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error loading budget: $e'),
        ),
      ),
    );
  }
}
