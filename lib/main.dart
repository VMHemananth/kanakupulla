
import 'package:flutter/material.dart';
// ...existing code...
import 'package:telephony/telephony.dart';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'web_csv_download_stub.dart'
    if (dart.library.html) 'web_csv_download.dart';
import 'category_helper.dart';
import 'db_helper.dart';
import 'expense_list_screen.dart';
import 'monthly_compare_screen.dart';
import 'models.dart';
// ...existing code...

// Load user details from shared_preferences
// This method should be inside _MyHomePageState, not at the top level.
// ...existing code...

// ...existing code...


// ...existing code...

// Main entry point and KanakupullaApp
void main() {
  runApp(const KanakupullaApp());
}

class KanakupullaApp extends StatelessWidget {
  const KanakupullaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kanakupulla',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(title: 'Kanakupulla'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Fallback custom year picker dialog for web/Edge
  Future<DateTime?> _showCustomYearPicker(BuildContext context, int currentYear) async {
    int tempYear = currentYear;
    return await showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Year'),
          content: StatefulBuilder(
            builder: (ctx2, setStateDialog) => DropdownButton<int>(
              value: tempYear,
              items: List.generate(5, (i) {
                int y = DateTime.now().year - 2 + i;
                return DropdownMenuItem(value: y, child: Text(y.toString()));
              }),
              onChanged: (y) {
                if (y != null) {
                  setStateDialog(() { tempYear = y; });
                }
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () => Navigator.pop(ctx, DateTime(tempYear)),
            ),
          ],
        );
      },
    );
  }
  // Export expenses for selected month/year as CSV
  Future<void> _exportExpensesCsv() async {
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No expenses to export for this month.')));
      return;
    }
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Title,Amount,Category,Date');
    for (final e in expenses) {
      final dateStr = '${e.date.day.toString().padLeft(2, '0')}-${e.date.month.toString().padLeft(2, '0')}-${e.date.year}';
      final title = e.title.replaceAll(',', ' ');
      final category = e.category.replaceAll(',', ' ');
      csvBuffer.writeln('"$title",${e.amount},"$category","$dateStr"');
    }
    final csvString = csvBuffer.toString();
    try {
      if (kIsWeb) {
        downloadCsvWeb(csvString, 'expenses_${selectedYear}_${selectedMonth}.csv');
      } else {
        // Mobile/desktop: save to file and share
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/expenses_${selectedYear}_${selectedMonth}.csv');
        await file.writeAsString(csvString);
        await Share.shareXFiles([XFile(file.path)], text: 'Expenses for $selectedMonth/$selectedYear');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to export: $e')));
    }
  }
  bool isLoading = false;
  String? loadError;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  List<String> categories = [];
  List<Expense> expenses = [];
  double salaryAmount = 0;
  double budgetAmount = 0;
  String profileImagePath = '';
  String userName = '';
  String userEmail = '';

  // Load user details from shared_preferences
  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? '';
      userEmail = prefs.getString('userEmail') ?? '';
      profileImagePath = prefs.getString('profileImagePath') ?? '';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserDetails();
  }

  Future<void> _loadData() async {
    setState(() { isLoading = true; loadError = null; });
    try {
      categories = await CategoryHelper.getCategories();
      final allExpenses = await DBHelper.getExpenses();
      expenses = allExpenses.where((e) => e.date.month == selectedMonth && e.date.year == selectedYear).toList();
      // Load salary for selected month/year
      var salaries = await DBHelper.getSalaries();
      var salary = salaries.firstWhere(
        (s) => s.date.month == selectedMonth && s.date.year == selectedYear,
        orElse: () => Salary(id: '', amount: 0, date: DateTime(selectedYear, selectedMonth, 1)),
      );
      salaryAmount = salary.amount;
      // Load budget for selected month/year
      var budgets = await DBHelper.getBudgets();
      var budget = budgets.firstWhere(
        (b) => b.month == '${selectedYear}_${selectedMonth}',
        orElse: () => Budget(id: '', month: '', amount: 0),
      );
      budgetAmount = budget.amount;
      // Prompt user to enter salary if not set for this month
      if (salaryAmount == 0) {
        // Delay to ensure UI is ready before showing dialog
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) _showAddSalaryDialog();
        });
      }
    } catch (e, st) {
      loadError = 'Failed to load data: $e';
      print('LoadData error: $e\n$st');
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 64,
                    child: profileImagePath.isNotEmpty
                        ? CircleAvatar(
                            radius: 32,
                            backgroundImage: FileImage(File(profileImagePath)),
                          )
                        : const CircleAvatar(
                            radius: 32,
                            child: Icon(Icons.person, size: 32),
                          ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Kanakupulla', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('User Profile'),
              onTap: _showUserProfileDialog,
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Add Salary'),
              onTap: _showAddSalaryDialog,
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Manage Categories'),
              onTap: _showManageCategoriesDialog,
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text('Set Monthly Budget'),
              onTap: _showSetBudgetDialog,
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Monthly Compare'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => MonthlyCompareScreen(
                      initialMonth: selectedMonth,
                      initialYear: selectedYear,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : loadError != null
              ? Center(child: Text(loadError!, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Modernized top bar with month/year selector and View All Expenses
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Editable month/year chips
                            Row(
                              children: [
                                ActionChip(
                                  label: Text(monthNames[selectedMonth - 1], style: const TextStyle(fontWeight: FontWeight.bold)),
                                  avatar: const Icon(Icons.calendar_today, size: 18, color: Colors.blueGrey),
                                  backgroundColor: Colors.blue[50],
                                  onPressed: () async {
                                    final picked = await showMonthPicker(context, selectedYear, selectedMonth);
                                    if (picked != null) {
                                      setState(() {
                                        selectedYear = picked.year;
                                        selectedMonth = picked.month;
                                      });
                                      await _loadData();
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                ActionChip(
                                  label: Text(selectedYear.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                                  avatar: const Icon(Icons.edit_calendar, size: 18, color: Colors.blueGrey),
                                  backgroundColor: Colors.blue[50],
                                  onPressed: () async {
                                    DateTime? picked;
                                    try {
                                      // Try to use showYearPicker if available (mobile/desktop)
                                      if (Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS) {
                                        picked = await showDialog<DateTime>(
                                          context: context,
                                          builder: (ctx) => YearPickerDialog(
                                            initialYear: selectedYear,
                                          ),
                                        );
                                      } else {
                                        picked = await _showCustomYearPicker(context, selectedYear);
                                      }
                                    } catch (e) {
                                      // Fallback for web/Edge: custom year picker dialog
                                      picked = await _showCustomYearPicker(context, selectedYear);
                                    }
                                    if (picked?.year != null) {
                                      setState(() { selectedYear = picked!.year; });
                                      await _loadData();
                                    }
                                  },
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.download, color: Colors.green, size: 28),
                              tooltip: 'Download CSV',
                              onPressed: _exportExpensesCsv,
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.list),
                              label: const Text('View All Expenses'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(48, 40),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.blueAccent,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) => ExpenseListScreen(
                                      expenses: expenses,
                                      user: User(
                                        categories: categories,
                                        workingDaysPerMonth: 22,
                                        workingHoursPerDay: 8,
                                        profilePicPath: profileImagePath,
                                      ),
                                      currentMonthSalary: salaryAmount,
                                      onEdit: (id) async {
                                        // ...existing code...
                                      },
                                      onDelete: (id) async {
                                        // ...existing code...
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSalaryBalanceCard(),
                        const SizedBox(height: 16),
                        _buildBudgetProgressBar(),
                        const SizedBox(height: 16),
                        _buildExpensePieChart(),
                        const SizedBox(height: 16),
                        const Text('Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        // ...existing code...
                      ],
                    ),
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
        tooltip: 'Add Expense',
      ),
    );
  }

  // Helper widget methods
  // Remove _buildMonthYearSelector, now handled by chips in the top bar

  // Helper to show month picker dialog
  Future<DateTime?> showMonthPicker(BuildContext context, int year, int month) async {
    int tempMonth = month;
    int tempYear = year;
    return await showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Select Month'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<int>(
                value: tempMonth,
                items: List.generate(12, (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(monthNames[i]),
                )),
                onChanged: (m) {
                  if (m != null) {
                    tempMonth = m;
                    (ctx as Element).markNeedsBuild();
                  }
                },
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: tempYear,
                items: List.generate(5, (i) {
                  int y = DateTime.now().year - 2 + i;
                  return DropdownMenuItem(value: y, child: Text(y.toString()));
                }),
                onChanged: (y) {
                  if (y != null) {
                    tempYear = y;
                    (ctx as Element).markNeedsBuild();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Select'),
              onPressed: () => Navigator.pop(ctx, DateTime(tempYear, tempMonth)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetProgressBar() {
    double totalExpense = expenses.fold(0, (sum, e) => sum + e.amount);
    double progress = budgetAmount > 0 ? (totalExpense / budgetAmount).clamp(0, 1) : 0;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.grey[300], color: Colors.blueAccent),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  tooltip: 'Edit Budget',
                  onPressed: _showEditBudgetDialog,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Budget: ₹${budgetAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Spent: ₹${totalExpense.toStringAsFixed(2)}', style: TextStyle(color: progress > 0.8 ? Colors.red : Colors.black)),
            if (budgetAmount > 0 && totalExpense > budgetAmount)
              const Text('Warning: Over budget!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensePieChart() {
    if (expenses.isEmpty || categories.isEmpty) {
      return SizedBox(height: 220, child: Center(child: Text('No expense data for chart', style: TextStyle(fontSize: 16))));
    }
    final sections = <PieChartSectionData>[];
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    for (int i = 0; i < categories.length; i++) {
      final cat = categories[i];
      final catTotal = expenses.where((e) => e.category == cat).fold(0.0, (sum, e) => sum + e.amount);
      if (catTotal > 0) {
        sections.add(PieChartSectionData(
          value: catTotal,
          title: cat,
          color: Colors.primaries[i % Colors.primaries.length],
          radius: 60,
          titleStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
        ));
      }
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Expense Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 180, child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 32,
                borderData: FlBorderData(show: false),
              ),
            )),
            SizedBox(height: 8),
            ...sections.map((s) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 14, height: 14, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                    SizedBox(width: 6),
                    Text(s.title ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Text('₹${s.value.toStringAsFixed(2)}'),
                Text('${total > 0 ? ((s.value / total) * 100).toStringAsFixed(1) : '0'}%'),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryBalanceCard() {
    double totalExpense = expenses.fold(0, (sum, e) => sum + e.amount);
    double balance = salaryAmount - totalExpense;
    double progress = salaryAmount > 0 ? (totalExpense / salaryAmount).clamp(0, 1) : 0;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Salary & Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Salary:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${salaryAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.green)),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blueAccent),
                  tooltip: 'Edit Salary',
                  onPressed: _showEditSalaryDialog,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${totalExpense.toStringAsFixed(2)}', style: TextStyle(color: Colors.red)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Balance:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹${balance.toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? Colors.blue : Colors.red)),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              color: progress < 0.8 ? Colors.blueAccent : Colors.redAccent,
            ),
            SizedBox(height: 4),
            Text('Spent ${(progress * 100).toStringAsFixed(1)}% of salary', style: TextStyle(color: progress < 0.8 ? Colors.black : Colors.red)),
          ],
        ),
      ),
    );
  }

  // Dialog methods (stubs)
  // User Profile Dialog
  void _showUserProfileDialog() async {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);
    String imagePath = profileImagePath;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('User Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (picker != null) {
                      setState(() { imagePath = picker.path; });
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: imagePath.isNotEmpty ? FileImage(File(imagePath)) : null,
                    child: imagePath.isEmpty ? const Icon(Icons.person, size: 40) : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('userName', nameController.text.trim());
                await prefs.setString('userEmail', emailController.text.trim());
                await prefs.setString('profileImagePath', imagePath);
                setState(() {
                  userName = nameController.text.trim();
                  userEmail = emailController.text.trim();
                  profileImagePath = imagePath;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showAddSalaryDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Salary'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Salary Amount'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value == null || value <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid salary amount')));
                return;
              }
              final salary = Salary(
                id: '${selectedYear}_${selectedMonth}',
                amount: value,
                date: DateTime(selectedYear, selectedMonth, 1),
              );
              await DBHelper.insertSalary(salary);
              Navigator.pop(ctx);
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salary added')));
            },
          ),
        ],
      ),
    );
  }
  void _showSetBudgetDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Budget Amount'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value == null || value <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid budget amount')));
                return;
              }
              final budget = Budget(
                id: '${selectedYear}_${selectedMonth}',
                month: '${selectedYear}_${selectedMonth}',
                amount: value,
              );
              await DBHelper.insertBudget(budget);
              Navigator.pop(ctx);
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget set')));
            },
          ),
        ],
      ),
    );
  }
  void _showManageCategoriesDialog() async {
    List<String> cats = List.from(categories);
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Manage Categories'),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Add Category'),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cats.length,
                    itemBuilder: (context, i) {
                      final cat = cats[i];
                      return ListTile(
                        title: Text(cat),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final editController = TextEditingController(text: cat);
                                final result = await showDialog<String>(
                                  context: context,
                                  builder: (ctx2) => AlertDialog(
                                    title: const Text('Edit Category'),
                                    content: TextField(
                                      controller: editController,
                                      decoration: const InputDecoration(labelText: 'Category Name'),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () => Navigator.pop(ctx2),
                                      ),
                                      ElevatedButton(
                                        child: const Text('Save'),
                                        onPressed: () => Navigator.pop(ctx2, editController.text.trim()),
                                      ),
                                    ],
                                  ),
                                );
                                if (result != null && result.isNotEmpty && result != cat) {
                                  // Remove old, add new
                                  await CategoryHelper.deleteCategory(cat);
                                  await CategoryHelper.insertCategory(result);
                                  cats[i] = result;
                                  setStateDialog(() {});
                                  await _loadData();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category updated')));
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await CategoryHelper.deleteCategory(cat);
                                cats.removeAt(i);
                                setStateDialog(() {});
                                await _loadData();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category deleted')));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a category name')));
                  return;
                }
                if (cats.contains(name)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category already exists')));
                  return;
                }
                await CategoryHelper.insertCategory(name);
                cats.add(name);
                controller.clear();
                setStateDialog(() {});
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category added')));
              },
            ),
          ],
        ),
      ),
    );
  }
  void _showAddExpenseDialog() async {
    if (categories.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No Categories'),
          content: const Text('Please add a category before adding expenses.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      );
      return;
    }
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = categories.isNotEmpty ? categories[0] : '';
    DateTime selectedDate = DateTime(selectedYear, selectedMonth, DateTime.now().day);
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) {
                    if (val != null) setStateDialog(() { selectedCategory = val; });
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text('Select Date'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(selectedYear - 2),
                      lastDate: DateTime(selectedYear + 2),
                    );
                    if (picked != null) {
                      setStateDialog(() { selectedDate = picked; });
                    }
                  },
                ),
                SizedBox(height: 8),
                Text(
                  'Selected Date: '
                  '${selectedDate.day.toString().padLeft(2, '0')}-'
                  '${selectedDate.month.toString().padLeft(2, '0')}-'
                  '${selectedDate.year}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () async {
                final title = titleController.text.trim();
                final amount = double.tryParse(amountController.text);
                if (title.isEmpty || amount == null || amount <= 0 || selectedCategory.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid expense details')));
                  return;
                }
                final expense = Expense(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: title,
                  amount: amount,
                  date: selectedDate,
                  category: selectedCategory,
                );
                await DBHelper.insertExpense(expense);
                Navigator.pop(ctx);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expense added')));
              },
            ),
          ],
        ),
      ),
    );
  }

  // Edit Salary Dialog
  void _showEditSalaryDialog() {
    final controller = TextEditingController(text: salaryAmount > 0 ? salaryAmount.toStringAsFixed(2) : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Salary'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Salary Amount'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value == null || value <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid salary amount')));
                return;
              }
              final salary = Salary(
                id: '${selectedYear}_${selectedMonth}',
                amount: value,
                date: DateTime(selectedYear, selectedMonth, 1),
              );
              await DBHelper.insertSalary(salary);
              Navigator.pop(ctx);
              await _loadData();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salary updated')));
            },
          ),
        ],
      ),
    );
  }

  // Edit Budget Dialog
  void _showEditBudgetDialog() {
    final controller = TextEditingController(text: budgetAmount > 0 ? budgetAmount.toStringAsFixed(2) : '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Budget Amount'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value == null || value <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid budget amount')));
                return;
              }
              final budget = Budget(
                id: '${selectedYear}_${selectedMonth}',
                month: '${selectedYear}_${selectedMonth}',
                amount: value,
              );
              await DBHelper.insertBudget(budget);
              Navigator.pop(ctx);
              await _loadData();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budget updated')));
            },
          ),
        ],
      ),
    );
  }
}


// Place these at the top level, after all classes:

final List<String> monthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

class YearPickerDialog extends StatelessWidget {
  final int initialYear;
  const YearPickerDialog({Key? key, required this.initialYear}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int tempYear = initialYear;
    return AlertDialog(
      title: const Text('Select Year'),
      content: StatefulBuilder(
        builder: (ctx, setStateDialog) => DropdownButton<int>(
          value: tempYear,
          items: List.generate(5, (i) {
            int y = DateTime.now().year - 2 + i;
            return DropdownMenuItem(value: y, child: Text(y.toString()));
          }),
          onChanged: (y) {
            if (y != null) {
              setStateDialog(() { tempYear = y; });
            }
          },
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text('Select'),
          onPressed: () => Navigator.pop(context, DateTime(tempYear)),
        ),
      ],
    );
  }
}
