import 'package:flutter/material.dart';

class CategoryColors {
  static const Map<String, Color> _colors = {
    'Food': Colors.orange,
    'Transport': Colors.blue,
    'Shopping': Colors.pink,
    'Bills': Colors.red,
    'Entertainment': Colors.purple,
    'Health': Colors.green,
    'Education': Colors.indigo,
    'Others': Colors.grey,
    'Investments': Colors.teal,
    'Salary': Colors.green,
    'Business': Colors.blueAccent,
    'Gift': Colors.amber,
  };

  static Color getColor(String category) {
    if (_colors.containsKey(category)) {
      return _colors[category]!;
    }
    // Fallback: Generate color from hash
    return Colors.primaries[category.hashCode % Colors.primaries.length];
  }
}
