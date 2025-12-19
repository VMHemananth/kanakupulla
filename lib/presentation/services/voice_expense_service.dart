import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

final voiceExpenseServiceProvider = Provider((ref) => VoiceExpenseService());

class VoiceExpenseService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;

  Future<bool> initialize() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }
    
    _isAvailable = await _speech.initialize(
      onError: (val) => print('Voice Error: $val'),
      onStatus: (val) => print('Voice Status: $val'),
    );
    return _isAvailable;
  }

  Future<void> listen({
    required Function(String text) onResult,
  }) async {
    if (!_isAvailable) {
      bool initialized = await initialize();
      if (!initialized) return;
    }

    _speech.listen(
      onResult: (val) => onResult(val.recognizedWords),
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      localeId: 'en_IN', // Default to Indian English given currency context
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> stop() async {
    await _speech.stop();
  }

  ({String title, double amount, String category}) parseExpense(String text) {
    // 1. Extract Amount (First number sequence found)
    // Supports integers and decimals: "spent 50.50 on..."
    final amountRegex = RegExp(r'(\d+(\.\d+)?)');
    final amountMatch = amountRegex.firstMatch(text);
    
    double amount = 0.0;
    String title = text;
    
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(0)!) ?? 0.0;
      // Remove amount from title to clean it up
      // "Tea 50" -> "Tea "
      title = text.replaceAll(amountMatch.group(0)!, '').trim();
    }

    // 2. Clean up common filler words
    final fillers = ['rupees', 'rs', 'for', 'spent', 'on', 'is', 'was', 'cost'];
    for (var word in fillers) {
       title = title.replaceAll(RegExp(r'\b' + word + r'\b', caseSensitive: false), '');
    }
    title = title.replaceAll(RegExp(r'\s+'), ' ').trim(); // Remove extra spaces
    if (title.isEmpty) title = 'Quick Expense';

    // 3. Infer Category
    String category = 'Miscellaneous';
    final lowerTitle = title.toLowerCase();
    
    final categoryKeywords = {
      'Food': ['tea', 'coffee', 'lunch', 'dinner', 'breakfast', 'snack', 'food', 'burger', 'pizza', 'biryani'],
      'Transport': ['fuel', 'petrol', 'diesel', 'uber', 'ola', 'auto', 'bus', 'train', 'flight', 'ticket'],
      'Shopping': ['cloth', 'dress', 'shirt', 'pant', 'shoe', 'shopping', 'buy'],
      'Groceries': ['milk', 'vegetable', 'fruit', 'grocery', 'oil', 'rice'],
      'Bills': ['recharge', 'wifi', 'internet', 'bill', 'electricity', 'water', 'gas'],
      'Entertainment': ['movie', 'cinema', 'game', 'netflix', 'prime'],
      'Health': ['medicine', 'doctor', 'hospital', 'tablet', 'pill'],
    };

    for (var entry in categoryKeywords.entries) {
      for (var keyword in entry.value) {
        if (lowerTitle.contains(keyword)) {
          category = entry.key;
          break;
        }
      }
      if (category != 'Miscellaneous') break;
    }

    return (title: title, amount: amount, category: category);
  }
}
