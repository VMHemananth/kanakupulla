import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/contribution_model.dart';
import '../../../data/models/split_models.dart';
import '../../providers/split_provider.dart';

class AddContributionDialog extends ConsumerStatefulWidget {
  final String groupId;
  final List<GroupMember> members;

  const AddContributionDialog({super.key, required this.groupId, required this.members});

  @override
  ConsumerState<AddContributionDialog> createState() => _AddContributionDialogState();
}

class _AddContributionDialogState extends ConsumerState<AddContributionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String? _memberId;

  @override
  void initState() {
    super.initState();
    if (widget.members.isNotEmpty) {
      _memberId = widget.members.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Funds to Pool'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _memberId,
              decoration: const InputDecoration(labelText: 'Contributed By'),
              items: widget.members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
              onChanged: (val) => setState(() => _memberId = val),
              validator: (val) => val == null ? 'Please select a member' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
              keyboardType: TextInputType.number,
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter amount';
                if (double.tryParse(val) == null) return 'Invalid amount';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Add Funds'),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _memberId != null) {
      final contribution = GroupContribution(
        id: const Uuid().v4(),
        groupId: widget.groupId,
        memberId: _memberId!,
        amount: double.parse(_amountController.text),
        date: DateTime.now(),
      );

      ref.read(groupDetailsProvider(widget.groupId).notifier).addContribution(contribution);
      Navigator.pop(context);
    }
  }
}
