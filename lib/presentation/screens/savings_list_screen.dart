import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import '../../data/models/savings_goal_model.dart';
import '../providers/savings_provider.dart';
import 'add_goal_screen.dart';
import 'add_expense_screen.dart';
import 'savings_history_screen.dart';

class SavingsListScreen extends ConsumerStatefulWidget {
  const SavingsListScreen({super.key});

  @override
  ConsumerState<SavingsListScreen> createState() => _SavingsListScreenState();
}

class _SavingsListScreenState extends ConsumerState<SavingsListScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalsAsync = ref.watch(savingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          goalsAsync.when(
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
                  
                  // Smart Insight Logic
                  String? insightText;
                  if (goal.deadline != null && goal.currentAmount < goal.targetAmount) {
                    final now = DateTime.now();
                    final daysLeft = goal.deadline!.difference(now).inDays;
                    final amountNeeded = goal.targetAmount - goal.currentAmount;
                    
                    if (daysLeft > 0) {
                       final daily = amountNeeded / daysLeft;
                       if (daysLeft > 60) {
                         final months = (daysLeft / 30).ceil();
                         final monthly = amountNeeded / months;
                         insightText = "💡 Save ₹${monthly.toStringAsFixed(0)}/month to reach on time";
                       } else {
                         insightText = "⚡ Save ₹${daily.toStringAsFixed(0)}/day to reach on time";
                       }
                    } else if (daysLeft <= 0) {
                       insightText = "⚠️ Deadline passed!";
                    }
                  }

                  // Visual Identity
                  final goalColor = goal.color != null ? Color(goal.color!) : Colors.blue;
                  final goalIcon = goal.icon != null ? IconData(int.parse(goal.icon!), fontFamily: 'MaterialIcons') : Icons.savings;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: goalColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(goalIcon, color: goalColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(goal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    if (goal.deadline != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Target: ${DateFormat('dd MMM yyyy').format(goal.deadline!)}',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'edit') {
                                     Navigator.push(context, MaterialPageRoute(builder: (_) => AddGoalScreen(goal: goal)));
                                  } else if (val == 'history') {
                                     Navigator.push(context, MaterialPageRoute(builder: (_) => SavingsHistoryScreen(goal: goal)));
                                  } else if (val == 'delete') {
                                     _showDeleteDialog(context, ref, goal);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(value: 'history', child: Text('View History')),
                                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Center(
                             child: Text(
                               '₹${goal.currentAmount.toStringAsFixed(0)} / ₹${goal.targetAmount.toStringAsFixed(0)}',
                               style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                             )
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 12,
                            backgroundColor: Colors.grey[200],
                            color: progress >= 1.0 ? Colors.green : goalColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                           const SizedBox(height: 8),
                           Center(
                             child: Text('$percentage%', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold))
                          ),
                          
                          if (insightText != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: goalColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: goalColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(child: Text(insightText, style: TextStyle(color: goalColor, fontWeight: FontWeight.w600))),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _navigateToAddExpenseForGoal(context, goal),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Money'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Theme.of(context).primaryColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
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
          
          // Confetti Overlay
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
          ),
        ],
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

  void _navigateToAddExpenseForGoal(BuildContext context, SavingsGoalModel goal) async {
    final preProgress = (goal.currentAmount / goal.targetAmount);
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(initialSavingsGoalId: goal.id),
      ),
    );
    
    // Check if we need to celebrate
    final updatedGoals = ref.read(savingsProvider).value ?? [];
    try {
      final updatedGoal = updatedGoals.firstWhere((g) => g.id == goal.id);
      final postProgress = (updatedGoal.currentAmount / updatedGoal.targetAmount);
      
      if (preProgress < 1.0 && postProgress >= 1.0) {
        _confettiController.play();
        if (mounted) {
           showDialog(
             context: context, 
             builder: (_) => AlertDialog(
               title: const Text('🎉 Goal Reached!'),
               content: Text('Congratulations! You have reached your target for ${goal.name}.'),
               actions: [
                 TextButton(onPressed: () => Navigator.pop(context), child: const Text('Awesome!'))
               ],
             )
           );
        }
      }
    } catch (e) {
      // Goal not found or other error
    }
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
