import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';
import '../models/split_models.dart';
import '../models/debt_model.dart';

class PdfService {
  Future<void> generateExpenseReport(List<ExpenseModel> expenses) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    // Sort expenses by date
    expenses.sort((a, b) => b.date.compareTo(a.date));

    final totalAmount = expenses.fold<double>(0, (sum, item) => sum + item.amount);

    // Calculate Category Totals
    final categoryTotals = <String, double>{};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    // Sort by value desc
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Colors helper (Simple Mapping)
    PdfColor getCategoryColor(String category) {
      switch (category) {
        case 'Food': return PdfColors.orange;
        case 'Transport': return PdfColors.blue;
        case 'Shopping': return PdfColors.purple;
        case 'Bills': return PdfColors.red;
        case 'Entertainment': return PdfColors.pink;
        case 'Health': return PdfColors.cyan;
        case 'Education': return PdfColors.yellow;
        case 'Others': return PdfColors.grey;
        case 'Salary': return PdfColors.green;
        case 'Rent': return PdfColors.brown;
        default: return PdfColors.blueGrey;
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Expense Report', style: pw.TextStyle(font: boldFont, fontSize: 24)),
                pw.Text(DateFormat('MMMM yyyy').format(expenses.firstOrNull?.date ?? DateTime.now()), style: pw.TextStyle(font: font, fontSize: 18)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Summary Row
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
            children: [
              pw.Column(children: [
                pw.Text('Total Expenses', style: pw.TextStyle(font: font, fontSize: 14)),
                pw.Text('INR ${totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(font: boldFont, fontSize: 20, color: PdfColors.red)),
              ]),
              pw.Column(children: [
                pw.Text('Transaction Count', style: pw.TextStyle(font: font, fontSize: 14)),
                pw.Text('${expenses.length}', style: pw.TextStyle(font: boldFont, fontSize: 20)),
              ]),
            ],
          ),
          pw.SizedBox(height: 30),

          // Pie Chart
          if (sortedCategories.isNotEmpty)
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Category Breakdown', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                pw.SizedBox(height: 15),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.SizedBox(
                        height: 200,
                        child: pw.Chart(
                          title: pw.Text('Expenses by Category'),
                          grid: pw.PieGrid(),
                          datasets: sortedCategories.map((e) {
                            final percentage = (e.value / totalAmount * 100).toStringAsFixed(1);
                            return pw.PieDataSet(
                              legend: '$percentage%',
                              value: e.value,
                              color: getCategoryColor(e.key),
                              legendStyle: const pw.TextStyle(fontSize: 10),
                              legendPosition: pw.PieLegendPosition.outside,
                              offset: 10,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 20),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: sortedCategories.map((e) {
                          final percentage = (e.value / totalAmount * 100).toStringAsFixed(1);
                          return pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(vertical: 2),
                            child: pw.Row(
                              children: [
                                pw.Container(
                                  width: 10,
                                  height: 10,
                                  color: getCategoryColor(e.key),
                                ),
                                pw.SizedBox(width: 5),
                                pw.Expanded(
                                  child: pw.Text(
                                    '${e.key}: ${e.value.toStringAsFixed(0)} ($percentage%)',
                                    style: pw.TextStyle(font: font, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
              ],
            ),

          pw.Text('Detailed Transactions', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(font: boldFont),
            cellStyle: pw.TextStyle(font: font),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['Date', 'Title', 'Category', 'Amount'],
            columnWidths: {
              0: const pw.FixedColumnWidth(60),
              1: const pw.FlexColumnWidth(),
              2: const pw.FixedColumnWidth(80),
              3: const pw.FixedColumnWidth(70),
            },
            data: expenses.map((e) => [
              DateFormat('dd/MM/yyyy').format(e.date),
              e.title,
              e.category,
              e.amount.toStringAsFixed(2),
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'expense_report_${DateFormat('yyyy_MM').format(expenses.firstOrNull?.date ?? DateTime.now())}.pdf',
    );
  }



  Future<void> generateGroupReport({
    required String groupName,
    required List<GroupMember> members,
    required List<SplitExpense> expenses,
    required Map<String, double> balances,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    final totalAmount = expenses.fold<double>(0, (sum, item) => sum + (item.type == 'SETTLEMENT' ? 0 : item.amount));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(groupName, style: pw.TextStyle(font: boldFont, fontSize: 24)),
                pw.Text(DateFormat('MMMM yyyy').format(DateTime.now()), style: pw.TextStyle(font: font, fontSize: 18)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Balances Summary
          pw.Text('Net Balances', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(font: boldFont),
            cellStyle: pw.TextStyle(font: font),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['Member', 'Status', 'Amount'],
            data: members.map((m) {
              final bal = balances[m.id] ?? 0.0;
              if (bal.abs() < 1) return null;
              final isPos = bal >= 0;
              return [
                m.name,
                isPos ? 'Gets Back' : 'Owes',
                'INR ${bal.abs().toStringAsFixed(0)}',
              ];
            }).whereType<List<String>>().toList(),
          ),
          
          pw.SizedBox(height: 30),
          
          // Expenses Table
          pw.Text('Transactions (Total: INR ${totalAmount.toStringAsFixed(0)})', style: pw.TextStyle(font: boldFont, fontSize: 16)),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(font: boldFont),
            cellStyle: pw.TextStyle(font: font, fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['Date', 'Title', 'Paid By', 'Amount'],
            columnWidths: {
              0: const pw.FixedColumnWidth(60),
              1: const pw.FlexColumnWidth(),
              2: const pw.FixedColumnWidth(80),
              3: const pw.FixedColumnWidth(70),
            },
            data: expenses.map((e) {
              final payerName = members.firstWhere(
                (m) => m.id == e.paidByMemberId, 
                orElse: () => const GroupMember(id: '', groupId: '', name: 'Unknown')
              ).name;
              final isSettlement = e.type == 'SETTLEMENT';
              return [
                DateFormat('dd/MM/yy').format(e.date),
                isSettlement ? 'Payment: ${e.title}' : e.title,
                payerName,
                'INR ${e.amount.toStringAsFixed(0)}',
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: '${groupName.replaceAll(' ', '_')}_Report.pdf',
    );
  }
  Future<void> generateMonthlyCompareReport({
    required String month1Title,
    required String month2Title,
    required List<double> trendData, // Last 6 months totals
    required List<String> trendLabels, // Last 6 months names
    required List<String> categories,
    required Map<String, double> totals1,
    required Map<String, double> totals2,
  }) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    final maxTrend = trendData.isNotEmpty ? trendData.reduce((a, b) => a > b ? a : b) : 100.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Monthly Comparison Report', style: pw.TextStyle(font: boldFont, fontSize: 24)),
                  pw.Text('Generated: ${DateFormat('dd MMM yyyy').format(DateTime.now())}', style: pw.TextStyle(font: font, fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // 1. Expense Trend (Line Chart approximation)
            pw.Text('Expense Trend (Last 6 Months)', style: pw.TextStyle(font: boldFont, fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Container(
              height: 150,
              child: pw.Chart(
                grid: pw.CartesianGrid(
                  xAxis: pw.FixedAxis(
                    List.generate(trendData.length, (i) => i.toDouble()),
                  ),
                  yAxis: pw.FixedAxis(
                     [0.0, maxTrend * 0.5, maxTrend],
                  ),
                ),
                datasets: [
                  pw.LineDataSet(
                    drawSurface: true,
                    isCurved: true,
                    drawPoints: true,
                    pointColor: PdfColors.blue,
                    color: PdfColors.blue,
                    surfaceColor: PdfColors.blue100,
                    data: List.generate(trendData.length, (i) => pw.PointChartValue(i.toDouble(), trendData[i])),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // 2. Category Comparison (Bar Chart)
            pw.Text('Category Comparison ($month1Title vs $month2Title)', style: pw.TextStyle(font: boldFont, fontSize: 16)),
            pw.SizedBox(height: 10),
            categories.isEmpty 
              ? pw.Text('No data to compare') 
              : pw.Table(
                children: [
                    // A simple visual representation using a Table instead of complex BarChart widget for better side-by-side control
                    pw.TableRow(
                      children: [
                         pw.Text('Category', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                         pw.Text(month1Title, style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.blue)),
                         pw.Text(month2Title, style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.green)),
                         pw.Text('Visual', style: pw.TextStyle(font: boldFont, fontSize: 10)),
                      ]
                    ),
                    ...categories.map((cat) {
                       final v1 = totals1[cat] ?? 0.0;
                       final v2 = totals2[cat] ?? 0.0;
                       final maxVal = (totals1.values.fold(0.0, (m, e) => e > m ? e : m) > totals2.values.fold(0.0, (m, e) => e > m ? e : m)) 
                          ? totals1.values.fold(0.0, (m, e) => e > m ? e : m) 
                          : totals2.values.fold(0.0, (m, e) => e > m ? e : m);
                       
                       final w1 = maxVal > 0 ? (v1 / maxVal) * 80 : 0.0;
                       final w2 = maxVal > 0 ? (v2 / maxVal) * 80 : 0.0;

                       return pw.TableRow(
                         verticalAlignment: pw.TableCellVerticalAlignment.middle,
                         children: [
                           pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(cat, style: pw.TextStyle(font: font, fontSize: 10))),
                           pw.Text(v1.toStringAsFixed(0), style: pw.TextStyle(font: font, fontSize: 10)),
                           pw.Text(v2.toStringAsFixed(0), style: pw.TextStyle(font: font, fontSize: 10)),
                           pw.Column(
                             crossAxisAlignment: pw.CrossAxisAlignment.start,
                             children: [
                               pw.Container(width: w1, height: 4, color: PdfColors.blue),
                               pw.SizedBox(height: 2),
                               pw.Container(width: w2, height: 4, color: PdfColors.green),
                             ]
                           )
                         ]
                       );
                    }),
                ]
              ),

             pw.SizedBox(height: 30),

            // 3. Detailed Breakdown
            pw.Text('Detailed Breakdown', style: pw.TextStyle(font: boldFont, fontSize: 16)),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(font: boldFont),
              cellStyle: pw.TextStyle(font: font, fontSize: 10),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              headers: ['Category', month1Title, month2Title, 'Difference', '% Change'], // Added % Change
              data: categories.map((cat) {
                final v1 = totals1[cat] ?? 0.0;
                final v2 = totals2[cat] ?? 0.0;
                final diff = v1 - v2;
                final isInc = diff > 0; // Increase means spent MORE in Month 1 than Month 2? 
                // Wait, logic in logic file: Month 1 is usually "Current/Selected", Month 2 is "Previous/Comparision".
                // In UI: "Month 1" selector, "Month 2" selector.
                // Diff = v1 - v2. 
                // Using UI logic: diff > 0 means Month 1 > Month 2.
                
                String percentStr = '0%';
                if (v2 != 0) {
                   final p = ((diff / v2) * 100);
                   percentStr = '${p > 0 ? '+' : ''}${p.toStringAsFixed(1)}%';
                } else if (v1 > 0) {
                   percentStr = '+100%'; // Infinite increase
                }

                return [
                  cat,
                  v1.toStringAsFixed(0),
                  v2.toStringAsFixed(0),
                  (diff > 0 ? '+' : '') + diff.toStringAsFixed(0),
                  percentStr,
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Monthly_Compare_${month1Title.replaceAll(' ', '')}_vs_${month2Title.replaceAll(' ', '')}.pdf',
    );
  }

  Future<void> generateDebtStatement(DebtModel debt) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    final dateFormat = DateFormat('dd MMM yyyy');
    
    // Calculate totals from payments
    final totalPaid = debt.payments.fold(0.0, (sum, p) => sum + p.amount);
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Debt Statement', style: pw.TextStyle(font: boldFont, fontSize: 24)),
                      pw.Text('For: ${debt.personName}', style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Text('Date: ${dateFormat.format(DateTime.now())}', style: pw.TextStyle(font: font, fontSize: 12)),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            
            // Summary Box
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  pw.Column(children: [
                    pw.Text('Principal Amount', style: pw.TextStyle(font: font)),
                    pw.SizedBox(height: 4),
                    pw.Text('INR ${debt.principalAmount > 0 ? debt.principalAmount.toStringAsFixed(0) : (debt.amount + totalPaid).toStringAsFixed(0)}', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                  ]),
                   pw.Container(width: 1, height: 30, color: PdfColors.grey400),
                  pw.Column(children: [
                    pw.Text('Total Paid', style: pw.TextStyle(font: font)),
                    pw.SizedBox(height: 4),
                    pw.Text('INR ${totalPaid.toStringAsFixed(0)}', style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.green)),
                  ]),
                  pw.Container(width: 1, height: 30, color: PdfColors.grey400),
                  pw.Column(children: [
                    pw.Text('Outstanding', style: pw.TextStyle(font: font)),
                    pw.SizedBox(height: 4),
                    pw.Text('INR ${debt.amount.toStringAsFixed(0)}', style: pw.TextStyle(font: boldFont, fontSize: 16, color: PdfColors.red)),
                  ]),
                ],
              ),
            ),
            
            pw.SizedBox(height: 30),
            
            pw.Text('Payment History', style: pw.TextStyle(font: boldFont, fontSize: 16)),
            pw.SizedBox(height: 10),
            
            debt.payments.isEmpty 
              ? pw.Text('No payments recorded yet.', style: pw.TextStyle(font: font, fontStyle: pw.FontStyle.italic))
              : pw.Table.fromTextArray(
                  context: context,
                  headerStyle: pw.TextStyle(font: boldFont),
                  cellStyle: pw.TextStyle(font: font),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  headers: ['Date', 'Amount Paid', 'Balance After'],
                  data: () {
                     // Reconstruct flow for balance
                     double currentBalance = debt.principalAmount > 0 ? debt.principalAmount : (debt.amount + totalPaid);
                     final sortedPayments = List<LoanPayment>.from(debt.payments)..sort((a, b) => a.date.compareTo(b.date));
                     
                     return sortedPayments.map((p) {
                       currentBalance -= p.amount;
                       return [
                         dateFormat.format(p.date),
                         'INR ${p.amount.toStringAsFixed(0)}',
                         'INR ${currentBalance.toStringAsFixed(0)}',
                       ];
                     }).toList();
                  }(),
                ),
                
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.Center(child: pw.Text('Generated by Kanakupulla App', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey))),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Statement_${debt.personName.replaceAll(' ', '_')}.pdf',
    );
  }
}
