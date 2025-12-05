import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/yearly_stats_provider.dart';

class YearlyReportScreen extends ConsumerStatefulWidget {
  const YearlyReportScreen({super.key});

  @override
  ConsumerState<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends ConsumerState<YearlyReportScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(yearlyStatsProvider(_selectedYear));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yearly Financial Overview'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Year Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    setState(() {
                      _selectedYear--;
                    });
                  },
                ),
                Text(
                  '$_selectedYear',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () {
                    setState(() {
                      _selectedYear++;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: statsAsync.when(
              data: (stats) {
                // Calculate Yearly Totals
                double totalIncome = 0;
                double totalExpense = 0;
                for (var s in stats) {
                  totalIncome += s.income;
                  totalExpense += s.expense;
                }
                double totalSaved = totalIncome - totalExpense;

                return Column(
                  children: [
                    // Yearly Summary Card
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      color: Colors.blueAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Text(
                              'YEARLY SUMMARY',
                              style: TextStyle(color: Colors.white70, letterSpacing: 1.2, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('Money In', style: TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${totalIncome.toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Container(height: 40, width: 1, color: Colors.white24),
                                Column(
                                  children: [
                                    const Text('Money Out', style: TextStyle(color: Colors.white70)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${totalExpense.toStringAsFixed(0)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 8),
                            Text(
                              'Total Saved: ₹${totalSaved.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              totalSaved >= 0 
                                ? 'Great job! You are in the green.' 
                                : 'Warning: Expenses exceeded income.',
                              style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    
                    // Monthly List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: stats.length,
                        itemBuilder: (context, index) {
                          final stat = stats[index];
                          final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, stat.month));
                          final isSaved = stat.balance >= 0;
                          final percentage = stat.income > 0 ? (stat.expense / stat.income) : (stat.expense > 0 ? 1.0 : 0.0);
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        monthName,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSaved ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isSaved ? 'Saved ₹${stat.balance.toStringAsFixed(0)}' : 'Overspent ₹${stat.balance.abs().toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: isSaved ? Colors.green[700] : Colors.red[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Income: ₹${stat.income.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                      Text('Spent: ₹${stat.expense.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percentage > 1 ? 1 : percentage,
                                      backgroundColor: Colors.green.withValues(alpha: 0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        percentage > 1 ? Colors.red : (percentage > 0.8 ? Colors.orange : Colors.green),
                                      ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading data: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
