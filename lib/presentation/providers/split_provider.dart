import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/split_models.dart';
import '../../data/repositories/split_repository.dart';

final splitGroupsProvider = StateNotifierProvider<SplitGroupsNotifier, AsyncValue<List<SplitGroup>>>((ref) {
  final repository = ref.watch(splitRepositoryProvider);
  return SplitGroupsNotifier(repository);
});

class SplitGroupsNotifier extends StateNotifier<AsyncValue<List<SplitGroup>>> {
  final SplitRepository _repository;

  SplitGroupsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      state = const AsyncValue.loading();
      final groups = await _repository.getGroups();
      state = AsyncValue.data(groups);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createGroup(String name) async {
    try {
      await _repository.createGroup(name);
      await loadGroups();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateGroup(SplitGroup group) async {
    try {
      await _repository.updateGroup(group);
      await loadGroups();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await _repository.deleteGroup(groupId);
      await loadGroups();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addMember(String groupId, String name) async {
    try {
      await _repository.addMember(groupId, name);
      await loadGroups();
    } catch (e) {
      // Handle error
    }
  }
}

final groupDetailsProvider = StateNotifierProvider.family<GroupDetailsNotifier, AsyncValue<GroupDetailsState>, String>((ref, groupId) {
  final repository = ref.watch(splitRepositoryProvider);
  return GroupDetailsNotifier(repository, groupId);
});

class GroupDetailsState {
  final List<GroupMember> members;
  final List<SplitExpense> expenses;
  final Map<String, double> balances;

  GroupDetailsState({
    this.members = const [],
    this.expenses = const [],
    this.balances = const {},
  });
}

class GroupDetailsNotifier extends StateNotifier<AsyncValue<GroupDetailsState>> {
  final SplitRepository _repository;
  final String groupId;

  GroupDetailsNotifier(this._repository, this.groupId) : super(const AsyncValue.loading()) {
    loadDetails();
  }

  Future<void> loadDetails() async {
    try {
      state = const AsyncValue.loading();
      final members = await _repository.getMembers(groupId);
      final expenses = await _repository.getExpenses(groupId);
      final balances = await _repository.getBalances(groupId);
      
      state = AsyncValue.data(GroupDetailsState(
        members: members,
        expenses: expenses,
        balances: balances,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMember(String name) async {
    try {
      await _repository.addMember(groupId, name);
      await loadDetails();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addExpense(SplitExpense expense) async {
    try {
      await _repository.addExpense(expense);
      await loadDetails();
    } catch (e) {
      // Handle error
    }
  }
}
