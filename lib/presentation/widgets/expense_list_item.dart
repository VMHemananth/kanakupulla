import 'package:flutter/material.dart';
import '../../data/models/expense_model.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';

class ExpenseListItem extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onTap;

  const ExpenseListItem({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCredit = expense.paymentMethod == 'Credit Card';
    final isIncome = expense.category.toLowerCase() == 'income' || expense.category.toLowerCase() == 'salary'; 
    // Adjust logic if 'income' is treated differently or if this item is used for income too.
    
    // Determine icon and color
    final iconData = _getIconForCategory(expense.category);
    final color = _getColorForCategory(expense.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Icon Box
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(iconData, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${expense.category} • ${DateFormat('MMM d').format(expense.date)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${expense.amount.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCredit ? Colors.redAccent : theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (isCredit)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Credit',
                          style: TextStyle(fontSize: 10, color: Colors.redAccent.withOpacity(0.8)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Icons.restaurant_rounded;
      case 'transport': return Icons.directions_car_rounded;
      case 'shopping': return Icons.shopping_bag_rounded;
      case 'bills': return Icons.receipt_long_rounded;
      case 'entertainment': return Icons.movie_rounded;
      case 'health': return Icons.medical_services_rounded;
      case 'education': return Icons.school_rounded;
      case 'fuel': return Icons.local_gas_station_rounded;
      case 'grocery': return Icons.shopping_basket_rounded;
      default: return Icons.category_rounded;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food': return Colors.orange;
      case 'transport': return Colors.blue;
      case 'shopping': return Colors.purple;
      case 'bills': return Colors.redAccent;
      case 'entertainment': return Colors.pinkAccent;
      case 'health': return Colors.teal;
      case 'education': return Colors.indigo;
      case 'fuel': return Colors.amber;
      case 'grocery': return Colors.green;
      default: return Colors.blueGrey;
    }
  }
}
