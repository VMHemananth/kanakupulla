import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/sms_service.dart';
import '../providers/sms_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../../data/models/category_model.dart';

class TransactionReviewScreen extends ConsumerWidget {
  const TransactionReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(smsTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Transactions')),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return const Center(child: Text('No new transactions found.'));
          }
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final txn = transactions[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.message, color: Colors.blue),
                  title: Text(txn.merchant ?? 'Unknown Merchant'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('MMM d, yyyy - h:mm a').format(txn.date)),
                      Text(txn.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('₹${txn.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () => _addExpense(context, ref, txn),
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
    );
  }

  void _addExpense(BuildContext context, WidgetRef ref, TransactionCandidate txn) {
    // Pre-fill add expense dialog/screen
    final titleController = TextEditingController(text: txn.merchant ?? 'Expense');
    final amountController = TextEditingController(text: txn.amount.toString());
    String selectedCategory = 'Others';
    String selectedPaymentMethod = 'Online';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Expense'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
            // Simplified category selection for now
            // Dynamic category selection
            Consumer(
              builder: (context, ref, _) {
                final categoriesAsync = ref.watch(categoryProvider);
                return categoriesAsync.when(
                  data: (categories) {
                    // Update selectedCategory if not in list (or default to first available)
                    if (categories.isNotEmpty && !categories.any((c) => c.name == selectedCategory)) {
                       // Try to find 'Others' or fallback to first
                       final hasOthers = categories.any((c) => c.name == 'Others');
                       selectedCategory = hasOthers ? 'Others' : categories.first.name;
                    }
                    
                    return DropdownButtonFormField<String>(
                      value: categories.any((c) => c.name == selectedCategory) ? selectedCategory : null,
                      items: categories.map((c) => DropdownMenuItem(value: c.name, child: Text(c.name))).toList(),
                      onChanged: (v) {
                        if (v != null) selectedCategory = v;
                      },
                      decoration: const InputDecoration(labelText: 'Category'),
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading categories: $e'),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount == null) return;

              final expense = ExpenseModel(
                id: const Uuid().v4(),
                title: titleController.text,
                amount: amount,
                date: txn.date,
                category: selectedCategory,
                paymentMethod: selectedPaymentMethod,
              );
              ref.read(expensesProvider.notifier).addExpense(expense);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense Added')));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
