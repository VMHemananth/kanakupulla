import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/date_provider.dart';
import '../providers/expense_provider.dart';
import '../../data/services/sms_service.dart';
import '../services/voice_expense_service.dart';
import '../providers/user_provider.dart';
import '../widgets/salary_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/expense_chart.dart';
import '../widgets/recent_expenses.dart';
import '../widgets/expense_chart.dart';
import '../widgets/recent_expenses.dart';
// import '../widgets/credit_usage_card.dart'; // Deprecated
import '../widgets/weekly_spending_chart.dart';
import '../widgets/income_expense_gauge.dart';
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
import '../widgets/financial_health_widgets.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }
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
        
        // Helper to handle days > 28
        DateTime getValidDate(int y, int m, int d) {
           final lastDay = DateTime(y, m + 1, 0).day;
           return DateTime(y, m, d > lastDay ? lastDay : d);
        }

        // Cycle: From [Month-1, BillingDay] to [Month, BillingDay - 1]
        // Handle Start Date: Month-1, BillingDay (Clamped)
        final cycleStart = getValidDate(now.year, now.month - 1, card.billingDay);
        
        // Handle End Date: Month, BillingDay - 1 (Clamped)
        // Note: If BillingDay is 1, BillingDay-1 is 0. DateTime handles 0 as last day of prev month correctly.
        // But better to be explicit:
        DateTime cycleEnd;
        if (card.billingDay == 1) {
           // If billing is 1st, cycle ends on last day of previous month
           final lastDayPrevMonth = DateTime(now.year, now.month, 0);
           cycleEnd = DateTime(lastDayPrevMonth.year, lastDayPrevMonth.month, lastDayPrevMonth.day, 23, 59, 59);
        } else {
           cycleEnd = getValidDate(now.year, now.month, card.billingDay - 1);
           cycleEnd = cycleEnd.add(const Duration(hours: 23, minutes: 59, seconds: 59));
        }
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
                        date: getValidDate(now.year, now.month + 1, card.billingDay), // Due date approx next month
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
    final theme = Theme.of(context);
    final user = ref.watch(userProvider);

    ref.listen(selectedDateProvider, (previous, next) {
      _checkFixedExpenses(next);
    });

    ref.listen(fixedExpensesProvider, (previous, next) {
      _checkFixedExpenses(date);
    });

    final expensesAsync = ref.watch(expensesProvider);
    final incomeAsync = ref.watch(salaryProvider);
    
    final totalExpense = expensesAsync.value?.fold(0.0, (sum, e) {
      if (e.paymentMethod == 'Credit Card' && !e.isCreditCardBill) return sum!;
      return sum! + e.amount;
    }) ?? 0.0;
    final totalIncome = incomeAsync.value?.fold(0.0, (sum, e) => sum! + e.amount) ?? 0.0;
    final balance = totalIncome - totalExpense;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetService().updateWidget(balance);
    });
    
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          // Background Gradient Header
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.tertiary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildCustomHeader(context, user, date),
                const SizedBox(height: 16), // Spacing between header and card
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      boxShadow: [
                         BoxShadow(
                           color: Colors.black.withOpacity(0.05),
                           blurRadius: 10,
                           offset: const Offset(0, -5),
                         ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.refresh(expensesProvider);
                        },
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 32, 20, 100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(context, "Quick Actions", null),
                              const SizedBox(height: 16),
                              _buildQuickActions(context),
                              const SizedBox(height: 32),
                              
                              const UnifiedCreditCard(),
                              const SizedBox(height: 24),
                              const IncomeExpenseGauge(),
                              const SizedBox(height: 32),
                              
                              _buildSectionHeader(context, 'Spending Trends', () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => const AnalysisScreen()));
                              }),
                              const SizedBox(height: 16),
                              const WeeklySpendingChart(),
                              const SizedBox(height: 24),
                              const ExpenseChart(), // Interactive Breakdown
                              const SizedBox(height: 32),
                              
                              _buildSectionHeader(context, 'Recent Activity', () {
                                Navigator.push(context, MaterialPageRoute(builder: (c) => const ExpenseListScreen()));
                              }),
                              const SizedBox(height: 16),
                              const RecentExpenses(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context, user, ref), // Extracted drawer for cleaner code
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'voice_fab',
            onPressed: () => _showVoiceInput(context, ref),
            backgroundColor: theme.colorScheme.tertiary,
            child: const Icon(Icons.mic, color: Colors.white),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'add_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, dynamic user, DateTime date) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                  Text(
                    user.name.split(' ').first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                   _scaffoldKey.currentState?.openDrawer();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: user.profilePicPath != null 
                      ? (user.profilePicPath!.startsWith('http') 
                          ? NetworkImage(user.profilePicPath!) 
                          : FileImage(File(user.profilePicPath!)) as ImageProvider)
                      : null,
                    child: user.profilePicPath == null ? const Icon(Icons.person) : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Month Selector
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = DateTime(picked.year, picked.month);
                ref.refresh(expensesProvider);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMMM yyyy').format(date),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context, dynamic user, WidgetRef ref) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name),
            accountEmail: Text(user.email),
            currentAccountPicture: CircleAvatar(
               backgroundImage: user.profilePicPath != null 
                 ? (user.profilePicPath!.startsWith('http') 
                     ? NetworkImage(user.profilePicPath!) 
                     : FileImage(File(user.profilePicPath!)) as ImageProvider)
                 : null,
               child: user.profilePicPath == null ? const Icon(Icons.person) : null,
            ),
             decoration: BoxDecoration(
               gradient: LinearGradient(
                 colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
               ),
             ),
          ),
          
             ListTile(
              leading: const Icon(Icons.pie_chart),
              title: const Text('Spending Analysis'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,MaterialPageRoute(builder: (context) => const AnalysisScreen()));
              },
            ),
             ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Calendar View'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,MaterialPageRoute(builder: (context) => const DailyExpensesCalendarScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.savings),
              title: const Text('Savings & Goals'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,MaterialPageRoute(builder: (context) => const SavingsListScreen()));
              },
            ),

            const Divider(),
            
            ExpansionTile(
              leading: const Icon(Icons.tune),
              title: const Text('Manage'),
              children: [
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Categories & Budgets'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesAndBudgetsScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('Credit Cards'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCreditCardsScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.push_pin),
                  title: const Text('Fixed Expenses'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageFixedExpensesScreen()));
                  },
                ),
                 ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Recurring Income'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageRecurringIncomeScreen()));
                  },
                ),
              ],
            ),

            ExpansionTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Reports'),
              children: [
                ListTile(
                  title: const Text('Yearly Overview'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const YearlyReportScreen()));
                  },
                ),
                ListTile(
                  title: const Text('Monthly Comparison'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MonthlyCompareScreen()));
                  },
                ),
              ],
            ),
            
            const Divider(),

            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export Data'),
              onTap: () {
                Navigator.pop(context);
                 _showExportDialog();
              },
            ),
             ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback? onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color
          )
        ),
        if (onAction != null)
          TextButton(
            onPressed: onAction,
            child: const Row(
              children: [
                 Text('View All', style: TextStyle(fontWeight: FontWeight.bold)),
                 SizedBox(width: 4),
                 Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          )
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildActionButton(context, Icons.account_balance_wallet, 'Salary', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const IncomeListScreen()));
          }),
          _buildActionButton(context, Icons.savings, 'Budget', () {
             _showSetBudgetDialog(context, ref, DateTime.now());
          }),
          _buildActionButton(context, Icons.list_alt, 'Transactions', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const ExpenseListScreen()));
          }),
          _buildActionButton(context, Icons.email, 'Inbox', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const SmsTransactionsScreen()));
          }),
          _buildActionButton(context, Icons.calendar_month, 'Calendar', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const DailyExpensesCalendarScreen()));
          }),
          _buildActionButton(context, Icons.pie_chart, 'Analysis', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalysisScreen()));
          }),
          _buildActionButton(context, Icons.group, 'Split', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const GroupListScreen()));
          }),
           _buildActionButton(context, Icons.money_off, 'Loans', () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const DebtListScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }


  Widget _buildInsightCard(BuildContext context, IconData icon, Color color, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: color, fontSize: 12)),
              ],
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

  void _showVoiceInput(BuildContext context, WidgetRef ref) async {
    final voiceService = ref.read(voiceExpenseServiceProvider);
    
    // Initialize & Check Permissions
    bool available = await voiceService.initialize();
    if (!available) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied or not available.')),
        );
      }
      return;
    }

    String spokenText = "Listening...";
    
    // Show Listening Dialog
    await showDialog(
      context: context,
      barrierDismissible: true, // Allow tapping out to cancel
      builder: (dialogContext) {
        // Start listening immediately
        voiceService.listen(
          onResult: (text) {
             spokenText = text;
          },
        );

        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic, size: 48, color: Colors.indigoAccent),
              const SizedBox(height: 16),
              const Text('Speak your expense...', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              const Text('e.g., "Tea 20 rupees"', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await voiceService.stop();
                  Navigator.pop(dialogContext); // Close listening dialog
                  if (spokenText != "Listening..." && spokenText.isNotEmpty) {
                    _processVoiceResult(context, ref, spokenText);
                  }
                },
                child: const Text('Done'),
              )
            ],
          ),
        );
      },
    );
  }

  void _processVoiceResult(BuildContext context, WidgetRef ref, String text) {
    print('Processing Voice Text: $text'); // Debug
    final voiceService = ref.read(voiceExpenseServiceProvider);
    final parsed = voiceService.parseExpense(text);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          initialAmount: parsed.amount > 0 ? parsed.amount : null,
          initialTitle: parsed.title,
          initialCategory: parsed.category != 'Miscellaneous' ? parsed.category : null,
        ),
      ),
    );
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
