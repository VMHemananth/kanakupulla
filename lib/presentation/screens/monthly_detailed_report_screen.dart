import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/salary_repository.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/salary_model.dart';
import '../../core/utils/category_colors.dart';
import '../../core/utils/financial_calculator.dart';

class MonthlyDetailedReportScreen extends ConsumerStatefulWidget {
  final int month;
  final int year;

  const MonthlyDetailedReportScreen({
    super.key,
    required this.month,
    required this.year,
  });

  @override
  ConsumerState<MonthlyDetailedReportScreen> createState() => _MonthlyDetailedReportScreenState();
}

class _MonthlyDetailedReportScreenState extends ConsumerState<MonthlyDetailedReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<ExpenseModel> _expenses = [];
  List<SalaryModel> _incomes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final expenseRepo = ref.read(expenseRepositoryProvider);
      final salaryRepo = ref.read(salaryRepositoryProvider);

      final allExpenses = await expenseRepo.getExpenses();
      final allSalaries = await salaryRepo.getSalaries();

      if (mounted) {
        setState(() {
          _expenses = allExpenses.where((e) => 
            e.date.year == widget.year && e.date.month == widget.month
          ).toList();
          
          _incomes = allSalaries.where((s) => 
            s.date.year == widget.year && s.date.month == widget.month
          ).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final monthName = DateFormat('MMMM yyyy').format(DateTime(widget.year, widget.month));

    return Scaffold(
      appBar: AppBar(
        title: Text(monthName),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(theme),
                _buildIncomeTab(theme),
                _buildExpenseTab(theme),
              ],
            ),
    );
  }



  Widget _buildOverviewTab(ThemeData theme) {
    double totalIncome = FinancialCalculator.calculateTotalIncome(_incomes);
    double totalExpense = FinancialCalculator.calculateTotalExpense(_expenses);
    double savings = FinancialCalculator.calculateNetSavings(totalIncome, totalExpense);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primaryContainer, theme.colorScheme.surface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                 Text('Net Savings', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                 const SizedBox(height: 12),
                 Text(
                   '₹${savings.toStringAsFixed(0)}',
                   style: theme.textTheme.displayMedium?.copyWith(
                     fontWeight: FontWeight.bold,
                     color: savings >= 0 ? Colors.green : theme.colorScheme.error,
                   ),
                 ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Income vs Expense', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.3,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: theme.colorScheme.surfaceContainerHighest,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        rod.toY.toStringAsFixed(0),
                        TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            val == 0 ? 'Income' : (val == 1 ? 'Expense' : ''),
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: totalIncome, 
                        color: Colors.green, 
                        width: 50, 
                        borderRadius: BorderRadius.circular(12),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2,
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        ),
                      )
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: totalExpense, 
                        color: theme.colorScheme.error, 
                        width: 50, 
                        borderRadius: BorderRadius.circular(12),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2,
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomeTab(ThemeData theme) {
    if (_incomes.isEmpty) {
      return Center(child: Text('No income records for this month', style: TextStyle(color: theme.colorScheme.outline)));
    }

    // Group by Source
    Map<String, double> sourceTotals = {};
    for (var i in _incomes) {
      sourceTotals[i.source] = (sourceTotals[i.source] ?? 0) + i.amount;
    }
    
    final sortedEntries = sourceTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    double total = _incomes.fold(0, (sum, e) => sum + e.amount);

    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sortedEntries.map((e) {
                final isTouched = false; 
                final color = Colors.primaries[sortedEntries.indexOf(e) % Colors.primaries.length];
                return PieChartSectionData(
                  value: e.value,
                  title: '${(e.value / total * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  color: color,
                  badgeWidget: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    child: Text(e.key, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  badgePositionPercentageOffset: 1.2,
                );
              }).toList(),
              sectionsSpace: 4,
              centerSpaceRadius: 50,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: sortedEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.primaries[index % Colors.primaries.length].withOpacity(0.2),
                    child: Icon(Icons.attach_money, color: Colors.primaries[index % Colors.primaries.length], size: 20),
                  ),
                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('₹${entry.value.toStringAsFixed(0)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTab(ThemeData theme) {
    if (_expenses.isEmpty) {
      return Center(child: Text('No expenses records for this month', style: TextStyle(color: theme.colorScheme.outline)));
    }

    // Group by Category
    Map<String, double> catTotals = {};
    double total = 0;
    
    for (var e in _expenses) {
       // Correct Logic: Count Consumption (Purchases), Exclude Bill Payments
       if (e.isCreditCardBill) continue; 
       
       catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
       total += e.amount;
    }

    final sortedEntries = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (total == 0) {
       return Center(child: Text('No valid expenses (e.g. only credit card usage)', style: TextStyle(color: theme.colorScheme.outline)));
    }

    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sections: sortedEntries.map((e) {
                return PieChartSectionData(
                  value: e.value,
                  title: '${(e.value / total * 100).toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  color: CategoryColors.getColor(e.key),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: sortedEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              return Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: CategoryColors.getColor(entry.key).withOpacity(0.2),
                    radius: 20,
                    child: Text(entry.key.isNotEmpty ? entry.key[0] : '?', style: TextStyle(color: CategoryColors.getColor(entry.key), fontWeight: FontWeight.bold)),
                  ),
                  title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('₹${entry.value.toStringAsFixed(0)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
