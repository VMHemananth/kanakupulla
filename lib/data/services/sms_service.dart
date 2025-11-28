import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';

class TransactionCandidate {
  final String sender;
  final String body;
  final DateTime date;
  final double amount;
  final String? merchant;

  TransactionCandidate({
    required this.sender,
    required this.body,
    required this.date,
    required this.amount,
    this.merchant,
  });
}

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<bool> requestPermission() async {
    var status = await Permission.sms.status;
    if (status.isDenied) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  Future<List<TransactionCandidate>> getTransactionMessages() async {
    final permission = await requestPermission();
    if (!permission) return [];

    final messages = await _query.querySms(
      kinds: [SmsQueryKind.inbox],
      count: 50, // Limit to recent 50 messages
    );

    final candidates = <TransactionCandidate>[];

    for (var msg in messages) {
      if (msg.body == null || msg.sender == null) continue;
      
      final body = msg.body!.toLowerCase();
      // Basic filtering for transaction messages
      if (body.contains('debited') || 
          body.contains('spent') || 
          body.contains('paid') || 
          body.contains('sent') ||
          body.contains('txn')) {
        
        final amount = _extractAmount(body);
        if (amount != null) {
          candidates.add(TransactionCandidate(
            sender: msg.sender!,
            body: msg.body!,
            date: msg.date ?? DateTime.now(),
            amount: amount,
            merchant: _extractMerchant(body),
          ));
        }
      }
    }
    return candidates;
  }

  double? _extractAmount(String body) {
    // Regex to find amount: e.g., Rs. 100, INR 100, Rs 100.00
    final regex = RegExp(r'(?:rs\.?|inr)\s*(\d+(?:,\d+)*(?:\.\d{2})?)', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null) {
      String amountStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }
    return null;
  }

  String? _extractMerchant(String body) {
    // Very basic extraction, looks for "to" or "at"
    final regex = RegExp(r'(?:to|at)\s+([a-zA-Z0-9\s]+)(?:\.|with|on|using|ref)', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null) {
      return match.group(1)!.trim();
    }
    return null;
  }
}
