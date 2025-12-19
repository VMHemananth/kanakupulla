import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sms_provider.dart';
import '../../data/services/sms_service.dart';
import 'add_expense_screen.dart';

class SmsTransactionsScreen extends ConsumerStatefulWidget {
  const SmsTransactionsScreen({super.key});

  @override
  ConsumerState<SmsTransactionsScreen> createState() => _SmsTransactionsScreenState();
}

class _SmsTransactionsScreenState extends ConsumerState<SmsTransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    final smsAsync = ref.watch(smsTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Inbox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(smsTransactionsProvider),
          ),
        ],
      ),
      body: smsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.sms_failed, size: 64, color: Colors.grey),
                   const SizedBox(height: 16),
                   const Text(
                     'No bank transactions found.',
                     style: TextStyle(fontSize: 18, color: Colors.grey),
                   ),
                   const SizedBox(height: 8),
                   TextButton(
                     onPressed: () => ref.refresh(smsTransactionsProvider),
                     child: const Text('Scan Again'),
                   ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final txn = transactions[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          txn.merchant ?? txn.sender,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${txn.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, yyyy • h:mm a').format(txn.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        txn.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 32),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddExpenseScreen(
                            initialAmount: txn.amount,
                            initialDate: txn.date,
                            initialTitle: txn.merchant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Scanning SMS for transactions...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               const Icon(Icons.error_outline, size: 48, color: Colors.red),
               const SizedBox(height: 16),
               Text('Error: $err'),
               const SizedBox(height: 8),
               ElevatedButton(
                 onPressed: () => ref.refresh(smsTransactionsProvider),
                 child: const Text('Retry'),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
