import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/services/pdf_service.dart';
import '../../data/models/debt_model.dart';
import '../../data/models/expense_model.dart';
import '../providers/debt_provider.dart';
import '../providers/expense_provider.dart';
import 'add_debt_screen.dart';
import 'loan_details_screen.dart';

class DebtListScreen extends ConsumerWidget {
  const DebtListScreen({super.key});
  
  // ... build method same ...
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

  bool _isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    // Compare dates only
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.isBefore(today);
  }

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
                        final isOverdue = !debt.isSettled && _isOverdue(debt.dueDate);

                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: isOverdue 
                             ? RoundedRectangleBorder(side: const BorderSide(color: Colors.red, width: 2), borderRadius: BorderRadius.circular(12)) 
                             : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: debt.isSettled ? Colors.grey : (type == 'Lent' ? Colors.green : Colors.red),
                              child: Icon(
                                debt.isSettled ? Icons.check : (type == 'Lent' ? Icons.arrow_upward : Icons.arrow_downward),
                                color: Colors.white,
                              ),
                            ),
                            title: Text(debt.personName, style: TextStyle(decoration: debt.isSettled ? TextDecoration.lineThrough : null)),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${DateFormat('dd MMM').format(debt.date)}${debt.dueDate != null ? ' • Due: ${DateFormat('dd MMM').format(debt.dueDate!)}' : ''}'),
                                  if (isOverdue)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'Overdue by ${DateTime.now().difference(debt.dueDate!).inDays} days',
                                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                  
                                  // Payoff Progress Bar
                                  Builder(
                                    builder: (context) {
                                      // Calculate progress
                                      // If principalAmount is stored, use it. Else roughly estimate Total = Amount + Paid.
                                      // Note: Amount is "Outstanding". 
                                      double totalPaid = debt.payments.fold(0.0, (sum, p) => sum + p.amount);
                                      double currentOutstanding = debt.amount;
                                      
                                      // Total Loan Value
                                      double totalValue = (debt.principalAmount > 0) ? debt.principalAmount : (currentOutstanding + totalPaid);
                                      
                                      // If no payments yet and principal not set, effectively 0 progress
                                      if (totalValue <= 0) totalValue = currentOutstanding; 
                                      if (totalValue <= 0) return const SizedBox.shrink(); // Should not happen for valid debt

                                      double progress = (totalPaid / totalValue).clamp(0.0, 1.0);
                                      
                                      // If it's a simple debt without payments tracking, and just edited amount? 
                                      // The complexity of tracking "Paid via edit" vs "Paid via Payment" exists.
                                      // But let's assume standard flow uses Payments.
                                      // If progress is 0, maybe hide? No, show empty bar to encourage payment.
                                      
                                      Color progressColor = type == 'Lent' ? Colors.green : Colors.orange;
                                      
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(4),
                                              child: LinearProgressIndicator(
                                                value: progress,
                                                backgroundColor: Colors.grey[200],
                                                color: progressColor,
                                                minHeight: 6,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Paid: ${(progress * 100).toStringAsFixed(0)}% • Remaining: ₹${currentOutstanding.toStringAsFixed(0)}',
                                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                  ),
                                ],
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
                                  onSelected: (value) async {
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
                                    } else if (value == 'share_msg') {
                                      _shareReminder(debt);
                                    } else if (value == 'share_pdf') {
                                      await PdfService().generateDebtStatement(debt);
                                    }
                                  },
                                  itemBuilder: (BuildContext context) {
                                    final List<PopupMenuItem<String>> items = [];
                                    
                                    if (!debt.isSettled && type == 'Lent') {
                                       items.add(const PopupMenuItem<String>(
                                          value: 'share_msg',
                                          child: Row(
                                            children: [
                                              Icon(Icons.share, color: Colors.green),
                                              SizedBox(width: 8),
                                              Text('WhatsApp / Share Reminder'),
                                            ],
                                          ),
                                        ));
                                    }

                                    items.add(const PopupMenuItem<String>(
                                      value: 'share_pdf',
                                      child: Row(
                                        children: [
                                          Icon(Icons.picture_as_pdf, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Generate Statement'),
                                        ],
                                      ),
                                    ));

                                    if (debt.isSettled) {
                                      items.add(const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ));
                                    } else {
                                      items.addAll([
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
                                      ]);
                                    }
                                    return items;
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
                          ),
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

  void _shareReminder(DebtModel debt) {
    if (debt.isSettled) return;
    
    String msg = "Hi ${debt.personName}, just a gentle reminder that the amount of ₹${debt.amount.toStringAsFixed(0)}";
    if (debt.dueDate != null) {
      msg += " was due on ${DateFormat('dd MMM').format(debt.dueDate!)}";
    }
    msg += ". Please let me know when you can transfer it. Thanks!";
    
    Share.share(msg);
  }

  // ... dialog methods same ...
  void _showPayEmiDialog(BuildContext context, WidgetRef ref, DebtModel debt) {
    // ... [existing implementation] ...
    final amountController = TextEditingController();
    bool addToExpenses = true;

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
                    
                    // Create payment record
                    final payment = LoanPayment(
                      id: const Uuid().v4(),
                      amount: amount,
                      date: DateTime.now(),
                      principalComponent: amount, // Assuming all is principal for simplicity in this dialog
                      interestComponent: 0,
                    );

                    final updatedDebt = debt.copyWith(
                      amount: newAmount,
                      isSettled: newAmount <= 0,
                      payments: [...debt.payments, payment], // Add payment to history
                    );
                    
                    ref.read(debtProvider.notifier).updateDebt(updatedDebt);

                    if (addToExpenses && debt.type == 'Borrowed') {
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

  // ... _addExpense, _showSettleDialog, _showDeleteDialog same ...
  void _addExpense(WidgetRef ref, double amount, String personName) {
    final expense = ExpenseModel(
      id: const Uuid().v4(),
      title: 'Loan Repayment: $personName (Partial)',
      amount: amount,
      date: DateTime.now(),
      category: 'Debt Repayment',
      paymentMethod: 'Cash', 
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
               // Update amount to 0 when settled manually for consistency? 
               // Or just keep the last known amount? Often better to zero it out so math works.
              final updatedDebt = debt.copyWith(isSettled: true, amount: 0);
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
