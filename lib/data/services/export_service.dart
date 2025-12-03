import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/csv_exporter.dart';
import '../../data/models/expense_model.dart';
import 'pdf_service.dart';

final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

class ExportService {
  final PdfService _pdfService = PdfService();

  Future<void> exportToCsv(List<ExpenseModel> expenses) async {
    await CsvExporter.exportExpenses(expenses);
  }

  Future<void> exportToPdf(List<ExpenseModel> expenses) async {
    await _pdfService.generateExpenseReport(expenses);
  }
}
