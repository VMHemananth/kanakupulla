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
                final remaining = budgetAmount - totalExpense;
                
                // Calculate daily limit
                final now = DateTime.now();
                final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
                final daysRemaining = daysInMonth - now.day + 1; // Including today
                final dailyLimit = daysRemaining > 0 ? (remaining / daysRemaining) : 0.0;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Monthly Budget', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            if (budgetAmount > 0)
                              Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => _showEditBudgetDialog(context, ref, budgetAmount),
                            ),
                          ],
                        ),
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
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Budget: ₹${budgetAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text('Spent: ₹${totalExpense.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Remaining: ₹${remaining.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: remaining < 0 ? Colors.red : Colors.green,
                              ),
                            ),
                            if (remaining > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Daily Limit: ₹${dailyLimit.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                              ),
                            ],
                          ],
                        ),
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

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref, double currentAmount) {
    final controller = TextEditingController(text: currentAmount > 0 ? currentAmount.toStringAsFixed(0) : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Monthly Budget'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null) {
                ref.read(budgetProvider.notifier).setBudget(amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
