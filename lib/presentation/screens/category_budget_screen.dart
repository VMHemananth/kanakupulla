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
                final remainingAllocatable = monthlyLimit - totalAllocated;

                // Calculate spent amount per category
                final spentMap = <String, double>{};
                for (var expense in expenses) {
                  spentMap[expense.category] = (spentMap[expense.category] ?? 0) + expense.amount;
                }

                return Column(
                  children: [
                    // Summary Card - Gradient Style
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.tertiary, // Gradient from Indigo to Rose
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                           BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Monthly Income Limit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text('₹${monthlyLimit.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                child: const Icon(Icons.account_balance, color: Colors.white),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Allocated', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text('₹${totalAllocated.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Available to Allocate', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Text('₹${remainingAllocatable.toStringAsFixed(0)}', 
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16, 
                                      color: remainingAllocatable < 0 ? Theme.of(context).colorScheme.error : Colors.white
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Copy Option (if no budgets)
                    if (budgets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(categoryBudgetsProvider.notifier).copyBudgetsFromPreviousMonth();
                          }, 
                          icon: const Icon(Icons.copy, size: 16), 
                          label: Text('Copy from ${DateFormat('MMMM').format(DateTime(date.year, date.month - 1))}'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final budgetAmount = budgetMap[category.name];
                          final spentAmount = spentMap[category.name] ?? 0.0;
                          final theme = Theme.of(context);
                          
                          if (budgetAmount == null) {
                             return Container(
                               margin: const EdgeInsets.symmetric(horizontal: 16),
                               decoration: BoxDecoration(
                                 color: theme.colorScheme.surface,
                                 borderRadius: BorderRadius.circular(16),
                                 border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
                               ),
                               child: ListTile(
                                 leading: CircleAvatar(
                                   backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                   child: Icon(Icons.category_outlined, color: theme.colorScheme.onSurfaceVariant, size: 20),
                                 ),
                                 title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                 subtitle: const Text('No budget set', style: TextStyle(fontSize: 12)),
                                 trailing: TextButton(
                                   onPressed: () => _showSetBudgetDialog(context, ref, category.name, null),
                                   child: const Text('Set'),
                                 ),
                               ),
                             );
                          }

                          final progress = budgetAmount > 0 ? spentAmount / budgetAmount : (spentAmount > 0 ? 1.0 : 0.0);
                          final isOverBudget = progress > 1.0;
                          final cardColor = isOverBudget ? theme.colorScheme.errorContainer.withOpacity(0.3) : theme.colorScheme.surface;
                          final progressColor = isOverBudget ? theme.colorScheme.error : (progress > 0.8 ? Colors.orange : theme.colorScheme.primary);

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                         CircleAvatar(
                                           radius: 18,
                                           backgroundColor: theme.colorScheme.primaryContainer,
                                           child: Icon(Icons.category, color: theme.colorScheme.primary, size: 18),
                                         ),
                                         const SizedBox(width: 12),
                                         Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () => _showSetBudgetDialog(context, ref, category.name, budgetAmount),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                                        child: const Icon(Icons.edit, size: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progress > 1 ? 1 : progress,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    color: progressColor,
                                    minHeight: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Spent', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                                        Text(
                                          '₹${spentAmount.toStringAsFixed(0)}',
                                          style: TextStyle(color: progressColor, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Budget', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                                        Text(
                                          '₹${budgetAmount.toStringAsFixed(0)}',
                                          style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (isOverBudget)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.warning_amber_rounded, size: 16, color: theme.colorScheme.error),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Exceeded by ₹${(spentAmount - budgetAmount).toStringAsFixed(0)}',
                                            style: TextStyle(color: theme.colorScheme.error, fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
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
