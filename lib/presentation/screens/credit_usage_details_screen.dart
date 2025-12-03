import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/credit_card_provider.dart';

import '../../data/models/expense_model.dart';
import '../../data/models/credit_card_model.dart';
import 'add_expense_screen.dart';

class CreditUsageDetailsScreen extends ConsumerWidget {
  const CreditUsageDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final creditCardsAsync = ref.watch(creditCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Usage Details'),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          return creditCardsAsync.when(
            data: (creditCards) {
              // Filter credit card expenses for the current month (already filtered by provider)
              // that are NOT bills
              final ccExpenses = expenses.where(
                (e) => e.paymentMethod == 'Credit Card' && !e.isCreditCardBill
              ).toList();

              if (ccExpenses.isEmpty) {
                return const Center(child: Text('No credit card usage this month'));
              }

              // Group by Credit Card ID
              final groupedExpenses = <String, List<ExpenseModel>>{};
              for (var expense in ccExpenses) {
                final cardId = expense.creditCardId ?? 'Unassigned';
                if (!groupedExpenses.containsKey(cardId)) {
                  groupedExpenses[cardId] = [];
                }
                groupedExpenses[cardId]!.add(expense);
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedExpenses.length,
                itemBuilder: (context, index) {
                  final cardId = groupedExpenses.keys.elementAt(index);
                  final cardExpenses = groupedExpenses[cardId]!;
                  final totalAmount = cardExpenses.fold(0.0, (sum, ExpenseModel e) => sum + e.amount);
                  
                  String cardName = 'Unassigned';
                  if (cardId != 'Unassigned') {
                    final card = creditCards.firstWhere(
                      (c) => c.id == cardId,
                      orElse: () => const CreditCardModel(id: '', name: 'Unknown Card', billingDay: 1, lastBillGeneratedMonth: ''),
                    );
                    cardName = card.name;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: ExpansionTile(
                      title: Text(
                        cardName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Total: ₹${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                      ),
                      children: cardExpenses.map<Widget>((ExpenseModel expense) {
                        return ListTile(
                          title: Text(expense.title),
                          subtitle: Text(DateFormat('MMM d, yyyy').format(expense.date)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddExpenseScreen(expense: expense),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    _confirmDeleteExpense(context, ref, expense);
                                  }
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading cards: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading expenses: $e')),
      ),
    );
  }
  void _confirmDeleteExpense(BuildContext context, WidgetRef ref, ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense?'),
        content: Text('Are you sure you want to delete "${expense.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(expensesProvider.notifier).deleteExpense(expense.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
