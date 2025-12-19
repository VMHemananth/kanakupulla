import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';

class WeeklySpendingChart extends ConsumerWidget {
  const WeeklySpendingChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.bar_chart, color: Colors.purple),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last 7 Days', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    Text(
                      'Spending Trend', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: expensesAsync.when(
                data: (expenses) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  
                  // 1. Generate Last 7 Days Keys
                  final days = List.generate(7, (index) {
                    final date = today.subtract(Duration(days: 6 - index));
                    return date;
                  });

                  // 2. Aggregate Expenses
                  final dailyTotals = <int, double>{};
                  double maxSpend = 0;

                  for (var e in expenses) {
                     // Check if expense date is within last 7 days range
                     // Normalize dates to ignore time
                     final eDate = DateTime(e.date.year, e.date.month, e.date.day);
                     if (!eDate.isBefore(days.first) && !eDate.isAfter(days.last)) {
                        // Find index (0 to 6)
                        final diff = eDate.difference(days.first).inDays;
                        if (diff >= 0 && diff < 7) {
                          dailyTotals[diff] = (dailyTotals[diff] ?? 0) + e.amount;
                          if (dailyTotals[diff]! > maxSpend) {
                            maxSpend = dailyTotals[diff]!;
                          }
                        }
                     }
                  }

                  if (maxSpend == 0) maxSpend = 100; // Avoid division by zero

                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxSpend * 1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                           tooltipBgColor: Colors.purpleAccent,
                           getTooltipItem: (group, groupIndex, rod, rodIndex) {
                             return BarTooltipItem(
                               '₹${rod.toY.toStringAsFixed(0)}',
                               const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                             );
                           },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= 7) return const SizedBox.shrink();
                              final date = days[index];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  DateFormat('E').format(date)[0], // M, T, W...
                                  style: TextStyle(
                                    color: index == 6 ? Colors.purple : Colors.grey,
                                    fontWeight: index == 6 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        final amount = dailyTotals[index] ?? 0;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: amount,
                              color: index == 6 ? Colors.purple : Colors.purple.shade200,
                              width: 16,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxSpend * 1.2,
                                color: Colors.grey.withOpacity(0.1),
                              ), 
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
