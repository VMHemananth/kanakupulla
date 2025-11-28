import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Expenses'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: (_selectedCategory != null || _selectedDateRange != null)
                  ? Colors.amber
                  : null,
            ),
            onPressed: () => _showFilterDialog(context, categoriesAsync.value ?? []),
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) {
          // Apply Filters
          final filteredExpenses = expenses.where((expense) {
            // Search Filter
            if (_searchQuery.isNotEmpty &&
                !expense.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
              return false;
            }
            // Category Filter
            if (_selectedCategory != null && expense.category != _selectedCategory) {
              return false;
            }
            // Date Range Filter
            if (_selectedDateRange != null) {
              if (expense.date.isBefore(_selectedDateRange!.start) ||
                  expense.date.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
                return false;
              }
            }
            return true;
          }).toList();

          if (filteredExpenses.isEmpty) {
            return const Center(child: Text('No expenses found matching criteria.'));
          }

          return ListView.builder(
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];
              return Dismissible(
                key: Key(expense.id),
                background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white)),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  ref.read(expensesProvider.notifier).deleteExpense(expense.id);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Expense deleted')));
                },
                child: ListTile(
                  title: Text(expense.title),
                  subtitle: Text(
                      '${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('₹${expense.amount}'),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Confirm delete
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Expense'),
                              content: const Text('Are you sure you want to delete this expense?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () {
                                    ref.read(expensesProvider.notifier).deleteExpense(expense.id);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddExpenseScreen(expense: expense),
                      ),
                    );
                  },
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

  void _showFilterDialog(BuildContext context, List<dynamic> categories) {
    // We need to map dynamic to CategoryModel or just use names if it's a list of models
    // Assuming categories is List<CategoryModel> based on provider
    final categoryNames = categories.map((e) => e.name as String).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Expenses'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('All')),
                    ...categoryNames.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date Range'),
                  subtitle: Text(_selectedDateRange == null
                      ? 'All Time'
                      : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDateRange: _selectedDateRange,
                    );
                    if (picked != null) {
                      setState(() => _selectedDateRange = picked);
                    }
                  },
                ),
                if (_selectedDateRange != null)
                  TextButton(
                    onPressed: () => setState(() => _selectedDateRange = null),
                    child: const Text('Clear Date Range'),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Reset filters
                  setState(() {
                    _selectedCategory = null;
                    _selectedDateRange = null;
                  });
                  // Update parent state as well since dialog state is local to builder
                  this.setState(() {
                    _selectedCategory = null;
                    _selectedDateRange = null;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Clear All'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Apply is implicit since we updated the state variables
                  // But we need to make sure the parent widget rebuilds with new values
                  // The values _selectedCategory and _selectedDateRange are in the parent state
                  // and we updated them via closure? No, we need to update parent state.
                  // Actually, _selectedCategory is a field of _ExpenseListScreenState.
                  // Inside StatefulBuilder, setState only rebuilds the dialog.
                  // We need to update the outer state variables.
                  // Since we are accessing _selectedCategory directly, we are updating the outer variable.
                  // We just need to call outer setState to refresh the list when dialog closes.
                  this.setState(() {}); 
                  Navigator.pop(ctx);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}
