import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';
import '../../data/services/pdf_service.dart';
import '../../core/utils/financial_calculator.dart';

class MonthlyCompareScreen extends ConsumerStatefulWidget {
  const MonthlyCompareScreen({super.key});

  @override
  ConsumerState<MonthlyCompareScreen> createState() => _MonthlyCompareScreenState();
}


class _MonthlyCompareScreenState extends ConsumerState<MonthlyCompareScreen> {
  // ... existing variables ...
  int month1 = DateTime.now().month;
  int year1 = DateTime.now().year;
  int month2 = DateTime.now().month == 1 ? 12 : DateTime.now().month - 1;
  int year2 = DateTime.now().month == 1 ? DateTime.now().year - 1 : DateTime.now().year;

  final List<String> monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(allExpensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Compare'),
        actions: [
           expensesAsync.when(
             data: (expenses) => IconButton(
               icon: const Icon(Icons.picture_as_pdf),
               tooltip: 'Export Report',
               onPressed: () => _exportPdf(expenses),
             ),
             loading: () => const SizedBox.shrink(),
             error: (_, __) => const SizedBox.shrink(),
           ),
        ],
      ),
      body: expensesAsync.when(
        data: (allExpenses) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthSelectors(),
                const SizedBox(height: 24),
                const Text('Expense Trend (Last 6 Months)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildTrendChart(allExpenses),
                const SizedBox(height: 24),
                const Text('Category Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildComparisonChart(allExpenses),
                const SizedBox(height: 24),
                const Text('Detailed Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildDetailedList(allExpenses),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  // ... _buildMonthSelectors omitted ...
  Widget _buildMonthSelectors() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Month 1', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: month1,
                      items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(monthNames[i]))),
                      onChanged: (m) { if (m != null) setState(() => month1 = m); },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: year1,
                      items: List.generate(5, (i) {
                        int year = DateTime.now().year - 2 + i;
                        return DropdownMenuItem(value: year, child: Text(year.toString()));
                      }),
                      onChanged: (y) { if (y != null) setState(() => year1 = y); },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Month 2', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: month2,
                      items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(monthNames[i]))),
                      onChanged: (m) { if (m != null) setState(() => month2 = m); },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      value: year2,
                      items: List.generate(5, (i) {
                        int year = DateTime.now().year - 2 + i;
                        return DropdownMenuItem(value: year, child: Text(year.toString()));
                      }),
                      onChanged: (y) { if (y != null) setState(() => year2 = y); },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ... _buildTrendChart omitted (assume same) ...
  Widget _buildTrendChart(List<ExpenseModel> allExpenses) {
    // Calculate last 6 months totals
    final now = DateTime.now();
    final trendData = <FlSpot>[];
    double maxTotal = 0;

    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final monthlyExpenses = allExpenses
          .where((e) => e.date.year == date.year && e.date.month == date.month)
          .toList();
      final total = FinancialCalculator.calculateTotalExpense(monthlyExpenses);
      
      trendData.add(FlSpot((5 - i).toDouble(), total));
      if (total > maxTotal) maxTotal = total;
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index > 5) return const Text('');
                  final date = DateTime(now.year, now.month - (5 - index), 1);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(monthNames[date.month - 1], style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: trendData,
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
          maxY: maxTotal * 1.2, // Add some padding
        ),
      ),
    );
  }

  // ... _buildComparisonChart omitted (assume same) ...
  Widget _buildComparisonChart(List<ExpenseModel> allExpenses) {
    final expenses1 = allExpenses.where((e) => e.date.month == month1 && e.date.year == year1).toList();
    final expenses2 = allExpenses.where((e) => e.date.month == month2 && e.date.year == year2).toList();

    final allCats = <String>{};
    for (var e in expenses1) allCats.add(e.category);
    for (var e in expenses2) allCats.add(e.category);
    final catList = allCats.toList()..sort();

    final totals1 = {for (var c in catList) c: FinancialCalculator.calculateTotalExpense(expenses1.where((e) => e.category == c).toList())};
    final totals2 = {for (var c in catList) c: FinancialCalculator.calculateTotalExpense(expenses2.where((e) => e.category == c).toList())};

    if (catList.isEmpty) return const Center(child: Text('No data to compare'));
    
     // Find max value for scaling
    double maxY = 0;
    for (var cat in catList) {
      if ((totals1[cat] ?? 0) > maxY) maxY = totals1[cat]!;
      if ((totals2[cat] ?? 0) > maxY) maxY = totals2[cat]!;
    }

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY * 1.1,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final cat = catList[group.x.toInt()];
                final value = rod.toY;
                final monthName = rodIndex == 0 ? monthNames[month1 - 1] : monthNames[month2 - 1];
                return BarTooltipItem(
                  '$cat\n$monthName: ₹${value.toStringAsFixed(0)}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= catList.length) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        catList[index].length > 6 ? '${catList[index].substring(0, 6)}...' : catList[index],
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
                reservedSize: 40,
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(catList.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: totals1[catList[i]] ?? 0,
                  color: Colors.blue,
                  width: 10,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                ),
                BarChartRodData(
                  toY: totals2[catList[i]] ?? 0,
                  color: Colors.green,
                  width: 10,
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDetailedList(List<ExpenseModel> allExpenses) {
    final expenses1 = allExpenses.where((e) => e.date.month == month1 && e.date.year == year1).toList();
    final expenses2 = allExpenses.where((e) => e.date.month == month2 && e.date.year == year2).toList();

    final allCats = <String>{};
    for (var e in expenses1) allCats.add(e.category);
    for (var e in expenses2) allCats.add(e.category);
    final catList = allCats.toList()..sort();

    final totals1 = {for (var c in catList) c: FinancialCalculator.calculateTotalExpense(expenses1.where((e) => e.category == c).toList())};
    final totals2 = {for (var c in catList) c: FinancialCalculator.calculateTotalExpense(expenses2.where((e) => e.category == c).toList())};

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: catList.length,
      itemBuilder: (context, index) {
        final cat = catList[index];
        final amt1 = totals1[cat] ?? 0;
        final amt2 = totals2[cat] ?? 0;
        final diff = amt1 - amt2;
        final isIncrease = diff > 0;
        final diffColor = isIncrease ? Colors.red : Colors.green;
        final diffIcon = isIncrease ? Icons.arrow_upward : Icons.arrow_downward;
        
        // Calculate Percentage Change
        String percentStr = '0%';
        if (amt2 != 0) {
           final p = ((diff / amt2) * 100).abs();
           percentStr = '${p.toStringAsFixed(1)}%';
        } else if (amt1 > 0) {
           percentStr = '100%';
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${monthNames[month1 - 1]}: ₹${amt1.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue)),
                      Text('${monthNames[month2 - 1]}: ₹${amt2.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(diffIcon, size: 16, color: diffColor),
                      Text(
                        ' ₹${diff.abs().toStringAsFixed(0)} ',
                        style: TextStyle(color: diffColor, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '($percentStr)', 
                         style: TextStyle(color: diffColor, fontSize: 12),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportPdf(List<ExpenseModel> allExpenses) async {
     // Prepare Data for PDF
     final now = DateTime.now();
     
     // 1. Trend Data
     final trendValues = <double>[];
     final trendLabels = <String>[];
     for (int i = 5; i >= 0; i--) {
        final date = DateTime(now.year, now.month - i, 1);
        final monthlyExpenses = allExpenses
            .where((e) => e.date.year == date.year && e.date.month == date.month).toList();
        final total = FinancialCalculator.calculateTotalExpense(monthlyExpenses);
        trendValues.add(total);
        trendLabels.add(monthNames[date.month - 1]);
     }

     // 2. Comparison Data
     final expenses1 = allExpenses.where((e) => e.date.month == month1 && e.date.year == year1).toList();
     final expenses2 = allExpenses.where((e) => e.date.month == month2 && e.date.year == year2).toList();
     final allCats = <String>{};
     for (var e in expenses1) allCats.add(e.category);
     for (var e in expenses2) allCats.add(e.category);
     final catList = allCats.toList()..sort();
     
     final totals1 = {for (var c in catList) c: FinancialCalculator.calculateTotalExpense(expenses1.where((e) => e.category == c).toList())};
     final totals2 = {for (var c in catList) c: FinancialCalculator.calculateTotalExpense(expenses2.where((e) => e.category == c).toList())};

     // Call Service
     try {
       await PdfService().generateMonthlyCompareReport(
         month1Title: '${monthNames[month1 - 1]} $year1',
         month2Title: '${monthNames[month2 - 1]} $year2',
         trendData: trendValues,
         trendLabels: trendLabels,
         categories: catList,
         totals1: totals1,
         totals2: totals2,
       );
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report generated successfully')));
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
       }
     }
  }
}
