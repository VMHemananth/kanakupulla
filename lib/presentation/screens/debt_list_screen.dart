import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/expense_model.dart';
import '../providers/debt_provider.dart';
import '../providers/expense_provider.dart';
import 'add_debt_screen.dart';
import 'loan_details_screen.dart';

class DebtListScreen extends ConsumerWidget {
  const DebtListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Debts & Loans'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Lent (Owes Me)'),
              Tab(text: 'Borrowed (I Owe)'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DebtTab(type: 'Lent'),
            DebtTab(type: 'Borrowed'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddDebtScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class DebtTab extends ConsumerWidget {
  final String type;

  const DebtTab({super.key, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtProvider);

    return debtsAsync.when(
      data: (debts) {
        final filteredDebts = debts.where((d) => d.type == type).toList();
        final totalAmount = filteredDebts
            .where((d) => !d.isSettled)
            .fold(0.0, (sum, d) => sum + d.amount);

        return Column(
          children: [
            // Summary Card
            Card(
              margin: const EdgeInsets.all(16),
              color: type == 'Lent' ? Colors.green[100] : Colors.red[100],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      type == 'Lent' ? 'Total to Receive' : 'Total to Pay',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '₹${totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: type == 'Lent' ? Colors.green[800] : Colors.red[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: filteredDebts.isEmpty
                  ? const Center(child: Text('No records found'))
                  : ListView.builder(
                      itemCount: filteredDebts.length,
                      itemBuilder: (context, index) {
                        final debt = filteredDebts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: debt.isSettled ? Colors.grey : (type == 'Lent' ? Colors.green : Colors.red),
                            child: Icon(
                              debt.isSettled ? Icons.check : (type == 'Lent' ? Icons.arrow_upward : Icons.arrow_downward),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(debt.personName, style: TextStyle(decoration: debt.isSettled ? TextDecoration.lineThrough : null)),
                          subtitle: Text(
                            '${DateFormat('dd MMM').format(debt.date)}${debt.dueDate != null ? ' • Due: ${DateFormat('dd MMM').format(debt.dueDate!)}' : ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '₹${debt.amount.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      decoration: debt.isSettled ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  if (!debt.isSettled)
                                    Text(
                                      'Tap to Pay/Edit',
                                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AddDebtScreen(debt: debt)),
                                    );
                                  } else if (value == 'pay') {
                                    _showPayEmiDialog(context, ref, debt);
                                  } else if (value == 'settle') {
                                    _showSettleDialog(context, ref, debt);
                                  } else if (value == 'delete') {
                                    _showDeleteDialog(context, ref, debt);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  if (debt.isSettled) {
                                    return <PopupMenuEntry<String>>[
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
                                    ];
                                  }
                                  return <PopupMenuEntry<String>>[
                                    const PopupMenuItem<String>(
                                      value: 'pay',
                                      child: Row(
                                        children: [
                                          Icon(Icons.payment, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text('Pay EMI / Reduce'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, color: Colors.orange),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'settle',
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Mark Settled'),
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
                                  ];
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => LoanDetailsScreen(debt: debt)),
                             );
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  void _showPayEmiDialog(BuildContext context, WidgetRef ref, DebtModel debt) {
    final amountController = TextEditingController();
    bool addToExpenses = true; // Default to true for Borrowed (paying back is an expense usually? Or just transfer?)
    // Actually, paying back a loan is a transfer, but users might want to track it.
    // Let's default to false to avoid double counting if they already track it manually.
    // Or better, ask them.

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(debt.type == 'Lent' ? 'Receive Payment' : 'Pay EMI / Reduce Principal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Current Balance: ₹${debt.amount.toStringAsFixed(2)}'),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Only show "Add to Expenses" if it's a loan we are paying back
                if (debt.type == 'Borrowed')
                  CheckboxListTile(
                    title: const Text('Record as Expense?'),
                    subtitle: const Text('Add this payment to your daily expenses'),
                    value: addToExpenses,
                    onChanged: (val) => setState(() => addToExpenses = val ?? false),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountController.text);
                  if (amount != null && amount > 0) {
                    if (amount > debt.amount) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount cannot exceed current balance')));
                      return;
                    }

                    final newAmount = debt.amount - amount;
                    final updatedDebt = debt.copyWith(
                      amount: newAmount,
                      isSettled: newAmount <= 0,
                    );
                    
                    ref.read(debtProvider.notifier).updateDebt(updatedDebt);

                    if (addToExpenses && debt.type == 'Borrowed') {
                      // Add to expenses logic here (requires importing expense provider and model)
                      // For now, we'll just show a message that it's not fully linked yet or link it if imports allow.
                      // Let's link it properly.
                      _addExpense(ref, amount, debt.personName);
                    }

                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _addExpense(WidgetRef ref, double amount, String personName) {
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      title: 'Loan Repayment: $personName (Partial)',
      amount: amount,
      date: DateTime.now(),
      category: 'Debt Repayment',
      paymentMethod: 'Cash', // Default, could be improved
    );
    ref.read(expensesProvider.notifier).addExpense(expense);
  }

  void _showSettleDialog(BuildContext context, WidgetRef ref, DebtModel debt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Settled?'),
        content: Text('Did ${debt.personName} ${debt.type == 'Lent' ? 'return' : 'receive'} the full amount?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final updatedDebt = debt.copyWith(isSettled: true);
              ref.read(debtProvider.notifier).updateDebt(updatedDebt);
              Navigator.pop(ctx);
            },
            child: const Text('Yes, Settled'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, DebtModel debt) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Record?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(debtProvider.notifier).deleteDebt(debt.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
