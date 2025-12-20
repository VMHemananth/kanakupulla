import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/date_provider.dart';
import '../providers/credit_card_provider.dart';
import '../../data/models/credit_card_model.dart';
import '../screens/credit_usage_details_screen.dart';

class CreditUsageCard extends ConsumerWidget {
  const CreditUsageCard({super.key});

  @override
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final expensesAsync = ref.watch(allExpensesProvider);
    
    // Requirement 2: "should not show in other months"
    // Only show if selected month matches current real-world month
    if (selectedDate.year != now.year || selectedDate.month != now.month) {
      return const SizedBox.shrink();
    }

    return expensesAsync.when(
      data: (expenses) {
        final creditCards = ref.watch(creditCardProvider).valueOrNull ?? [];
        
        double creditUsage = 0;

        for (var card in creditCards) {
          DateTime startDate;
          
          if (card.lastBillGeneratedMonth != null) {
             try {
               final parts = card.lastBillGeneratedMonth!.split('-');
               final year = int.parse(parts[0]);
               final month = int.parse(parts[1]);
               
               // Logic: Start from billing day of that month (Clamped)
               final lastDay = DateTime(year, month + 1, 0).day;
               startDate = DateTime(year, month, card.billingDay > lastDay ? lastDay : card.billingDay);
             } catch (e) {
               startDate = DateTime(2000);
             }
          } else {
            startDate = DateTime(2000);
          }

          final cardExpenses = expenses.where((e) {
            if (e.creditCardId != card.id) return false;
            if (e.paymentMethod != 'Credit Card') return false;
            if (e.isCreditCardBill) return false;
            
            // Must be after last bill start
            if (!e.date.isAfter(startDate.subtract(const Duration(seconds: 1)))) return false;

            return true;
          });

          for (var e in cardExpenses) {
            creditUsage += e.amount;
          }
        }

        if (creditUsage == 0) return const SizedBox.shrink();

        return Card(
          elevation: 2,
          color: Colors.indigo, // Set background color to support white text
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreditUsageDetailsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Semi-transparent white
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.credit_card, color: Colors.white), // White icon
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Credit Usage',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), // White text
                        ),
                        const Text(
                          'To be billed',
                          style: TextStyle(color: Colors.white70, fontSize: 12), // White-70 text
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${creditUsage.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white, // White text
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white70),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
