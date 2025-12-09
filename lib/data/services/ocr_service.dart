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
    final skipWords = [
      'welcome', 'tax', 'invoice', 'bill', 'receipt', 'gst', 'tin', 'tel', 'ph', 'date', 'time', 
      'cashier', 'table', 'order', 'no', 'copy', 'original', 'duplicate', 'customer', 'merchant',
      'shop', 'store', 'market'
    ];
    
    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        final lineText = line.text.trim();
        if (lineText.isEmpty) continue;
        
        // Check if line contains only numbers or special chars
        if (RegExp(r'^[\d\W]+$').hasMatch(lineText)) continue;
        
        // Check if line contains skip words
        if (skipWords.any((word) => lineText.toLowerCase().contains(word))) continue;

        // Merchant names are often at the top. Skip very short lines.
        if (lineText.length < 3) continue;

        // If we passed checks, this is likely the merchant name
        merchantName = lineText;
        break; 
      }
      if (merchantName != null) break;
    }

    // --- 2. Extract Amount (Improved Strategy) ---
    double? amount;
    
    // Regex to match currency amounts.
    // Supports: 1,234.50 | 1234.50 | 12.00 | .50
    // Handles currency symbols (₹, $, etc.) and "Rs" prefix.
    final priceRegex = RegExp(
      r'(?:[\u20B9\u20A8\u0024\u00A3\u20AC]|Rs\.?|INR|MRP|Net|Total)?\s*[:\-\s]?\s*(\d{1,3}(?:[,\s]?\d{3})*(?:\.\d{1,2})?)', 
      caseSensitive: false,
    );

    // Strong keywords usually indicating the final bill amount
    final totalKeywords = ['grand total', 'net amount', 'total payable', 'bill amount', 'amount due', 'to pay'];
    // Generic keywords found near amounts
    final genericKeywords = ['total', 'amount', 'balance', 'due', 'payable'];
    // Keywords to avoid or treat as lower priority (subtotals, taxes, etc.)
    final avoidKeywords = ['subtotal', 'sub total', 'tax', 'vat', 'gst', 'discount', 'change', 'tendered', 'cash', 'card'];

    // Helper to parse double from string cleaning common OCR errors
    double? parseAmount(String str) {
      // Remove currency symbols and common non-numeric chars except dot and comma
      String cleaned = str.replaceAll(RegExp(r'[^\d.,]'), '');
      // Handle commas (1,234.50 -> 1234.50)
      cleaned = cleaned.replaceAll(',', '');
      return double.tryParse(cleaned);
    }

    // Strategy 1: Bottom-up search for "Total" keywords
    // We search from the bottom because the grand total is usually at the end.
    for (int i = lines.length - 1; i >= 0; i--) {
      final line = lines[i].trim().toLowerCase();
      if (line.isEmpty) continue;

      // Check if line contains any strong or generic total keywords
      bool isStrongMatch = totalKeywords.any((k) => line.contains(k));
      bool isGenericMatch = genericKeywords.any((k) => line.contains(k));

      if (isStrongMatch || isGenericMatch) {
         // If it's a generic match, ensure it's not a "subtotal" type line unless we haven't found anything else
         if (isGenericMatch && !isStrongMatch) {
           if (avoidKeywords.any((k) => line.contains(k))) {
             continue; // Skip subtotal/tax lines for now
           }
         }

         // Attempt to find number in the same line
         double? validAmount;
         final matches = priceRegex.allMatches(lines[i]);
         for (var match in matches) {
            double? val = parseAmount(match.group(1)!);
            if (val != null) validAmount = val; // Take the last match in the line usually
         }

         // If not in same line, check next line (physically below)
         if (validAmount == null && i + 1 < lines.length) {
            final nextLine = lines[i+1];
            final matchesNext = priceRegex.allMatches(nextLine);
             for (var match in matchesNext) {
               double? val = parseAmount(match.group(1)!);
               if (val != null) validAmount = val;
            }
         }

         if (validAmount != null && validAmount > 0) {
           amount = validAmount;
           break; // Found the bottom-most total, stop searching
         }
      }
    }

    // Strategy 2: If no keyword-based amount found, find the largest valid number in the text
    // We prioritize the bottom half of the receipt for this fallback.
    if (amount == null) {
      double maxVal = 0.0;
      
      // Analyze all lines
      for (var line in lines) {
        final matches = priceRegex.allMatches(line);
         for (var match in matches) {
           double? val = parseAmount(match.group(1)!);
           if (val != null) {
             // Filter out unlikely amounts similar to previous logic
             if (val >= 2020 && val <= 2030 && !line.contains('.')) continue; // Years
             if (val > 500000) continue; // Unlikely large amounts (phones)
             
             if (val > maxVal) maxVal = val;
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
