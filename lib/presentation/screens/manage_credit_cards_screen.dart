import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/credit_card_model.dart';
import '../providers/credit_card_provider.dart';

class ManageCreditCardsScreen extends ConsumerWidget {
  const ManageCreditCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditCardsAsync = ref.watch(creditCardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Credit Cards')),
      body: creditCardsAsync.when(
        data: (cards) {
          if (cards.isEmpty) {
            return const Center(child: Text('No credit cards added yet.'));
          }
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return ListTile(
                leading: const Icon(Icons.credit_card, color: Colors.blue),
                title: Text(card.name),
                subtitle: Text('Billing Day: ${card.billingDay}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showAddDialog(context, ref, card: card),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        ref.read(creditCardProvider.notifier).deleteCreditCard(card.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref, {CreditCardModel? card}) {
    final nameController = TextEditingController(text: card?.name ?? '');
    final dayController = TextEditingController(text: card?.billingDay.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(card == null ? 'Add Credit Card' : 'Edit Credit Card'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Card Name (e.g. HDFC)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dayController,
              decoration: const InputDecoration(labelText: 'Billing Day (1-31)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final day = int.tryParse(dayController.text);
              if (nameController.text.isNotEmpty && day != null && day >= 1 && day <= 31) {
                final newCard = CreditCardModel(
                  id: card?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  billingDay: day,
                  lastBillGeneratedMonth: card?.lastBillGeneratedMonth,
                );

                if (card == null) {
                  ref.read(creditCardProvider.notifier).addCreditCard(newCard);
                } else {
                  ref.read(creditCardProvider.notifier).updateCreditCard(newCard);
                }
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid details')),
                );
              }
            },
            child: Text(card == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }
}
