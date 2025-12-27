import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../providers/budget_rule_provider.dart';

class BudgetRuleSettingsScreen extends ConsumerStatefulWidget {
  const BudgetRuleSettingsScreen({super.key});

  @override
  ConsumerState<BudgetRuleSettingsScreen> createState() => _BudgetRuleSettingsScreenState();
}

class _BudgetRuleSettingsScreenState extends ConsumerState<BudgetRuleSettingsScreen> {
  late double _needs;
  late double _wants;
  late double _savings;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final rule = ref.read(budgetRuleProvider);
      _needs = rule.needs;
      _wants = rule.wants;
      _savings = rule.savings;
      _isInit = true;
    }
  }

  void _validateAndSave() async {
    final total = _needs + _wants + _savings;
    if ((total - 100).abs() > 0.1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Total must be 100%. Current total: ${total.toStringAsFixed(1)}%'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await ref.read(budgetRuleProvider.notifier).updateRule(_needs, _wants, _savings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Budget rules updated successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  void _resetToDefault() {
    setState(() {
      _needs = 50;
      _wants = 30;
      _savings = 20;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _needs + _wants + _savings;
    final isValid = (total - 100).abs() <= 0.1;

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Rules')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Customize your budget allocation rule. The standard recommendation is 50/30/20.',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Verification Indicator
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                border: Border.all(color: isValid ? Colors.green : Colors.red),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Allocation',
                    style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                  ),
                  Text(
                    '${total.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: isValid ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSlider(context, 'Needs', _needs, Colors.blueGrey, (val) => setState(() => _needs = val)),
            _buildSlider(context, 'Wants', _wants, Colors.orange, (val) => setState(() => _wants = val)),
            _buildSlider(context, 'Savings', _savings, Colors.green, (val) => setState(() => _savings = val)),

            const SizedBox(height: 24),
            
            OutlinedButton.icon(
              onPressed: _resetToDefault,
              icon: const Icon(Icons.restore),
              label: const Text('Reset to 50/30/20'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isValid ? _validateAndSave : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context, String label, double value, Color color, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Text('${value.toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            label: value.toStringAsFixed(0),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
