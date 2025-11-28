import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/expense_model.dart';

class PdfService {
  Future<void> generateExpenseReport(List<ExpenseModel> expenses) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.interRegular();
    final boldFont = await PdfGoogleFonts.interBold();

    // Sort expenses by date
    expenses.sort((a, b) => b.date.compareTo(a.date));

    final totalAmount = expenses.fold<double>(0, (sum, item) => sum + item.amount);

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
                pw.Text(DateFormat('MMMM yyyy').format(DateTime.now()), style: pw.TextStyle(font: font, fontSize: 18)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Expenses:', style: pw.TextStyle(font: boldFont, fontSize: 18)),
              pw.Text('INR ${totalAmount.toStringAsFixed(2)}', style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.red)),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(font: boldFont),
            cellStyle: pw.TextStyle(font: font),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            headers: ['Date', 'Title', 'Category', 'Amount'],
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
      name: 'expense_report_${DateFormat('yyyy_MM').format(DateTime.now())}.pdf',
    );
  }
}
