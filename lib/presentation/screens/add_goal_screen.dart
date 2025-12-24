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

  int? _selectedColorValue;
  int? _selectedIconCodePoint;

  final List<Color> _colors = [
    Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.teal, Colors.pink, Colors.indigo
  ];

  final List<IconData> _icons = [
    Icons.savings, Icons.directions_car, Icons.home, Icons.flight, 
    Icons.school, Icons.medical_services, Icons.shopping_bag, Icons.favorite,
    Icons.laptop, Icons.pets, Icons.fitness_center, Icons.music_note
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetAmountController = TextEditingController(
        text: widget.goal?.targetAmount.toStringAsFixed(0) ?? '');
    _currentAmountController = TextEditingController(
        text: widget.goal?.currentAmount.toStringAsFixed(0) ?? '0');
    _deadline = widget.goal?.deadline;
    _selectedColorValue = widget.goal?.color ?? Colors.blue.value;
    
    // Parse icon if exists, else default
    if (widget.goal?.icon != null) {
       _selectedIconCodePoint = int.tryParse(widget.goal!.icon!);
    } else {
       _selectedIconCodePoint = Icons.savings.codePoint;
    }
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
              // Icon Picker
              Text('Choose Icon', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _icons.map((icon) {
                  final isSelected = _selectedIconCodePoint == icon.codePoint;
                  return InkWell(
                    onTap: () => setState(() => _selectedIconCodePoint = icon.codePoint),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(_selectedColorValue!).withOpacity(0.2) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: Color(_selectedColorValue!), width: 2) : null,
                      ),
                      child: Icon(icon, color: isSelected ? Color(_selectedColorValue!) : Colors.grey, size: 28),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Color Picker
              Text('Choose Color', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _colors.map((color) {
                    final isSelected = _selectedColorValue == color.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedColorValue = color.value),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected ? Border.all(color: Colors.black, width: 3) : null,
                            boxShadow: [
                               if (isSelected) BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)
                            ]
                          ),
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 24) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

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
                  final val = double.tryParse(value);
                  if (val == null) return 'Invalid amount';
                  if (val <= 0) return 'Target must be greater than 0';
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
                contentPadding: EdgeInsets.zero,
                title: const Text('Target Date (Optional)'),
                subtitle: Text(_deadline != null ? DateFormat('dd MMM yyyy').format(_deadline!) : 'No Deadline'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(), // Prevent past dates
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _deadline = picked);
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(_selectedColorValue!),
                  foregroundColor: Colors.white,
                ),
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
          color: _selectedColorValue,
          icon: _selectedIconCodePoint?.toString(),
        );
        ref.read(savingsProvider.notifier).updateGoal(updatedGoal);
      } else {
        final goal = SavingsGoalModel(
          id: const Uuid().v4(),
          name: name,
          targetAmount: targetAmount,
          currentAmount: currentAmount,
          deadline: _deadline,
          color: _selectedColorValue,
          icon: _selectedIconCodePoint?.toString(),
        );
        ref.read(savingsProvider.notifier).addGoal(goal);
      }
      Navigator.pop(context);
    }
  }
}
