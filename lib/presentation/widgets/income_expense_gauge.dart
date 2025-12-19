import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/salary_provider.dart';

class IncomeExpenseGauge extends ConsumerWidget {
  const IncomeExpenseGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final incomeAsync = ref.watch(salaryProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Spending Velocity', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  expensesAsync.when(
                    data: (expenses) {
                       final income = incomeAsync.value?.fold(0.0, (sum, i) => sum + i.amount) ?? 0.0;
                       
                       double totalExpense = 0;
                       if (expenses.isNotEmpty) {
                         totalExpense = expenses.fold(0.0, (sum, e) {
                            if (e.paymentMethod == 'Credit Card' && !e.isCreditCardBill) return sum;
                            return sum + e.amount;
                         });
                       }

                       // If no income, gauge is meaningless or full red if expenses exist
                       if (income == 0) {
                         if (totalExpense > 0) {
                           return _buildGauge(context, 100, 0, 100); // Maxed out red
                         } else {
                           return _buildGauge(context, 0, 100, 0); // Empty green
                         }
                       }

                       final percentage = (totalExpense / income) * 100;
                       
                       // Determine Needle or Fill Position
                       // Using a semi-circle pie chart to show "Zones"
                       // And a pointer? Or just fill the pie up to the percentage?
                       // User asked for "Green Zone: 0-50%, Yellow: 50-85%, Red: >85%"
                       // Best approach: Background tracks showing zones, and a "needle" or a progress bar filling it.
                       // Easier with PieChart: 
                       // Section 1: Value = percentage (Color based on zone)
                       // Section 2: Value = 100 - percentage (Grey)
                       
                       Color color;
                       String label;
                       if (percentage > 85) {
                         color = Colors.red;
                         label = 'Critical';
                       } else if (percentage > 50) {
                         color = Colors.orange;
                         label = 'Caution';
                       } else {
                         color = Colors.green;
                         label = 'Safe';
                       }

                       double value = percentage > 100 ? 100 : percentage;

                       return Stack(
                         alignment: Alignment.bottomCenter,
                         children: [
                           PieChart(
                             PieChartData(
                               startDegreeOffset: 180,
                               centerSpaceRadius: 0,
                               sectionsSpace: 0,
                               sections: [
                                 // Active Part
                                 PieChartSectionData(
                                   value: value,
                                   color: color,
                                   radius: 60,
                                   showTitle: false,
                                 ),
                                 // Remaining Part
                                 PieChartSectionData(
                                   value: 100 - value,
                                   color: Colors.grey.withOpacity(0.2),
                                   radius: 60,
                                   showTitle: false,
                                 ),
                                 // Invisible bottom half to force semi-circle shape
                                 PieChartSectionData(
                                   value: 100,
                                   color: Colors.transparent,
                                   radius: 60,
                                   showTitle: false,
                                 ),
                               ],
                             ),
                           ),
                           // Cover the center to make it look like a gauge/donut
                           Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                           ),
                           // Overlay Text
                           Padding(
                             padding: const EdgeInsets.only(bottom: 20.0),
                             child: Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 Text(
                                   '${percentage.toStringAsFixed(0)}%', 
                                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)
                                 ),
                                 Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
                               ],
                             ),
                           ),
                         ],
                       );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error'),
                  ),
                ],
              ),
            ),
            // Zone Indicators
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text('0%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                   Text('50%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                   Text('85%', style: TextStyle(fontSize: 10, color: Colors.grey)),
                   Text('100%+', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGauge(BuildContext context, double val, double max, double min) {
      // Simple fallback placeholder if needed
      return const SizedBox();
  }
}
