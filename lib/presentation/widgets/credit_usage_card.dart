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
    final expensesAsync = ref.watch(allExpensesProvider);

    return expensesAsync.when(
      data: (expenses) {
        final creditCards = ref.watch(creditCardProvider).valueOrNull ?? [];
        
        double creditUsage = 0;

        for (var card in creditCards) {
          DateTime startDate;
          
          if (card.lastBillGeneratedMonth != null) {
             // If last bill was generated for "2023-11", it covers up to billing day of Nov.
             // So we start counting from the day AFTER that cycle ended?
             // Actually, simplest logic: find the date of the last bill cut-off.
             // lastBillGeneratedMonth format: "YYYY-MM"
             try {
               final parts = card.lastBillGeneratedMonth!.split('-');
               final year = int.parse(parts[0]);
               final month = int.parse(parts[1]);
               
               // The bill for (year, month) covers expenses until:
               // If bill is generated on Billing Day of Month M, it usually covers M-1 to M (depending on cycle).
               // But our logic in CheckBills says we generate it after the cycle ends.
               // Let's assume lastBillGeneratedMonth means "Bill for this month's cycle is done".
               
               // If we generated bill for Nov (2023-11), then the cycle ended on Nov [BillingDay].
               // So we count expenses AFTER Nov [BillingDay].
               // Start counting from: DateTime(year, month, card.billingDay).add(Duration(days: 1))?
               // Wait, cycle is: [BillingDay of Prev Month] to [BillingDay-1 of Current Month].
               // If we generated bill for "2023-11", it means we covered the cycle ending in Nov.
               // The cycle ending in Nov is: Oct [BillingDay] to Nov [BillingDay-1].
               // So we should start counting from Nov [BillingDay].
               
               startDate = DateTime(year, month, card.billingDay);
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
            
            // Check if expense is AFTER the last billed cycle start date
            // Actually, we want expenses that haven't been billed yet.
            // If startDate is 2000, all are unbilled.
            // If startDate is Nov 5, we want expenses >= Nov 5.
            
            // Strict comparison: Date must be on or after startDate.
            // (Use year/month/day comparison to be safe against time components if any)
            return e.date.isAfter(startDate.subtract(const Duration(seconds: 1)));
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
