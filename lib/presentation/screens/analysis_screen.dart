import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/salary_provider.dart';
import '../providers/category_provider.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../widgets/daily_spending_chart.dart';
import '../providers/date_provider.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final incomeAsync = ref.watch(salaryProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Analysis')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '50/30/20 Rule',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '50% Needs • 30% Wants • 20% Savings',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (expensesAsync.isLoading || incomeAsync.isLoading || categoriesAsync.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (expensesAsync.hasError || incomeAsync.hasError)
              const Center(child: Text('Error loading data'))
            else
              _buildAnalysisContent(
                context, 
                expensesAsync.value ?? [], 
                incomeAsync.value ?? [],
                categoriesAsync.value ?? [],
                ref.watch(selectedDateProvider),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(
    BuildContext context, 
    List<dynamic> expenses, 
    List<dynamic> incomes,
    List<CategoryModel> categories,
    DateTime date,
  ) {
    final totalIncome = incomes.fold<double>(0, (sum, item) => sum + item.amount);
    
    if (totalIncome == 0) {
      return const Center(
        child: Text('Please add income to see analysis.'),
      );
    }

    // Create a map for quick lookup
    final categoryTypeMap = {for (var c in categories) c.name: c.type};

    // Categorize expenses
    double needs = 0;
    double wants = 0;
    double savingsFromExpenses = 0; // If user tracks investments as expenses

    for (var expense in expenses) {
      final type = categoryTypeMap[expense.category] ?? 'Want'; // Default to Want
      if (type == 'Need') {
        needs += expense.amount;
      } else if (type == 'Savings') {
        savingsFromExpenses += expense.amount;
      } else {
        wants += expense.amount;
      }
    }

    // Savings is remaining balance + any expenses marked as 'Savings' (e.g. Investments)
    final savings = (totalIncome - (needs + wants + savingsFromExpenses)) + savingsFromExpenses;
    
    // Calculate percentages
    final needsPct = (needs / totalIncome * 100);
    final wantsPct = (wants / totalIncome * 100);
    final savingsPct = (savings / totalIncome * 100);

    return Column(
      children: [
        _buildSmartForecast(context, expenses, totalIncome, date),
        const SizedBox(height: 24),
        _buildTopSpenders(context, expenses, categories),
        const SizedBox(height: 24),
        _buildCategoryCard(
          context,
          'Needs',
          needs,
          totalIncome * 0.5,
          needsPct,
          Colors.blue,
          'Rent, Groceries, Bills, Health',
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          context,
          'Wants',
          wants,
          totalIncome * 0.3,
          wantsPct,
          Colors.orange,
          'Shopping, Dining, Entertainment',
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          context,
          'Savings',
          savings,
          totalIncome * 0.2,
          savingsPct,
          Colors.green,
          'Investments, Emergency Fund',
          isSavings: true,
        ),
        const SizedBox(height: 24),
        DailySpendingChart(expenses: expenses.cast<ExpenseModel>(), date: date),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        const Text(
          'Suggestions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildSuggestions(needsPct, wantsPct, savingsPct),
      ],
    );
  }

  Widget _buildSmartForecast(BuildContext context, List<dynamic> expenses, double totalIncome, DateTime date) {
    final now = DateTime.now();
    // Only forecast for current month
    if (date.year != now.year || date.month != now.month) {
      return const SizedBox.shrink();
    }

    final daysPassed = now.day;
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final totalSpent = expenses.fold<double>(0, (sum, item) => sum + item.amount);
    
    if (daysPassed == 0) return const SizedBox.shrink();

    final avgDaily = totalSpent / daysPassed;
    final projectedTotal = avgDaily * totalDaysInMonth;
    final status = projectedTotal > totalIncome ? 'Risk of Overspending' : 'On Track';
    final statusColor = projectedTotal > totalIncome ? Colors.red : Colors.green;

    return Card(
      elevation: 4,
      color: Colors.indigo[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_graph, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text('Smart Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Projected Total', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
                    Text('₹${projectedTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Based on your average daily spending of ₹${avgDaily.toStringAsFixed(0)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[800], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSpenders(BuildContext context, List<dynamic> expenses, List<CategoryModel> categories) {
    final categoryTotals = <String, double>{};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final top3 = sortedCategories.take(3).toList();

    if (top3.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Spending Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: top3.length,
            itemBuilder: (context, index) {
              final entry = top3[index];
              return Card(
                margin: const EdgeInsets.only(right: 12),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 16, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    double current,
    double target,
    double percentage,
    Color color,
    String description, {
    bool isSavings = false,
  }) {
    final isOverBudget = !isSavings && current > target;
    final isUnderTarget = isSavings && current < target;
    final statusColor = (isOverBudget || isUnderTarget) ? Colors.red : Colors.green;

    return GestureDetector(
      onTap: () {
        _showCategoryDetails(context, title, description, isSavings);
      },
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              const SizedBox(height: 4),
              Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (current / (isSavings ? (target * 2) : target)).clamp(0.0, 1.0), // Scale for visual
                backgroundColor: color.withOpacity(0.1),
                color: color,
                minHeight: 10,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Spent: ₹${current.toStringAsFixed(0)}'),
                  Text('Target: ${isSavings ? '≥' : '≤'} ₹${target.toStringAsFixed(0)}'),
                ],
              ),
              if (isOverBudget || isUnderTarget) ...[
                const SizedBox(height: 8),
                Text(
                  isSavings 
                    ? 'You are below your savings target.' 
                    : 'You have exceeded your $title budget.',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, String title, String description, bool isSavings) {
    // We need access to expenses and categories here. 
    // Since this is a stateless widget, we can pass them or use Consumer in the bottom sheet.
    // Using Consumer is cleaner.
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, _) {
            final expenses = ref.watch(expensesProvider).value ?? [];
            final categories = ref.watch(categoryProvider).value ?? [];
            final categoryTypeMap = {for (var c in categories) c.name: c.type};

            // Filter expenses
            final filteredExpenses = expenses.where((e) {
              final type = categoryTypeMap[e.category] ?? 'Want';
              if (isSavings) return type == 'Savings';
              if (title == 'Needs') return type == 'Need';
              return type == 'Want'; // Default to Want
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '$title Expenses',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: filteredExpenses.isEmpty
                      ? const Center(child: Text('No expenses found for this category.'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: filteredExpenses.length,
                          itemBuilder: (context, index) {
                            final expense = filteredExpenses[index];
                            return ListTile(
                              leading: CircleAvatar(child: Text(expense.category[0])),
                              title: Text(expense.title),
                              subtitle: Text(expense.category),
                              trailing: Text(
                                '₹${expense.amount.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _buildSuggestions(double needsPct, double wantsPct, double savingsPct) {
    final List<Widget> suggestions = [];

    if (needsPct > 50) {
      suggestions.add(_buildSuggestionItem(
        'Reduce Needs',
        'Your needs are taking up ${needsPct.toStringAsFixed(1)}% of your income. Look for ways to save on utilities, groceries, or rent.',
      ));
    }

    if (wantsPct > 30) {
      suggestions.add(_buildSuggestionItem(
        'Cut Down Wants',
        'Your wants are at ${wantsPct.toStringAsFixed(1)}%. Try cooking at home more often or cancelling unused subscriptions.',
      ));
    }

    if (savingsPct < 20) {
      suggestions.add(_buildSuggestionItem(
        'Boost Savings',
        'You are saving only ${savingsPct.toStringAsFixed(1)}%. Try to set aside at least 20% for your future.',
      ));
    }

    if (suggestions.isEmpty) {
      suggestions.add(_buildSuggestionItem(
        'Great Job!',
        'You are balancing your finances perfectly according to the 50/30/20 rule!',
        icon: Icons.thumb_up,
        color: Colors.green,
      ));
    }

    return Column(children: suggestions);
  }

  Widget _buildSuggestionItem(String title, String body, {IconData icon = Icons.lightbulb, Color color = Colors.amber}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(body),
      ),
    );
  }
}
