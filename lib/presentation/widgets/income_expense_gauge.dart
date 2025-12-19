import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/salary_provider.dart';
import '../providers/budget_provider.dart';
import '../screens/income_list_screen.dart';
import '../screens/manage_categories_and_budgets_screen.dart';

class IncomeExpenseGauge extends ConsumerWidget {
  const IncomeExpenseGauge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final incomeAsync = ref.watch(salaryProvider);

    return Card(
      elevation: 8,
      margin: EdgeInsets.zero, // Dashboard padding handles it
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.blueGrey[900]!,
            ],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: expensesAsync.when(
          data: (expenses) {
             final income = incomeAsync.value?.fold(0.0, (sum, i) => sum + i.amount) ?? 0.0;
             
             double totalExpense = 0;
             if (expenses.isNotEmpty) {
               totalExpense = expenses.fold(0.0, (sum, e) {
                  if (e.paymentMethod == 'Credit Card' && !e.isCreditCardBill) return sum;
                  return sum + e.amount;
               });
             }

             final balance = income - totalExpense;
             
             final budgetAsync = ref.watch(budgetProvider);
             final budget = budgetAsync.value?.amount ?? 0.0;
             final budgetPercentage = budget > 0 ? (totalExpense / budget).clamp(0.0, 1.0) : 0.0;
             final budgetLeft = budget - totalExpense;

             return Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 // 1. Total Balance Section
                 const Text(
                   'Total Balance', 
                   style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w500)
                 ),
                 const SizedBox(height: 8),
                 Text(
                   '₹${balance.toStringAsFixed(0)}',
                   style: TextStyle(
                     color: Colors.white, 
                     fontSize: 32, 
                     fontWeight: FontWeight.bold,
                     letterSpacing: 1.0
                   ),
                 ),
                 const SizedBox(height: 32),

                 // 2. Income & Expense Row
                 Row(
                   children: [
                     // Income Column
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(4),
                                 decoration: BoxDecoration(
                                   color: Colors.green.withOpacity(0.2),
                                   shape: BoxShape.circle
                                 ),
                                 child: const Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                               ),
                               const SizedBox(width: 8),
                               const Text('Income', style: TextStyle(color: Colors.white70, fontSize: 12)),
                             ],
                           ),
                           const SizedBox(height: 8),
                           income > 0 
                           ? Material( // Interactive Edit Area
                               color: Colors.transparent,
                               child: InkWell(
                                 onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (c) => const IncomeListScreen()));
                                 },
                                 borderRadius: BorderRadius.circular(4),
                                 child: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Text(
                                       '₹${income >= 10000 ? '${(income/1000).toStringAsFixed(1)}k' : income.toStringAsFixed(0)}',
                                       style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)
                                     ),
                                     const SizedBox(width: 4),
                                     const Icon(Icons.edit, color: Colors.white24, size: 12),
                                   ],
                                 ),
                               ),
                             )
                           : OutlinedButton.icon( // Explicit Add Button
                               onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => const IncomeListScreen()));
                               },
                               icon: const Icon(Icons.add, size: 14, color: Colors.greenAccent),
                               label: const Text('Add Income', style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
                               style: OutlinedButton.styleFrom(
                                 side: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 minimumSize: Size.zero,
                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                               ),
                             ),
                         ],
                       ),
                     ),
                     
                     // Expense Column 
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(4),
                                 decoration: BoxDecoration(
                                   color: Colors.red.withOpacity(0.2),
                                   shape: BoxShape.circle
                                 ),
                                 child: const Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                               ),
                               const SizedBox(width: 8),
                               const Text('Expense', style: TextStyle(color: Colors.white70, fontSize: 12)),
                             ],
                           ),
                           const SizedBox(height: 8),
                           Text(
                             '₹${totalExpense >= 10000 ? '${(totalExpense/1000).toStringAsFixed(1)}k' : totalExpense.toStringAsFixed(0)}',
                             style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
                 
                 const SizedBox(height: 32),

                 // 3. Monthly Budget Section
                 if (budget > 0) ...[
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       const Text('Monthly Budget', style: TextStyle(color: Colors.white54, fontSize: 12)),
                       InkWell(
                         onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageCategoriesAndBudgetsScreen()));
                         },
                         borderRadius: BorderRadius.circular(4),
                         child: Row(
                           children: [
                             Text(
                               '${(budgetPercentage * 100).toStringAsFixed(0)}% used', 
                               style: TextStyle(
                                 color: budgetPercentage > 0.85 ? Colors.redAccent : Colors.white70, 
                                 fontSize: 12, 
                                 fontWeight: FontWeight.bold
                               )
                             ),
                             const SizedBox(width: 4),
                             const Icon(Icons.edit, size: 12, color: Colors.white24),
                           ],
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 8),
                   ClipRRect(
                     borderRadius: BorderRadius.circular(4),
                     child: LinearProgressIndicator(
                       value: budgetPercentage,
                       minHeight: 6,
                       backgroundColor: Colors.white10,
                       valueColor: AlwaysStoppedAnimation<Color>(
                         budgetPercentage > 0.85 ? Colors.redAccent : (budgetPercentage > 0.5 ? Colors.orangeAccent : Colors.greenAccent)
                       ),
                     ),
                   ),
                   const SizedBox(height: 8),
                   Text(
                     '₹${budgetLeft.toStringAsFixed(0)} left to spend',
                     style: const TextStyle(color: Colors.white38, fontSize: 11),
                   ),
                 ] else ...[
                    // Explicit Set Budget Button if 0
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageCategoriesAndBudgetsScreen()));
                        },
                        icon: const Icon(Icons.account_balance_wallet, size: 16, color: Colors.purpleAccent),
                        label: const Text('Set Monthly Budget', style: TextStyle(color: Colors.purpleAccent)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.purpleAccent.withOpacity(0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ),
                 ],
               ],
             );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
          error: (_, __) => const Text('Error loading data', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
  
  Widget _buildStat(BuildContext context, String label, double amount, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '₹${amount >= 10000 ? '${(amount/1000).toStringAsFixed(1)}k' : amount.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildGauge(BuildContext context, double val, double max, double min) {
      // Simple fallback placeholder if needed
      return const SizedBox();
  }
}
