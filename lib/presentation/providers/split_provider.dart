import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/split_models.dart';
import '../../data/models/contribution_model.dart';
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
  final List<GroupContribution> contributions;
  final List<ActivityLog> activities;
  final double poolBalance;
  final Map<String, double> memberPoolBalances;

  GroupDetailsState({
    this.members = const [],
    this.expenses = const [],
    this.balances = const {},
    this.contributions = const [],
    this.activities = const [],
    this.poolBalance = 0.0,
    this.memberPoolBalances = const {},
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
      final contributions = await _repository.getContributions(groupId);
      final activities = await _repository.getActivities(groupId);
      
      // Calculate Pool Logic
      double totalPool = 0;
      final poolBalances = <String, double>{};
      
      // Initialize valid members in pool map
      for (var m in members) {
        poolBalances[m.id] = 0.0;
      }
      
      // Add contributions
      for (var c in contributions) {
        totalPool += c.amount;
        poolBalances[c.memberId] = (poolBalances[c.memberId] ?? 0) + c.amount;
      }
      
      // Deduct pool expenses
      for (var e in expenses) {
        if (e.isPaidFromPool) {
          totalPool -= e.amount;
          
          if (e.splitWith.isNotEmpty) {
             final share = e.amount / e.splitWith.length;
             for (var uid in e.splitWith) {
               poolBalances[uid] = (poolBalances[uid] ?? 0) - share;
             }
          }
        }
      }

      state = AsyncValue.data(GroupDetailsState(
        members: members,
        expenses: expenses,
        balances: balances,
        contributions: contributions,
        activities: activities,
        poolBalance: totalPool,
        memberPoolBalances: poolBalances,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addContribution(GroupContribution contribution) async {
    try {
      await _repository.addContribution(contribution);
      await loadDetails();
    } catch (e) {
      // Handle error
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

  Future<void> updateMember(GroupMember member) async {
    try {
      await _repository.updateMember(member);
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

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _repository.deleteExpense(expenseId);
      await loadDetails();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteMember(String memberId) async {
    try {
      await _repository.deleteMember(memberId);
      await loadDetails();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteContribution(String contributionId) async {
    try {
      await _repository.deleteContribution(contributionId);
      await loadDetails();
    } catch (e) {
      // Handle error
    }
  }
}
