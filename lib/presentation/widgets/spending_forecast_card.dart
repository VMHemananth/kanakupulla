import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';

class SpendingForecastCard extends ConsumerStatefulWidget {
  const SpendingForecastCard({super.key});

  @override
  ConsumerState<SpendingForecastCard> createState() => _SpendingForecastCardState();
}

class _SpendingForecastCardState extends ConsumerState<SpendingForecastCard> {
  bool _isAlertDismissed = false;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);
    final budgetAsync = ref.watch(budgetProvider);

    return expensesAsync.when(
      data: (expenses) {
        return budgetAsync.when(
          data: (budgetModel) {
            final monthlyBudget = budgetModel?.amount ?? 0;
            if (monthlyBudget <= 0) return const SizedBox.shrink(); // No budget set

            final now = DateTime.now();
            final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
            final dayOfMonth = now.day;

            double totalSpent = 0;
            for (var e in expenses) {
              if (e.amount > 0 && !(e.paymentMethod == 'Credit Card' && !e.isCreditCardBill)) {
                 totalSpent += e.amount;
              }
            }

            final dailyVelocity = totalSpent / dayOfMonth;
            final projectedTotal = dailyVelocity * daysInMonth;
            
            final isOverBudget = projectedTotal > monthlyBudget;
            final difference = (projectedTotal - monthlyBudget).abs();
            
            // Calculate recommended daily spend to stay on track
            final remainingBudget = monthlyBudget - totalSpent;
            final remainingDays = daysInMonth - dayOfMonth;
            final recommendedDaily = remainingDays > 0 ? (remainingBudget > 0 ? remainingBudget / remainingDays : 0) : 0;

            // Use darker colors for readability
            Color cardColor = isOverBudget ? Colors.orange.shade50 : Colors.green.shade50;
            Color textColor = Colors.black87; // Darker text for readability
            IconData icon = isOverBudget ? Icons.warning_amber_rounded : Icons.trending_up;
            Color iconColor = isOverBudget ? Colors.deepOrange : Colors.green.shade700;

            // Logic to show/hide alert based on dismissal
            // If it IS over budget, we check if it was dismissed.
            if (isOverBudget && _isAlertDismissed) {
                 return const SizedBox.shrink();
            }

            return Card(
              color: cardColor,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(icon, color: iconColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isOverBudget ? 'Spending Analysis' : 'On Track',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOverBudget)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _isAlertDismissed = true;
                              });
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.close, size: 20, color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isOverBudget && !_isAlertDismissed) ...[
                      Text(
                        'You are spending too fast! At this rate, you will exceed your budget by ₹${difference.toStringAsFixed(0)}.',
                        style: TextStyle(color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Limit daily spend to ₹${recommendedDaily.toStringAsFixed(0)} to stay on track.',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                      const SizedBox(height: 4),
                       // Added Projected Total here as requested, allowing user to see projection even if over budget.
                      Text(
                        'Projected Total: ₹${projectedTotal.toStringAsFixed(0)} / ₹${monthlyBudget.toStringAsFixed(0)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black), // Ensure readable color
                      ),
                    ] else ...[
                       // Minimized view or Good state
                       if (isOverBudget)
                          Text(
                            'Alert dismissed. Projected: ₹${projectedTotal.toStringAsFixed(0)}',
                             style: TextStyle(color: textColor, fontStyle: FontStyle.italic),
                          )
                       else
                          Text(
                            'Great job! You are on track to save ₹${difference.toStringAsFixed(0)} this month.',
                             style: TextStyle(color: textColor),
                          ),
                       const SizedBox(height: 4),
                       if (!isOverBudget)
                          Text(
                            'Projected Total: ₹${projectedTotal.toStringAsFixed(0)} / ₹${monthlyBudget.toStringAsFixed(0)}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900), // Readable dark green
                          ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
