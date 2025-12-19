import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/date_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/salary_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/recent_expenses.dart';
import '../widgets/credit_usage_card.dart';
import '../widgets/weekly_spending_chart.dart';
import '../widgets/income_expense_gauge.dart';
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';
import 'monthly_compare_screen.dart';
import 'sms_transactions_screen.dart';
import 'yearly_report_screen.dart';
import 'income_list_screen.dart';
import 'transaction_review_screen.dart';
import 'analysis_screen.dart';
import 'daily_expenses_calendar_screen.dart';
import 'manage_categories_and_budgets_screen.dart';
import 'manage_fixed_expenses_screen.dart';
import 'manage_recurring_income_screen.dart';
import 'manage_credit_cards_screen.dart';
import '../providers/salary_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/sms_provider.dart';
import '../../core/utils/csv_exporter.dart';
import '../providers/fixed_expense_provider.dart';
import '../providers/auth_provider.dart';

import '../../data/repositories/credit_card_repository.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/models/expense_model.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../../data/services/pdf_service.dart';
import 'search_screen.dart';
import 'debt_list_screen.dart';
import 'savings_list_screen.dart';
import 'split/group_list_screen.dart';
import '../../data/services/widget_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initial check for current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final date = ref.read(selectedDateProvider);
      _checkFixedExpenses(date);
      _checkCreditCardBills();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // We can't easily listen to provider changes here without triggering builds.
    // Instead, we can listen in the build method or use a ProviderListener.
    // But simplest is to just call _checkFixedExpenses whenever the date changes in the build method?
    // No, that would trigger async work during build.
    // Better: Use ref.listen in build.
  }

  Future<void> _checkFixedExpenses(DateTime date) async {
    final missing = await ref.read(fixedExpensesProvider.notifier).getMissingFixedExpenses(date);
    
    if (missing.isNotEmpty) {
      for (var fixed in missing) {
        final expense = ExpenseModel(
          id: '${fixed.id}_${date.year}_${date.month}', // Deterministic ID
          title: fixed.title,
          amount: fixed.amount,
          date: DateTime(date.year, date.month, fixed.dayOfMonth > 0 ? fixed.dayOfMonth : 1),
          category: fixed.category,
          paymentMethod: 'Cash',
        );
        ref.read(expensesProvider.notifier).addExpense(expense);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auto-added ${missing.length} fixed expenses for ${DateFormat('MMMM').format(date)}.')),
        );
      }
    }
  }

  Future<void> _checkCreditCardBills() async {
    // Check for bills using repository directly
    final repo = ref.read(creditCardRepositoryProvider);
    final cardsList = await repo.getCreditCards();
    final now = DateTime.now();
    final currentMonthStr = '${now.year}-${now.month}';

    for (var card in cardsList) {
      // Trigger: Day AFTER Billing Day
      // Why? To ensure the billing day is fully complete and all expenses are recorded.
      // Also check if we haven't already generated/checked for this month
      
      // Calculate previous month's target billing if we are past billing day
      // Logic: If today is billingDay + 1, we are checking for the cycle ending yesterday.
      
      // Simpler check: If today > billingDay and lastBill != thisMonth
      // But user specifically asked for "On the day after billing day".
      bool isDayAfterBilling = now.day == (card.billingDay + 1);
      // Handle edge case where billing day is month end? 
      // Simplified: Just strictly check day match for now, or >= if user missed opening app yesterday.
      
      // Allow checking any day AFTER billing day, until marked as done for this month
      if (now.day > card.billingDay && card.lastBillGeneratedMonth != currentMonthStr) {
        // We have a pending bill check for this month.
        
        // Cycle: From [Month-1, BillingDay] to [Month, BillingDay - 1]
        final cycleEnd = DateTime(now.year, now.month, card.billingDay - 1, 23, 59, 59);
        final cycleStart = DateTime(now.year, now.month - 1, card.billingDay);
        
        final allExpenses = await ref.read(expenseRepositoryProvider).getExpenses();
        final cycleExpenses = allExpenses.where((e) => 
          e.creditCardId == card.id && 
          e.date.isAfter(cycleStart.subtract(const Duration(seconds: 1))) && 
          e.date.isBefore(cycleEnd.add(const Duration(seconds: 1))) &&
          !e.isCreditCardBill // Don't count bills
        ).toList();

        final totalAmount = cycleExpenses.fold(0.0, (sum, e) => sum + e.amount);

        if (totalAmount > 0) {
           // Show Dialog
           if (!mounted) continue;
           
           // We shouldn't block the loop with await showDialog immediately multiple times? 
           // For safety, let's just trigger one dialog at a time, or chained?
           // Using a delayed check or just showing for the first pending one found is safer for UX.
           
           await showDialog(
             context: context,
             builder: (ctx) => AlertDialog(
               title: Text('Generate Bill for ${card.name}?'),
               content: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text('Billing Cycle Ended: ${DateFormat('MMM d').format(cycleEnd)}'),
                   const SizedBox(height: 8),
                   Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),
                   const SizedBox(height: 16),
                   const Text('Add this as a bill payment expense for next month?'),
                 ],
               ),
               actions: [
                 TextButton(
                   onPressed: () async {
                     // NO: Just mark as checked so we don't ask again this month
                     Navigator.pop(ctx);
                     final updatedCard = card.copyWith(lastBillGeneratedMonth: currentMonthStr);
                     await repo.updateCreditCard(updatedCard);
                   },
                   child: const Text('No, Manual'),
                 ),
                 ElevatedButton(
                   onPressed: () async {
                     // YES: Generate Bill
                     Navigator.pop(ctx);
                     
                     final billExpense = ExpenseModel(
                        id: 'bill_${card.id}_${now.year}_${now.month}',
                        title: '${card.name} Bill',
                        amount: totalAmount,
                        date: DateTime(now.year, now.month + 1, card.billingDay), // Due date approx next month
                        category: 'Bills',
                        paymentMethod: 'Bank Transfer',
                        isCreditCardBill: true,
                        creditCardId: card.id,
                      );

                      await ref.read(expensesProvider.notifier).addExpense(billExpense);
                      
                      final updatedCard = card.copyWith(lastBillGeneratedMonth: currentMonthStr);
                      await repo.updateCreditCard(updatedCard);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bill generated for ₹${totalAmount.toStringAsFixed(0)}')),
                        );
                      }
                   },
                   child: const Text('Yes, Add Bill'),
                 ),
               ],
             ),
           );
           
           // Break after showing one dialog to avoid stacking. Will check others next time app opens/home refreshes.
           break; 
        } else {
           // No expenses, mark checked
           final updatedCard = card.copyWith(lastBillGeneratedMonth: currentMonthStr);
           await repo.updateCreditCard(updatedCard);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedDateProvider);
    final user = ref.watch(userProvider);

    // Listen for date changes to trigger auto-add
    ref.listen(selectedDateProvider, (previous, next) {
      _checkFixedExpenses(next);
    });

    // Listen for fixed expense changes to trigger auto-add (e.g. after adding new fixed expense)
    ref.listen(fixedExpensesProvider, (previous, next) {
      _checkFixedExpenses(date);
    });

    // Calculate Balance for Widget
    final expensesAsync = ref.watch(expensesProvider);
    final incomeAsync = ref.watch(salaryProvider);
    
    final totalExpense = expensesAsync.value?.fold(0.0, (sum, e) => sum! + e.amount) ?? 0.0;
    final totalIncome = incomeAsync.value?.fold(0.0, (sum, e) => sum! + e.amount) ?? 0.0;
    final balance = totalIncome - totalExpense;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetService().updateWidget(balance);
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanakupulla'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                // We only care about month and year
                ref.read(selectedDateProvider.notifier).state = DateTime(picked.year, picked.month);
                // Refresh data
                ref.refresh(expensesProvider);
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: UserAccountsDrawerHeader(
                accountName: Text(user.name),
                accountEmail: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                      Text(user.phoneNumber!, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: user.profilePicPath != null 
                    ? (user.profilePicPath!.startsWith('http') 
                        ? NetworkImage(user.profilePicPath!) 
                        : FileImage(File(user.profilePicPath!)) as ImageProvider)
                    : null,
                  child: user.profilePicPath == null ? const Icon(Icons.person) : null,
                ),
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Monthly Compare'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MonthlyCompareScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Spending Analysis'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AnalysisScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Calendar View'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DailyExpensesCalendarScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageCategoriesAndBudgetsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('Fixed Expenses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageFixedExpensesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Recurring Income'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageRecurringIncomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Credit Cards'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageCreditCardsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text('Debts & Loans'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DebtListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text('Bill Split'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GroupListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Savings Goals'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavingsListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export Report'),
              onTap: () {
                Navigator.pop(context);
                _showExportDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Yearly Financial Overview'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const YearlyReportScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(expensesProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... existing header ...
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy').format(date),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.list),
                    label: const Text('View All'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(48, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const ExpenseListScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              const SizedBox(height: 16),
              const IncomeExpenseGauge(),
              const SizedBox(height: 16),
              _buildInsightBanner(context, ref),
              const SizedBox(height: 16),
              _buildQuickActions(context),
              const SizedBox(height: 16),

              // Prompts
              Consumer(builder: (context, ref, _) {
                final incomeAsync = ref.watch(salaryProvider);
                final budgetAsync = ref.watch(budgetProvider);
                
                final hasIncome = incomeAsync.value?.isNotEmpty ?? false;
                final hasBudget = budgetAsync.value != null;

                if (hasIncome && hasBudget) return const SizedBox.shrink();

                final colorScheme = Theme.of(context).colorScheme;

                return Column(
                  children: [
                    if (!hasIncome)
                      Card(
                        color: colorScheme.errorContainer, // Better dark mode support
                        child: ListTile(
                          leading: Icon(Icons.warning, color: colorScheme.onErrorContainer),
                          title: Text('No Income Added', style: TextStyle(color: colorScheme.onErrorContainer)),
                          subtitle: Text('Add your salary to track balance.', style: TextStyle(color: colorScheme.onErrorContainer)),
                          trailing: TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const IncomeListScreen()));
                            },
                            child: Text('ADD', style: TextStyle(color: colorScheme.onErrorContainer, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    if (!hasBudget)
                      Card(
                        color: colorScheme.secondaryContainer,
                        child: ListTile(
                          leading: Icon(Icons.info, color: colorScheme.onSecondaryContainer),
                          title: Text('No Budget Set', style: TextStyle(color: colorScheme.onSecondaryContainer)),
                          subtitle: Text('Set a monthly budget to track spending.', style: TextStyle(color: colorScheme.onSecondaryContainer)),
                          trailing: TextButton(
                            onPressed: () {
                              _showSetBudgetDialog(context, ref, date);
                            },
                            child: Text('SET', style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    // SMS Prompt
                    Consumer(builder: (context, ref, _) {
                      final smsAsync = ref.watch(smsTransactionsProvider);
                      return smsAsync.when(
                        data: (txns) {
                          if (txns.isEmpty) return const SizedBox.shrink();
                          return Card(
                            color: colorScheme.tertiaryContainer,
                            child: ListTile(
                              leading: Icon(Icons.sms, color: colorScheme.onTertiaryContainer),
                              title: Text('New Transactions', style: TextStyle(color: colorScheme.onTertiaryContainer)),
                              subtitle: Text('${txns.length} potential expenses found.', style: TextStyle(color: colorScheme.onTertiaryContainer)),
                              trailing: TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => const TransactionReviewScreen()));
                                },
                                child: Text('REVIEW', style: TextStyle(color: colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              }),
              const CreditUsageCard(),
              const SizedBox(height: 16),
              const SalaryCard(),
              const SizedBox(height: 16),
              const BudgetCard(),
              const SizedBox(height: 16),
              const WeeklySpendingChart(),
              const SizedBox(height: 16),
              // const SizedBox(height: 16), // duplicte removed
              const ExpenseChart(),
              const SizedBox(height: 16),
              const RecentExpenses(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddExpenseScreen(initialDate: date)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(context, Icons.camera_alt, 'Scan', () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
             );
             // Note: Ideally AddExpenseScreen should open camera directly if a flag is passed, 
             // but 'Scan' just opening form with easy access to camera is fine for now MVP.
             // Actually, the user asked for "Scan Receipt" -> let's make it trigger scan on open if possible or just open screen.
        }),
        _buildActionButton(context, Icons.email, 'Inbox', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SmsTransactionsScreen()),
            );
        }),
        _buildActionButton(context, Icons.calendar_month, 'Calendar', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DailyExpensesCalendarScreen()),
            );
        }),
        _buildActionButton(context, Icons.pie_chart, 'Analysis', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AnalysisScreen()),
            );
        }),
        _buildActionButton(context, Icons.group, 'Split', () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const GroupListScreen()),
             );
        }),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInsightBanner(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetProvider);
    final expensesAsync = ref.watch(expensesProvider);
    
    if (!budgetAsync.hasValue || !expensesAsync.hasValue || budgetAsync.value == null) {
      return const SizedBox.shrink();
    }

    final totalBudget = budgetAsync.value!;
    final totalExpense = expensesAsync.value!.fold(0.0, (sum, e) => sum + e.amount);
    final percentage = (totalExpense / totalBudget.amount) * 100;

    String message = '';
    Color color = Colors.green;
    IconData icon = Icons.check_circle;

    if (percentage > 100) {
      message = 'Alert: Budget exceeded by ${(percentage - 100).toStringAsFixed(0)}%!';
      color = Colors.red;
      icon = Icons.warning;
    } else if (percentage > 85) {
       message = 'Heads up: You used ${percentage.toStringAsFixed(0)}% of your budget.';
       color = Colors.orange;
       icon = Icons.info;
    } else {
       message = 'Good job! You are ${(100 - percentage).toStringAsFixed(0)}% under budget.';
       color = Colors.green;
       icon = Icons.thumb_up;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _exportCsv() async {
    try {
      final expensesAsync = ref.read(expensesProvider);
      if (expensesAsync.hasValue) {
        await CsvExporter.exportExpenses(expensesAsync.value!);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No expenses to export')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('CSV export failed: $e')),
        );
      }
    }
  }

  Future<void> _generatePdf() async {
    try {
      final expensesAsync = ref.read(expensesProvider);
      if (expensesAsync.hasValue) {
        await PdfService().generateExpenseReport(expensesAsync.value!);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No expenses to export')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF generation failed: $e')),
        );
      }
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Export Report'),
        content: const Text('Choose a format to export your expenses.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _exportCsv();
            },
            icon: const Icon(Icons.table_chart),
            label: const Text('CSV'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _generatePdf();
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('PDF'),
          ),
        ],
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, WidgetRef ref, DateTime date) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null) {
                // Validation: Check against Income
                final incomeList = ref.read(salaryProvider).value ?? [];
                final totalIncome = incomeList.fold(0.0, (sum, e) => sum + e.amount);

                if (totalIncome == 0) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add income before setting a budget.')),
                  );
                  return;
                }

                if (amount > totalIncome) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Budget (₹${amount.toStringAsFixed(0)}) cannot exceed Total Income (₹${totalIncome.toStringAsFixed(0)})')),
                  );
                  return;
                }

                ref.read(budgetProvider.notifier).setBudget(amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
