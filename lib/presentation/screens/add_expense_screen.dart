import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/savings_goal_model.dart';
import '../providers/expense_provider.dart';
import '../providers/user_provider.dart';
import '../providers/category_provider.dart';
import '../providers/credit_card_provider.dart';
import '../providers/savings_provider.dart';
import '../../data/services/ocr_service.dart';
import 'package:image_picker/image_picker.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../core/utils/voice_parser.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel? expense; // Keep for editing existing expenses
  final DateTime? initialDate;
  final double? initialAmount;
  final String? initialTitle;
  final String? initialSavingsGoalId;

  const AddExpenseScreen({
    super.key, 
    this.expense, 
    this.initialDate, 
    this.initialAmount, 
    this.initialTitle,
    this.initialSavingsGoalId,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  String? _paymentMethod = 'Cash'; // Default
  String? _selectedCreditCardId;
  String? _selectedSavingsGoalId;
  
  late stt.SpeechToText _speech;
  bool _isListening = false;
  File? _receiptImage;
  bool _isProcessingImage = false;
  final OCRService _ocrService = OCRService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expense?.title ?? widget.initialTitle ?? '');
    _amountController = TextEditingController(text: widget.expense?.amount.toString() ?? widget.initialAmount?.toStringAsFixed(0) ?? '');
    _speech = stt.SpeechToText();
    
    if (widget.expense != null) {
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
      _paymentMethod = widget.expense!.paymentMethod ?? 'Cash';
      _selectedCreditCardId = widget.expense!.creditCardId;
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
      if (widget.initialSavingsGoalId != null) {
        _selectedCategory = 'Savings';
        _selectedSavingsGoalId = widget.initialSavingsGoalId;
      }
    }
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
        onStatus: (status) {},
        onError: (errorNotification) {},
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
    if (text.isEmpty) return;

    final categoriesAsync = ref.read(categoryProvider);
    final categories = categoriesAsync.value?.map((e) => e.name).toList() ?? [];

    final cardsAsync = ref.read(creditCardProvider);
    final cards = cardsAsync.value ?? [];

    final result = VoiceParser.parse(text, categories, cards);

    setState(() {
      if (result.amount != null) {
        _amountController.text = result.amount.toString();
      }
      if (result.title != null && result.title!.isNotEmpty) {
        _titleController.text = result.title!;
      }
      if (result.category != null) {
        _selectedCategory = result.category;
      }
      if (result.paymentMethod != null) {
        _paymentMethod = result.paymentMethod!;
        // Reset card if method changed to something else
        if (_paymentMethod != 'Credit Card') {
          _selectedCreditCardId = null;
        }
      }
      if (result.creditCardId != null) {
        _selectedCreditCardId = result.creditCardId;
        _paymentMethod = 'Credit Card'; // Ensure method matches found card
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parsed: Title="${result.title}", Cat="${result.category}", Amt="${result.amount}"'),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Future<void> _scanReceipt() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final status = await Permission.camera.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Camera permission is required to scan receipts')),
            );
          }
          return;
        }
      }

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Scanning receipt...')),
          );
        }

        final ocrService = ref.read(ocrServiceProvider);
        final result = await ocrService.scanReceipt(image.path);

        setState(() {
          if (result['merchant'] != 'Unknown Merchant') {
            _titleController.text = result['merchant'];
          }
          if (result['amount'] > 0) {
            _amountController.text = result['amount'].toString();
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Scanned: ${result['merchant']}, ₹${result['amount']}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning receipt: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);
    final categories = categoriesAsync.value?.map((e) => e.name).toList() ?? [];

    // Ensure state category is valid or reset
    if (_selectedCategory != null && !categories.contains(_selectedCategory) && _selectedCategory != 'Savings') {
       // If category was deleted or invalid, and it's not our special 'Savings' case if handled manually (though usually 'Savings' should be in list)
       // Checks if 'Savings' is in categories list. If not, it might be an issue if we force it.
       // Assuming 'Savings' is a valid category that exists.
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            tooltip: 'Scan Receipt',
            onPressed: _scanReceipt,
          ),
        ],
      ),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount > 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: categories.contains(_selectedCategory) ? _selectedCategory : null,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() {
                  _selectedCategory = val;
                  if (_selectedCategory != 'Savings') {
                    _selectedSavingsGoalId = null;
                  }
                }),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              if (_selectedCategory == 'Savings') ... [
                 const SizedBox(height: 16),
                 Consumer(
                   builder: (context, ref, _) {
                     final goalsAsync = ref.watch(savingsProvider);
                     return goalsAsync.when(
                       data: (goals) {
                         if (goals.isEmpty) {
                           return const Text('No savings goals found. Create one first.', style: TextStyle(color: Colors.orange));
                         }
                         return DropdownButtonFormField<String>(
                           value: _selectedSavingsGoalId, // Goals might change, ensure ID is valid
                           decoration: const InputDecoration(labelText: 'Select Goal to Contribute', border: OutlineInputBorder()),
                           items: goals.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                           onChanged: (val) => setState(() => _selectedSavingsGoalId = val),
                           validator: (value) => value == null ? 'Please select a goal' : null,
                         );
                       },
                       loading: () => const LinearProgressIndicator(),
                       error: (e, _) => Text('Error loading goals: $e'),
                     );
                   }
                 )
              ],
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
                onChanged: (val) => setState(() {
                  _paymentMethod = val!;
                  if (_paymentMethod != 'Credit Card') {
                    _selectedCreditCardId = null;
                  }
                }),
              ),
              if (_paymentMethod == 'Credit Card') ...[
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final cardsAsync = ref.watch(creditCardProvider);
                    return cardsAsync.when(
                      data: (cards) {
                        if (cards.isEmpty) {
                          return const Text('No credit cards found. Please add one in Settings.', style: TextStyle(color: Colors.red));
                        }
                        return DropdownButtonFormField<String>(
                          value: _selectedCreditCardId,
                          decoration: const InputDecoration(labelText: 'Select Credit Card', border: OutlineInputBorder()),
                          items: cards.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) => setState(() => _selectedCreditCardId = val),
                          validator: (value) => value == null ? 'Please select a card' : null,
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                    );
                  },
                ),
              ],
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

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final amountVal = double.parse(_amountController.text);
      
      final expense = ExpenseModel(
        id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: amountVal,
        date: _selectedDate,
        category: _selectedCategory!,
        paymentMethod: _paymentMethod,
        creditCardId: _selectedCreditCardId,
      );

      // Save Expense
      if (widget.expense == null) {
        await ref.read(expensesProvider.notifier).addExpense(expense);
      } else {
        await ref.read(expensesProvider.notifier).updateExpense(expense);
      }

      // Update Savings Goal if applicable
      if (_selectedCategory == 'Savings' && _selectedSavingsGoalId != null) {
        final goals = ref.read(savingsProvider).value ?? [];
        try {
          final goal = goals.firstWhere((g) => g.id == _selectedSavingsGoalId);
          final updatedGoal = goal.copyWith(currentAmount: goal.currentAmount + amountVal);
          await ref.read(savingsProvider.notifier).updateGoal(updatedGoal);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(content: Text('Added ₹$amountVal to ${goal.name}')),
            );
          }
        } catch (e) {
          // Goal might not be found
          // debugPrint('Error updating goal: $e');
        }
      }

      if (mounted) Navigator.pop(context);
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
