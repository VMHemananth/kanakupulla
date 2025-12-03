import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../../core/utils/category_colors.dart';

class ExpenseChart extends ConsumerStatefulWidget {
  const ExpenseChart({super.key});

  @override
  ConsumerState<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends ConsumerState<ExpenseChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Expense Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: expensesAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) return const Center(child: Text('No Data'));
                  
                  // Group by category
                  final Map<String, double> categoryTotals = {};
                  double total = 0;
                  for (var e in expenses) {
                    if (e.amount <= 0) continue; // Skip invalid amounts
                    if (e.paymentMethod == 'Credit Card' && !e.isCreditCardBill) continue;
                    categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
                    total += e.amount;
                  }

                  if (total <= 0) return const Center(child: Text('No Data'));

                  final entries = categoryTotals.entries.toList();

                  return Row(
                    children: [
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection == null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 0,
                                centerSpaceRadius: 40,
                                sections: List.generate(entries.length, (i) {
                                  final isTouched = i == touchedIndex;
                                  final fontSize = isTouched ? 18.0 : 12.0;
                                  final radius = isTouched ? 70.0 : 50.0;
                                  final entry = entries[i];
                                  final percentage = (entry.value / total) * 100;
                                  
                                  return PieChartSectionData(
                                    color: CategoryColors.getColor(entry.key),
                                    value: entry.value,
                                    title: '${percentage.toStringAsFixed(0)}%',
                                    radius: radius,
                                    titleStyle: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    borderSide: isTouched 
                                      ? const BorderSide(color: Colors.white, width: 2) 
                                      : BorderSide.none,
                                  );
                                }),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  touchedIndex != -1 && touchedIndex < entries.length
                                      ? entries[touchedIndex].key
                                      : 'Total',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  touchedIndex != -1 && touchedIndex < entries.length
                                      ? '₹${entries[touchedIndex].value.toStringAsFixed(0)}'
                                      : '₹${total.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold, 
                                    color: touchedIndex != -1 && touchedIndex < entries.length
                                      ? CategoryColors.getColor(entries[touchedIndex].key)
                                      : Colors.black
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: entries.asMap().entries.map((e) {
                             final index = e.key;
                             final entry = e.value;
                             final isTouched = index == touchedIndex;
                             return InkWell(
                               onTap: () {
                                 setState(() {
                                   if (touchedIndex == index) {
                                     touchedIndex = -1; // Toggle off
                                   } else {
                                     touchedIndex = index;
                                   }
                                 });
                               },
                               child: Padding(
                                 padding: const EdgeInsets.symmetric(vertical: 4.0),
                                 child: Row(
                                   children: [
                                     AnimatedContainer(
                                       duration: const Duration(milliseconds: 300),
                                       width: isTouched ? 16 : 12, 
                                       height: isTouched ? 16 : 12,
                                       decoration: BoxDecoration(
                                         color: CategoryColors.getColor(entry.key),
                                         shape: BoxShape.circle,
                                         border: isTouched ? Border.all(color: CategoryColors.getColor(entry.key), width: 2) : null,
                                       ),
                                     ),
                                     const SizedBox(width: 8),
                                     Expanded(
                                       child: Text(
                                         entry.key, 
                                         style: TextStyle(
                                           fontSize: isTouched ? 14 : 12, 
                                           fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                                           color: isTouched ? CategoryColors.getColor(entry.key) : Colors.grey[800],
                                         ), 
                                         overflow: TextOverflow.ellipsis
                                       )
                                     ),
                                   ],
                                 ),
                               ),
                             );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
