import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';

class ExpenseChart extends ConsumerWidget {
  const ExpenseChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

                  final sections = categoryTotals.entries.map((entry) {
                    final index = categoryTotals.keys.toList().indexOf(entry.key);
                    final percentage = (entry.value / total) * 100;
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      color: Colors.primaries[index % Colors.primaries.length],
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }).toList();

                  return Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            sections: sections,
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: categoryTotals.entries.map((e) {
                             final index = categoryTotals.keys.toList().indexOf(e.key);
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
                                   Expanded(child: Text(e.key, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
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
