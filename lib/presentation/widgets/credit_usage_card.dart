import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/date_provider.dart';
import '../screens/credit_usage_details_screen.dart';

class CreditUsageCard extends ConsumerWidget {
  const CreditUsageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);

    return expensesAsync.when(
      data: (expenses) {
        // Calculate total credit usage for the selected month
        // Note: This includes all CC expenses that are NOT bills.
        final creditUsage = expenses
            .where((e) => e.paymentMethod == 'Credit Card' && !e.isCreditCardBill)
            .fold(0.0, (sum, e) => sum + e.amount);

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
                        Text(
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
