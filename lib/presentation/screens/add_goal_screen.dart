import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../data/models/savings_goal_model.dart';
import '../providers/savings_provider.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  final SavingsGoalModel? goal;
  const AddGoalScreen({super.key, this.goal});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetAmountController = TextEditingController(
        text: widget.goal?.targetAmount.toStringAsFixed(0) ?? '');
    _currentAmountController = TextEditingController(
        text: widget.goal?.currentAmount.toStringAsFixed(0) ?? '0');
    _deadline = widget.goal?.deadline;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.goal != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Savings Goal' : 'New Savings Goal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Goal Name (e.g., New Car)', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(labelText: 'Target Amount', border: OutlineInputBorder(), prefixText: '₹'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter target amount';
                  if (double.tryParse(value) == null) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentAmountController,
                decoration: const InputDecoration(labelText: 'Current Savings (Optional)', border: OutlineInputBorder(), prefixText: '₹'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Target Date (Optional)'),
                subtitle: Text(_deadline != null ? DateFormat('dd MMM yyyy').format(_deadline!) : 'No Deadline'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _deadline = picked);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(isEditing ? 'Update Goal' : 'Create Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final targetAmount = double.parse(_targetAmountController.text);
      final currentAmount = double.tryParse(_currentAmountController.text) ?? 0.0;

      if (widget.goal != null) {
        final updatedGoal = widget.goal!.copyWith(
          name: name,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          deadline: _deadline,
        );
        ref.read(savingsProvider.notifier).updateGoal(updatedGoal);
      } else {
        final goal = SavingsGoalModel(
          id: const Uuid().v4(),
          name: name,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          deadline: _deadline,
        );
        ref.read(savingsProvider.notifier).addGoal(goal);
      }
      Navigator.pop(context);
    }
  }
}
