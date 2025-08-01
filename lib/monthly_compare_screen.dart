import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'db_helper.dart';
import 'models.dart';

class MonthlyCompareScreen extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  MonthlyCompareScreen({required this.initialMonth, required this.initialYear});

  @override
  State<MonthlyCompareScreen> createState() => _MonthlyCompareScreenState();
}

class _MonthlyCompareScreenState extends State<MonthlyCompareScreen> {
  int month1 = 1;
  int year1 = 2024;
  int month2 = 2;
  int year2 = 2024;
  List<Expense> expenses1 = [];
  List<Expense> expenses2 = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    month1 = widget.initialMonth;
    year1 = widget.initialYear;
    month2 = month1 == 12 ? 1 : month1 + 1;
    year2 = month1 == 12 ? year1 + 1 : year1;
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => loading = true);
    expenses1 = (await DBHelper.getExpenses()).where((e) => e.date.month == month1 && e.date.year == year1).toList();
    expenses2 = (await DBHelper.getExpenses()).where((e) => e.date.month == month2 && e.date.year == year2).toList();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final allCats = <String>{};
    expenses1.forEach((e) => allCats.add(e.category));
    expenses2.forEach((e) => allCats.add(e.category));
    final catList = allCats.toList();
    final totals1 = {for (var c in catList) c: expenses1.where((e) => e.category == c).fold(0.0, (sum, e) => sum + e.amount)};
    final totals2 = {for (var c in catList) c: expenses2.where((e) => e.category == c).fold(0.0, (sum, e) => sum + e.amount)};

    return Scaffold(
      appBar: AppBar(title: Text('Monthly Compare')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: DropdownButton<int>(
                  value: month1,
                  items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(monthNames[i]))),
                  onChanged: (m) { if (m != null) setState(() { month1 = m; _loadExpenses(); }); },
                )),
                SizedBox(width: 8),
                Expanded(child: DropdownButton<int>(
                  value: year1,
                  items: List.generate(5, (i) {
                    int year = DateTime.now().year - 2 + i;
                    return DropdownMenuItem(value: year, child: Text(year.toString()));
                  }),
                  onChanged: (y) { if (y != null) setState(() { year1 = y; _loadExpenses(); }); },
                )),
              ],
            ),
            Row(
              children: [
                Expanded(child: DropdownButton<int>(
                  value: month2,
                  items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(monthNames[i]))),
                  onChanged: (m) { if (m != null) setState(() { month2 = m; _loadExpenses(); }); },
                )),
                SizedBox(width: 8),
                Expanded(child: DropdownButton<int>(
                  value: year2,
                  items: List.generate(5, (i) {
                    int year = DateTime.now().year - 2 + i;
                    return DropdownMenuItem(value: year, child: Text(year.toString()));
                  }),
                  onChanged: (y) { if (y != null) setState(() { year2 = y; _loadExpenses(); }); },
                )),
              ],
            ),
            SizedBox(height: 16),
            loading
                ? CircularProgressIndicator()
                : catList.isEmpty
                  ? Text('No expenses for selected months.')
                  : SizedBox(
                      height: 220,
                      child: BarChart(
                        BarChartData(
                          barGroups: List.generate(catList.length, (i) =>
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(toY: totals1[catList[i]] ?? 0, color: Colors.blue, width: 12),
                                BarChartRodData(toY: totals2[catList[i]] ?? 0, color: Colors.green, width: 12),
                              ],
                              barsSpace: 4,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                              int idx = value.toInt();
                              if (idx >= 0 && idx < catList.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(catList[idx], style: TextStyle(fontSize: 12)),
                                );
                              }
                              return Text('');
                            })),
                          ),
                          barTouchData: BarTouchData(enabled: true),
                          gridData: FlGridData(show: true),
                        ),
                      ),
                    ),
            SizedBox(height: 8),
            ...catList.map((cat) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cat, style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${monthNames[month1 - 1]} $year1: ₹${(totals1[cat] ?? 0).toStringAsFixed(2)}'),
                Text('${monthNames[month2 - 1]} $year2: ₹${(totals2[cat] ?? 0).toStringAsFixed(2)}'),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

const List<String> monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];
