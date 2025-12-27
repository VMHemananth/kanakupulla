import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/models/budget_rule_model.dart';

class BudgetRuleNotifier extends StateNotifier<BudgetRuleModel> {
  final SettingsRepository _settingsRepository;

  BudgetRuleNotifier(this._settingsRepository) : super(BudgetRuleModel.defaultRule()) {
    _loadRule();
  }

  void _loadRule() {
    state = _settingsRepository.getBudgetRule();
  }

  Future<void> updateRule(double needs, double wants, double savings) async {
    final newRule = BudgetRuleModel(needs: needs, wants: wants, savings: savings);
    state = newRule;
    await _settingsRepository.saveBudgetRule(newRule);
  }

  Future<void> resetToDefault() async {
    final defaultRule = BudgetRuleModel.defaultRule();
    state = defaultRule;
    await _settingsRepository.saveBudgetRule(defaultRule);
  }
}

final budgetRuleProvider = StateNotifierProvider<BudgetRuleNotifier, BudgetRuleModel>((ref) {
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return BudgetRuleNotifier(settingsRepo);
});
