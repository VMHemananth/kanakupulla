import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/savings_goal_model.dart';
import '../providers/expense_provider.dart';

class SavingsHistoryScreen extends ConsumerWidget {
  final SavingsGoalModel goal;

  const SavingsHistoryScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allExpensesAsync = ref.watch(allExpensesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('${goal.name} History')),
      body: allExpensesAsync.when(
        data: (expenses) {
          final history = expenses.where((e) => e.savingsGoalId == goal.id).toList();
          history.sort((a, b) => b.date.compareTo(a.date)); // Newest first

          if (history.isEmpty) {
             return const Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Icon(Icons.history, size: 64, color: Colors.grey),
                   SizedBox(height: 16),
                   Text('No deposits yet'),
                 ],
               ),
             );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final expense = history[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward, color: Colors.green),
                ),
                title: Text('Added ₹${expense.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormat('dd MMM yyyy, hh:mm a').format(expense.date)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Undo Deposit',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Undo Deposit?'),
                        content: Text('Remove ₹${expense.amount.toStringAsFixed(0)} from goal and delete this record?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              ref.read(expensesProvider.notifier).deleteExpense(expense.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Undo', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
