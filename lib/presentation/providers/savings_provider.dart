import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/savings_goal_model.dart';
import '../../data/repositories/savings_repository.dart';

final savingsProvider = StateNotifierProvider<SavingsNotifier, AsyncValue<List<SavingsGoalModel>>>((ref) {
  final repository = ref.watch(savingsRepositoryProvider);
  return SavingsNotifier(repository);
});

class SavingsNotifier extends StateNotifier<AsyncValue<List<SavingsGoalModel>>> {
  final SavingsRepository _repository;

  SavingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadGoals();
  }

  Future<void> loadGoals() async {
    try {
      state = const AsyncValue.loading();
      final goals = await _repository.getGoals();
      state = AsyncValue.data(goals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addGoal(SavingsGoalModel goal) async {
    try {
      await _repository.addGoal(goal);
      await loadGoals();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateGoal(SavingsGoalModel goal) async {
    try {
      await _repository.updateGoal(goal);
      await loadGoals();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteGoal(String id) async {
    try {
      await _repository.deleteGoal(id);
      await loadGoals();
    } catch (e) {
      // Handle error
    }
  }
}
