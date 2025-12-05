import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';
import '../widgets/expense_list_item.dart';
import '../../core/utils/csv_exporter.dart';
import '../../data/services/pdf_service.dart';

class DailyExpensesCalendarScreen extends ConsumerStatefulWidget {
  const DailyExpensesCalendarScreen({super.key});

  @override
  ConsumerState<DailyExpensesCalendarScreen> createState() => _DailyExpensesCalendarScreenState();
}

 class _DailyExpensesCalendarScreenState extends ConsumerState<DailyExpensesCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  /// Groups expenses by their date (stripped of time time)
  Map<DateTime, List<ExpenseModel>> _groupExpensesByDate(List<ExpenseModel> expenses) {
    final Map<DateTime, List<ExpenseModel>> data = {};
    for (var expense in expenses) {
      final date = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (data[date] == null) {
        data[date] = [];
      }
      data[date]!.add(expense);
    }
    return data;
  }

  void _showExportOptions(BuildContext context, List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expenses to export for this day.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export as PDF'),
                onTap: () async {
                  Navigator.pop(context);
                  await PdfService().generateExpenseReport(expenses);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PDF Report generated.')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Export as CSV'),
                onTap: () async {
                  Navigator.pop(context);
                  await CsvExporter.exportExpenses(expenses);
                  // CsvExporter handles sharing internally
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Spending Calendar'),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          final groupedExpenses = _groupExpensesByDate(expenses);
          
          // Get expenses for the selected day
          final selectedDateKey = _selectedDay != null 
              ? DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)
              : DateTime(_focusedDay.year, _focusedDay.month, _focusedDay.day);
          
          final selectedDayExpenses = groupedExpenses[selectedDateKey] ?? [];
          final totalAmount = selectedDayExpenses.fold(0.0, (sum, e) => sum + e.amount);

          return Column(
            children: [
              TableCalendar<ExpenseModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarFormat: CalendarFormat.month,
                
                // Use eventLoader to show markers
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return groupedExpenses[key] ?? [];
                },

                calendarStyle: const CalendarStyle(
                  markersMaxCount: 1,
                  markerDecoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          DateFormat('MMM d, yyyy').format(selectedDateKey),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          icon: const Icon(Icons.ios_share, size: 20, color: Colors.blue),
                          onPressed: () => _showExportOptions(context, selectedDayExpenses),
                          tooltip: 'Export Report',
                        ),
                      ],
                    ),
                    Text(
                      'Total: ₹${totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: selectedDayExpenses.isEmpty
                    ? const Center(
                        child: Text('No expenses on this day'),
                      )
                    : ListView.builder(
                        itemCount: selectedDayExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = selectedDayExpenses[index];
                          return ExpenseListItem(expense: expense);
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
