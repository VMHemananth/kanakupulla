import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import 'expense_list_item.dart';

class RecentExpenses extends ConsumerWidget {
  const RecentExpenses({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);

    return expensesAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'No recent transactions.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
          );
        }
        
        // Sort by date descending if not already sorted (usually provider handles it, but good to be safe)
        // expenses.sort((a, b) => b.date.compareTo(a.date)); 
        // Assuming provider returns sorted list.
        
        return ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: expenses.length > 5 ? 5 : expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index];
            return ExpenseListItem(
              expense: expense,
              onTap: () {
                 // Define navigation or details view if needed
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
