import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'manage_categories_screen.dart';
import 'category_budget_screen.dart';

class ManageCategoriesAndBudgetsScreen extends StatefulWidget {
  final int initialIndex;
  const ManageCategoriesAndBudgetsScreen({super.key, this.initialIndex = 0});

  @override
  State<ManageCategoriesAndBudgetsScreen> createState() => _ManageCategoriesAndBudgetsScreenState();
}

class _ManageCategoriesAndBudgetsScreenState extends State<ManageCategoriesAndBudgetsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Budgets'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CategoryListWidget(),
          CategoryBudgetListWidget(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? Consumer(
              builder: (context, ref, _) => FloatingActionButton(
                onPressed: () => showAddCategoryDialog(context, ref),
                child: const Icon(Icons.add),
              ),
            )
          : null,
    );
  }
}
