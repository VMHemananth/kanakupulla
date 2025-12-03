import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/fixed_expense_model.dart';
import '../../data/services/notification_service.dart';
import '../providers/fixed_expense_provider.dart';
import '../providers/category_provider.dart';

class ManageFixedExpensesScreen extends ConsumerWidget {
  const ManageFixedExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fixedExpensesAsync = ref.watch(fixedExpensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fixed Expenses')),
      body: fixedExpensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) {
            return const Center(child: Text('No fixed expenses added yet.'));
          }
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                title: Text(expense.title),
                subtitle: Text('${expense.category} • Day ${expense.dayOfMonth}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹${expense.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showAddDialog(context, ref, expense: expense),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(fixedExpensesProvider.notifier).deleteFixedExpense(expense.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, {FixedExpenseModel? expense}) {
    final titleController = TextEditingController(text: expense?.title ?? '');
    final amountController = TextEditingController(text: expense?.amount.toString() ?? '');
    final dayController = TextEditingController(text: expense?.dayOfMonth.toString() ?? '');
    String? selectedCategory = expense?.category;
    bool isAutoAdd = expense?.isAutoAdd ?? true; // Default to true

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final categoriesAsync = ref.watch(categoryProvider);
          final categories = categoriesAsync.value?.map((e) => e.name).toList() ?? [];

          return AlertDialog(
            title: Text(expense == null ? 'Add Fixed Expense' : 'Edit Fixed Expense'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title (e.g. Rent)'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) => setState(() => selectedCategory = val),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: dayController,
                    decoration: const InputDecoration(labelText: 'Day of Month (1-31)'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Auto-add to monthly expenses'),
                    value: isAutoAdd,
                    onChanged: (val) => setState(() => isAutoAdd = val ?? true),
                  ),
                  CheckboxListTile(
                    title: const Text('Remind me 1 day before'),
                    value: true, // TODO: Store this in model if needed, for now default true or just a one-time trigger
                    onChanged: (val) {}, // Placeholder for now
                    subtitle: const Text('Notification at 10 AM on the day before'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  final day = int.tryParse(dayController.text);

                  if (titleController.text.isNotEmpty && 
                      amount != null && amount > 0 &&
                      selectedCategory != null &&
                      day != null && day >= 1 && day <= 31) {
                    
                    final newExpense = FixedExpenseModel(
                      id: expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text,
                      amount: amount,
                      category: selectedCategory!,
                      dayOfMonth: day,
                      isAutoAdd: isAutoAdd,
                    );
                    
                    if (expense == null) {
                      ref.read(fixedExpensesProvider.notifier).addFixedExpense(newExpense);
                    } else {
                      ref.read(fixedExpensesProvider.notifier).updateFixedExpense(newExpense);
                    }

                    // Schedule notification
                    final reminderDay = day > 1 ? day - 1 : 1; // Simple logic: remind 1 day before
                    ref.read(notificationServiceProvider).scheduleMonthlyNotification(
                      id: newExpense.id.hashCode,
                      title: 'Bill Reminder: ${newExpense.title}',
                      body: 'Your fixed expense of ₹${newExpense.amount} is due tomorrow.',
                      dayOfMonth: reminderDay,
                    );

                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter valid details (Amount > 0, Day 1-31)')),
                    );
                  }
                },
                child: Text(expense == null ? 'Add' : 'Update'),
              ),
            ],
          );
        }
      ),
    );
  }
}
