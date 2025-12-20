import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../providers/expense_provider.dart';

class WeeklySpendingChart extends ConsumerWidget {
  const WeeklySpendingChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final theme = Theme.of(context);

    // Define colors from AppTheme or fallbacks
    final cashColor = AppTheme.secondaryColor; // Teal
    final creditColor = AppTheme.tertiaryColor; // Rose

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.show_chart_rounded, color: theme.colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last 7 Days', 
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                        ),
                        Text(
                          'Spending Trend', 
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                        ),
                      ],
                    ),
                  ],
                ),
                // Legend
                Row(
                  children: [
                    _buildLegendDot(cashColor, 'Cash'),
                    const SizedBox(width: 12),
                    _buildLegendDot(creditColor, 'Credit'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
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
                  final dailyCash = <int, double>{};
                  final dailyCredit = <int, double>{};
                  double maxSpend = 0;

                  for (var e in expenses) {
                     // Check if expense date is within last 7 days range
                     final eDate = DateTime(e.date.year, e.date.month, e.date.day);
                     if (!eDate.isBefore(days.first) && !eDate.isAfter(days.last)) {
                        if (e.isCreditCardBill) continue; // Skip bill payments
                        final diff = eDate.difference(days.first).inDays;
                        if (diff >= 0 && diff < 7) {
                          if (e.paymentMethod == 'Credit Card') {
                            dailyCredit[diff] = (dailyCredit[diff] ?? 0) + e.amount;
                          } else {
                            dailyCash[diff] = (dailyCash[diff] ?? 0) + e.amount;
                          }
                          
                          final totalForDay = (dailyCash[diff] ?? 0) + (dailyCredit[diff] ?? 0);
                          if (totalForDay > maxSpend) {
                            maxSpend = totalForDay;
                          }
                        }
                     }
                  }

                  if (maxSpend == 0) maxSpend = 100;

                  // Create Spots
                  final cashSpots = <FlSpot>[];
                  final creditSpots = <FlSpot>[];

                  for (int i = 0; i < 7; i++) {
                    cashSpots.add(FlSpot(i.toDouble(), dailyCash[i] ?? 0));
                    creditSpots.add(FlSpot(i.toDouble(), dailyCredit[i] ?? 0));
                  }

                  return LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxSpend * 1.1, // Add buffer
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                           tooltipBgColor: theme.colorScheme.surfaceContainerHighest,
                           getTooltipItems: (touchedSpots) {
                             return touchedSpots.map((spot) {
                               final isCredit = spot.barIndex == 1; // Credit is added second
                               return LineTooltipItem(
                                 '${isCredit ? "Credit" : "Cash"}\n₹${spot.y.toStringAsFixed(0)}',
                                 TextStyle(
                                   color: isCredit ? creditColor : cashColor, 
                                   fontWeight: FontWeight.bold,
                                   fontSize: 12,
                                 ),
                               );
                             }).toList();
                           },
                        ),
                        handleBuiltInTouches: true,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= 7) return const SizedBox.shrink();
                              final date = days[index];
                              final isToday = index == 6;
                              return Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Text(
                                  DateFormat('E').format(date)[0], 
                                  style: TextStyle(
                                    color: isToday ? theme.colorScheme.primary : theme.colorScheme.outline,
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
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
                      gridData: FlGridData(
                        show: true, 
                        drawVerticalLine: false,
                        horizontalInterval: maxSpend / 4,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: theme.colorScheme.outlineVariant.withOpacity(0.5), 
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        // Cash Line
                        LineChartBarData(
                          spots: cashSpots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: cashColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          preventCurveOverShooting: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 4,
                              color: theme.colorScheme.surface,
                              strokeWidth: 2,
                              strokeColor: cashColor,
                            ),
                            checkToShowDot: (spot, barData) => spot.x == 6, // Only show for today
                          ),
                          belowBarData: BarAreaData(
                            show: true, 
                            gradient: LinearGradient(
                              colors: [cashColor.withOpacity(0.2), cashColor.withOpacity(0.0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          ),
                        ),
                        // Credit Line
                        LineChartBarData(
                          spots: creditSpots,
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: creditColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          preventCurveOverShooting: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                              radius: 4,
                              color: theme.colorScheme.surface,
                              strokeWidth: 2,
                              strokeColor: creditColor,
                            ),
                            checkToShowDot: (spot, barData) => spot.x == 6, // Only show for today
                          ),
                          belowBarData: BarAreaData(
                            show: true, 
                             gradient: LinearGradient(
                              colors: [creditColor.withOpacity(0.2), creditColor.withOpacity(0.0)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          ),
                        ),
                      ],
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

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

