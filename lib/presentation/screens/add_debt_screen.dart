import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../data/models/debt_model.dart';
import '../providers/debt_provider.dart';
import '../../core/utils/loan_calculator.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  final DebtModel? debt;
  const AddDebtScreen({super.key, this.debt});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _roiController;
  late TextEditingController _tenureController;
  
  late String _type;
  late String _interestType;
  late DateTime _date;
  DateTime? _dueDate;
  
  double? _calculatedEMI;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.debt?.personName ?? '');
    _amountController = TextEditingController(text: widget.debt?.principalAmount.toString() ?? (widget.debt?.amount.toString() ?? '')); // Use principal if available, else current amount
    _descriptionController = TextEditingController(text: widget.debt?.description ?? '');
    _roiController = TextEditingController(text: widget.debt?.roi.toString() ?? '0');
    _tenureController = TextEditingController(text: widget.debt?.tenureMonths.toString() ?? '0');
    
    _type = widget.debt?.type ?? 'Lent';
    _interestType = widget.debt?.interestType ?? 'Fixed';
    _date = widget.debt?.date ?? DateTime.now();
    _dueDate = widget.debt?.dueDate;
    
    _amountController.addListener(_calculateEMI);
    _roiController.addListener(_calculateEMI);
    _tenureController.addListener(_calculateEMI);
    
    if (widget.debt != null) {
      _calculateEMI();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _roiController.dispose();
    _tenureController.dispose();
    super.dispose();
  }

  void _calculateEMI() {
    final principal = double.tryParse(_amountController.text) ?? 0;
    final roi = double.tryParse(_roiController.text) ?? 0;
    final tenure = int.tryParse(_tenureController.text) ?? 0;

    if (principal > 0 && roi > 0 && tenure > 0) {
      setState(() {
        _calculatedEMI = LoanCalculator.calculateEMI(principal, roi, tenure);
      });
    } else if (principal > 0 && tenure > 0 && roi == 0) {
       setState(() {
        _calculatedEMI = principal / tenure;
      });
    } else {
      setState(() {
        _calculatedEMI = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If editing a Fixed interest loan, ROI shouldn't be editable? 
    // Requirement: "user should not able to edit the roi" if fixed.
    final bool isFixedAndEditing = widget.debt != null && _interestType == 'Fixed';
    final bool canEditRoi = !isFixedAndEditing; 

    return Scaffold(
      appBar: AppBar(title: Text(widget.debt == null ? 'Add Debt / Loan' : 'Edit Debt / Loan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Type Selection
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Lent', label: Text('Lent')),
                  ButtonSegment(value: 'Borrowed', label: Text('Borrowed')),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Person / Bank Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Total Loan Amount', border: OutlineInputBorder(), prefixText: '₹'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
                readOnly: widget.debt != null, // Principal amount usually doesn't change on edit, only on creation? Or allow edit but warn? Let's allow edit if not payments made.
              ),
              const SizedBox(height: 16),
              
              // Loan Specifics
              Row(
                children: [
                   Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _interestType,
                      decoration: const InputDecoration(labelText: 'Interest Type', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Fixed', child: Text('Fixed')),
                        DropdownMenuItem(value: 'Floating', child: Text('Floating')),
                      ],
                      onChanged: widget.debt == null ? (val) { // Cannot change type after creation usually
                        if (val != null) setState(() => _interestType = val);
                      } : null, 
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _roiController,
                      decoration: const InputDecoration(labelText: 'ROI (%)', border: OutlineInputBorder(), suffixText: '%'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: canEditRoi,
                      validator: (value) {
                         if (value != null && value.isNotEmpty && double.tryParse(value) == null) return 'Invalid';
                         return null;
                      },
                    ),
                  ),
                ],
              ),
              if (isFixedAndEditing)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('ROI is locked for Fixed Interest loans.', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ),
                
              const SizedBox(height: 16),
              TextFormField(
                controller: _tenureController,
                decoration: const InputDecoration(labelText: 'Tenure (Months)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                 validator: (value) {
                     if (value != null && value.isNotEmpty && int.tryParse(value) == null) return 'Invalid';
                     return null;
                  },
              ),

              if (_calculatedEMI != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      const Text('Estimated EMI', style: TextStyle(color: Colors.grey)),
                      Text('₹${_calculatedEMI!.toStringAsFixed(0)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                      if (_tenureController.text.isNotEmpty)
                         Text('Total Payment: ₹${(_calculatedEMI! * (int.tryParse(_tenureController.text) ?? 0)).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_date)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
               
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveDebt,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(widget.debt == null ? 'Save' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveDebt() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final roi = double.tryParse(_roiController.text) ?? 0.0;
      final tenure = int.tryParse(_tenureController.text) ?? 0;
      
      final debt = DebtModel(
        id: widget.debt?.id ?? const Uuid().v4(),
        personName: _nameController.text,
        amount: widget.debt?.amount ?? amount, // Keep tracking outstanding separately? Wait, if new, outstanding = principal.
        principalAmount: amount, // Assuming user enters original amount here
        type: _type,
        date: _date,
        dueDate: _dueDate, // Logic for due date? Maybe Calculate based on tenure? Or let user set?
        description: _descriptionController.text,
        isSettled: widget.debt?.isSettled ?? false,
        roi: roi,
        interestType: _interestType,
        tenureMonths: tenure,
        payments: widget.debt?.payments ?? [],
      );

      // Fix for "amount" logic:
      // If new, amount = principalAmount
      // If edit, amount = existing outstanding (unless we want to recalculate based on payments? Logic complexity here)
      // Simplest: If new, outstanding = principal. If edit, keep outstanding unless principal changed? 
      // Let's assume on Edit, we update non-financials or only future parameters. 
      final finalDebt = widget.debt == null 
          ? debt.copyWith(amount: amount) 
          : debt.copyWith(amount: widget.debt!.amount); // Preserve outstanding on edit
          
      if (widget.debt == null) {
        ref.read(debtProvider.notifier).addDebt(finalDebt);
      } else {
        ref.read(debtProvider.notifier).updateDebt(finalDebt);
      }
      Navigator.pop(context);
    }
  }
}
