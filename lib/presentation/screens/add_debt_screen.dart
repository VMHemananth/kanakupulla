import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../data/models/debt_model.dart';
import '../providers/debt_provider.dart';

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
  late String _type;
  late DateTime _date;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.debt?.personName ?? '');
    _amountController = TextEditingController(text: widget.debt?.amount.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.debt?.description ?? '');
    _type = widget.debt?.type ?? 'Lent';
    _date = widget.debt?.date ?? DateTime.now();
    _dueDate = widget.debt?.dueDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  ButtonSegment(value: 'Lent', label: Text('Lent (Owes Me)')),
                  ButtonSegment(value: 'Borrowed', label: Text('Borrowed (I Owe)')),
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
                decoration: const InputDecoration(labelText: 'Person Name', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder(), prefixText: '₹'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
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
              ListTile(
                title: const Text('Due Date (Optional)'),
                subtitle: Text(_dueDate != null ? DateFormat('dd MMM yyyy').format(_dueDate!) : 'Not Set'),
                trailing: const Icon(Icons.event),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? _date.add(const Duration(days: 7)),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
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
      final debt = DebtModel(
        id: widget.debt?.id ?? const Uuid().v4(),
        personName: _nameController.text,
        amount: double.parse(_amountController.text),
        type: _type,
        date: _date,
        dueDate: _dueDate,
        description: _descriptionController.text,
        isSettled: widget.debt?.isSettled ?? false,
      );

      if (widget.debt == null) {
        ref.read(debtProvider.notifier).addDebt(debt);
      } else {
        ref.read(debtProvider.notifier).updateDebt(debt);
      }
      Navigator.pop(context);
    }
  }
}
