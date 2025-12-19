import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_model.dart';
import 'dart:math';

class MonthlyTrendChart extends StatelessWidget {
  final List<ExpenseModel> allExpenses;
  final DateTime selectedDate;

  const MonthlyTrendChart({
    super.key,
    required this.allExpenses,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define Months
    final thisMonthStart = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastMonthStart = DateTime(selectedDate.year, selectedDate.month - 1, 1);
    
    // 2. Filter Expenses
    final thisMonthExpenses = allExpenses.where((e) => 
      e.date.year == thisMonthStart.year && 
      e.date.month == thisMonthStart.month &&
      !((e.paymentMethod == 'Credit Card') && !e.isCreditCardBill)
    ).toList();

    final lastMonthExpenses = allExpenses.where((e) => 
      e.date.year == lastMonthStart.year && 
      e.date.month == lastMonthStart.month &&
      !((e.paymentMethod == 'Credit Card') && !e.isCreditCardBill)
    ).toList();

    // 3. Calculate Cumulative Totals
    List<FlSpot> getCumulativeSpots(List<ExpenseModel> expenses, DateTime startOfMonth) {
      final days = DateTime(startOfMonth.year, startOfMonth.month + 1, 0).day;
      final dailyTotals = List<double>.filled(days + 1, 0); // index 0 unused or day 0? 1-based indexing for days.
      
      // Zero out day 0 (start point)
      dailyTotals[0] = 0; 

      // Fill daily amounts
      for (var e in expenses) {
        if (e.date.day <= days) {
          dailyTotals[e.date.day] += e.amount;
        }
      }

      // Convert to cumulative
      double runningTotal = 0;
      final spots = <FlSpot>[const FlSpot(0, 0)];
      
      // Determine max day to plot (if this month, stop at today)
      final now = DateTime.now();
      final isCurrentMonth = startOfMonth.year == now.year && startOfMonth.month == now.month;
      final maxDay = isCurrentMonth ? now.day : days;

      for (int i = 1; i <= days; i++) {
        runningTotal += dailyTotals[i];
        if (i <= maxDay) {
           spots.add(FlSpot(i.toDouble(), runningTotal));
        }
      }
      return spots;
    }

    final thisMonthSpots = getCumulativeSpots(thisMonthExpenses, thisMonthStart);
    final lastMonthSpots = getCumulativeSpots(lastMonthExpenses, lastMonthStart);

    // 4. Determine Max Y for scaling
    double maxY = 0;
    for (var s in thisMonthSpots) maxY = max(maxY, s.y);
    for (var s in lastMonthSpots) maxY = max(maxY, s.y);
    if (maxY == 0) maxY = 1000;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Spending Trend',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Now', style: TextStyle(fontSize: 10)),
                    const SizedBox(width: 8),
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Last Month', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent.withOpacity(0.8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            'Day ${spot.x.toInt()}: ₹${spot.y.toStringAsFixed(0)}',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true, 
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                     bottomTitles: AxisTitles(
                       sideTitles: SideTitles(
                         showTitles: true,
                         interval: 5,
                         getTitlesWidget: (value, meta) {
                           if (value == 0) return const SizedBox.shrink();
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                           );
                         },
                       ),
                     ),
                     leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                     topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 31,
                  minY: 0,
                  maxY: maxY * 1.1,
                  lineBarsData: [
                    // Last Month (Grey)
                    LineChartBarData(
                      spots: lastMonthSpots,
                      isCurved: true,
                      color: Colors.grey.withOpacity(0.5),
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                      dashArray: [5, 5],
                    ),
                    // This Month (Blue)
                    LineChartBarData(
                      spots: thisMonthSpots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
