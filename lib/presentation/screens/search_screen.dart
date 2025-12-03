import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allExpensesAsync = ref.watch(allExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search expenses...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (value) {
            setState(() {
              _query = value;
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _query = '';
                });
              },
            ),
        ],
      ),
      body: allExpensesAsync.when(
        data: (expenses) {
          if (_query.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Search by title, category, or amount', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final results = expenses.where((e) {
            final q = _query.toLowerCase();
            return e.title.toLowerCase().contains(q) ||
                e.category.toLowerCase().contains(q) ||
                e.amount.toString().contains(q);
          }).toList();

          // Sort by date descending
          results.sort((a, b) => b.date.compareTo(a.date));

          if (results.isEmpty) {
            return const Center(child: Text('No matching expenses found.'));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final expense = results[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Icon(_getCategoryIcon(expense.category), color: Colors.blue),
                ),
                title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${DateFormat('MMM d, y').format(expense.date)} • ${expense.category}'),
                trailing: Text(
                  '₹${expense.amount.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExpenseScreen(expense: expense),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant;
      case 'transport': return Icons.directions_bus;
      case 'shopping': return Icons.shopping_bag;
      case 'bills': return Icons.receipt;
      case 'entertainment': return Icons.movie;
      case 'health': return Icons.local_hospital;
      case 'education': return Icons.school;
      case 'investments': return Icons.trending_up;
      default: return Icons.category;
    }
  }
}
