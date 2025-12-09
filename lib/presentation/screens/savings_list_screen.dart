import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/savings_goal_model.dart';
import '../providers/savings_provider.dart';
import 'add_goal_screen.dart';
import 'add_expense_screen.dart';

class SavingsListScreen extends ConsumerWidget {
  const SavingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.savings, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No savings goals yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddGoalScreen()),
                      );
                    },
                    child: const Text('Create Goal'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
              final percentage = (progress * 100).toStringAsFixed(1);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(goal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                if (goal.deadline != null)
                                  Text(
                                    'Target: ${DateFormat('dd MMM yyyy').format(goal.deadline!)}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.green),
                            onPressed: () => _navigateToAddExpenseForGoal(context, goal),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddGoalScreen(goal: goal),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _showDeleteDialog(context, ref, goal),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        color: progress >= 1.0 ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('₹${goal.currentAmount.toStringAsFixed(0)} saved'),
                          Text('$percentage%'),
                          Text('Target: ₹${goal.targetAmount.toStringAsFixed(0)}'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGoalScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddExpenseForGoal(BuildContext context, SavingsGoalModel goal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(initialSavingsGoalId: goal.id),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, SavingsGoalModel goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Goal?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(savingsProvider.notifier).deleteGoal(goal.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
