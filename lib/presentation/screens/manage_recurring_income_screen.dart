import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/recurring_income_provider.dart';
import '../../data/models/recurring_income_model.dart';

class ManageRecurringIncomeScreen extends ConsumerStatefulWidget {
  const ManageRecurringIncomeScreen({super.key});

  @override
  ConsumerState<ManageRecurringIncomeScreen> createState() => _ManageRecurringIncomeScreenState();
}

class _ManageRecurringIncomeScreenState extends ConsumerState<ManageRecurringIncomeScreen> {
  @override
  Widget build(BuildContext context) {
    final recurringIncomesAsync = ref.watch(recurringIncomeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recurring Income')),
      body: recurringIncomesAsync.when(
        data: (incomes) {
          if (incomes.isEmpty) {
            return const Center(child: Text('No recurring income added'));
          }
          return ListView.builder(
            itemCount: incomes.length,
            itemBuilder: (context, index) {
              final income = incomes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(income.source, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Day: ${income.dayOfMonth} | Auto-Add: ${income.isAutoAdd ? "On" : "Off"}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('₹${income.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showAddDialog(context, income: income),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => ref.read(recurringIncomeProvider.notifier).deleteRecurringIncome(income.id),
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
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, {RecurringIncomeModel? income}) {
    final sourceController = TextEditingController(text: income?.source ?? '');
    final amountController = TextEditingController(text: income?.amount.toString() ?? '');
    final dayController = TextEditingController(text: income?.dayOfMonth.toString() ?? '1');
    bool isAutoAdd = income?.isAutoAdd ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(income == null ? 'Add Recurring Income' : 'Edit Recurring Income'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sourceController,
                    decoration: const InputDecoration(labelText: 'Source (e.g., Salary, Rent)'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: dayController,
                    decoration: const InputDecoration(labelText: 'Day of Month (1-31)'),
                    keyboardType: TextInputType.number,
                  ),
                  CheckboxListTile(
                    title: const Text('Auto-Add to Income List'),
                    value: isAutoAdd,
                    onChanged: (val) => setState(() => isAutoAdd = val ?? true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final source = sourceController.text;
                  final amount = double.tryParse(amountController.text) ?? 0;
                  final day = int.tryParse(dayController.text) ?? 1;

                  if (source.isNotEmpty && amount > 0) {
                    final newIncome = RecurringIncomeModel(
                      id: income?.id ?? const Uuid().v4(),
                      source: source,
                      amount: amount,
                      dayOfMonth: day,
                      isAutoAdd: isAutoAdd,
                    );

                    if (income == null) {
                      ref.read(recurringIncomeProvider.notifier).addRecurringIncome(newIncome);
                    } else {
                      ref.read(recurringIncomeProvider.notifier).updateRecurringIncome(newIncome);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(income == null ? 'Add' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
  }
}
