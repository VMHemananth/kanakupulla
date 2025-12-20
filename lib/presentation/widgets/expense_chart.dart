import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../providers/date_provider.dart';
import '../../core/utils/category_colors.dart';

enum SpendingFilter { cash, credit, all }

class ExpenseChart extends ConsumerStatefulWidget {
  const ExpenseChart({super.key});

  @override
  ConsumerState<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends ConsumerState<ExpenseChart> {
  int touchedIndex = -1;
  SpendingFilter _filter = SpendingFilter.cash;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(allExpensesProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Expense Breakdown', 
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SegmentedButton<SpendingFilter>(
                  segments: const [
                    ButtonSegment(value: SpendingFilter.cash, label: Text('Cash', style: TextStyle(fontSize: 10))),
                    ButtonSegment(value: SpendingFilter.credit, label: Text('Credit', style: TextStyle(fontSize: 10))),
                    ButtonSegment(value: SpendingFilter.all, label: Text('All', style: TextStyle(fontSize: 10))),
                  ], 
                  selected: {_filter},
                  onSelectionChanged: (Set<SpendingFilter> newSelection) {
                    setState(() {
                      _filter = newSelection.first;
                    });
                  },
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 240, 
              child: expensesAsync.when(
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pie_chart_outline_rounded, size: 48, color: theme.colorScheme.outlineVariant),
                          const SizedBox(height: 12),
                          Text('No expenses yet', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    );
                  }
                  
                  // Group by category based on filter
                  final Map<String, double> categoryTotals = {};
                  double total = 0;
                  
                  for (var e in expenses) {
                    if (e.amount <= 0) continue; 
                    
                    // Filter by Date (same as expensesProvider logic)
                    if (e.date.year != selectedDate.year || e.date.month != selectedDate.month) continue;

                    bool include = false;
                    switch (_filter) {
                      case SpendingFilter.cash:
                        // Cash + Bills 
                        if (e.paymentMethod != 'Credit Card' || e.isCreditCardBill) include = true;
                        break;
                      case SpendingFilter.credit:
                        // Credit Card transactions only 
                        if (e.paymentMethod == 'Credit Card' && !e.isCreditCardBill) include = true;
                        break;
                      case SpendingFilter.all:
                        // All transactions (Exclude bills to avoid double counting if treating logic that way)
                        // Actually, if we view ALL, we typically want the raw transactions.
                        // But if we have bills paying off cc, that's transfer.
                        if (!e.isCreditCardBill) include = true;
                        break;
                    }

                    if (include) {
                      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
                      total += e.amount;
                    }
                  }

                  if (total <= 0) {
                     return Center(
                       child: Text('No data for this filter', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))
                     );
                  }

                  final entries = categoryTotals.entries.toList();
                  // Sort by amount descending for better visualization
                  entries.sort((a, b) => b.value.compareTo(a.value));

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                sectionsSpace: 4, 
                                centerSpaceRadius: 60,
                                startDegreeOffset: -90,
                                sections: List.generate(entries.length, (i) {
                                  final isTouched = i == touchedIndex;
                                  final radius = isTouched ? 40.0 : 30.0;
                                  final entry = entries[i];
                                  final percentage = (entry.value / total) * 100;
                                  
                                  return PieChartSectionData(
                                    color: CategoryColors.getColor(entry.key),
                                    value: entry.value,
                                    title: '', 
                                    radius: radius,
                                    badgeWidget: isTouched ? Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                                      ),
                                      child: Text(
                                        '${percentage.toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: CategoryColors.getColor(entry.key),
                                        ),
                                      ),
                                    ) : null,
                                    badgePositionPercentageOffset: 1.1,
                                    borderSide: isTouched 
                                      ? BorderSide(color: theme.colorScheme.surface, width: 2) 
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
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
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
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: touchedIndex != -1 && touchedIndex < entries.length
                                      ? CategoryColors.getColor(entries[touchedIndex].key)
                                      : theme.colorScheme.onSurface
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Legend Section
                      Expanded(
                        flex: 4,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          itemCount: entries.length,
                          separatorBuilder: (c, i) => const SizedBox(height: 12),
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
                               borderRadius: BorderRadius.circular(8),
                               child: AnimatedContainer(
                                 duration: const Duration(milliseconds: 200),
                                 padding: const EdgeInsets.all(8),
                                 decoration: BoxDecoration(
                                   color: isTouched ? CategoryColors.getColor(entry.key).withOpacity(0.1) : Colors.transparent,
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child: Row(
                                   children: [
                                     Container(
                                       width: 10, 
                                       height: 10,
                                       decoration: BoxDecoration(
                                         color: CategoryColors.getColor(entry.key),
                                         shape: BoxShape.circle,
                                       ),
                                     ),
                                     const SizedBox(width: 10),
                                     Expanded(
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text(
                                             entry.key, 
                                             style: theme.textTheme.bodySmall?.copyWith(
                                               fontWeight: FontWeight.w600,
                                               color: isTouched ? CategoryColors.getColor(entry.key) : theme.colorScheme.onSurface,
                                             ), 
                                             overflow: TextOverflow.ellipsis
                                           ),
                                           Text(
                                             '${percentage.toStringAsFixed(1)}%', 
                                             style: theme.textTheme.labelSmall?.copyWith(
                                               color: theme.colorScheme.onSurfaceVariant,
                                             ), 
                                           ),
                                         ],
                                       )
                                     ),
                                     Text(
                                       '₹${entry.value.toStringAsFixed(0)}',
                                       style: theme.textTheme.bodyMedium?.copyWith(
                                         fontWeight: FontWeight.bold,
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
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
