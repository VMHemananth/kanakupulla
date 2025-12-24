import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/fixed_expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/credit_card_model.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/budget_repository.dart';
import '../../data/models/budget_model.dart';
import 'package:intl/intl.dart';

class NextMonthEstimationScreen extends ConsumerStatefulWidget {
  const NextMonthEstimationScreen({super.key});

  @override
  ConsumerState<NextMonthEstimationScreen> createState() => _NextMonthEstimationScreenState();
}
// ... (rest of the file until _commitToBudget)

// I will start a new hunk for _commitToBudget to keep it clean.


class _NextMonthEstimationScreenState extends ConsumerState<NextMonthEstimationScreen> {
  final _incomeController = TextEditingController();
  final List<Map<String, dynamic>> _knownExpenses = [];
  
  // Controllers for adding new expense
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  double _creditDues = 0;
  bool _isLoadingDues = true;


  @override
  void initState() {
    super.initState();
    // Defer processing to build phase or post frame to safely access providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateCreditDues();
      _loadFixedExpenses(); // Auto-load fixed for convenience
    });
  }

  @override
  void dispose() {
    _incomeController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _calculateCreditDues() async {
    // We need "Outstanding Credit Card Spend" that will be billed NEXT month.
    // This typically means current month's pending unbilled spend.
    
    final allExpenses = ref.read(allExpensesProvider).value ?? [];
    final creditCards = ref.read(creditCardProvider).value ?? [];
    
    double totalDues = 0;
    final now = DateTime.now();

    for (var expense in allExpenses) {
       if (expense.paymentMethod != 'Credit Card' || expense.isCreditCardBill) continue;
       
       final card = creditCards.firstWhere((c) => c.id == expense.creditCardId, 
          orElse: () => CreditCardModel(id: '', name: '', billingDay: 1));
          
       if (card.id.isNotEmpty) {
         bool isOutstanding = false;
         // Heuristic: Sum of All Credit Card Usage in CURRENT Month.
         if (expense.date.month == now.month && expense.date.year == now.year) {
           isOutstanding = true;
         }
         
         if (isOutstanding) {
           totalDues += expense.amount;
         }
       }
    }

    if (mounted) {
      setState(() {
        _creditDues = totalDues;
        _isLoadingDues = false;
      });
    }
  }
  
  void _loadFixedExpenses() {
    // Only load if empty to act as suggestions
    if (_knownExpenses.isNotEmpty) return;
    
    final fixedList = ref.read(fixedExpensesProvider).value ?? [];
    setState(() {
      for (var f in fixedList) {
        _knownExpenses.add({
          'title': f.title,
          'category': f.category,
          'amount': f.amount,
        });
      }
    });
  }

  Future<void> _fetchSmartSuggestions() async {
    // Analyze PREVIOUS Month's spending
    final now = DateTime.now();
    final prevMonthDate = DateTime(now.year, now.month - 1);
    final allExpenses = ref.read(allExpensesProvider).value ?? [];
    
    final prevExpenses = allExpenses.where((e) => 
      e.date.year == prevMonthDate.year && 
      e.date.month == prevMonthDate.month &&
      !e.isCreditCardBill // Exclude bills
    ).toList();
    
    if (prevExpenses.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No data from last month found')));
      return;
    }

    // Aggregate by Category
    final categoryTotals = <String, double>{};
    for (var e in prevExpenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    setState(() {
      _knownExpenses.clear();
      // Load Fixed Expenses First (Priority)
      final fixedList = ref.read(fixedExpensesProvider).value ?? [];
      for (var f in fixedList) {
         _knownExpenses.add({
          'title': f.title,
          'category': f.category,
          'amount': f.amount,
          'isFixed': true
        });
      }
      
      // Add Variable Categories from History
      for (var entry in categoryTotals.entries) {
        // Skip if category roughly matches a fixed expense? Keep it simple: Add all.
        // User can delete duplicates.
        // Or better: Check if we already have this category from fixed?
        // Fixed expenses usually track "Rent", "Netflix". 
        // Aggregated category is "Housing", "Entertainment".
        // Let's add them as generic Category budgets.
        
        // Filter out if exact amount match? Unlikely.
        _knownExpenses.add({
          'title': '${entry.key} Budget',
          'category': entry.key,
          'amount': entry.value, // Start with actuals
          'isFixed': false
        });
      }
      
      // Auto-populate income if available?
      // Assuming user inputs income manually for now.
    });
    
     if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loaded last month\'s spending')));
  }

  void _addCustomExpense() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    
    if (title.isEmpty || amountText.isEmpty) return;
    final amount = double.tryParse(amountText);
    if (amount == null) return;

    setState(() {
      _knownExpenses.add({
        'title': title,
        'category': 'Others', // Default
        'amount': amount,
        'isFixed': false
      });
      _titleController.clear();
      _amountController.clear();
    });
    Navigator.pop(context); // Close dialog
  }

  void _showAddDialog() {
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        title: const Text("Add Known Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Expense Name (e.g. Rent)"),
              textCapitalization: TextCapitalization.sentences,
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addCustomExpense, child: const Text("Add")),
        ],
      )
    );
  }

  void _removeExpense(int index) {
    setState(() {
      _knownExpenses.removeAt(index);
    });
  }
  
  Future<void> _commitToBudget() async {
    // Save these values to the Budget Table for NEXT MONTH
    final now = DateTime.now();
    var targetYear = now.year;
    var targetMonth = now.month + 1;
    if (targetMonth > 12) {
      targetMonth = 1;
      targetYear++;
    }
    
    final repo = ref.read(budgetRepositoryProvider);
    final monthId = '${targetYear}_$targetMonth';
    
    try {
      // 1. Save Total Monthly Budget (Income - Dues?) 
      // User entered Income. Usually Total Budget = Income.
      final income = double.tryParse(_incomeController.text) ?? 0.0;
      if (income > 0) {
        await repo.setBudget(BudgetModel(
          id: '${monthId}_TOTAL',
          month: monthId,
          amount: income,
          // category: null -> implies Total Budget
        ));
      }
      
      // 2. Save Category Budgets
      // We have a mixed list of "Title"s. We need to aggregate by Category.
      final Map<String, double> catBudgets = {};
      
      for (var item in _knownExpenses) {
         final cat = item['category'] as String?;
         if (cat == null || cat.isEmpty) continue;
         
         catBudgets[cat] = (catBudgets[cat] ?? 0) + (item['amount'] as double);
      }
      
      for (var entry in catBudgets.entries) {
         await repo.setBudget(BudgetModel(
           id: '${monthId}_${entry.key}',
           month: monthId,
           category: entry.key,
           amount: entry.value
         ));
      }
      
      if (mounted) {
        // Invalidate providers to force refresh on other screens
        ref.invalidate(budgetProvider);
        ref.invalidate(categoryBudgetsProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Budget committed for ${DateFormat('MMMM').format(DateTime(targetYear, targetMonth))}!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving budget: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final income = double.tryParse(_incomeController.text) ?? 0.0;
    final totalKnown = _knownExpenses.fold(0.0, (sum, item) => sum + (item['amount'] as double));
    final remaining = income - _creditDues - totalKnown;
    final isControl = remaining >= 0;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Month Estimator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Smart Suggestions',
            onPressed: _fetchSmartSuggestions,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Income Input
            _buildSectionHeader(context, "1. Assumed Income", Icons.attach_money, Colors.green),
            const SizedBox(height: 8),
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter expected income",
                prefixText: "₹ ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 24),

            // 2. Credit Dues (Deduction)
            _buildSectionHeader(context, "2. Outstanding Credit Dues", Icons.credit_card, Colors.orange),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("To be paid next month", style: TextStyle(fontWeight: FontWeight.w500)),
                  _isLoadingDues 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text("- ₹${_creditDues.toStringAsFixed(0)}", 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Known Expenses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader(context, "3. Known Expenses", Icons.list_alt, Colors.blue),
                if (_knownExpenses.isNotEmpty)
                  Text(
                    '${_knownExpenses.length} items',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                   if (_knownExpenses.isEmpty)
                     Padding(
                       padding: const EdgeInsets.all(24.0),
                       child: Center(child: Text("Use 'Smart Suggestions' or Add items", style: TextStyle(color: theme.colorScheme.onSurfaceVariant))),
                     ),
                   
                   ..._knownExpenses.asMap().entries.map((entry) {
                     final idx = entry.key;
                     final item = entry.value;
                     return ListTile(
                       title: Text(item['title']),
                       subtitle: Text(item['category'] ?? 'Others', style: const TextStyle(fontSize: 12)),
                       trailing: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Text("- ₹${(item['amount'] as double).toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                           IconButton(
                             icon: const Icon(Icons.close, size: 16),
                             onPressed: () => _removeExpense(idx),
                           )
                         ],
                       ),
                     );
                   }),
                   
                   const Divider(height: 1),
                   ListTile(
                     leading: const Icon(Icons.add_circle, color: Colors.blue),
                     title: const Text("Add Manual Expense", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
                     onTap: _showAddDialog,
                   ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Summary / Verdict
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isControl 
                    ? [const Color(0xFF059669), const Color(0xFF10B981)] // Green
                    : [const Color(0xFFDC2626), const Color(0xFFEF4444)], // Red
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isControl ? Colors.green : Colors.red).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6)
                  )
                ]
              ),
              child: Column(
                children: [
                   Text(
                     "ESTIMATED REMAINING", 
                     style: TextStyle(color: Colors.white.withOpacity(0.8), letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold)
                   ),
                   const SizedBox(height: 8),
                   Text(
                     "₹${remaining.toStringAsFixed(0)}",
                     style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                   ),
                   const SizedBox(height: 16),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     decoration: BoxDecoration(
                       color: Colors.white.withOpacity(0.2),
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Icon(isControl ? Icons.check_circle : Icons.warning, color: Colors.white, size: 20),
                         const SizedBox(width: 8),
                         Text(
                           isControl ? "Status: Under Control" : "Status: Not in Control",
                           style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                         ),
                       ],
                     ),
                   )
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            if (isControl && _knownExpenses.isNotEmpty)
              ElevatedButton.icon(
                onPressed: _commitToBudget,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                icon: const Icon(Icons.save_alt),
                label: const Text('Commit to Next Month Budget'),
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
      ],
    );
  }
}
