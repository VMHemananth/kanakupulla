import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/category_model.dart';
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
import '../../core/theme/app_theme.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseModel? expense; // Keep for editing existing expenses
  final DateTime? initialDate;
  final double? initialAmount;
  final String? initialTitle;
  final String? initialCategory;
  final String? initialSavingsGoalId;

  const AddExpenseScreen({
    super.key, 
    this.expense, 
    this.initialDate, 
    this.initialAmount, 
    this.initialTitle,
    this.initialCategory,
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
      _selectedSavingsGoalId = widget.expense!.savingsGoalId;
    } else {
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedCategory = widget.initialCategory;
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
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
            SnackBar(
              content: Text('Scanned: ${result['merchant']}, ₹${result['amount']}'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
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
    final theme = Theme.of(context);

    // Ensure state category is valid or reset
    if (_selectedCategory != null && !categories.contains(_selectedCategory) && _selectedCategory != 'Savings') {
       // Assuming 'Savings' is a valid category that exists logic maintained from original code
    }

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.expense == null ? 'New Expense' : 'Edit Expense',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
           IconButton(
            icon: Icon(Icons.camera_alt_rounded, color: theme.colorScheme.primary),
            tooltip: 'Scan Receipt',
            onPressed: _scanReceipt,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Input
              TextFormField(
                controller: _amountController,
                style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '₹0',
                  hintStyle: theme.textTheme.displaySmall?.copyWith(color: theme.colorScheme.outline.withOpacity(0.5)),
                  border: InputBorder.none,
                  prefixText: '₹ ',
                  prefixStyle: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter amount';
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Title and Voice
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _titleController,
                      decoration: inputDecoration.copyWith(labelText: 'What is this for?', prefixIcon: const Icon(Icons.edit_note_rounded)),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: _listen,
                    onLongPress: _listen,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.redAccent : theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_rounded,
                        color: _isListening ? Colors.white : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: categories.contains(_selectedCategory) ? _selectedCategory : null,
                decoration: inputDecoration.copyWith(labelText: 'Category', prefixIcon: const Icon(Icons.category_rounded)),
                dropdownColor: theme.colorScheme.surfaceContainer,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() {
                  _selectedCategory = val;
                  if (_selectedCategory != 'Savings') {
                    _selectedSavingsGoalId = null;
                  }
                }),
                validator: (value) => value == null ? 'Select category' : null,
              ),

              // Savings Goal Selection
              if (_selectedCategory == 'Savings') ... [
                 const SizedBox(height: 16),
                 Consumer(
                   builder: (context, ref, _) {
                     final goalsAsync = ref.watch(savingsProvider);
                     return goalsAsync.when(
                       data: (goals) {
                         if (goals.isEmpty) {
                           return Container(
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               color: Colors.orange.withOpacity(0.1),
                               borderRadius: BorderRadius.circular(16),
                             ),
                             child: const Text('No savings goals found. Create one first.', style: TextStyle(color: Colors.orange)),
                           );
                         }
                         return DropdownButtonFormField<String>(
                           value: _selectedSavingsGoalId,
                           decoration: inputDecoration.copyWith(labelText: 'Select Goal', prefixIcon: const Icon(Icons.savings_rounded)),
                           dropdownColor: theme.colorScheme.surfaceContainer,
                           items: goals.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))).toList(),
                           onChanged: (val) => setState(() => _selectedSavingsGoalId = val),
                           validator: (value) => value == null ? 'Select a goal' : null,
                         );
                       },
                       loading: () => const LinearProgressIndicator(),
                       error: (e, _) => Text('Error loading goals: $e'),
                     );
                   }
                 )
              ],
              const SizedBox(height: 16),

              // Payment Method & Date Row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: inputDecoration.copyWith(labelText: 'Payment', prefixIcon: const Icon(Icons.payment_rounded)),
                      dropdownColor: theme.colorScheme.surfaceContainer,
                      items: const [
                        DropdownMenuItem(value: 'Debit Card', child: Text('Debit Card')),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: theme.copyWith(
                                datePickerTheme: DatePickerThemeData(
                                  backgroundColor: theme.colorScheme.surface,
                                  headerBackgroundColor: theme.colorScheme.primary,
                                )
                              ),
                              child: child!,
                            );
                          }
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}', 
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
                            ),
                            Text(
                              'Date', 
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Credit Card Selection
              if (_paymentMethod == 'Credit Card') ...[
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final cardsAsync = ref.watch(creditCardProvider);
                    return cardsAsync.when(
                      data: (cards) {
                        return DropdownButtonFormField<String>(
                          value: _selectedCreditCardId,
                          decoration: inputDecoration.copyWith(labelText: 'Select Card', prefixIcon: const Icon(Icons.credit_card_rounded)),
                          dropdownColor: theme.colorScheme.surfaceContainer,
                          items: cards.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (val) => setState(() => _selectedCreditCardId = val),
                          validator: (value) => value == null ? 'Select a card' : null,
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                    );
                  },
                ),
              ],

              const SizedBox(height: 48),

              // Save Button
              FilledButton(
                onPressed: _saveExpense,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                ),
                child: Text(
                  widget.expense == null ? 'Save Transaction' : 'Update Transaction',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              
              if (widget.expense != null) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _deleteExpense,
                  icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                  label: Text('Delete Transaction', style: TextStyle(color: theme.colorScheme.error)),
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
      
      // Auto-calculate Need vs Want
      final categories = ref.read(categoryProvider).value ?? [];
      final category = categories.firstWhere(
        (c) => c.name == _selectedCategory, 
        orElse: () => const CategoryModel(name: 'Unknown', type: 'Want')
      );
      final isNeed = category.type == 'Need';
      
      final now = DateTime.now();
      if (_selectedDate.isAfter(now)) {
         final dateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
         final todayOnly = DateTime(now.year, now.month, now.day);
         if (dateOnly.isAfter(todayOnly)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot save expense for a future date.')),
            );
            return;
         }
      }

      final expense = ExpenseModel(
        id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: amountVal,
        date: _selectedDate,
        category: _selectedCategory!,
        paymentMethod: _paymentMethod,
        creditCardId: _selectedCreditCardId,
        savingsGoalId: _selectedSavingsGoalId,
        isNeed: isNeed,
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
               SnackBar(
                 content: Text('Added ₹$amountVal to ${goal.name}'),
                 behavior: SnackBarBehavior.floating,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
               ),
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
