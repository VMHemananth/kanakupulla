import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense_model.dart';

class DailySpendingChart extends StatelessWidget {
  final List<ExpenseModel> expenses;
  final DateTime date;

  const DailySpendingChart({
    super.key,
    required this.expenses,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final dailyTotals = List.generate(daysInMonth, (index) => 0.0);

    for (var expense in expenses) {
      if (expense.date.year == date.year && expense.date.month == date.month) {
        dailyTotals[expense.date.day - 1] += expense.amount;
      }
    }

    final maxAmount = dailyTotals.reduce((curr, next) => curr > next ? curr : next);
    final maxY = maxAmount > 0 ? maxAmount * 1.2 : 100.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Spending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueAccent,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${group.x + 1} ${DateFormat('MMM').format(date)}\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '₹${rod.toY.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.yellow,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
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
                          final day = value.toInt() + 1;
                          if (day % 5 == 0 || day == 1) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                day.toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(daysInMonth, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: dailyTotals[index],
                          color: dailyTotals[index] > 0 ? Colors.blue : Colors.grey[300],
                          width: 6,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
