import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../providers/split_provider.dart';
import '../../../data/models/split_models.dart';

class GroupDetailsScreen extends ConsumerWidget {
  final String groupId;
  final String groupName;

  const GroupDetailsScreen({super.key, required this.groupId, required this.groupName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailsAsync = ref.watch(groupDetailsProvider(groupId));

    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            tooltip: 'Add Members',
            onPressed: () => _showAddMemberDialog(context, ref),
          ),
        ],
      ),
      body: detailsAsync.when(
        data: (state) {
          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Expenses'),
                    Tab(text: 'Balances'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildExpensesTab(context, ref, state),
                      _buildBalancesTab(state),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpensesTab(BuildContext context, WidgetRef ref, GroupDetailsState state) {
    if (state.expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No expenses yet'),
            if (state.members.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () => _showAddMemberDialog(context, ref),
                  child: const Text('Add Members First'),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.expenses.length,
      itemBuilder: (context, index) {
        final expense = state.expenses[index];
        final payerName = state.members.firstWhere(
          (m) => m.id == expense.paidByMemberId,
          orElse: () => GroupMember(id: '', groupId: '', name: 'Unknown'),
        ).name;

        return Card(
          child: ListTile(
            title: Text(expense.title),
            subtitle: Text('Paid by $payerName • ${DateFormat('MMM d').format(expense.date)}'),
            trailing: Text(
              '₹${expense.amount.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalancesTab(GroupDetailsState state) {
    if (state.members.isEmpty) return const Center(child: Text('No members'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.members.length,
      itemBuilder: (context, index) {
        final member = state.members[index];
        final balance = state.balances[member.id] ?? 0.0;
        final isPositive = balance >= 0;

        return Card(
          child: ListTile(
            title: Text(member.name),
            trailing: Text(
              isPositive ? 'Gets back ₹${balance.toStringAsFixed(0)}' : 'Owes ₹${balance.abs().toStringAsFixed(0)}',
              style: TextStyle(
                color: isPositive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddMemberDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final members = <String>[];
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Members'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        setState(() {
                          members.add(controller.text);
                          controller.clear();
                        });
                      }
                    },
                  ),
                ),
                onSubmitted: (val) {
                  if (val.isNotEmpty) {
                    setState(() {
                      members.add(val);
                      controller.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (members.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: members.map((m) => Chip(
                    label: Text(m),
                    onDeleted: () {
                      setState(() {
                        members.remove(m);
                      });
                    },
                  )).toList(),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  members.add(controller.text);
                }
                if (members.isNotEmpty) {
                  for (var name in members) {
                    ref.read(groupDetailsProvider(groupId).notifier).addMember(name);
                  }
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add All'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(groupDetailsProvider(groupId)).value;
    if (state == null || state.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add members first')),
      );
      if (state?.members.isEmpty ?? true) {
        _showAddMemberDialog(context, ref);
      }
      return;
    }

    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String? paidBy = state.members.first.id;
    List<String> splitWith = state.members.map((m) => m.id).toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title (e.g., Dinner)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: paidBy,
                  decoration: const InputDecoration(labelText: 'Paid By'),
                  items: state.members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                  onChanged: (val) => setState(() => paidBy = val),
                ),
                const SizedBox(height: 16),
                const Text('Split With:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: state.members.map((member) {
                    final isSelected = splitWith.contains(member.id);
                    return FilterChip(
                      label: Text(member.name),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            splitWith.add(member.id);
                          } else {
                            splitWith.remove(member.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                if (titleController.text.isNotEmpty && amount != null && paidBy != null && splitWith.isNotEmpty) {
                  final expense = SplitExpense(
                    id: const Uuid().v4(),
                    groupId: groupId,
                    title: titleController.text,
                    amount: amount,
                    paidByMemberId: paidBy!,
                    date: DateTime.now(),
                    splitWith: splitWith,
                  );
                  ref.read(groupDetailsProvider(groupId).notifier).addExpense(expense);
                  Navigator.pop(ctx);
                } else if (splitWith.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select at least one member to split with')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
