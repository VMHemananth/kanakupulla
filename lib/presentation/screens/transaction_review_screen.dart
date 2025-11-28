import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/sms_service.dart';
import '../providers/sms_provider.dart';
import '../providers/expense_provider.dart';

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
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: ['Food', 'Transport', 'Shopping', 'Bills', 'Others']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => selectedCategory = v!,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final expense = ExpenseModel(
                id: const Uuid().v4(),
                title: titleController.text,
                amount: double.parse(amountController.text),
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
