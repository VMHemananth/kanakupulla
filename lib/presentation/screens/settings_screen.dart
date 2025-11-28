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
import '../../data/services/pdf_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final BackupService _backupService = BackupService();
  final PdfService _pdfService = PdfService();
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

  Future<void> _generatePdf() async {
    setState(() => _isLoading = true);
    try {
      final expensesAsync = ref.read(expensesProvider);
      if (expensesAsync.hasValue) {
        await _pdfService.generateExpenseReport(expensesAsync.value!);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No expenses to export')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF generation failed: $e')),
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
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf),
                  title: const Text('Export PDF Report'),
                  subtitle: const Text('Generate a PDF report of your expenses'),
                  onTap: _generatePdf,
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
