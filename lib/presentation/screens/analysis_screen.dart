import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/salary_provider.dart';
import '../providers/category_provider.dart';
import '../../data/models/category_model.dart';
import '../providers/date_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/expense_model.dart';
import 'next_month_estimation_screen.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Redesign: "Spending Controller"
    // Focus: Proactive Daily Control
    
    final expensesAsync = ref.watch(expensesProvider);
    final incomeAsync = ref.watch(salaryProvider);
    final categoriesAsync = ref.watch(categoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, 
      appBar: AppBar(
        title: Text(
          'Spending Controller', 
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)
        ),
        elevation: 0,
        centerTitle: false,
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.next_plan_outlined),
            tooltip: 'Next Month Plan',
            onPressed: () {
               // Navigation to Estimation Screen
               Navigator.push(context, MaterialPageRoute(builder: (c) => const NextMonthEstimationScreen()));
            },
          ),
        ],
      ),
      body: expensesAsync.when(
        data: (expenses) => incomeAsync.when(
          data: (incomes) => categoriesAsync.when(
            data: (categories) => _buildAdvisorBody(
              context, 
              expenses, 
              incomes, 
              categories, 
              ref.watch(selectedDateProvider),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildAdvisorBody(
    BuildContext context, 
    List<dynamic> expenses, 
    List<dynamic> incomes, 
    List<CategoryModel> categories,
    DateTime date,
  ) {
    // 1. Data Aggregation
    final totalIncome = incomes.fold<double>(0, (sum, item) => sum + item.amount);
    final categoryTypeMap = {for (var c in categories) c.name: c.type};

    double totalNeeds = 0;
    double totalWants = 0;
    double totalSavings = 0; // Savings expenses + unspent income
    double totalExpenseAmount = 0;

    Map<String, double> categorySpending = {};

    for (var expense in expenses) {
      if (expense.isCreditCardBill) continue; 
      
      final type = categoryTypeMap[expense.category] ?? 'Want';
      final amount = expense.amount as double;
      totalExpenseAmount += amount;
      
      categorySpending[expense.category] = (categorySpending[expense.category] ?? 0) + amount;

      if (type == 'Need') totalNeeds += amount;
      else if (type == 'Savings') totalSavings += amount;
      else totalWants += amount;
    }

    // 2. Logic Check: Effective Wealth Change
    final netCashFlow = totalIncome - totalExpenseAmount;
    
    // Effective Savings = Explicit Savings + (Surplus OR -Deficit)
    // This represents the true 'Net Change in Wealth' for the month.
    final effectiveSavings = totalSavings + netCashFlow;

    final savingsRate = totalIncome > 0 ? (effectiveSavings / totalIncome * 100) : 0.0;
    final wantsRate = totalIncome > 0 ? (totalWants / totalIncome * 100) : 0.0;
    final needsRate = totalIncome > 0 ? (totalNeeds / totalIncome * 100) : 0.0;

    // 3. Grading Logic
    String grade = "F";
    Color gradeColor = Colors.red;
    String feedback = "Critical Warning: You are spending more than you earn.";

    if (netCashFlow < 0) {
      // OVERSPENDING SCENARIO
      if (effectiveSavings > 0) {
        // Technically wealth increased (saved 20k, deficit 5k = +15k), BUT habit is bad.
        // Penalty: Max Grade C.
        grade = "C";
        gradeColor = Colors.orange;
        feedback = "Warning: You are saving, but living beyond your income (using debt/reserves).";
      } else {
        // Wealth decreased.
        grade = "F";
        gradeColor = Colors.red;
        feedback = "Critical: You are overspending and eroding your financial health.";
      }
    } else {
      // POSITIVE CASH FLOW SCENARIO
      if (savingsRate >= 20 && wantsRate <= 35) {
        grade = "A+";
        gradeColor = const Color(0xFF10B981); // Green
        feedback = "Excellent! You are a master saver. Your wealth is growing fast.";
      } else if (savingsRate >= 15) {
        grade = "B";
        gradeColor = Colors.blue;
        feedback = "Good job. You are saving well, but watch your 'Wants' spending.";
      } else if (savingsRate > 5) { // Lowered bar slightly for C
        grade = "C";
        gradeColor = Colors.orange;
        feedback = "You are saving a little. Try to increase your savings rate.";
      } else {
        // Break even or very low savings
        grade = "D";
        gradeColor = Colors.amber;
        feedback = "You are living paycheck to paycheck. Prioritize saving.";
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Report Card Hero
          _buildReportCard(context, grade, gradeColor, feedback, savingsRate),
          const SizedBox(height: 24),

          // 2. The Benchmarker (Needs / Wants / Savings vs 50/30/20)
          Text("Reality Check", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildBenchmarkBar(context, "Needs (Rent, Bills)", needsRate, 50, Colors.blueGrey),
          const SizedBox(height: 12),
          _buildBenchmarkBar(context, "Wants (Fun, Food)", wantsRate, 30, Colors.orange),
          const SizedBox(height: 12),
          _buildBenchmarkBar(context, "Savings (Future)", savingsRate, 20, Colors.green, isMin: true),
          
          const SizedBox(height: 32),

          // 3. Wealth Projector
          if (savingsRate > 5)
            _buildWealthProjector(context, effectiveSavings),
          
           if (savingsRate <= 5)
             _buildWakeUpCall(context, totalWants),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String grade, Color color, String feedback, double savingsRate) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))
        ]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Financial Grade", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(grade, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: color)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.verified_user_outlined, color: color, size: 32),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(feedback, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, height: 1.4, fontSize: 16)),
          const SizedBox(height: 16),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Savings Rate", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              Text("${savingsRate.toStringAsFixed(1)}%", style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBenchmarkBar(BuildContext context, String title, double current, double target, Color color, {bool isMin = false}) {
    // isMin = true means "At least X", false means "At most X"
    final theme = Theme.of(context);
    bool isWarning = isMin ? (current < target) : (current > target);
    Color barColor = isWarning ? Colors.red : color;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              "${current.toStringAsFixed(1)}% / ${target.toStringAsFixed(0)}%", 
              style: TextStyle(
                color: isWarning ? Colors.red : theme.colorScheme.onSurface,
                fontWeight: isWarning ? FontWeight.bold : FontWeight.normal
              )
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(height: 10, decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(5))),
            FractionallySizedBox(
              widthFactor: (current / 100).clamp(0.0, 1.0),
              child: Container(height: 10, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(5))),
            ),
            // Target Marker
            Positioned(
              left: (MediaQuery.of(context).size.width - 40) * (target / 100),
              child: Container(
                width: 2, height: 10, color: Colors.black,
              ),
            )
          ],
        ),
        if (isWarning)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              isMin ? "Goal not met. Boost this!" : "Limit exceeded. Cut back.",
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          )
      ],
    );
  }

  Widget _buildWealthProjector(BuildContext context, double monthlySavings) {
    if (monthlySavings <= 0) return const SizedBox.shrink();
    
    // Future Value Formula: PMT * (((1 + r)^n - 1) / r)
    // r = monthly interest rate (assume 8% annual => 0.0066)
    // n = months
    
    final r = 0.08 / 12;
    // 1 Year
    final fv1 = monthlySavings * ((getPow(1+r, 12) - 1) / r);
    // 10 Years
    final fv10 = monthlySavings * ((getPow(1+r, 120) - 1) / r);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF111827)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_graph_rounded, color: Colors.amber),
              const SizedBox(width: 8),
              const Text("Wealth Projector", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "If you keep saving like this...",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _wealthRow("In 1 Year", fv1),
          const SizedBox(height: 12),
          _wealthRow("In 10 Years", fv10, isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildWakeUpCall(BuildContext context, double wants) {
     // Calculate opportunity cost of 20% of wants
     final potentialSave = wants * 0.20;
     final r = 0.08 / 12;
     final fv10 = potentialSave * ((getPow(1+r, 120) - 1) / r);

     return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text("Opportunity Cost Alert", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "You spent ₹${wants.toStringAsFixed(0)} on Wants. If you saved just 20% of that (₹${potentialSave.toStringAsFixed(0)}), you could have:",
             style: const TextStyle(color: Colors.black87)
          ),
          const SizedBox(height: 12),
          Text(
            "₹${fv10.toStringAsFixed(0)} in 10 years.",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black)
          ),
          const Text("(Assuming 8% investment return)", style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _wealthRow(String label, double amount, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          "₹${amount.toStringAsFixed(0)}", 
          style: TextStyle(
            color: isHighlight ? Colors.amber : Colors.white, 
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            fontSize: isHighlight ? 18 : 14
          )
        ),
      ],
    );
  }

  double getPow(double x, int n) {
      double result = 1;
      for (int i = 0; i < n; i++) {
          result *= x; 
      }
      return result;
  }
}
