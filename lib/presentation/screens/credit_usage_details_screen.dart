import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/date_provider.dart';
import '../providers/credit_card_provider.dart';

import '../../data/models/expense_model.dart';
import '../../data/models/credit_card_model.dart';
import 'add_expense_screen.dart';

class CreditUsageDetailsScreen extends ConsumerStatefulWidget {
  const CreditUsageDetailsScreen({super.key});

  @override
  ConsumerState<CreditUsageDetailsScreen> createState() => _CreditUsageDetailsScreenState();
}

class _CreditUsageDetailsScreenState extends ConsumerState<CreditUsageDetailsScreen> {
  // Store selected expense IDs for manual billing
  final Set<String> _selectedExpenseIds = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    // Use allExpensesProvider to get raw data (including filtered CC expenses)
    final expensesAsync = ref.watch(allExpensesProvider);
    final creditCardsAsync = ref.watch(creditCardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Usage Details'),
        actions: [
          if (_isSelectionMode)
             IconButton(
               icon: const Icon(Icons.close),
               onPressed: () {
                 setState(() {
                   _isSelectionMode = false;
                   _selectedExpenseIds.clear();
                 });
               },
             )
          else
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                return creditCardsAsync.when(
                  data: (creditCards) {
                    final selectedDate = ref.watch(selectedDateProvider);
                    final now = DateTime.now();

                    // Filter: CREDIT CARD ONLY + NOT BILLS + DATE/BILLING LOGIC
                    final ccExpenses = expenses.where((e) {
                      if (e.paymentMethod != 'Credit Card' || e.isCreditCardBill) return false;

                      // Get card for billing day logic
                      final card = creditCards.firstWhere(
                        (c) => c.id == e.creditCardId, 
                        orElse: () => CreditCardModel(id: '', name: '', billingDay: 1),
                      );

                      if (card.id.isEmpty && e.creditCardId != null) return false;

                      final isSelectedMonth = e.date.year == selectedDate.year && e.date.month == selectedDate.month;
                      
                      final isPreviousMonth = (e.date.year == selectedDate.year && e.date.month == selectedDate.month - 1) ||
                                            (selectedDate.month == 1 && e.date.month == 12 && e.date.year == selectedDate.year - 1);

                      if (isSelectedMonth) {
                        return true;
                      } else if (isPreviousMonth) {
                        final lastDayOfSelectedMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
                        // Use clamping logic
                        final effectiveBillingDay = card.billingDay > lastDayOfSelectedMonth ? lastDayOfSelectedMonth : card.billingDay;
                        final billingDeadline = DateTime(selectedDate.year, selectedDate.month, effectiveBillingDay);
                        
                        return now.isBefore(billingDeadline);
                      }

                      return false;
                    }).toList();
            
                    // Sort descending by date
                    ccExpenses.sort((a,b) => b.date.compareTo(a.date));
            
                    if (ccExpenses.isEmpty) {
                      return const Center(child: Text('No credit card usage found'));
                    }
            
                    // Group by Card ID
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
                            // Maintain state if selection mode changes? 
                            // ExpansionTile doesn't support easy selection of children unless custom 
                            // For simplicity, we make the children Selectable ListTiles
                            initiallyExpanded: true,
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
                                leading: _isSelectionMode 
                                  ? Checkbox(
                                      value: _selectedExpenseIds.contains(expense.id),
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedExpenseIds.add(expense.id);
                                          } else {
                                            _selectedExpenseIds.remove(expense.id);
                                          }
                                        });
                                      },
                                    ) 
                                  : null,
                                title: Text(expense.title),
                                subtitle: Text(DateFormat('MMM d, yyyy').format(expense.date)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '₹${expense.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (!_isSelectionMode)
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
                                            child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text('Edit')]),
                                          ),
                                          const PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete')]),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                onTap: _isSelectionMode ? () {
                                  setState(() {
                                    if (_selectedExpenseIds.contains(expense.id)) {
                                      _selectedExpenseIds.remove(expense.id);
                                    } else {
                                      _selectedExpenseIds.add(expense.id);
                                    }
                                  });
                                } : null,
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
          ),
          // Bottom Bar for Actions
          if (_isSelectionMode && _selectedExpenseIds.isNotEmpty)
             Container(
               padding: const EdgeInsets.all(16),
               color: Colors.blue.withValues(alpha: 0.1),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text('${_selectedExpenseIds.length} selected'),
                   ElevatedButton.icon(
                     onPressed: () => _generateBillFromSelection(context, ref),
                     icon: const Icon(Icons.receipt_long),
                     label: const Text('Add to Bill'),
                   ),
                 ],
               ),
             ),
        ],
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

  Future<void> _generateBillFromSelection(BuildContext context, WidgetRef ref) async {
    // 1. Calculate Total
    final allExpenses = ref.read(allExpensesProvider).value ?? [];
    final selectedExpenses = allExpenses.where((e) => _selectedExpenseIds.contains(e.id)).toList();
    final total = selectedExpenses.fold(0.0, (sum, e) => sum + e.amount);

    // 2. Ask for Bill Date
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'SELECT BILL PAYMENT MONTH',
    );

    if (date == null) return;
    
    // Check if items are from different cards
    final cardIds = selectedExpenses.map((e) => e.creditCardId).toSet();
    if (cardIds.length > 1) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select expenses from the same card.')));
      }
      return;
    }

    final cardId = cardIds.first;
    // get card details for name
    final creditCards = ref.read(creditCardProvider).value ?? [];
    String cardName = 'Credit Card';
    if (cardId != null) {
        final card = creditCards.firstWhere((c) => c.id == cardId, orElse: () => const CreditCardModel(id: '', name: 'Credit Card', billingDay: 1, lastBillGeneratedMonth: ''));
        cardName = card.name;
    }

    // 3. Create Bill Expense
    final billExpense = ExpenseModel(
      id: 'manual_bill_${DateTime.now().millisecondsSinceEpoch}',
      title: '$cardName Bill (Manual)',
      amount: total,
      date: date,
      category: 'Bills',
      paymentMethod: 'Bank Transfer',
      isCreditCardBill: true,
      creditCardId: cardId, // Associate bill with card too? Maybe not needed for bill itself to track against usage, but good for context
    );

    // 4. Save Expense
    await ref.read(expensesProvider.notifier).addExpense(billExpense);

    // 5. Update Credit Card "Last Bill Generated" to advance cycle
    if (cardId != null) {
       // Identify the billing month based on the selected Bill Date
       // We assume the bill date typically corresponds to the month the bill is issued/paid
       // which should close the cycle for that relative month.
       final newLastBillMonth = DateFormat('yyyy-MM').format(date);
       
       final creditCards = ref.read(creditCardProvider).value ?? [];
       final cardToUpdate = creditCards.firstWhere((c) => c.id == cardId, orElse: () => const CreditCardModel(id: '', name: '', billingDay: 1));
       
       if (cardToUpdate.id.isNotEmpty) {
         final updatedCard = cardToUpdate.copyWith(lastBillGeneratedMonth: newLastBillMonth);
         await ref.read(creditCardProvider.notifier).updateCreditCard(updatedCard);
       }
    }
    
    if (mounted) {
      setState(() {
        _isSelectionMode = false;
        _selectedExpenseIds.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bill created for ₹${total.toStringAsFixed(2)}')));
    }
  }
}
