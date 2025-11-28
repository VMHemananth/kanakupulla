import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';

class CategoryBudgetScreen extends ConsumerWidget {
  const CategoryBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);
    final budgetsAsync = ref.watch(categoryBudgetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Category Budgets')),
      body: categoriesAsync.when(
        data: (categories) {
          return budgetsAsync.when(
            data: (budgets) {
              // Create a map of category -> budget amount
              final budgetMap = {for (var b in budgets) b.category!: b.amount};

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final currentBudget = budgetMap[category.name];

                  return ListTile(
                    title: Text(category.name),
                    subtitle: Text(currentBudget != null 
                      ? 'Budget: ₹${currentBudget.toStringAsFixed(0)}' 
                      : 'No budget set'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showSetBudgetDialog(context, ref, category.name, currentBudget),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref, String category, double? currentAmount) {
    final controller = TextEditingController(text: currentAmount?.toString() ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Budget for $category'),
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
                ref.read(categoryBudgetsProvider.notifier).setCategoryBudget(category, amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
