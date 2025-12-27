import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category_model.dart';
import '../providers/category_provider.dart';
import '../providers/budget_rule_provider.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      body: const CategoryListWidget(),
      floatingActionButton: Consumer(
        builder: (context, ref, _) => FloatingActionButton(
          onPressed: () => showAddCategoryDialog(context, ref),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class CategoryListWidget extends ConsumerWidget {
  const CategoryListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);

    return categoriesAsync.when(
      data: (categories) {
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSavings = category.name.toLowerCase() == 'savings';
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getColorForType(category.type),
                child: Text(category.name[0]),
              ),
              title: Text(category.name),
              subtitle: Text(category.type),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showAddCategoryDialog(context, ref, category: category),
                  ),
                  if (!isSavings)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        try {
                          await ref.read(categoryProvider.notifier).deleteCategory(category.name);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        }
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
    );
  }
}

Color _getColorForType(String type) {
  switch (type) {
    case 'Need': return Colors.blue;
    case 'Want': return Colors.orange;
    case 'Savings': return Colors.green;
    default: return Colors.grey;
  }
}

void showAddCategoryDialog(BuildContext context, WidgetRef ref, {CategoryModel? category}) {
  final nameController = TextEditingController(text: category?.name ?? '');
  String selectedType = category?.type ?? 'Want';

  final budgetRule = ref.read(budgetRuleProvider); // Get current rules

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Category Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                DropdownMenuItem(value: 'Need', child: Text('Need (${budgetRule.needs.toStringAsFixed(0)}%)')),
                DropdownMenuItem(value: 'Want', child: Text('Want (${budgetRule.wants.toStringAsFixed(0)}%)')),
                DropdownMenuItem(value: 'Savings', child: Text('Savings (${budgetRule.savings.toStringAsFixed(0)}%)')),
              ],
              onChanged: (val) => setState(() => selectedType = val!),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final newCategory = CategoryModel(
                  name: nameController.text,
                  type: selectedType,
                );
                
                try {
                  if (category == null) {
                    await ref.read(categoryProvider.notifier).addCategory(newCategory);
                  } else {
                    await ref.read(categoryProvider.notifier).updateCategory(category.name, newCategory);
                  }
                  if (context.mounted) Navigator.pop(ctx);
                } catch (e) {
                  // Show error snackbar
                   if (context.mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                     );
                   }
                }
              }
            },
            child: Text(category == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    ),
  );
}
