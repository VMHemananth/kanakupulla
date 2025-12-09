import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../providers/yearly_stats_provider.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/repositories/salary_repository.dart';
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
    final yearExpenses = allExpenses.where((e) => e.date.year == _selectedYear).toList();
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
                                    legendStyle: const pw.TextStyle(fontSize: 8),
                                    legendPosition: pw.PieLegendPosition.outside,
                                    offset: 10,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yearly Financial Overview'),
        centerTitle: true,
        actions: [
          statsAsync.when(
            data: (stats) => IconButton(
              icon: const Icon(Icons.print),
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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      _selectedYear--;
                    });
                  },
                ),
                Text(
                  '$_selectedYear',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      _selectedYear++;
                    });
                  },
                ),
              ],
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

                return Column(
                  children: [
                    // Yearly Summary Card
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      color: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              'YEARLY SUMMARY',
                              style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Money In', style: TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${totalIncome.toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(height: 40, width: 1, color: Colors.white24),
                                Column(
                                  children: [
                                    const Text('Money Out', style: TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${totalExpense.toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 8),
                            Text(
                              'Total Saved: ₹${totalSaved.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              totalSaved >= 0 
                                ? 'Great job! You are in the green.' 
                                : 'Warning: Expenses exceeded income.',
                              style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    
                    // Monthly List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: stats.length,
                        itemBuilder: (context, index) {
                          final stat = stats[index];
                          final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, stat.month));
                          final isSaved = stat.balance >= 0;
                          final percentage = stat.income > 0 ? (stat.expense / stat.income) : (stat.expense > 0 ? 1.0 : 0.0);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          monthName,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isSaved ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            isSaved ? 'Saved ₹${stat.balance.toStringAsFixed(0)}' : 'Overspent ₹${stat.balance.abs().toStringAsFixed(0)}',
                                            style: TextStyle(
                                              color: isSaved ? Colors.green[700] : Colors.red[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Income: ₹${stat.income.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                        Text('Spent: ₹${stat.expense.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: percentage > 1 ? 1 : percentage,
                                        backgroundColor: Colors.green.withValues(alpha: 0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          percentage > 1 ? Colors.red : (percentage > 0.8 ? Colors.orange : Colors.green),
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
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading data: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
