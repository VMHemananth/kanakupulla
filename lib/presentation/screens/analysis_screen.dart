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
import '../../core/theme/app_theme.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final incomeAsync = ref.watch(salaryProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Insights', 
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme),
            const SizedBox(height: 32),
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
            const SizedBox(height: 80), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '50/30/20 Rule',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '50% Needs • 30% Wants • 20% Savings',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    final totalIncome = incomes.fold<double>(0, (sum, item) => sum + item.amount);
    
    if (expenses.isEmpty && totalIncome == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.analytics_outlined, size: 64, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(
                'Add expenses or income to see analysis', 
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
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
    // If income is 0, savings is technically negative of expenses, but for display let's standardise
    final savings = totalIncome > 0 
        ? (totalIncome - (needs + wants + savingsFromExpenses)) + savingsFromExpenses 
        : savingsFromExpenses;
    
    // Calculate percentages
    final needsPct = totalIncome > 0 ? (needs / totalIncome * 100) : 0.0;
    final wantsPct = totalIncome > 0 ? (wants / totalIncome * 100) : 0.0;
    final savingsPct = totalIncome > 0 ? (savings / totalIncome * 100) : 0.0;

    return Column(
      children: [
        _buildSmartForecast(context, expenses, totalIncome, date, allExpenses),
        const SizedBox(height: 32),
        MonthlyTrendChart(allExpenses: allExpenses, selectedDate: date),
        const SizedBox(height: 32),
        _buildTopSpenders(context, expenses, categories),
        const SizedBox(height: 32),
        if (totalIncome > 0) ...[
          _buildCategoryCard(
            context,
            'Needs',
            needs,
            totalIncome * 0.5,
            needsPct,
            theme.colorScheme.primary, // Indigo
            'Rent, Groceries, Bills',
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            'Wants',
            wants,
            totalIncome * 0.3,
            wantsPct,
            theme.colorScheme.secondary, // Teal
            'Shopping, Dining',
          ),
          const SizedBox(height: 16),
          _buildCategoryCard(
            context,
            'Savings',
            savings,
            totalIncome * 0.2,
            savingsPct,
            const Color(0xFF10B981), // Emerald 500
            'Investments, Emergency Fund',
            isSavings: true,
          ),
          const SizedBox(height: 32),
        ],
        DailySpendingChart(expenses: expenses.cast<ExpenseModel>(), date: date),
        const SizedBox(height: 32),
        Divider(color: theme.colorScheme.outline.withOpacity(0.2)),
        const SizedBox(height: 24),
        Text(
          'Smart Suggestions',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildSuggestions(context, needsPct, wantsPct, savingsPct, totalIncome > 0),
      ],
    );
  }

  Widget _buildSmartForecast(BuildContext context, List<dynamic> expenses, double totalIncome, DateTime date, List<ExpenseModel> allExpenses) {
    final now = DateTime.now();
    final theme = Theme.of(context);
    
    // Only forecast for current month
    if (date.year != now.year || date.month != now.month) {
      return const SizedBox.shrink();
    }

    final daysPassed = now.day;
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = totalDaysInMonth - daysPassed;
    
    final totalSpent = expenses.fold<double>(0, (sum, item) => sum + (item.isCreditCardBill ? 0 : item.amount));
    
    // Smart Forecast Logic
    double projectedTotal = 0;
    
    // Progressive Weighted Forecast Logic
    // We blend "CurrentPace" with "HistoricalAverage" based on how far we are in the month.
    // Early month = Trust History. Late month = Trust Actuals.
    
    // 1. Calculate Historical Average (Last 3 months)
    double historicalAvg = 0;
    int monthsCount = 0;
    for (int i = 1; i <= 3; i++) {
      final targetMonth = DateTime(now.year, now.month - i, 1);
      final monthExpenses = allExpenses.where((e) => 
        e.date.year == targetMonth.year && e.date.month == targetMonth.month
      ).toList();
      
      if (monthExpenses.isNotEmpty) {
          historicalAvg += monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
          monthsCount++;
      }
    }
    if (monthsCount > 0) {
      historicalAvg /= monthsCount;
    }

    // 2. Calculate Current Pace Projection
    final avgDaily = daysPassed > 0 ? totalSpent / daysPassed : 0.0;
    final currentPaceProjection = avgDaily * totalDaysInMonth;

    // 3. Blend them using Linear Interpolation (Lerp)
    if (monthsCount > 0) {
      // Weight of current pace increases as month progresses
      final progressWeight = daysPassed / totalDaysInMonth;
      
      // Example: Day 1 (1/30) -> 3% Current, 97% History. 
      // Example: Day 15 (15/30) -> 50% Current, 50% History.
      // Example: Day 30 (30/30) -> 100% Current.
      projectedTotal = (currentPaceProjection * progressWeight) + (historicalAvg * (1 - progressWeight));
    } else {
      // No history? Trust current pace 100% (volatile but necessary)
      projectedTotal = currentPaceProjection;
    }

    final isRisky = totalIncome > 0 && projectedTotal > totalIncome;
    // If no income, risk is unknown, assume neutral or warning if spend is high? Let's say "Projected"
    final status = totalIncome > 0 
        ? (isRisky ? 'Risk of Overspending' : 'On Track')
        : 'Projected Spend';
        
    final statusColor = totalIncome > 0 
        ? (isRisky ? theme.colorScheme.error : theme.colorScheme.tertiary)
        : theme.colorScheme.primary;
    
    // SAFE DAILY SPEND CALCULATION
    String safeSpendText = "N/A";
    double safeDaily = 0;
    
    if (totalIncome > 0) {
       final remainingBudget = totalIncome - totalSpent;
       safeDaily = (remainingBudget > 0 && daysRemaining > 0) ? remainingBudget / daysRemaining : 0.0;
       safeSpendText = '₹${safeDaily.toStringAsFixed(0)}/day';
    } else {
       safeSpendText = "Set Income";
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text('Monthly Forecast', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ],
          ),
          const SizedBox(height: 20),
          
          // Row 1: Projection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Projected Total', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('₹${projectedTotal.toStringAsFixed(0)}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Container(height: 1, color: theme.colorScheme.outline.withOpacity(0.1)),
          const SizedBox(height: 20),
          
          // Row 2: The Actionable Advice
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle
                ),
                child: Icon(Icons.shield_outlined, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Safe Daily Limit', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'Spend max ', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14)),
                          TextSpan(text: safeSpendText, style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopSpenders(BuildContext context, List<dynamic> expenses, List<CategoryModel> categories) {
    final theme = Theme.of(context);
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
        Text('Top Spending Categories', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: top3.length,
            itemBuilder: (context, index) {
              final entry = top3[index];
              return Container(
                width: 150,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                         entry.key.isNotEmpty ? entry.key[0] : '?',
                         style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '₹${entry.value.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                    ),
                  ],
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
    final theme = Theme.of(context);
    final isOverBudget = !isSavings && current > target;
    final isUnderTarget = isSavings && current < target;
    final statusColor = (isOverBudget || isUnderTarget) ? theme.colorScheme.error : theme.colorScheme.tertiary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showCategoryDetails(context, title, description, isSavings),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4, height: 24,
                          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                        ),
                        const SizedBox(width: 12),
                        Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('${percentage.toStringAsFixed(1)}%', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(description, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (current / (isSavings ? (target * 2) : target)).clamp(0.0, 1.0),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: color,
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Spent: ₹${current.toStringAsFixed(0)}', style: theme.textTheme.bodyMedium),
                    Text('Goal: ${isSavings ? '≥' : '≤'} ₹${target.toStringAsFixed(0)}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                  ],
                ),
                if (isOverBudget || isUnderTarget) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isSavings 
                        ? 'You are below your savings target.' 
                        : 'You have exceeded your $title budget.',
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(BuildContext context, String title, String description, bool isSavings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, _) {
            final theme = Theme.of(context);
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

            return Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: theme.colorScheme.outline.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$title Expenses',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(description, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 24),
                  Expanded(
                    child: filteredExpenses.isEmpty
                        ? Center(child: Text('No expenses found.', style: TextStyle(color: theme.colorScheme.outline)))
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24),
                            itemCount: filteredExpenses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final expense = filteredExpenses[index];
                               return Container(
                                 decoration: BoxDecoration(
                                   color: theme.colorScheme.surfaceContainer,
                                   borderRadius: BorderRadius.circular(16),
                                 ),
                                 child: ListTile(
                                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                   leading: CircleAvatar(
                                     backgroundColor: theme.colorScheme.primaryContainer,
                                     child: Text(expense.category.isNotEmpty ? expense.category[0] : '?', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
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
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildSuggestions(BuildContext context, double needsPct, double wantsPct, double savingsPct, bool isIncomeAvailable) {
    final List<Widget> suggestions = [];
    final theme = Theme.of(context);

    if (!isIncomeAvailable) {
       suggestions.add(_buildSuggestionItem(
        context,
        'Set Income',
        'Add your income in "Salary" section to get personalized financial advice.',
        icon: Icons.info_outline,
        color: Colors.blue,
      ));
      return Column(children: suggestions);
    }

    if (needsPct > 50) {
      suggestions.add(_buildSuggestionItem(
        context,
        'Reduce Needs',
        'Your needs are taking up ${needsPct.toStringAsFixed(1)}% of your income. Look for ways to save.',
        onTap: () => _showCategoryDetails(context, 'Needs', 'Needs Expenses', false),
      ));
    }

    if (wantsPct > 30) {
      suggestions.add(_buildSuggestionItem(
        context,
        'Cut Down Wants',
        'Your wants are at ${wantsPct.toStringAsFixed(1)}%. Try cancelling unused subscriptions.',
        onTap: () => _showCategoryDetails(context, 'Wants', 'Discretionary Expenses', false),
      ));
    }

    if (savingsPct < 20) {
      suggestions.add(_buildSuggestionItem(
        context,
        'Boost Savings',
        'You are saving only ${savingsPct.toStringAsFixed(1)}%. Try to set aside at least 20%.',
        onTap: () => _showCategoryDetails(context, 'Savings', 'Savings & Investments', true),
      ));
    }

    if (suggestions.isEmpty) {
      suggestions.add(_buildSuggestionItem(
        context,
        'Great Job!',
        'You are balancing your finances perfectly according to the 50/30/20 rule!',
        icon: Icons.thumb_up_rounded,
        color: Colors.green,
      ));
    }

    return Column(children: suggestions);
  }

  Widget _buildSuggestionItem(BuildContext context, String title, String body, {IconData icon = Icons.lightbulb_rounded, Color color = Colors.amber, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(body, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
