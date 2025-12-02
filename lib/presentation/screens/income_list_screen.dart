import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/salary_model.dart';
import '../providers/salary_provider.dart';
import '../providers/date_provider.dart';

class IncomeListScreen extends ConsumerWidget {
  const IncomeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomesAsync = ref.watch(salaryProvider);
    final date = ref.watch(selectedDateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Income - ${DateFormat('MMMM yyyy').format(date)}'),
      ),
      body: incomesAsync.when(
        data: (incomes) {
          if (incomes.isEmpty) {
            return const Center(child: Text('No income added for this month.'));
          }
          return ListView.builder(
            itemCount: incomes.length,
            itemBuilder: (context, index) {
              final income = incomes[index];
              return Dismissible(
                key: Key(income.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  ref.read(salaryProvider.notifier).deleteIncome(income.id);
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(income.source[0]),
                  ),
                  title: Text(income.source),
                  subtitle: income.title != null ? Text(income.title!) : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${income.amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref.read(salaryProvider.notifier).deleteIncome(income.id);
                        },
                      ),
                    ],
                  ),
                  onTap: () => _showAddIncomeDialog(context, ref, date, income: income),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIncomeDialog(context, ref, date),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddIncomeDialog(BuildContext context, WidgetRef ref, DateTime date, {SalaryModel? income}) {
    final amountController = TextEditingController(text: income?.amount.toString() ?? '');
    final sourceController = TextEditingController(text: income?.source ?? 'Salary');
    final titleController = TextEditingController(text: income?.title ?? '');
    final workingDaysController = TextEditingController(text: income?.workingDays?.toString() ?? '');
    final workingHoursController = TextEditingController(text: income?.workingHours?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(income == null ? 'Add Income' : 'Edit Income'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
              ),
              TextFormField(
                controller: sourceController,
                decoration: const InputDecoration(labelText: 'Source (e.g. Salary, Freelance)'),
              ),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Description (Optional)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: workingDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Working Days',
                        hintText: 'Optional',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: workingHoursController,
                      decoration: const InputDecoration(
                        labelText: 'Working Hours',
                        hintText: 'Optional',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newIncome = SalaryModel(
                  id: income?.id ?? const Uuid().v4(),
                  amount: double.parse(amountController.text),
                  date: income?.date ?? date,
                  source: sourceController.text,
                  title: titleController.text.isEmpty ? null : titleController.text,
                  workingDays: int.tryParse(workingDaysController.text),
                  workingHours: int.tryParse(workingHoursController.text),
                );
                ref.read(salaryProvider.notifier).addIncome(newIncome); // addIncome handles replace/update in repo
                Navigator.pop(ctx);
              }
            },
            child: Text(income == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}
