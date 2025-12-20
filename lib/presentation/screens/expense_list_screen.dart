import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/expense_list_item.dart';
import 'add_expense_screen.dart';
import '../../core/theme/app_theme.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  amountHighLow,
  amountLowHigh,
}

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
  SortOption _sortOption = SortOption.dateNewest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('All Transactions', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [

          PopupMenuButton<SortOption>(
            icon: Icon(Icons.sort_rounded, color: theme.colorScheme.onSurface),
            tooltip: 'Sort by',
            color: theme.colorScheme.surfaceContainer,
            onSelected: (SortOption result) {
              setState(() {
                _sortOption = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.dateNewest,
                child: Text('Date: Newest First'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.dateOldest,
                child: Text('Date: Oldest First'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.amountHighLow,
                child: Text('Amount: High to Low'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.amountLowHigh,
                child: Text('Amount: Low to High'),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: (_selectedCategory != null || _selectedDateRange != null)
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            onPressed: () => _showFilterDialog(context, categoriesAsync.value ?? []),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
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
      ),
      body: expensesAsync.when(
        data: (expenses) {
          // Apply Filters
          var filteredExpenses = expenses.where((expense) {
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

          // Apply Sorting
          switch (_sortOption) {
            case SortOption.dateNewest:
              filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
              break;
            case SortOption.dateOldest:
              filteredExpenses.sort((a, b) => a.date.compareTo(b.date));
              break;
            case SortOption.amountHighLow:
              filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
              break;
            case SortOption.amountLowHigh:
              filteredExpenses.sort((a, b) => a.amount.compareTo(b.amount));
              break;
          }

          if (filteredExpenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found', 
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredExpenses.length,
            itemBuilder: (context, index) {
              final expense = filteredExpenses[index];
              return Dismissible(
                key: Key(expense.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      title: const Text('Delete Transaction'),
                      content: const Text('Are you sure you want to delete this transaction?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  ref.read(expensesProvider.notifier).deleteExpense(expense.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Transaction deleted'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    )
                  );
                },
                child: ExpenseListItem(
                  expense: expense,
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
    final categoryNames = categories.map((e) => e.name as String).toList();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Filter Transactions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  ),
                  dropdownColor: theme.colorScheme.surfaceContainer,
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('All')),
                    ...categoryNames.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                  ],
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      initialDateRange: _selectedDateRange,
                      builder: (context, child) {
                        return Theme(
                          data: theme.copyWith(
                            datePickerTheme: DatePickerThemeData(
                              backgroundColor: theme.colorScheme.surface,
                              headerBackgroundColor: theme.colorScheme.primary,
                            )
                          ),
                          child: child!,
                        );
                      }
                    );
                    if (picked != null) {
                      setState(() => _selectedDateRange = picked);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date Range', style: theme.textTheme.labelSmall),
                            Text(
                              _selectedDateRange == null
                                  ? 'All Time'
                                  : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                  this.setState(() {
                    _selectedCategory = null;
                    _selectedDateRange = null;
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Clear All'),
              ),
              FilledButton(
                onPressed: () {
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
