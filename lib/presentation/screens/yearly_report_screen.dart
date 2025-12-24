import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../providers/yearly_stats_provider.dart';
import '../providers/expense_provider.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/salary_repository.dart';
import '../../data/repositories/salary_repository.dart';
import '../../core/utils/financial_calculator.dart';
import 'monthly_detailed_report_screen.dart';

class YearlyReportScreen extends ConsumerStatefulWidget {
  const YearlyReportScreen({super.key});

  @override
  ConsumerState<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends ConsumerState<YearlyReportScreen> {
  int _selectedYear = DateTime.now().year;

  Future<void> _generatePdf(List<MonthlyStat> stats) async {
    final pdf = pw.Document();
    
    // 1. Fetch RAW DATA for detailed charts
    // We need all expenses and income for the selected year to generate breakdown charts
    final allExpenses = await ref.read(expenseRepositoryProvider).getExpenses();
    final allSalaries = await ref.read(salaryRepositoryProvider).getSalaries();

    // Filter for selected year
    final yearExpenses = allExpenses.where((e) => e.date.year == _selectedYear && !e.isCreditCardBill).toList();
    final yearIncome = allSalaries.where((s) => s.date.year == _selectedYear).toList();

    // Helper to get PDF Color from String category
    PdfColor getPdfColor(String category) {
      // Simple hash-based color generation for PDF if specific mapping needed
      // Map common categories to PdfColors
      switch (category) {
        case 'Food': return PdfColors.orange;
        case 'Transport': return PdfColors.blue;
        case 'Shopping': return PdfColors.pink;
        case 'Bills': return PdfColors.red;
        case 'Entertainment': return PdfColors.purple;
        case 'Health': return PdfColors.green;
        case 'Education': return PdfColors.indigo;
        case 'Others': return PdfColors.grey;
        case 'Investments': return PdfColors.teal;
        case 'Salary': return PdfColors.green;
        case 'Business': return PdfColors.blueAccent;
        case 'Gift': return PdfColors.amber;
        default: 
           // Hash generation
           final colors = [PdfColors.blue, PdfColors.red, PdfColors.green, PdfColors.orange, PdfColors.purple, PdfColors.teal];
           return colors[category.hashCode % colors.length];
      }
    }

    // Calculate totals for Summary Page
    double totalIncome = 0;
    double totalExpense = 0;
    for (var s in stats) {
      totalIncome += s.income;
      totalExpense += s.expense;
    }
    double totalSaved = totalIncome - totalExpense;

    // Y-Axis Max for Chart
    double maxYIn = 0;
    double maxYEx = 0;
    for (var s in stats) {
       if (s.income > maxYIn) maxYIn = s.income;
       if (s.expense > maxYEx) maxYEx = s.expense;
    }
    double paramsMaxY = (maxYIn > maxYEx ? maxYIn : maxYEx) * 1.2; 
    if (paramsMaxY == 0) paramsMaxY = 1000; // Default if no data

    // --- PAGE 1: YEARLY SUMMARY & TREND ---
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Yearly Financial Report - $_selectedYear', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              
              // Summary Box
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(children: [pw.Text('Total Income'), pw.Text('INR ${totalIncome.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.green))]),
                    pw.Column(children: [pw.Text('Total Expense'), pw.Text('INR ${totalExpense.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.red))]),
                    pw.Column(children: [pw.Text('Net Savings'), pw.Text('INR ${totalSaved.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18, color: PdfColors.blue))]),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Yearly Trend Chart (Bar Chart)
              pw.Text('Monthly Trend', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.SizedBox(
                height: 200,
                child: pw.Chart(
                  grid: pw.CartesianGrid(
                    xAxis: pw.FixedAxis(
                      List.generate(12, (i) => i), 
                    ),
                    yAxis: pw.FixedAxis(
                      [0, paramsMaxY * 0.2, paramsMaxY * 0.4, paramsMaxY * 0.6, paramsMaxY * 0.8, paramsMaxY],
                      divisions: true,
                    ),
                  ),
                  datasets: [
                    pw.BarDataSet(
                      color: PdfColors.blue300,
                      legend: 'Income',
                      width: 10,
                      data: stats.map((s) => pw.PointChartValue(s.month.toDouble() - 1, s.income)).toList(),
                    ),
                    pw.BarDataSet(
                      color: PdfColors.red300,
                      legend: 'Expense',
                      width: 10,
                      data: stats.map((s) => pw.PointChartValue(s.month.toDouble() - 1, s.expense)).toList(),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Simple Table Summary
               pw.Table.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignment: pw.Alignment.centerLeft,
                headers: <String>['Month', 'Income', 'Expense', 'Balance'],
                data: stats.map((stat) {
                  return <String>[
                    DateFormat('MMMM').format(DateTime(_selectedYear, stat.month)),
                    '${stat.income.toStringAsFixed(0)}',
                    '${stat.expense.toStringAsFixed(0)}',
                    '${stat.balance.toStringAsFixed(0)}',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    // Helper to process chart data (Group small values)
    List<MapEntry<String, double>> processChartData(Map<String, double> data) {
      if (data.isEmpty) return [];
      var sorted = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      if (sorted.length <= 6) return sorted;
      
      // Take top 5
      var top5 = sorted.take(5).toList();
      // Sum rest
      double others = sorted.skip(5).fold(0, (sum, e) => sum + e.value);
      if (others > 0) {
        top5.add(MapEntry('Others', others));
      }
      return top5;
    }

    // --- MONTHLY DETAILED PAGES ---
    // Iterate through months (only those with data or all 12?)
    // Let's iterate all 12 months for consistency
    for (int month = 1; month <= 12; month++) {
      final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, month));
      
      // Filter Data for Month
      final mExpenses = yearExpenses.where((e) => e.date.month == month).toList();
      final mIncome = yearIncome.where((s) => s.date.month == month).toList();

      if (mExpenses.isEmpty && mIncome.isEmpty) continue; // Skip empty months

      // Calculate Chart Data
      // Expense by Category
      final expByCategory = <String, double>{};
      for (var e in mExpenses) {
        expByCategory[e.category] = (expByCategory[e.category] ?? 0) + e.amount;
      }
      
      // Income by Source (Category)
      final incBySource = <String, double>{};
      for (var i in mIncome) {
         // SalaryModel usually needs a category/title? Assuming 'category' or 'title'
         // SalaryModel: id, date, amount, description. No category field? 
         // Assuming description or 'Salary' generic.
         // Let's use 'Salary' as default if no detailed source available in model, or use description grouped?
         // SalaryModel definition check: String description.
         incBySource[i.source] = (incBySource[i.source] ?? 0) + i.amount;
      }

      double mTotalExp = mExpenses.fold(0, (sum, e) => sum + e.amount);
      double mTotalInc = mIncome.fold(0, (sum, i) => sum + i.amount);

      final finalExpData = processChartData(expByCategory);
      final finalIncData = processChartData(incBySource);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(level: 1, child: pw.Text('$monthName $_selectedYear Details', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
                pw.SizedBox(height: 10),
                
                // Overview Bar (similar to App UI)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Income: ${mTotalInc.toStringAsFixed(0)}', style: const pw.TextStyle(color: PdfColors.green)),
                    pw.Text('Expense: ${mTotalExp.toStringAsFixed(0)}', style: const pw.TextStyle(color: PdfColors.red)),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.SizedBox(
                  height: 10,
                  child: pw.Stack(
                    children: [
                      pw.Container(
                        color: PdfColors.grey200,
                        width: double.infinity,
                      ),
                      if (mTotalInc > 0)
                        pw.Container(
                          width: (mTotalExp > mTotalInc ? 1.0 : mTotalExp / mTotalInc) * 450, // rough width mapping
                          color: (mTotalExp > mTotalInc) ? PdfColors.red : ((mTotalExp / mTotalInc) > 0.8 ? PdfColors.orange : PdfColors.green),
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Charts Row
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    // Expense Pie Chart
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text('Expense Breakdown', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          pw.SizedBox(height: 10),
                          pw.SizedBox(
                            height: 150,
                            child: pw.Chart(
                              title: pw.Text('Expenses'),
                              grid: pw.PieGrid(),
                              datasets: finalExpData.map((e) {
                                return pw.PieDataSet(
                                  legend: '${e.key} (${(e.value/mTotalExp*100).toStringAsFixed(0)}%)',
                                  value: e.value,
                                  color: getPdfColor(e.key),
                                  legendStyle: const pw.TextStyle(fontSize: 8),
                                  legendPosition: pw.PieLegendPosition.outside, // Try outside to avoid overlap
                                  offset: 10,
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    // Income Pie Chart
                    pw.Expanded(
                      child: pw.Column(
                        children: [
                          pw.Text('Income Breakdown', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                          pw.SizedBox(height: 10),
                           mIncome.isNotEmpty 
                           ? pw.SizedBox(
                              height: 150,
                              child: pw.Chart(
                                title: pw.Text('Income'),
                                grid: pw.PieGrid(),
                                datasets: finalIncData.map((e) {
                                  return pw.PieDataSet(
                                    legend: '${e.key} (${(e.value/mTotalInc*100).toStringAsFixed(0)}%)',
                                    value: e.value,
                                    color: PdfColors.green, 
                                    legendStyle: const pw.TextStyle(fontSize: 9),
                                    legendPosition: pw.PieLegendPosition.outside,
                                    offset: 25, // Increased offset for better spacing
                                  );
                                }).toList(),
                              ),
                            )
                           : pw.Text('No Income Records'),
                        ],
                      ),
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 20),
                
                // Top Expenses List (Top 5)
                pw.Text('Top Expenses', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Table.fromTextArray(
                  context: context,
                   border: null,
                   headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
                   headers: ['Date', 'Title', 'Category', 'Amount'],
                   data: mExpenses.take(10).map((e) => [ // Show top 10? or recent 10? Sort by amount?
                      DateFormat('MMM d').format(e.date),
                      e.title,
                      e.category,
                      e.amount.toStringAsFixed(0)
                   ]).toList(),
                ),

              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Kanakupulla_Full_Report_$_selectedYear',
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(yearlyStatsProvider(_selectedYear));
    final allExpensesAsync = ref.watch(allExpensesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Yearly Overview', 
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
        ),
        centerTitle: false,
        actions: [
          statsAsync.when(
            data: (stats) => IconButton(
              icon: Icon(Icons.picture_as_pdf_rounded, color: theme.colorScheme.primary),
              tooltip: 'Export PDF',
              onPressed: () => _generatePdf(stats),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Year Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: () {
                      setState(() {
                        _selectedYear--;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '$_selectedYear',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: () {
                      setState(() {
                        _selectedYear++;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: statsAsync.when(
              data: (stats) {
                // Calculate Yearly Totals
                double totalIncome = 0;
                double totalExpense = 0;
                for (var s in stats) {
                  totalIncome += s.income;
                  totalExpense += s.expense;
                }
                double totalSaved = totalIncome - totalExpense;

                return ListView( // Changed to ListView for better scrolling if content overflows
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    // Yearly Summary Card
                     Container(
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
                        children: [
                          Text(
                            'NET SAVINGS',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white.withOpacity(0.8), 
                              letterSpacing: 1.2, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₹${totalSaved.toStringAsFixed(0)}',
                            style: theme.textTheme.displayMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                        child: const Icon(Icons.arrow_downward_rounded, color: Colors.greenAccent, size: 16)
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Income', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${totalIncome.toStringAsFixed(0)}',
                                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Container(height: 40, width: 1, color: Colors.white.withOpacity(0.2)),
                              Column(
                                children: [
                                   Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                                        child: const Icon(Icons.arrow_upward_rounded, color: Colors.redAccent, size: 16)
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Expense', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8))),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${totalExpense.toStringAsFixed(0)}',
                                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    
                    // NEW: Inflation/Lifestyle Watch
                    if (allExpensesAsync.value != null && allExpensesAsync.value!.isNotEmpty)
                      _buildInflationWatch(stats, allExpensesAsync.value!),

                    const SizedBox(height: 24),
                    
                    Text('Monthly Breakdown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    // Monthly List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final stat = stats[index];
                        final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, stat.month));
                        final isSaved = stat.balance >= 0;
                        final percentage = stat.income > 0 ? (stat.expense / stat.income) : (stat.expense > 0 ? 1.0 : 0.0);
                        
                        return Container( // Replaced Card with Container for cleaner look
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                            ]
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MonthlyDetailedReportScreen(
                                    month: stat.month,
                                    year: _selectedYear,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        monthName,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSaved ? Colors.green.withOpacity(0.1) : theme.colorScheme.error.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isSaved ? '+ ₹${stat.balance.toStringAsFixed(0)}' : '- ₹${stat.balance.abs().toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: isSaved ? Colors.green[700] : theme.colorScheme.error,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Income: ₹${stat.income.toStringAsFixed(0)}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                      Text('Spent: ₹${stat.expense.toStringAsFixed(0)}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percentage > 1 ? 1 : percentage,
                                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        percentage > 1 ? theme.colorScheme.error : (percentage > 0.8 ? Colors.orangeAccent : Colors.greenAccent),
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading data: $e', style: TextStyle(color: theme.colorScheme.error))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInflationWatch(List<MonthlyStat> stats, List<dynamic> allExpenses) {
    final theme = Theme.of(context);
    // Filter expenses for current year
    final expenses = allExpenses.where((e) => e.date.year == _selectedYear).toList();
    // Logic: Compare Avg Spend of [first 3 available months] vs [last 3 available months]
    // Filter out bills for consumption logic (if not done by calculator usage below)
    if (expenses.isEmpty) return const SizedBox.shrink();

    // Use stats to determine active months
    final months = stats.map((s) => s.month).toSet().toList()..sort();
    
    // Check if we have enough data (need at least 3 months for reliable trend)
    if (months.length < 3) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
           children: [
             Icon(Icons.info_outline_rounded, color: theme.colorScheme.onSurfaceVariant),
             const SizedBox(width: 8),
             Expanded(
               child: Text(
                 'Inflation Watch requires at least 3 months of data to detect trends.',
                 style: theme.textTheme.bodyMedium?.copyWith(
                   color: theme.colorScheme.onSurfaceVariant, 
                   fontStyle: FontStyle.italic
                 ),
               ),
             ),
           ],
        ),
      );
    }

    // Logic: Compare Avg Spend of [first 3 available months] vs [last 3 available months]
    
    final earlyMonths = months.take(3).toList();
    final lateMonths = months.reversed.take(3).toList(); // Last 3, reversed order (latest first)

    double getAvgForCategory(List<int> targetMonths, String category) {
      double total = 0;
      for (var m in targetMonths) {
        final monthlyExp = expenses.where((e) => e.date.month == m && e.category == category).cast<ExpenseModel>().toList();
        // Use FinancialCalculator to sum valid expenses (excluding bills)
        final sum = FinancialCalculator.calculateTotalExpense(monthlyExp);
        total += sum;
      }
      return targetMonths.isEmpty ? 0 : total / targetMonths.length;
    }

    // Identify Categories
    final categories = expenses.map((e) => e.category).toSet();
    final alerts = <Map<String, dynamic>>[];

    for (var cat in categories) {
      final earlyAvg = getAvgForCategory(earlyMonths, cat);
      final lateAvg = getAvgForCategory(lateMonths, cat);
      
      // Thresholds: Significant spend (> 500) and > 15% increase
      if (earlyAvg > 500) { 
        final increase = lateAvg - earlyAvg;
        final pct = (increase / earlyAvg) * 100;
        
        if (pct > 15) { 
            alerts.add({
              'category': cat,
              'pct': pct,
              'early': earlyAvg,
              'late': lateAvg,
            });
        }
      }
    }

    if (alerts.isEmpty) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withOpacity(0.1)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
             children: [
               const Icon(Icons.check_circle_outline_rounded, color: Colors.green),
               const SizedBox(width: 12),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text('Lifestyle Watch', style: theme.textTheme.titleSmall?.copyWith(color: Colors.green[800], fontWeight: FontWeight.bold)),
                     const SizedBox(height: 2),
                     Text(
                       'Great! No significant spending increases detected.',
                       style: theme.textTheme.bodyMedium?.copyWith(color: Colors.green[700]),
                     ),
                   ],
                 ),
               ),
             ],
          ),
        );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             children: [
               Icon(Icons.trending_up, color: Colors.orange[800]),
               const SizedBox(width: 12),
               Text('Inflation & Lifestyle Watch', style: theme.textTheme.titleMedium?.copyWith(color: Colors.orange[800], fontWeight: FontWeight.bold)),
             ],
           ),
           const SizedBox(height: 12),
           Text(
             'Comparing average spending of the first 3 months vs last 3 months:', 
             style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange[900]),
           ),
           const SizedBox(height: 12),
           ...alerts.map((alert) => Padding(
             padding: const EdgeInsets.only(bottom: 8.0),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Icon(Icons.arrow_right_rounded, color: theme.colorScheme.error, size: 20),
                 Expanded(
                   child: RichText(
                     text: TextSpan(
                       style: theme.textTheme.bodyMedium,
                       children: [
                         TextSpan(text: '${alert['category']} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                         const TextSpan(text: 'rose by '),
                         TextSpan(text: '${alert['pct'].toStringAsFixed(0)}%', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                         TextSpan(text: ' (₹${alert['early'].toStringAsFixed(0)} → ₹${alert['late'].toStringAsFixed(0)})', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                       ],
                     ),
                   ),
                 ),
               ],
             ),
           )),
        ],
      ),
    );
  }
}
