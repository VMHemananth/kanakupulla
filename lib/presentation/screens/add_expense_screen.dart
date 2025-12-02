import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../providers/expense_provider.dart';
import '../providers/user_provider.dart';
import '../providers/category_provider.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  final DateTime? initialDate;

  const AddExpenseScreen({super.key, this.expense, this.initialDate});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late DateTime _selectedDate;
  String? _selectedCategory;
  String _paymentMethod = 'Salary';
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _amountController = TextEditingController(text: widget.expense?.amount.toString() ?? '');
    // If initialDate is provided, use it.
    // However, if initialDate is just the 1st of the current month (default behavior of dashboard),
    // we prefer showing today's date for better UX.
    if (widget.initialDate != null) {
      final now = DateTime.now();
      if (widget.initialDate!.year == now.year && 
          widget.initialDate!.month == now.month && 
          widget.initialDate!.day == 1) {
        _selectedDate = now;
      } else {
        _selectedDate = widget.initialDate!;
      }
    } else {
      _selectedDate = widget.expense?.date ?? DateTime.now();
    }
    
    _selectedCategory = widget.expense?.category;
    _paymentMethod = widget.expense?.paymentMethod ?? 'Salary';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (errorNotification) => print('onError: $errorNotification'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              setState(() {
                _isListening = false;
                _parseVoiceInput(result.recognizedWords);
              });
            }
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Speech recognition not available')),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _parseVoiceInput(String text) {
    // Simple heuristic: Extract numbers for amount, rest for title
    // Example: "Lunch 150" -> Title: Lunch, Amount: 150
    
    final words = text.split(' ');
    String? amountStr;
    final titleWords = <String>[];

    for (var word in words) {
      // Remove currency symbols if any
      final cleanWord = word.replaceAll(RegExp(r'[₹$]'), '');
      if (double.tryParse(cleanWord) != null) {
        amountStr = cleanWord;
      } else {
        titleWords.add(word);
      }
    }

    if (amountStr != null) {
      _amountController.text = amountStr;
    }
    
    if (titleWords.isNotEmpty) {
      // Capitalize first letter
      String title = titleWords.join(' ');
      if (title.isNotEmpty) {
        title = title[0].toUpperCase() + title.substring(1);
      }
      _titleController.text = title;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Parsed: "$text"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);
    final categories = categoriesAsync.value?.map((e) => e.name).toList() ?? [];

    return Scaffold(
      appBar: AppBar(title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onLongPress: _listen, // Alternative interaction
                    child: IconButton(
                      onPressed: _listen,
                      icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      color: _isListening ? Colors.red : Colors.grey,
                      style: IconButton.styleFrom(
                        backgroundColor: _isListening ? Colors.red.withOpacity(0.1) : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value) == null ? 'Please enter a valid amount' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                  DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                  DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                ],
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(widget.expense == null ? 'Save Expense' : 'Update Expense'),
              ),
              if (widget.expense != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _deleteExpense,
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete Expense', style: TextStyle(color: Colors.red)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final expense = ExpenseModel(
        id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory!,
        paymentMethod: _paymentMethod,
      );

      if (widget.expense == null) {
        ref.read(expensesProvider.notifier).addExpense(expense);
      } else {
        ref.read(expensesProvider.notifier).updateExpense(expense);
      }
      Navigator.pop(context);
    }
  }

  void _deleteExpense() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(expensesProvider.notifier).deleteExpense(widget.expense!.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
