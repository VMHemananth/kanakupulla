import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart'; 
import '../providers/date_provider.dart';
import '../providers/salary_provider.dart';
import '../../data/models/expense_model.dart';

class CategoryBudgetScreen extends StatelessWidget {
  const CategoryBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Category Budgets')),
      body: const CategoryBudgetListWidget(),
    );
  }
}

class CategoryBudgetListWidget extends ConsumerWidget {
  const CategoryBudgetListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);
    final budgetsAsync = ref.watch(categoryBudgetsProvider);
    final expensesAsync = ref.watch(expensesProvider);

    final monthlyBudgetAsync = ref.watch(budgetProvider);
    final date = ref.watch(selectedDateProvider);

    return categoriesAsync.when(
      data: (categories) {
        return budgetsAsync.when(
          data: (budgets) {
            return expensesAsync.when(
              data: (expenses) {
                 // Create a map of category -> budget amount
                final budgetMap = {for (var b in budgets) b.category!: b.amount};
                
                // Calculate allocated total
                final totalAllocated = budgets.fold(0.0, (sum, b) => sum + b.amount);
                final monthlyLimit = monthlyBudgetAsync.value?.amount ?? 0.0;
                final isOverAllocated = totalAllocated > monthlyLimit;

                // Calculate spent amount per category
                final spentMap = <String, double>{};
                for (var expense in expenses) {
                  spentMap[expense.category] = (spentMap[expense.category] ?? 0) + expense.amount;
                }

                return Column(
                  children: [
                    // Summary Card
                    Card(
                      margin: const EdgeInsets.all(16),
                      color: isOverAllocated ? Colors.red[50] : Colors.blue[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Monthly Limit', style: TextStyle(color: Colors.grey)),
                                    Text('₹${monthlyLimit.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Total Allocated', style: TextStyle(color: Colors.grey)),
                                    Text(
                                      '₹${totalAllocated.toStringAsFixed(0)}', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 18,
                                        color: isOverAllocated ? Colors.red : Colors.black,
                                      )
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (isOverAllocated && monthlyLimit > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Allocated budget exceeds monthly limit by ₹${(totalAllocated - monthlyLimit).toStringAsFixed(0)}',
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Copy Option (if no budgets)
                    if (budgets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await ref.read(categoryBudgetsProvider.notifier).copyBudgetsFromPreviousMonth();
                          }, 
                          icon: const Icon(Icons.copy), 
                          label: Text('Copy Budgets from ${DateFormat('MMMM').format(DateTime(date.year, date.month - 1))}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple[50],
                            foregroundColor: Colors.purple,
                            minimumSize: const Size(double.infinity, 45),
                          ),
                        ),
                      ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final budgetAmount = budgetMap[category.name];
                          final spentAmount = spentMap[category.name] ?? 0.0;
                          
                          if (budgetAmount == null) {
                             return ListTile(
                              leading: CircleAvatar(child: Text(category.name[0])),
                              title: Text(category.name),
                              subtitle: const Text('No budget set'),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showSetBudgetDialog(context, ref, category.name, null),
                              ),
                            );
                          }

                          final progress = budgetAmount > 0 ? spentAmount / budgetAmount : (spentAmount > 0 ? 1.0 : 0.0);
                          final isOverBudget = progress > 1.0;
                          final color = isOverBudget ? Colors.red : (progress > 0.8 ? Colors.orange : Colors.green);

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                           CircleAvatar(
                                             backgroundColor: color.withOpacity(0.1),
                                             child: Icon(Icons.category, color: color, size: 20),
                                           ),
                                           const SizedBox(width: 12),
                                           Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        onPressed: () => _showSetBudgetDialog(context, ref, category.name, budgetAmount),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  LinearProgressIndicator(
                                    value: progress > 1 ? 1 : progress,
                                    backgroundColor: Colors.grey[200],
                                    color: color,
                                    minHeight: 10,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Spent: ₹${spentAmount.toStringAsFixed(0)}',
                                        style: TextStyle(color: color, fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Budget: ₹${budgetAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                  if (isOverBudget)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Over Budget by ₹${(spentAmount - budgetAmount).toStringAsFixed(0)}',
                                        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading expenses: $e')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading budgets: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading categories: $e')),
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
                // Validation: Check against Total Income
                final incomeList = ref.read(salaryProvider).value ?? [];
                final totalIncome = incomeList.fold(0.0, (sum, e) => sum + e.amount);

                if (totalIncome == 0) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add income before setting a budget.')),
                  );
                  return;
                }

                // Check Category Sum Validation
                final currentBudgets = ref.read(categoryBudgetsProvider).value ?? [];
                // Exclude current category from sum if it exists, then add new amount
                double otherCategoriesSum = 0;
                for (var b in currentBudgets) {
                  if (b.category != category) {
                    otherCategoriesSum += b.amount;
                  }
                }
                final projectedTotal = otherCategoriesSum + amount;

                if (projectedTotal > totalIncome) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Total category budgets (₹${projectedTotal.toStringAsFixed(0)}) cannot exceed Total Income (₹${totalIncome.toStringAsFixed(0)})')),
                  );
                  return;
                }

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
