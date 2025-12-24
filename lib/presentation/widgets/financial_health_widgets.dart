import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/salary_provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/category_provider.dart';
import '../screens/credit_usage_details_screen.dart';

class SavingsRateCard extends ConsumerWidget {
  const SavingsRateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final incomeAsync = ref.watch(salaryProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '30% Savings Club',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            expensesAsync.when(
              data: (expenses) => incomeAsync.when(
                data: (incomes) {
                  final categoriesAsync = ref.watch(categoryProvider);
                  return categoriesAsync.when(
                    data: (categories) {
                      final totalIncome = incomes.fold(0.0, (sum, e) => sum + e.amount);
                      
                      // Create a map for quick lookup
                      final categoryTypeMap = {for (var c in categories) c.name: c.type};

                      // Calculate Allocated Savings (Investments + Savings Category)
                      double allocatedSavings = 0;
                      for (var e in expenses) {
                        final type = categoryTypeMap[e.category];
                        if (type == 'Savings') {
                           allocatedSavings += e.amount;
                        }
                      }

                      if (totalIncome == 0) {
                        return Text(
                          'Add income to track savings rate',
                          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                        );
                      }

                      // Rate based on Allocated Savings
                      final rate = (allocatedSavings / totalIncome).clamp(0.0, 1.0);
                      final percentage = (rate * 100).toStringAsFixed(1);
                      
                      Color color = AppTheme.tertiaryColor;
                      String message = "Boost your savings!";
                      IconData icon = Icons.savings_outlined;

                      if (rate >= 0.3) {
                        color = const Color(0xFFFFD700); // Gold
                        message = "Excellent! You're in the club! 🏆";
                        icon = Icons.emoji_events_rounded;
                      } else if (rate >= 0.2) {
                        color = AppTheme.secondaryColor;
                        message = "Good! Keep pushing for 30%";
                        icon = Icons.thumb_up_rounded;
                      } else if (rate >= 0.1) {
                        color = Colors.orange;
                        message = "You're getting there.";
                        icon = Icons.trending_up_rounded;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$percentage%', 
                                    style: theme.textTheme.displayMedium?.copyWith(
                                      color: color, 
                                      fontWeight: FontWeight.w800
                                    )
                                  ),
                                  Text(
                                    'Saved: ₹${allocatedSavings.toStringAsFixed(0)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(icon, color: color, size: 28),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: rate,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                              minHeight: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(message, 
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: color, 
                                  fontWeight: FontWeight.w600
                                )
                              ),
                              Text('Goal: 30%', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_,__) => const SizedBox.shrink(),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_,__) => const Text('Error loading income'),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_,__) => const Text('Error loading expenses'),
            ),
          ],
        ),
      ),
    );
  }
}

class UnifiedCreditCard extends ConsumerWidget {
  const UnifiedCreditCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Credit Health',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            expensesAsync.when(
              data: (expenses) {
                // PART 1: DEPENDENCY RATIO
                final incomesAsync = ref.watch(salaryProvider);
                
                return incomesAsync.when(
                  data: (incomes) {
                    final totalIncome = incomes.fold(0.0, (sum, e) => sum + e.amount);
                    if (totalIncome == 0) return const Text('Add income to track dependency');

                    double creditSpend = 0;
                    for (var e in expenses) {
                      if (e.isCreditCardBill) continue; 
                      if (e.paymentMethod == 'Credit Card') {
                        creditSpend += e.amount;
                      }
                    }

                    final ratio = (creditSpend / totalIncome).clamp(0.0, 1.0);
                    
                    Color color = AppTheme.secondaryColor;
                    String label = "Healthy Usage";
                    String advice = "You use credit wisely.";

                    if (ratio > 0.5) {
                      color = AppTheme.tertiaryColor;
                      label = "Critical Dependency";
                      advice = "Relies too much (>50%)";
                    } else if (ratio > 0.3) {
                      color = Colors.orange;
                      label = "High Risk";
                      advice = "Risk of debt trap (>30%)";
                    } else if (ratio > 0.1) {
                      color = Colors.amber;
                      label = "Moderate";
                      advice = "Keep under control.";
                    }

                    final allExpenses = ref.watch(allExpensesProvider).valueOrNull ?? [];
                    final creditCards = ref.watch(creditCardProvider).valueOrNull ?? [];
                    double upcomingBillAmount = 0;

                    for (var card in creditCards) {
                      DateTime startDate;
                      if (card.lastBillGeneratedMonth != null) {
                        try {
                           final parts = card.lastBillGeneratedMonth!.split('-');
                           final year = int.parse(parts[0]);
                           final month = int.parse(parts[1]);
                           final lastDay = DateTime(year, month + 1, 0).day;
                           startDate = DateTime(year, month, card.billingDay > lastDay ? lastDay : card.billingDay);
                        } catch (e) { startDate = DateTime(2000); }
                      } else { startDate = DateTime(2000); }

                      final cardExpenses = allExpenses.where((e) {
                        if (e.creditCardId != card.id) return false;
                        if (e.paymentMethod != 'Credit Card') return false;
                        if (e.isCreditCardBill) return false;
                        if (!e.date.isAfter(startDate.subtract(const Duration(seconds: 1)))) return false;
                        return true;
                      });
                      
                      for (var e in cardExpenses) upcomingBillAmount += e.amount;
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: Stack(
                                children: [
                                  Center(
                                    child: SizedBox(
                                      height: 60,
                                      width: 60,
                                      child: CircularProgressIndicator(
                                        value: ratio,
                                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                        valueColor: AlwaysStoppedAnimation<Color>(color),
                                        strokeWidth: 8,
                                        strokeCap: StrokeCap.round,
                                      ),
                                    ),
                                  ),
                                  Center(child: Text('${(ratio * 100).toInt()}%', 
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color))
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(label, style: theme.textTheme.titleMedium?.copyWith(
                                    color: color, fontWeight: FontWeight.bold
                                  )),
                                  Text(advice, style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            onTap: () {
                               Navigator.push(context, MaterialPageRoute(builder: (c) => const CreditUsageDetailsScreen()));
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Unbilled Usage', 
                                      style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                                    ),
                                    Text('₹${upcomingBillAmount.toStringAsFixed(0)}', 
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.primary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_,__) => const Text('Error loading income'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_,__) => const Text('Error loading data'),
            ),
          ],
        ),
      ),
    );
  }
}
