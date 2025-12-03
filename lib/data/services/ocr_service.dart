import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ocrServiceProvider = Provider<OCRService>((ref) => OCRService());

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<Map<String, dynamic>> scanReceipt(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    final lines = text.split('\n');

    // --- 1. Extract Merchant Name ---
    String? merchantName;
    // Skip common header words to find the real name
    final skipWords = [
      'welcome', 'tax', 'invoice', 'bill', 'receipt', 'gst', 'tin', 'tel', 'ph', 'date', 'time', 
      'cashier', 'table', 'order', 'no', 'copy', 'original', 'duplicate', 'customer'
    ];
    
    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        final lineText = line.text.trim();
        if (lineText.isEmpty) continue;
        
        // Check if line contains only numbers or special chars
        if (RegExp(r'^[\d\W]+$').hasMatch(lineText)) continue;
        
        // Check if line contains skip words
        if (skipWords.any((word) => lineText.toLowerCase().contains(word))) continue;

        // Heuristic: Merchant names are often at the top and might be all caps or title case
        // If it's very short (e.g. 1-2 chars), skip
        if (lineText.length < 3) continue;

        // If we passed checks, this is likely the merchant name
        merchantName = lineText;
        break; 
      }
      if (merchantName != null) break;
    }

    // --- 2. Extract Amount ---
    double? amount;
    
    // Regex for currency-like numbers (e.g., 1,234.50, 500.00, 1200)
    // Allows optional currency symbols and whitespace
    final priceRegex = RegExp(r'(?:Rs\.?|INR|₹)?\s*(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)', caseSensitive: false);
    
    // Keywords that indicate a total amount
    final totalKeywords = ['total', 'net', 'payable', 'bill amount', 'amount', 'grand total', 'cash', 'card', 'paid'];
    
    // Strategy 1: Look for keywords and find number on same or next line
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      
      if (totalKeywords.any((k) => line.contains(k))) {
        // Check same line
        var match = priceRegex.firstMatch(lines[i]);
        if (match != null) {
          String numStr = match.group(1)!.replaceAll(',', '');
          double? val = double.tryParse(numStr);
          if (val != null) {
            // If we found a "Total" keyword, this is a strong candidate.
            if (line.contains('tax') && !line.contains('total')) {
               // Skip tax amount if possible
            } else {
               // If we already have an amount, check if this one is larger (likely the grand total)
               if (amount == null || val > amount) {
                 amount = val;
               }
            }
          }
        }
        
        // Check next line if no amount found on same line OR to see if it's the value for the label
        if (i + 1 < lines.length) {
           match = priceRegex.firstMatch(lines[i+1]);
           if (match != null) {
             String numStr = match.group(1)!.replaceAll(',', '');
             double? val = double.tryParse(numStr);
             if (val != null) {
               if (amount == null || val > amount) {
                 amount = val;
               }
             }
           }
        }
      }
    }

    // Strategy 2: If no keyword-based amount found, find the largest number that looks like a price
    if (amount == null) {
      double maxVal = 0.0;
      final allMatches = priceRegex.allMatches(text);
      
      for (var match in allMatches) {
        String numStr = match.group(1)!.replaceAll(',', '');
        double? val = double.tryParse(numStr);
        
        if (val != null) {
          // Filter out unlikely amounts
          // 1. Dates (often parsed as numbers like 2023, 2024)
          if (val >= 2020 && val <= 2030) continue;
          
          // 2. Phone numbers (large integers)
          if (val > 10000 && !numStr.contains('.')) continue; // Phone numbers usually don't have decimals
          
          if (val > maxVal) {
            maxVal = val;
          }
        }
      }
      
      if (maxVal > 0) amount = maxVal;
    }

    return {
      'merchant': merchantName ?? 'Unknown Merchant',
      'amount': amount ?? 0.0,
    };
  }

  void dispose() {
    _textRecognizer.close();
  }
}
