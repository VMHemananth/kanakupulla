import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/salary_repository.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/salary_model.dart';
import '../../core/utils/category_colors.dart';

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

      setState(() {
        _expenses = allExpenses.where((e) => 
          e.date.year == widget.year && e.date.month == widget.month
        ).toList();
        
        _incomes = allSalaries.where((s) => 
          s.date.year == widget.year && s.date.month == widget.month
        ).toList();
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(DateTime(widget.year, widget.month));

    return Scaffold(
      appBar: AppBar(
        title: Text(monthName),
        bottom: TabBar(
          controller: _tabController,
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
                _buildOverviewTab(),
                _buildIncomeTab(),
                _buildExpenseTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    double totalIncome = _incomes.fold(0, (sum, e) => sum + e.amount);
    double totalExpense = _expenses.fold(0, (sum, e) => sum + e.amount);
    double savings = totalIncome - totalExpense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                   const Text('Net Savings', style: TextStyle(fontSize: 16, color: Colors.grey)),
                   const SizedBox(height: 8),
                   Text(
                     '₹${savings.toStringAsFixed(0)}',
                     style: TextStyle(
                       fontSize: 32, 
                       fontWeight: FontWeight.bold,
                       color: savings >= 0 ? Colors.green : Colors.red,
                     ),
                   ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.3,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const Text('Income');
                        if (val == 1) return const Text('Expense');
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(toY: totalIncome, color: Colors.green, width: 40, borderRadius: BorderRadius.circular(4))
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(toY: totalExpense, color: Colors.red, width: 40, borderRadius: BorderRadius.circular(4))
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

  Widget _buildIncomeTab() {
    if (_incomes.isEmpty) {
      return const Center(child: Text('No income records for this month'));
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
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sortedEntries.map((e) {
                final isTouched = false; // Simple version
                return PieChartSectionData(
                  value: e.value,
                  title: '${(e.value / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  color: Colors.primaries[sortedEntries.indexOf(e) % Colors.primaries.length],
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.primaries[index % Colors.primaries.length],
                  child: const Icon(Icons.attach_money, color: Colors.white, size: 16),
                ),
                title: Text(entry.key),
                trailing: Text('₹${entry.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseTab() {
    if (_expenses.isEmpty) {
      return const Center(child: Text('No expenses records for this month'));
    }

    // Group by Category
    Map<String, double> catTotals = {};
    double total = 0;
    
    for (var e in _expenses) {
       // Filter out credit card bills to avoid double counting if needed, or keep all
       // Assuming standard logic:
       if (e.paymentMethod == 'Credit Card' && !e.isCreditCardBill) continue; 
       
       catTotals[e.category] = (catTotals[e.category] ?? 0) + e.amount;
       total += e.amount;
    }

    final sortedEntries = catTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: [
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sortedEntries.map((e) {
                return PieChartSectionData(
                  value: e.value,
                  title: '${(e.value / total * 100).toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  color: CategoryColors.getColor(e.key),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: CategoryColors.getColor(entry.key),
                  radius: 16,
                ),
                title: Text(entry.key),
                trailing: Text('₹${entry.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              );
            },
          ),
        ),
      ],
    );
  }
}
