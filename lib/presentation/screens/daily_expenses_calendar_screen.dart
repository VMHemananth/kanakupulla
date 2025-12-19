import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../../data/models/expense_model.dart';
import '../widgets/expense_list_item.dart';
import '../../core/utils/csv_exporter.dart';
import '../../data/services/pdf_service.dart';
import 'add_expense_screen.dart';

class DailyExpensesCalendarScreen extends ConsumerStatefulWidget {
  const DailyExpensesCalendarScreen({super.key});

  @override
  ConsumerState<DailyExpensesCalendarScreen> createState() => _DailyExpensesCalendarScreenState();
}

class _DailyExpensesCalendarScreenState extends ConsumerState<DailyExpensesCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOn;

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

  double _calculateDailyTotal(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  Color _getHeatmapColor(double amount) {
    if (amount == 0) return Colors.transparent;
    if (amount < 500) return Colors.green.withOpacity(0.2);
    if (amount < 2000) return Colors.orange.withOpacity(0.3);
    return Colors.red.withOpacity(0.4);
  }
  
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Clear range when single day selected
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
  }
  
  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  void _showAddExpenseDialog(BuildContext context, DateTime date) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddExpenseScreen(initialDate: date),
        ),
      );
  }

  // ... _showExportOptions omitted for brevity, keeping same logic ...

  void _showExportOptions(BuildContext context, List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expenses to export for this selection.')),
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
        actions: [
          // Toggle between Range and Single selection if needed, 
          // but TableCalendar handles clicks intelligently usually.
          // Let's rely on standard interaction.
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final date = _selectedDay ?? DateTime.now();
          _showAddExpenseDialog(context, date);
        },
        child: const Icon(Icons.add),
      ),
      body: expensesAsync.when(
        data: (expenses) {
          final groupedExpenses = _groupExpensesByDate(expenses);
          
          List<ExpenseModel> selectedExpenses = [];
          if (_rangeSelectionMode == RangeSelectionMode.toggledOn && _rangeStart != null) {
             // Filter by range
             final end = _rangeEnd ?? _rangeStart!;
             selectedExpenses = expenses.where((e) {
               final d = DateTime(e.date.year, e.date.month, e.date.day);
               return !d.isBefore(_rangeStart!) && !d.isAfter(end);
             }).toList();
          } else if (_selectedDay != null) {
             // Single Day
             final key = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
             selectedExpenses = groupedExpenses[key] ?? [];
          }

          final totalAmount = selectedExpenses.fold(0.0, (sum, e) => sum + e.amount);

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TableCalendar<ExpenseModel>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    rangeSelectionMode: _rangeSelectionMode,
                    onRangeSelected: _onRangeSelected,
                    onDayLongPressed: (selectedDay, focusedDay) {
                       _showAddExpenseDialog(context, selectedDay);
                    },
  
                    calendarFormat: CalendarFormat.month,
                    
                    eventLoader: (day) {
                      final key = DateTime(day.year, day.month, day.day);
                      return groupedExpenses[key] ?? [];
                    },
  
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) => const SizedBox(),
                      defaultBuilder: (context, day, focusedDay) {
                         final key = DateTime(day.year, day.month, day.day);
                         final dayExpenses = groupedExpenses[key] ?? [];
                         final dailyTotal = _calculateDailyTotal(dayExpenses);
                         return _buildCalendarCell(day, dailyTotal, false);
                      },
                      todayBuilder: (context, day, focusedDay) {
                         final key = DateTime(day.year, day.month, day.day);
                         final dayExpenses = groupedExpenses[key] ?? [];
                         final dailyTotal = _calculateDailyTotal(dayExpenses);
                         return _buildCalendarCell(day, dailyTotal, false, isToday: true);
                      },
                      selectedBuilder: (context, day, focusedDay) {
                         final key = DateTime(day.year, day.month, day.day);
                         final dayExpenses = groupedExpenses[key] ?? [];
                         final dailyTotal = _calculateDailyTotal(dayExpenses);
                         return _buildCalendarCell(day, dailyTotal, true);
                      },
                      rangeStartBuilder: (context, day, focusedDay) {
                         final key = DateTime(day.year, day.month, day.day);
                         final dayExpenses = groupedExpenses[key] ?? [];
                         final dailyTotal = _calculateDailyTotal(dayExpenses);
                         return _buildRangeCell(day, dailyTotal, true, isSameDay(day, _rangeEnd));
                      },
                      rangeEndBuilder: (context, day, focusedDay) {
                         final key = DateTime(day.year, day.month, day.day);
                         final dayExpenses = groupedExpenses[key] ?? [];
                         final dailyTotal = _calculateDailyTotal(dayExpenses);
                         return _buildRangeCell(day, dailyTotal, false, true);
                      },
                      rangeHighlightBuilder: (context, day, isWithinRange) {
                        if (isWithinRange) {
                           return Container(color: Colors.blue.withOpacity(0.2));
                        }
                        return null;
                      }
                    ),
  
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _rangeSelectionMode == RangeSelectionMode.toggledOn 
                            ? 'Range Total' 
                            : (_selectedDay != null ? DateFormat('MMM d, yyyy').format(_selectedDay!) : 'Total'),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                         Text(
                          '₹${totalAmount.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.ios_share, size: 24, color: Colors.blue),
                      onPressed: () => _showExportOptions(context, selectedExpenses),
                      tooltip: 'Export Report',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: selectedExpenses.isEmpty
                    ? const Center(
                        child: Text('No expenses found for selection'),
                      )
                    : ListView.builder(
                        itemCount: selectedExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = selectedExpenses[index];
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

  Widget _buildCalendarCell(DateTime day, double dailyTotal, bool isSelected, {bool isToday = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasExpense = dailyTotal > 0;

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isSelected 
            ? colorScheme.primary 
            : (isToday ? colorScheme.primaryContainer.withOpacity(0.5) : Colors.transparent),
        borderRadius: BorderRadius.circular(50), 
        border: isToday && !isSelected ? Border.all(color: colorScheme.primary, width: 2) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(
              color: isSelected 
                  ? colorScheme.onPrimary 
                  : (isToday ? colorScheme.onPrimaryContainer : colorScheme.onSurface),
              fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
          if (hasExpense) ...[
            const SizedBox(height: 2),
            Text(
              '₹${dailyTotal >= 1000 ? '${(dailyTotal/1000).toStringAsFixed(1)}k' : dailyTotal.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? colorScheme.onPrimary : _getHeatmapColor(dailyTotal).withOpacity(1.0),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRangeCell(DateTime day, double dailyTotal, bool isStart, bool isEnd) {
     final colorScheme = Theme.of(context).colorScheme;
     final hasExpense = dailyTotal > 0;
     
     return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.horizontal(
          left: isStart ? const Radius.circular(16) : Radius.zero,
          right: isEnd ? const Radius.circular(16) : Radius.zero,
        ),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${day.day}',
            style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
          ),
          if (hasExpense) ...[
             const SizedBox(height: 2),
             Text(
              '₹${dailyTotal >= 1000 ? '${(dailyTotal/1000).toStringAsFixed(1)}k' : dailyTotal.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
