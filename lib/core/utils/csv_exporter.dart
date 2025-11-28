import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/expense_model.dart';

class CsvExporter {
  static Future<void> exportExpenses(List<ExpenseModel> expenses) async {
    final header = 'ID,Title,Amount,Date,Category,PaymentMethod\n';
    final rows = expenses.map((e) {
      return '${e.id},"${e.title}",${e.amount},${e.date.toIso8601String()},"${e.category}","${e.paymentMethod}"';
    }).join('\n');
    
    final csv = header + rows;
    
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/expenses.csv';
    final file = File(path);
    await file.writeAsString(csv);
    
    await Share.shareXFiles([XFile(path)], text: 'Here are your expenses.');
  }
}
