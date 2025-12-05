import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

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
    // Explicitly request SMS permission
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  Future<List<TransactionCandidate>> getTransactionMessages() async {
    try {
      final permission = await requestPermission();
      if (!permission) {
        debugPrint('SMS Permission denied');
        return [];
      }

      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 200, // Increased count
      );

      debugPrint('Fetched ${messages.length} SMS messages');

      final candidates = <TransactionCandidate>[];

      for (var msg in messages) {
        if (msg.body == null || (msg.sender == null || msg.sender!.isEmpty)) continue;
        
        final body = msg.body!.toLowerCase();
        
        // Expanded filtering for transaction messages
        if (body.contains('debited') || 
            body.contains('credited') ||
            body.contains('spent') || 
            body.contains('paid') || 
            body.contains('sent') ||
            body.contains('received') ||
            body.contains('withdraw') ||
            body.contains('atm') ||
            body.contains('bill') ||
            body.contains('recharge') ||
            body.contains('txn') ||
            body.contains('transfer') ||
            body.contains('purchase') ||
            body.contains('acct') ||
            body.contains('bank')) {
          
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
      debugPrint('Found ${candidates.length} transaction candidates');
      return candidates;
    } catch (e) {
      debugPrint('Error reading SMS: $e');
      return [];
    }
  }

  double? _extractAmount(String body) {
    // Robust Regex for Indian context and general usage
    // Matches: Rs.100, INR 100, 100.00, 1,200, etc.
    final regex = RegExp(r'(?:rs\.?|inr|₹|amount|amt|txn|val)\s*[:\.]?\s*(\d+(?:,\d+)*(?:\.\d{1,2})?)', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null) {
      String amountStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }
    return null;
  }

  String? _extractMerchant(String body) {
    // Looks for "to" or "at" followed by text until some terminator
    // Improved terminator list and prepositions
    final regex = RegExp(r'(?:to|at|via|info|ref|pymt|merch)\s+([a-zA-Z0-9\s&\-]+)(?:\.|with|on|using|txn|ref|is|succ|trans)', caseSensitive: false);
    final match = regex.firstMatch(body);
    if (match != null) {
      String merchant = match.group(1)!.trim();
      // Cleanup common trailing words if regex missed them
      final invalidTrailers = ['is', 'was', 'has', 'for', 'txn', 'ref'];
      for (var word in invalidTrailers) {
         if (merchant.toLowerCase().endsWith(' $word')) {
           merchant = merchant.substring(0, merchant.length - word.length - 1);
         }
      }
      return merchant.isNotEmpty ? merchant : null;
    }
    // Fallback: If no preposition found, maybe the sender is the merchant?
    // We can't know for sure without preposition, so returning null is safer to avoid garbage.
    return null;
  }
}
