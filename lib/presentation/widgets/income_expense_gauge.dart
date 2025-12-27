import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
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
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero, 
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B), // Slate 800
              Color(0xFF0F172A), // Slate 900
            ],
          ),
          boxShadow: [
             BoxShadow(
               color: Colors.blue.withOpacity(0.1),
               blurRadius: 20,
               offset: const Offset(0, 10),
             ),
          ],
        ),
        padding: const EdgeInsets.all(24.0),
        child: expensesAsync.when(
          data: (expenses) {
             final income = incomeAsync.value?.fold(0.0, (sum, i) => sum + i.amount) ?? 0.0;
             
              double totalExpense = 0;
              double cashOutflow = 0;

              if (expenses.isNotEmpty) {
                for (var e in expenses) {
                   // 1. Consumption: Exclude Bill Payments
                   if (!e.isCreditCardBill) {
                     totalExpense += e.amount;
                   }
                   
                   // 2. Cash Outflow: Exclude Credit Card Purchases (Liability, not Cash)
                   //    Include Bill Payments (Cash leaving bank)
                   if (e.paymentMethod != 'Credit Card') {
                     cashOutflow += e.amount;
                   }
                }
              }

              final balance = income - cashOutflow;
              
              // FIX: Use cashOutflow for the "Expense" display in Balance Box to match Balance calculation
              final displayExpense = cashOutflow;

              final budgetAsync = ref.watch(budgetProvider);
              final budget = budgetAsync.value?.amount ?? 0.0;
              final budgetPercentage = budget > 0 ? (totalExpense / budget).clamp(0.0, 1.0) : 0.0;
              final budgetLeft = budget - totalExpense;

             return Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 // 1. Total Balance Section
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(
                           'Total Balance', 
                           style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
                         ),
                         const SizedBox(height: 4),
                         Text(
                           '₹${balance.toStringAsFixed(0)}',
                           style: theme.textTheme.displaySmall?.copyWith(
                             color: Colors.white, 
                             fontWeight: FontWeight.bold,
                             letterSpacing: -0.5,
                           ),
                         ),
                       ],
                     ),
                     // Optional: Trend Icon or small graph could go here
                     Container(
                       padding: const EdgeInsets.all(12),
                       decoration: BoxDecoration(
                         color: Colors.white.withOpacity(0.05),
                         borderRadius: BorderRadius.circular(16),
                       ),
                       child: const Icon(Icons.account_balance, color: Colors.white70),
                     )
                   ],
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
                                 padding: const EdgeInsets.all(6),
                                 decoration: BoxDecoration(
                                   color: AppTheme.secondaryColor.withOpacity(0.2),
                                   shape: BoxShape.circle
                                 ),
                                 child: const Icon(Icons.arrow_downward, color: AppTheme.secondaryColor, size: 14),
                               ),
                               const SizedBox(width: 8),
                               const Text('Income', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                             ],
                           ),
                           const SizedBox(height: 12),
                           income > 0 
                           ? Material( 
                               color: Colors.transparent,
                               child: InkWell(
                                 onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (c) => const IncomeListScreen()));
                                 },
                                 borderRadius: BorderRadius.circular(8),
                                 child: Text(
                                   '₹${income >= 10000 ? '${(income/1000).toStringAsFixed(1)}k' : income.toStringAsFixed(0)}',
                                   style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
                                 ),
                               ),
                             )
                           : GestureDetector(
                               onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => const IncomeListScreen()));
                               },
                               child: const Text('Add +', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
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
                                 padding: const EdgeInsets.all(6),
                                 decoration: BoxDecoration(
                                   color: AppTheme.tertiaryColor.withOpacity(0.2),
                                   shape: BoxShape.circle
                                 ),
                                 child: const Icon(Icons.arrow_upward, color: AppTheme.tertiaryColor, size: 14),
                               ),
                               const SizedBox(width: 8),
                               const Text('Expense', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                             ],
                           ),
                           const SizedBox(height: 12),
                           Text(
                             '₹${displayExpense >= 10000 ? '${(displayExpense/1000).toStringAsFixed(1)}k' : displayExpense.toStringAsFixed(0)}',
                             style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)
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
                         child: Text(
                           '${(budgetPercentage * 100).toStringAsFixed(0)}% used', 
                           style: TextStyle(
                             color: budgetPercentage > 0.85 ? AppTheme.tertiaryColor : Colors.white, 
                             fontSize: 12, 
                             fontWeight: FontWeight.bold
                           )
                         ),
                       ),
                     ],
                   ),
                   const SizedBox(height: 12),
                   ClipRRect(
                     borderRadius: BorderRadius.circular(8),
                     child: LinearProgressIndicator(
                       value: budgetPercentage,
                       minHeight: 8,
                       backgroundColor: Colors.white.withOpacity(0.1),
                       valueColor: AlwaysStoppedAnimation<Color>(
                         budgetPercentage > 0.85 ? AppTheme.tertiaryColor : (budgetPercentage > 0.5 ? Colors.orangeAccent : AppTheme.secondaryColor)
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
                      child: TextButton.icon(
                        onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (c) => const ManageCategoriesAndBudgetsScreen()));
                        },
                        icon: const Icon(Icons.account_balance_wallet, size: 16, color: Colors.white70),
                        label: const Text('Set Monthly Budget', style: TextStyle(color: Colors.white)),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.1),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
