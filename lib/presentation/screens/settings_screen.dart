import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/backup_service.dart';
import '../providers/expense_provider.dart';
import '../providers/category_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/salary_provider.dart';
import '../providers/fixed_expense_provider.dart';
import '../providers/recurring_income_provider.dart';

import '../providers/theme_provider.dart';
import '../../data/services/export_service.dart';
import '../../data/services/biometric_service.dart';
import '../../data/repositories/settings_repository.dart';
import '../providers/app_lock_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final BackupService _backupService = BackupService();
  bool _isLoading = false;

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    try {
      await _backupService.createBackup();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restoreBackup() async {
    setState(() => _isLoading = true);
    try {
      final success = await _backupService.restoreBackup();
      if (success) {
        // Refresh all providers
        ref.refresh(expensesProvider);
        ref.refresh(categoryProvider);
        ref.refresh(budgetProvider);
        ref.refresh(salaryProvider);
        ref.refresh(fixedExpensesProvider);
        ref.refresh(recurringIncomeProvider);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data restored successfully')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restore cancelled or failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(themeProvider.notifier).setTheme(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('App Lock'),
                  subtitle: const Text('Secure with Biometrics/PIN'),
                  trailing: Switch(
                    value: ref.watch(appLockProvider),
                    onChanged: (value) async {
                      if (value) {
                        // verify before enabling
                        final success = await ref.read(biometricServiceProvider).authenticate();
                        if (success) {
                          await ref.read(appLockProvider.notifier).setAppLockEnabled(true);
                        }
                      } else {
                        // verify before disabling
                        final success = await ref.read(biometricServiceProvider).authenticate();
                        if (success) {
                          await ref.read(appLockProvider.notifier).setAppLockEnabled(false);
                        }
                      }
                    },
                  ),
                ),
                const Divider(),
                Consumer(
                  builder: (context, ref, _) {
                     final budgetAsync = ref.watch(budgetProvider);
                     return ListTile(
                       leading: const Icon(Icons.monetization_on),
                       title: const Text('Monthly Budget'),
                       subtitle: budgetAsync.when(
                         data: (budget) => Text(budget?.amount != null ? '₹${budget!.amount.toStringAsFixed(0)}' : 'Not Set'),
                         loading: () => const Text('Loading...'),
                         error: (_,__) => const Text('Error loading budget'),
                       ),
                       onTap: () {
                         final currentBudget = budgetAsync.value?.amount;
                         final controller = TextEditingController(text: currentBudget?.toString() ?? '');
                         showDialog(
                           context: context,
                           builder: (ctx) => AlertDialog(
                             title: const Text('Set Monthly Budget'),
                             content: TextField(
                               controller: controller,
                               keyboardType: TextInputType.number,
                               decoration: const InputDecoration(
                                 labelText: 'Amount',
                                 prefixText: '₹ ',
                                 border: OutlineInputBorder(),
                               ),
                             ),
                             actions: [
                               TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                               TextButton(
                                 onPressed: () {
                                   final amount = double.tryParse(controller.text);
                                   if (amount != null && amount > 0) {
                                     ref.read(budgetProvider.notifier).setBudget(amount);
                                     Navigator.pop(ctx);
                                   }
                                 }, 
                                 child: const Text('Save')
                               ),
                             ],
                           ),
                         );
                       },
                     );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Export your data to a JSON file'),
                  onTap: _createBackup,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: const Text('Restore Data'),
                  subtitle: const Text('Import data from a backup file'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Restore Data'),
                        content: const Text(
                            'This will replace all your current data with the data from the backup file. Are you sure?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _restoreBackup();
                            },
                            child: const Text('Restore', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
