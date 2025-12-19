import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/salary_provider.dart';
import '../providers/category_provider.dart';
import '../../data/models/category_model.dart';
import '../../data/models/expense_model.dart';
import '../widgets/daily_spending_chart.dart';
import '../widgets/monthly_trend_chart.dart';
import '../providers/date_provider.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);
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
            if (expensesAsync.isLoading || incomeAsync.isLoading || categoriesAsync.isLoading || allExpensesAsync.isLoading)
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
                allExpensesAsync.value ?? [],
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
    List<ExpenseModel> allExpenses,
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
        MonthlyTrendChart(allExpenses: allExpenses, selectedDate: date),
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
        _buildSuggestions(context, needsPct, wantsPct, savingsPct),
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
    final daysRemaining = totalDaysInMonth - daysPassed;
    
    final totalSpent = expenses.fold<double>(0, (sum, item) => sum + item.amount);
    
    if (daysPassed == 0) return const SizedBox.shrink();

    final avgDaily = totalSpent / daysPassed;
    final projectedTotal = avgDaily * totalDaysInMonth;
    final status = projectedTotal > totalIncome ? 'Risk of Overspending' : 'On Track';
    final statusColor = projectedTotal > totalIncome ? Colors.red : Colors.green;
    
    // SAFE DAILY SPEND CALCULATION
    final remainingBudget = totalIncome - totalSpent;
    final safeDaily = (remainingBudget > 0 && daysRemaining > 0) ? remainingBudget / daysRemaining : 0.0;

    return Card(
      elevation: 4,
      color: Colors.indigo[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            const SizedBox(height: 16),
            
            // Row 1: Projection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Projected Month End', style: TextStyle(color: Colors.indigo.shade700, fontSize: 12)),
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
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            
            const Divider(height: 24),
            
            // Row 2: The Actionable Advice
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.shield_outlined, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Safe Daily Limit', style: TextStyle(color: Colors.indigo.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(
                        'Spend max ₹${safeDaily.toStringAsFixed(0)}/day', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text('to finish the month within income.', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
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
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        style: const TextStyle(fontSize: 16, color: Colors.indigo, fontWeight: FontWeight.bold),
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCategoryDetails(context, title, description, isSavings),
        borderRadius: BorderRadius.circular(12),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (current / (isSavings ? (target * 2) : target)).clamp(0.0, 1.0),
                  backgroundColor: color.withOpacity(0.1),
                  color: color,
                  minHeight: 10,
                ),
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
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$title Expenses',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
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
                             return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo.shade50,
                                  child: Text(expense.category[0], style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('${expense.category} • ${expense.date.day}/${expense.date.month}'),
                                trailing: Text(
                                  '₹${expense.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
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

  Widget _buildSuggestions(BuildContext context, double needsPct, double wantsPct, double savingsPct) {
    final List<Widget> suggestions = [];

    if (needsPct > 50) {
      suggestions.add(_buildSuggestionItem(
        'Reduce Needs',
        'Your needs are taking up ${needsPct.toStringAsFixed(1)}% of your income. Look for ways to save.',
        onTap: () => _showCategoryDetails(context, 'Needs', 'Needs Expenses', false),
      ));
    }

    if (wantsPct > 30) {
      suggestions.add(_buildSuggestionItem(
        'Cut Down Wants',
        'Your wants are at ${wantsPct.toStringAsFixed(1)}%. Try cancelling unused subscriptions.',
        onTap: () => _showCategoryDetails(context, 'Wants', 'Discretionary Expenses', false),
      ));
    }

    if (savingsPct < 20) {
      suggestions.add(_buildSuggestionItem(
        'Boost Savings',
        'You are saving only ${savingsPct.toStringAsFixed(1)}%. Try to set aside at least 20%.',
        // No direct breakdown for savings "expense" usually, but we can show savings
        onTap: () => _showCategoryDetails(context, 'Savings', 'Savings & Investments', true),
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

  Widget _buildSuggestionItem(String title, String body, {IconData icon = Icons.lightbulb, Color color = Colors.amber, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(body, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
