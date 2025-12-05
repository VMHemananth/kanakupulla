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
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expense Breakdown', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 18,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'This Month',
                    style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220, // Increased height for better visibility
              child: expensesAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('No expenses yet', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  }
                  
                  // Group by category
                  final Map<String, double> categoryTotals = {};
                  double total = 0;
                  for (var e in expenses) {
                    if (e.amount <= 0) continue; 
                    if (e.paymentMethod == 'Credit Card' && !e.isCreditCardBill) continue;
                    categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
                    total += e.amount;
                  }

                  if (total <= 0) return const Center(child: Text('No Data'));

                  final entries = categoryTotals.entries.toList();
                  // Sort by amount descending for better visualization
                  entries.sort((a, b) => b.value.compareTo(a.value));

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chart Section
                      Expanded(
                        flex: 5,
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
                                sectionsSpace: 2, // Spacing between sections
                                centerSpaceRadius: 50, // Larger hole for donut effect
                                startDegreeOffset: -90,
                                sections: List.generate(entries.length, (i) {
                                  final isTouched = i == touchedIndex;
                                  final radius = isTouched ? 35.0 : 25.0; // Thinner ring
                                  final entry = entries[i];
                                  final percentage = (entry.value / total) * 100;
                                  
                                  return PieChartSectionData(
                                    color: CategoryColors.getColor(entry.key),
                                    value: entry.value,
                                    title: '', // Hide title on chart to keep it clean, show in center
                                    radius: radius,
                                    badgeWidget: isTouched ? Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                      ),
                                      child: Text(
                                        '${percentage.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: CategoryColors.getColor(entry.key),
                                        ),
                                      ),
                                    ) : null,
                                    badgePositionPercentageOffset: .98,
                                    borderSide: isTouched 
                                      ? const BorderSide(color: Colors.white, width: 2) 
                                      : BorderSide.none,
                                  );
                                }),
                              ),
                            ),
                            // Center Text
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  touchedIndex != -1 && touchedIndex < entries.length
                                      ? entries[touchedIndex].key
                                      : 'Total',
                                  style: const TextStyle(
                                    fontSize: 12, 
                                    fontWeight: FontWeight.w500, 
                                    color: Colors.grey
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  touchedIndex != -1 && touchedIndex < entries.length
                                      ? '₹${entries[touchedIndex].value.toStringAsFixed(0)}'
                                      : '₹${total.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold, 
                                    color: touchedIndex != -1 && touchedIndex < entries.length
                                      ? CategoryColors.getColor(entries[touchedIndex].key)
                                      : Theme.of(context).textTheme.bodyLarge?.color
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Legend Section
                      Expanded(
                        flex: 4,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: entries.length,
                          separatorBuilder: (c, i) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                             final entry = entries[index];
                             final isTouched = index == touchedIndex;
                             final percentage = (entry.value / total) * 100;
                             
                             return InkWell(
                               onTap: () {
                                 setState(() {
                                   if (touchedIndex == index) {
                                     touchedIndex = -1;
                                   } else {
                                     touchedIndex = index;
                                   }
                                 });
                               },
                               child: AnimatedContainer(
                                 duration: const Duration(milliseconds: 200),
                                 padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                 decoration: BoxDecoration(
                                   color: isTouched ? CategoryColors.getColor(entry.key).withOpacity(0.1) : Colors.transparent,
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child: Row(
                                   children: [
                                     Container(
                                       width: 12, 
                                       height: 12,
                                       decoration: BoxDecoration(
                                         color: CategoryColors.getColor(entry.key),
                                         shape: BoxShape.circle,
                                       ),
                                     ),
                                     const SizedBox(width: 8),
                                     Expanded(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text(
                                             entry.key, 
                                             style: TextStyle(
                                               fontSize: 12, 
                                               fontWeight: FontWeight.w600,
                                               color: isTouched ? CategoryColors.getColor(entry.key) : Theme.of(context).textTheme.bodyMedium?.color,
                                             ), 
                                             overflow: TextOverflow.ellipsis
                                           ),
                                           Text(
                                             '${percentage.toStringAsFixed(1)}%', 
                                             style: TextStyle(
                                               fontSize: 10, 
                                               color: Theme.of(context).textTheme.bodySmall?.color,
                                             ), 
                                           ),
                                         ],
                                       )
                                     ),
                                     Text(
                                       '₹${entry.value.toStringAsFixed(0)}',
                                       style: TextStyle(
                                         fontSize: 12,
                                         fontWeight: FontWeight.bold,
                                         color: Theme.of(context).textTheme.bodyMedium?.color,
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
                error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
