import '../../data/models/credit_card_model.dart';

class VoiceParserResult {
  final double? amount;
  final String? title;
  final String? category;
  final String? paymentMethod;
  final String? creditCardId;

  VoiceParserResult({
    this.amount,
    this.title,
    this.category,
    this.paymentMethod,
    this.creditCardId,
  });

  @override
  String toString() {
    return 'Amount: $amount, Title: $title, Category: $category, Method: $paymentMethod, CardId: $creditCardId';
  }
}

class VoiceParser {
  static VoiceParserResult parse(
    String text, 
    List<String> validCategories, 
    List<CreditCardModel> creditCards
  ) {
    String lowerText = text.toLowerCase();
    
    // 1. Extract Amount
    double? amount;
    // Matches "500", "rs 500", "500.50", etc.
    final amountRegex = RegExp(r'(?:rs\.?|inr|₹)?\s*(\d+(?:,\d+)*(?:\.\d{1,2})?)'); 
    final amountMatch = amountRegex.firstMatch(lowerText);
    if (amountMatch != null) {
      String amountStr = amountMatch.group(1)!.replaceAll(',', '');
      amount = double.tryParse(amountStr);
    }

    // 2. Extract Payment Method
    String? paymentMethod;
    if (lowerText.contains('upi') || lowerText.contains('gpay') || lowerText.contains('phonepe') || lowerText.contains('paytm')) {
      paymentMethod = 'UPI';
    } else if (lowerText.contains('cash')) {
      paymentMethod = 'Cash';
    } else if (lowerText.contains('card') || lowerText.contains('credit')) {
      paymentMethod = 'Credit Card';
    } else {
      // Default to null, user can select or let logic decide default
    }

    // 3. Extract Credit Card (if applicable)
    String? creditCardId;
    if (paymentMethod == 'Credit Card' || paymentMethod == null) {
      for (final card in creditCards) {
        if (lowerText.contains(card.name.toLowerCase())) {
          creditCardId = card.id;
          paymentMethod = 'Credit Card'; // Force method if card name found
          break;
        }
      }
    }

    // 4. Extract Category
    String? category;
    // Map of keywords to potential categories
    final Map<String, List<String>> keywordMap = {
      'Food': ['lunch', 'dinner', 'breakfast', 'snack', 'coffee', 'tea', 'restaurant', 'zomato', 'swiggy', 'food'],
      'Transport': ['fuel', 'petrol', 'diesel', 'gas', 'bus', 'train', 'flight', 'cab', 'taxi', 'uber', 'ola', 'auto'],
      'Shopping': ['shopping', 'clothes', 'dress', 'shirt', 'pant', 'shoes', 'amazon', 'flipkart', 'myntra'],
      'Bills': ['bill', 'electricity', 'water', 'internet', 'wifi', 'recharge', 'mobile', 'rent', 'emi'],
      'Entertainment': ['movie', 'cinema', 'netflix', 'prime', 'hotstar', 'subscription', 'game'],
      'Health': ['medicine', 'doctor', 'hospital', 'clinic', 'pharmacy', 'tablet'],
      'Education': ['fee', 'school', 'college', 'book', 'course', 'tuition'],
    };

    // Check against valid categories
    for (final cat in validCategories) {
      // Direct match
      if (lowerText.contains(cat.toLowerCase())) {
        category = cat;
        break;
      }
      
      // Keyword match
      if (keywordMap.containsKey(cat)) {
        for (final keyword in keywordMap[cat]!) {
          if (lowerText.contains(keyword)) {
            category = cat;
            break;
          }
        }
      }
      if (category != null) break;
    }

    // 5. Extract Title
    // Remove amount, payment keywords, specific category keywords from text to leave title
    // This is hard to perfect, so we'll use a heuristic:
    // Filter out common filler words and extracted numbers.
    String cleanTitle = text;
    
    // Remove Amount
    if (amountMatch != null) {
      cleanTitle = cleanTitle.replaceFirst(amountMatch.group(0)!, '');
    }

    // Remove filler phrases
    final fillers = [
      'spent', 'paid', 'for', 'on', 'using', 'via', 'with', 'in', 'at', 
      'rs', 'rupees', 'amount', 'purchase', 'bought'
    ];
    
    for (final filler in fillers) {
      final regex = RegExp(r'\b' + filler + r'\b', caseSensitive: false);
      cleanTitle = cleanTitle.replaceAll(regex, '');
    }

    // Remove payment method keywords
    if (paymentMethod != null) {
      cleanTitle = cleanTitle.replaceAll(RegExp(r'\b' + paymentMethod!.toLowerCase() + r'\b', caseSensitive: false), '');
    }
    
    // Remove card name
    if (creditCardId != null) {
       final card = creditCards.firstWhere((c) => c.id == creditCardId);
       cleanTitle = cleanTitle.replaceAll(RegExp(r'\b' + card.name.toLowerCase() + r'\b', caseSensitive: false), '');
    }

    // Clean up
    cleanTitle = cleanTitle.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // If empty, use category or "Expense"
    if (cleanTitle.isEmpty && category != null) {
      cleanTitle = category; // E.g. "Lunch"
    } else if (cleanTitle.isEmpty) {
      cleanTitle = 'Expense';
    } else {
      // Capitalize
      cleanTitle = cleanTitle[0].toUpperCase() + cleanTitle.substring(1);
    }

    return VoiceParserResult(
      amount: amount,
      title: cleanTitle,
      category: category,
      paymentMethod: paymentMethod,
      creditCardId: creditCardId,
    );
  }
}
