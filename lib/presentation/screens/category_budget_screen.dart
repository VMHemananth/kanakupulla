import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/budget_provider.dart';
import '../providers/category_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/date_provider.dart';
import '../providers/salary_provider.dart';
import '../../data/models/expense_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/budget_model.dart';
import '../../core/theme/app_theme.dart';

class CategoryBudgetScreen extends StatelessWidget {
  const CategoryBudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Budget Allocation')),
      body: const CategoryBudgetListWidget(),
    );
  }
}

class CategoryBudgetListWidget extends ConsumerStatefulWidget {
  const CategoryBudgetListWidget({super.key});

  @override
  ConsumerState<CategoryBudgetListWidget> createState() => _CategoryBudgetListWidgetState();
}

class _CategoryBudgetListWidgetState extends ConsumerState<CategoryBudgetListWidget> {
  // Local state for sliders. Key is Category Name.
  Map<String, double>? _draftBudgets;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
  }

  void _syncDraftBudgets(List<BudgetModel> budgets, List<CategoryModel> categories) {
    // If null, initialize completely
    if (_draftBudgets == null) {
      final Map<String, double> initialMap = {};
      for (var cat in categories) {
        final budget = budgets.firstWhere(
          (b) => b.category == cat.name,
          orElse: () => BudgetModel(id: '', month: '', amount: 0, category: cat.name), // Dummy default
        );
        initialMap[cat.name] = budget.amount;
      }
      _draftBudgets = initialMap;
      return;
    }

    // If already exists, check if we need to add new categories
    // This handles the case where a user adds a category while on this screen (or returns to it)
    for (var cat in categories) {
       if (!_draftBudgets!.containsKey(cat.name)) {
          final budget = budgets.firstWhere(
            (b) => b.category == cat.name,
            orElse: () => BudgetModel(id: '', month: '', amount: 0, category: cat.name),
          );
          _draftBudgets![cat.name] = budget.amount;
       }
    }
    
    // Also remove any categories that no longer exist
    final categoryNames = categories.map((c) => c.name).toSet();
    _draftBudgets!.removeWhere((key, value) => !categoryNames.contains(key));
  }
  
  void _updateBudget(String category, double newValue, double unallocated, double currentTotalLimit) {
    if (_draftBudgets == null) return;
    
    final oldValue = _draftBudgets![category] ?? 0.0;
    final diff = newValue - oldValue;

    // Check if we have enough unallocated funds (allow slight floating point error tolerance)
    if (diff > 0 && diff > unallocated + 0.01) {
      // Trying to increase more than available using slider? 
      // The slider max should prevent this, but just in case.
      return; 
    }

    setState(() {
      _draftBudgets![category] = newValue;
      _hasChanges = true;
    });
  }

  void _manualEditBudget(String category, double currentAmount, double unallocated) {
    final controller = TextEditingController(text: currentAmount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Budget for $category', style: GoogleFonts.outfit()),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(controller.text);
              if (val != null) {
                final diff = val - currentAmount;
                if (diff > unallocated) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cannot allocate more than available (₹${unallocated.toStringAsFixed(0)})')),
                  );
                } else {
                  setState(() {
                    _draftBudgets![category] = val;
                    _hasChanges = true;
                  });
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }

  void _autoAllocate(double unallocated, List<CategoryModel> categories) {
      if (_draftBudgets == null) return;
      
      // Smart Allocation Logic: 50/30/20 Rule
      // But we are allocating based on WHAT IS AVAILABLE in the Monthly Limit, 
      // not just the unallocated portion? 
      // Actually, typically if users click "Smart Distribute", they want to reset 
      // and distribute the ENTIRE monthly budget according to the rule.
      
      // Let's get the total monthly budget
      final monthlyLimit = ref.read(budgetProvider).value?.amount ?? 0.0;
      if (monthlyLimit <= 0) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please set a Total Monthly Budget first.')));
        return;
      }

      // Calculate Pools
      final needsPool = monthlyLimit * 0.50;
      final wantsPool = monthlyLimit * 0.30;
      final savingsPool = monthlyLimit * 0.20;

      // Group Categories
      final needsCats = categories.where((c) => c.type == 'Need').toList();
      final wantsCats = categories.where((c) => c.type == 'Want' || c.type == 'General').toList(); // Treat General as Want
      final savingsCats = categories.where((c) => c.type == 'Savings').toList();

      if (needsCats.isEmpty && wantsCats.isEmpty && savingsCats.isEmpty) return;

      setState(() {
        // Reset all to 0 first? Or overwrite? Overwrite is safer.
        
        // 1. Distribute Needs
        if (needsCats.isNotEmpty) {
           final share = needsPool / needsCats.length;
           for (var cat in needsCats) {
             _draftBudgets![cat.name] = share;
           }
        }
        // Handle overflow if no needs cats? For now, ignore.
        
        // 2. Distribute Wants
        if (wantsCats.isNotEmpty) {
           final share = wantsPool / wantsCats.length;
           for (var cat in wantsCats) {
             _draftBudgets![cat.name] = share;
           }
        }

        // 3. Distribute Savings
        if (savingsCats.isNotEmpty) {
           final share = savingsPool / savingsCats.length;
           for (var cat in savingsCats) {
             _draftBudgets![cat.name] = share;
           }
        }
        
        _hasChanges = true;
      });
  }
  
  Future<void> _saveChanges() async {
    if (_draftBudgets == null) return;
    try {
      await ref.read(categoryBudgetsProvider.notifier).batchSetCategoryBudgets(_draftBudgets!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Budgets saved successfully!')));
        setState(() {
          _hasChanges = false;
        });
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving budgets: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoryProvider);
    final budgetsAsync = ref.watch(categoryBudgetsProvider);
    final monthlyBudgetAsync = ref.watch(budgetProvider);
    final theme = Theme.of(context);

    // Combine loading states
    if (categoriesAsync.isLoading || budgetsAsync.isLoading || monthlyBudgetAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Handle errors
    if (categoriesAsync.hasError || budgetsAsync.hasError || monthlyBudgetAsync.hasError) {
       return const Center(child: Text('Error loading data'));
    }

    final categories = categoriesAsync.value ?? [];
    final budgets = budgetsAsync.value ?? [];
    final monthlyLimit = monthlyBudgetAsync.value?.amount ?? 0.0;

    // Initialize and sync draft budgets
    _syncDraftBudgets(budgets, categories);
    
    // Fallback if somehow still null (should not happen)
    if (_draftBudgets == null) return const LinearProgressIndicator();

    // Calculate totals based on LOCAL state
    final totalAllocated = _draftBudgets!.values.fold(0.0, (sum, val) => sum + val);
    final remainingAllocatable = max(0.0, monthlyLimit - totalAllocated);

    return Column(
      children: [
        // Summary Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: theme.colorScheme.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Budget', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('₹${monthlyLimit.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.white),
                  )
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Allocated', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('₹${totalAllocated.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Unallocated', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      Text('₹${remainingAllocatable.toStringAsFixed(0)}', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18, 
                          color: remainingAllocatable < 0 ? theme.colorScheme.error : Colors.white
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // Auto Allocate Button (Always allow reset/distribute if budget exists)
        if (monthlyLimit > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: FilledButton.icon(
              onPressed: () => _autoAllocate(remainingAllocatable, categories),
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Smart Distribute (50/30/20)'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                minimumSize: const Size(double.infinity, 45),
              ),
            ),
          ),
          
        const SizedBox(height: 8),

        // Category List
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
               _buildCategoryGroup('Needs (50%)', categories.where((c) => c.type == 'Need').toList(), remainingAllocatable, monthlyLimit, theme),
               _buildCategoryGroup('Wants (30%)', categories.where((c) => c.type == 'Want' || c.type == 'General').toList(), remainingAllocatable, monthlyLimit, theme),
               _buildCategoryGroup('Savings (20%)', categories.where((c) => c.type == 'Savings').toList(), remainingAllocatable, monthlyLimit, theme),
            ],
          ),
        ),
        
        // Save Button Footer
        if (_hasChanges)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                 BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: FilledButton(
                onPressed: _saveChanges,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Allocations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryGroup(String title, List<CategoryModel> groupCategories, double remainingAllocatable, double monthlyLimit, ThemeData theme) {
      if (groupCategories.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
          ),
          ...groupCategories.map((category) {
              final currentAmount = _draftBudgets![category.name] ?? 0.0;
              final maxSliderValue = currentAmount + remainingAllocatable;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                             CircleAvatar(
                               radius: 16,
                               backgroundColor: theme.colorScheme.primaryContainer,
                               child: Icon(Icons.category, color: theme.colorScheme.primary, size: 16),
                             ),
                             const SizedBox(width: 12),
                             Text(category.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        InkWell(
                          onTap: () => _manualEditBudget(category.name, currentAmount, remainingAllocatable),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${currentAmount.toStringAsFixed(0)}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Divider(height: 12, thickness: 0.5),
                    Row(
                      children: [
                        const Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Expanded(
                            child: Slider(
                            value: currentAmount,
                            min: 0,
                            // Visual Max is the Total Monthly Budget (so you see proportion)
                            // If limit is 0, use 100 just to render (it will be disabled)
                            max: monthlyLimit > 0 ? monthlyLimit : 100,
                            // Disable if no budget logic
                            onChanged: (monthlyLimit <= 0) ? null : (val) {
                                // Clamp the value to what is actually available
                                // Available for this category = Current + Unallocated
                                final absoluteMax = currentAmount + remainingAllocatable;
                                
                                if (val > absoluteMax) {
                                  val = absoluteMax;
                                }
                                
                                _updateBudget(category.name, val, remainingAllocatable, monthlyLimit);
                            },
                          ),
                        ),
                        Text(
                          'Max: ₹${(currentAmount + remainingAllocatable).toStringAsFixed(0)}', 
                          style: const TextStyle(fontSize: 10, color: Colors.grey)
                        ),
                      ],
                    ),
                  ],
                ),
              );
          }),
          const SizedBox(height: 8),
        ],
      );
  }
}
