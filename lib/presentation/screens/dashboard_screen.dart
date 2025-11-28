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
import 'add_expense_screen.dart';
import 'expense_list_screen.dart';
import 'monthly_compare_screen.dart';
import 'income_list_screen.dart';
import 'transaction_review_screen.dart';
import 'analysis_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_fixed_expenses_screen.dart';
import 'manage_recurring_income_screen.dart';
import 'category_budget_screen.dart';
import '../providers/salary_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/sms_provider.dart';
import '../../core/utils/csv_exporter.dart';
import '../providers/fixed_expense_provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/expense_model.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanakupulla'),
        actions: [
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
                    ? NetworkImage(user.profilePicPath!) // TODO: Handle local file
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
              leading: const Icon(Icons.category),
              title: const Text('Manage Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Category Budgets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CategoryBudgetScreen()),
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
              leading: const Icon(Icons.download),
              title: const Text('Export CSV'),
              onTap: () async {
                Navigator.pop(context);
                final expenses = ref.read(expensesProvider).value ?? [];
                await CsvExporter.exportExpenses(expenses);
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
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
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
              const SizedBox(height: 16),
              // Prompts
              Consumer(builder: (context, ref, _) {
                final incomeAsync = ref.watch(salaryProvider);
                final budgetAsync = ref.watch(budgetProvider);
                
                final hasIncome = incomeAsync.value?.isNotEmpty ?? false;
                final hasBudget = budgetAsync.value != null;

                if (hasIncome && hasBudget) return const SizedBox.shrink();

                return Column(
                  children: [
                    if (!hasIncome)
                      Card(
                        color: Colors.orange[50],
                        child: ListTile(
                          leading: const Icon(Icons.warning, color: Colors.orange),
                          title: const Text('No Income Added'),
                          subtitle: const Text('Add your salary or other income to track balance.'),
                          trailing: TextButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (c) => const IncomeListScreen()));
                            },
                            child: const Text('ADD'),
                          ),
                        ),
                      ),
                    if (!hasBudget)
                      Card(
                        color: Colors.blue[50],
                        child: ListTile(
                          leading: const Icon(Icons.info, color: Colors.blue),
                          title: const Text('No Budget Set'),
                          subtitle: const Text('Set a monthly budget to track your spending.'),
                          trailing: TextButton(
                            onPressed: () {
                              _showSetBudgetDialog(context, ref, date);
                            },
                            child: const Text('SET'),
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
                            color: Colors.purple[50],
                            child: ListTile(
                              leading: const Icon(Icons.sms, color: Colors.purple),
                              title: const Text('New Transactions Found'),
                              subtitle: Text('${txns.length} potential expenses from SMS.'),
                              trailing: TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (c) => const TransactionReviewScreen()));
                                },
                                child: const Text('REVIEW'),
                              ),
                            ),
                          );
                        },
                        loading: () => const SizedBox.shrink(), // Don't show loading on dashboard
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              }),
              const SalaryCard(),
              const SizedBox(height: 16),
              const BudgetCard(),
              const SizedBox(height: 16),
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
