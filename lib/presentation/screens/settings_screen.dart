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

import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/repositories/settings_repository.dart';
import '../providers/app_lock_provider.dart';

import 'budget_rule_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final BackupService _backupService = BackupService();

  bool _isLoading = false;
  


  @override
  void initState() {
    super.initState();
  }



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
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('Theme Mode'),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeState.mode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                    ],
                    onChanged: (mode) {
                      if (mode != null) {
                         ref.read(themeProvider.notifier).setThemeMode(mode);
                      }
                    },
                  ),
                ),
                ListTile(
                   leading: const Icon(Icons.palette),
                   title: const Text('Accent Color'),
                   subtitle: SingleChildScrollView(
                     scrollDirection: Axis.horizontal,
                     child: Row(
                       children: [
                         _buildColorOption(context, ref, Colors.blue, themeState.seedColor),
                         _buildColorOption(context, ref, Colors.indigo, themeState.seedColor),
                         _buildColorOption(context, ref, Colors.purple, themeState.seedColor),
                         _buildColorOption(context, ref, Colors.green, themeState.seedColor),
                         _buildColorOption(context, ref, Colors.teal, themeState.seedColor),
                         _buildColorOption(context, ref, Colors.orange, themeState.seedColor),
                         _buildColorOption(context, ref, Colors.red, themeState.seedColor),
                         _buildColorOption(context, ref, Colors.pink, themeState.seedColor),
                       ],
                     ),
                   ),
                ),
                const Divider(),
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
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication failed. App Lock not enabled.')));
                          }
                        }
                      } else {
                        // verify before disabling
                        final success = await ref.read(biometricServiceProvider).authenticate();
                        if (success) {
                          await ref.read(appLockProvider.notifier).setAppLockEnabled(false);
                        } else {
                           if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication failed. App Lock remains enabled.')));
                          }
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

                const Divider(),
                ListTile(
                  leading: const Icon(Icons.pie_chart_outline),
                  title: const Text('Budget Rules'),
                  subtitle: const Text('Customize 50/30/20 rule'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (c) => const BudgetRuleSettingsScreen()));
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Local Backup'),
                  subtitle: const Text('Export to JSON'),
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
  Widget _buildColorOption(BuildContext context, WidgetRef ref, Color color, Color selectedColor) {
    final isSelected = color.value == selectedColor.value;
    return GestureDetector(
      onTap: () {
        ref.read(themeProvider.notifier).setSeedColor(color);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8, top: 8),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
          boxShadow: [
             if(isSelected) const BoxShadow(blurRadius: 4, color: Colors.black26),
          ],
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
      ),
    );
  }
}
