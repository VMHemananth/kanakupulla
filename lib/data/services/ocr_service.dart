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
    
    // Improved Regex to catch amounts:
    // Matches: 1,234.50 | 1234.50 | 1234 | 1,234 | 12.00
    // Optional currency symbols: Rs, INR, ₹, $
    final priceRegex = RegExp(r'(?:[\u20B9\u20A8\u0024\u00A3\u20AC]|\b(?:Rs|INR|MRP|Net|Total)\b)?\s*[:\-\s]*(\d{1,3}(?:,\d{2,3})*(?:\.\d+)?)', caseSensitive: false);
    
    // Keywords that indicate a total amount
    final totalKeywords = ['total', 'net', 'payable', 'bill amount', 'grand total', 'cash', 'card', 'paid'];
    
    // Strategy 1: Look for keywords and find number on same or next line
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].toLowerCase();
      
      if (totalKeywords.any((k) => line.contains(k))) {
        // Check same line
        final matches = priceRegex.allMatches(lines[i]);
        for (var match in matches) {
           String numStr = match.group(1)!.replaceAll(',', '');
           double? val = double.tryParse(numStr);
           if (val != null) {
              if (amount == null || val > amount) {
                amount = val;
              }
           }
        }
        
        // Check next line if valid, sometimes the amount is below the label
        if (i + 1 < lines.length) {
           final matchesNext = priceRegex.allMatches(lines[i+1]);
           for (var match in matchesNext) {
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

    // Strategy 2: If no keyword-based amount found, find the largest number that looks like a price anywhere in the text
    if (amount == null) {
      double maxVal = 0.0;
      final allMatches = priceRegex.allMatches(text);
      
      for (var match in allMatches) {
        String numStr = match.group(1)!.replaceAll(',', '');
        double? val = double.tryParse(numStr);
        
        if (val != null) {
          // Filter out unlikely amounts
          // 1. Dates (often parsed as numbers like 2023, 2024)
          if (val >= 2020 && val <= 2030 && !numStr.contains('.')) continue;
          
          // 2. Phone numbers (large integers without decimals often > 100000)
          if (val > 100000 && !numStr.contains('.')) continue; 
          
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
