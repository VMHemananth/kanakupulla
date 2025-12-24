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
    final theme = Theme.of(context);
    final isLent = type == 'Lent';

    return debtsAsync.when(
      data: (debts) {
        final filteredDebts = debts.where((d) => d.type == type).toList();
        final totalAmount = filteredDebts
            .where((d) => !d.isSettled)
            .fold(0.0, (sum, d) => sum + d.amount);

        // Define Gradient Colors
        final gradientColors = isLent
            ? [const Color(0xFF10B981), const Color(0xFF059669)] // Emerald
            : [const Color(0xFFEF4444), const Color(0xFFDC2626)]; // Red

        return Column(
          children: [
            // 1. Hero Summary Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isLent ? 'Total To Receive' : 'Total To Pay',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLent ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '₹${totalAmount.toStringAsFixed(0)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Across ${filteredDebts.where((d) => !d.isSettled).length} active records',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                  ),
                ],
              ),
            ),

            // 2. List
            Expanded(
              child: filteredDebts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_rounded, size: 64, color: theme.colorScheme.outline.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No records found',
                            style: TextStyle(color: theme.colorScheme.secondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filteredDebts.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final debt = filteredDebts[index];
                        final isOverdue = !debt.isSettled && _isOverdue(debt.dueDate);

                        return Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(20),
                            border: isOverdue 
                              ? Border.all(color: theme.colorScheme.error.withOpacity(0.5), width: 1)
                              : null,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoanDetailsScreen(debt: debt)),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Avatar
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: debt.isSettled 
                                            ? Colors.grey.withOpacity(0.1) 
                                            : isLent ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2), // Green-100 / Red-100
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Center(
                                          child: Text(
                                            debt.personName.isNotEmpty ? debt.personName[0].toUpperCase() : '?',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: debt.isSettled 
                                                ? Colors.grey 
                                                : isLent ? const Color(0xFF166534) : const Color(0xFF991B1B),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  debt.personName,
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    decoration: debt.isSettled ? TextDecoration.lineThrough : null,
                                                    color: debt.isSettled ? theme.colorScheme.outline : null,
                                                  ),
                                                ),
                                                Text(
                                                  '₹${debt.amount.toStringAsFixed(0)}',
                                                  style: theme.textTheme.headlineSmall?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: debt.isSettled ? theme.colorScheme.outline : null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.calendar_today_rounded, size: 12, color: theme.colorScheme.outline),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat('MMM d').format(debt.date),
                                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                                                ),
                                                if (debt.dueDate != null && !debt.isSettled) ...[
                                                  const SizedBox(width: 8),
                                                  Container(width: 4, height: 4, decoration: BoxDecoration(color: theme.colorScheme.outline, shape: BoxShape.circle)),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Due ${DateFormat('MMM d').format(debt.dueDate!)}',
                                                    style: theme.textTheme.bodySmall?.copyWith(
                                                      color: isOverdue ? theme.colorScheme.error : theme.colorScheme.outline,
                                                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                                                    ),
                                                  ),
                                                ]
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Progress Bar (if active)
                                  if (!debt.isSettled) ...[
                                    const SizedBox(height: 16),
                                    Builder(
                                      builder: (context) {
                                        double totalPaid = debt.payments.fold(0.0, (sum, p) => sum + p.amount);
                                        double currentOutstanding = debt.amount;
                                        double totalValue = (debt.principalAmount > 0) ? debt.principalAmount : (currentOutstanding + totalPaid);
                                        if (totalValue <= 0) totalValue = currentOutstanding;
                                        if (totalValue <= 0) return const SizedBox.shrink();

                                        double progress = (totalPaid / totalValue).clamp(0.0, 1.0);
                                        
                                        return Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: LinearProgressIndicator(
                                                value: progress,
                                                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                                color: isLent ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                                minHeight: 8,
                                              ),
                                            ),
                                            if (progress > 0)
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Paid ${(progress * 100).toStringAsFixed(0)}%',
                                                      style: TextStyle(fontSize: 12, color: theme.colorScheme.outline, fontWeight: FontWeight.w500),
                                                    ),
                                                    Text(
                                                      '${(100 - progress * 100).toStringAsFixed(0)}% Remaining',
                                                      style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                                                    ),
                                                  ],
                                                ),
                                              )
                                          ],
                                        );
                                      }
                                    ),
                                    
                                    // Quick Actions Row
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _ActionButton(
                                          icon: Icons.edit_rounded, 
                                          label: 'Edit', 
                                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => AddDebtScreen(debt: debt)))
                                        ),
                                        Container(width: 1, height: 24, color: theme.colorScheme.outlineVariant),
                                        _ActionButton(
                                          icon: Icons.payment_rounded, 
                                          label: isLent ? 'Receive' : 'Pay', 
                                          onTap: () => _showPayEmiDialog(context, ref, debt),
                                          color: isLent ? Colors.green : Colors.blue,
                                        ),
                                        Container(width: 1, height: 24, color: theme.colorScheme.outlineVariant),
                                        _ActionButton(
                                          icon: Icons.more_horiz_rounded, 
                                          label: 'More', 
                                          onTap: () => _showMoreOptions(context, ref, debt, isLent),
                                        ),
                                      ],
                                    )
                                  ],
                                ],
                              ),
                            ),
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

  void _showMoreOptions(BuildContext context, WidgetRef ref, DebtModel debt, bool isLent) {
     showModalBottomSheet(
       context: context,
       builder: (ctx) => Container(
         padding: const EdgeInsets.all(16),
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             if (!debt.isSettled && isLent)
               ListTile(
                 leading: const Icon(Icons.share, color: Colors.green),
                 title: const Text('Share Reminder'),
                 onTap: () { Navigator.pop(ctx); _shareReminder(debt); },
               ),
             ListTile(
               leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
               title: const Text('Generate PDF Statement'),
               onTap: () async { Navigator.pop(ctx); await PdfService().generateDebtStatement(debt); },
             ),
             ListTile(
               leading: const Icon(Icons.check_circle_outline, color: Colors.blue),
               title: const Text('Mark as Settled'),
               onTap: () { Navigator.pop(ctx); _showSettleDialog(context, ref, debt); },
             ),
             ListTile(
               leading: const Icon(Icons.delete_outline, color: Colors.red),
               title: const Text('Delete Record'),
               onTap: () { Navigator.pop(ctx); _showDeleteDialog(context, ref, debt); },
             ),
           ],
         ),
       )
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color ?? theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w500,
              color: color ?? theme.colorScheme.onSurfaceVariant
            )),
          ],
        ),
      ),
    );
  }
}
