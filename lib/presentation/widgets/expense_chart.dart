import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';

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
                    categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
                    total += e.amount;
                  }

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
                                  final fontSize = isTouched ? 16.0 : 12.0;
                                  final radius = isTouched ? 60.0 : 50.0;
                                  final entry = entries[i];
                                  final percentage = (entry.value / total) * 100;
                                  
                                  return PieChartSectionData(
                                    color: Colors.primaries[i % Colors.primaries.length],
                                    value: entry.value,
                                    title: '${percentage.toStringAsFixed(0)}%',
                                    radius: radius,
                                    titleStyle: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
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
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  touchedIndex != -1 && touchedIndex < entries.length
                                      ? '₹${entries[touchedIndex].value.toStringAsFixed(0)}'
                                      : '₹${total.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                             return Padding(
                               padding: const EdgeInsets.symmetric(vertical: 2.0),
                               child: Row(
                                 children: [
                                   Container(
                                     width: 12, height: 12,
                                     decoration: BoxDecoration(
                                       color: Colors.primaries[index % Colors.primaries.length],
                                       shape: BoxShape.circle,
                                     ),
                                   ),
                                   const SizedBox(width: 8),
                                   Expanded(
                                     child: Text(
                                       entry.key, 
                                       style: TextStyle(
                                         fontSize: 12, 
                                         fontWeight: isTouched ? FontWeight.bold : FontWeight.normal
                                       ), 
                                       overflow: TextOverflow.ellipsis
                                     )
                                   ),
                                 ],
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
