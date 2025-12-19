import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/split_models.dart';
import '../models/contribution_model.dart';

final splitRepositoryProvider = Provider<SplitRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return SplitRepository(dbService);
});

class SplitRepository {
  final DatabaseService _dbService;

  SplitRepository(this._dbService);

  Future<List<SplitGroup>> getGroups() async {
    final db = await _dbService.database;
    final maps = await db.query('groups', orderBy: 'created_at DESC');
    return maps.map((e) => SplitGroup.fromJson(e)).toList();
  }

  Future<SplitGroup> createGroup(String name) async {
    final db = await _dbService.database;
    final group = SplitGroup(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    await db.insert('groups', group.toJson());
    return group;

  }

  Future<void> updateGroup(SplitGroup group) async {
    final db = await _dbService.database;
    await db.update(
      'groups',
      group.toJson(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<void> deleteGroup(String groupId) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      // Delete shares first (foreign key constraint might handle this, but safer to be explicit)
      // We need to find all expenses for this group to delete their shares
      final expenses = await txn.query('split_expenses', where: 'group_id = ?', whereArgs: [groupId]);
      for (var expense in expenses) {
        await txn.delete('expense_shares', where: 'expense_id = ?', whereArgs: [expense['id']]);
      }
      
      await txn.delete('split_expenses', where: 'group_id = ?', whereArgs: [groupId]);
      await txn.delete('group_members', where: 'group_id = ?', whereArgs: [groupId]);
      await txn.delete('groups', where: 'id = ?', whereArgs: [groupId]);
    });
  }

  Future<void> addMember(String groupId, String name) async {
    final db = await _dbService.database;
    final member = GroupMember(
      id: const Uuid().v4(),
      groupId: groupId,
      name: name,
    );
    await db.insert('group_members', member.toJson());
    await logActivity(groupId, 'Added member ${name}', 'User');
  }

  Future<List<GroupMember>> getMembers(String groupId) async {
    final db = await _dbService.database;
    final maps = await db.query('group_members', where: 'group_id = ?', whereArgs: [groupId]);
    return maps.map((e) => GroupMember.fromJson(e)).toList();
  }

  Future<void> updateMember(GroupMember member) async {
    final db = await _dbService.database;
    await db.update(
      'group_members',
      member.toJson(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }



  Future<void> addExpense(SplitExpense expense) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      await txn.insert('split_expenses', {
        'id': expense.id,
        'group_id': expense.groupId,
        'title': expense.title,
        'amount': expense.amount,
        'paid_by_member_id': expense.paidByMemberId,
        'date': expense.date.toIso8601String(),
        'is_paid_from_pool': expense.isPaidFromPool ? 1 : 0,
        'type': expense.type,
      });

      if (expense.splitWith.isNotEmpty) {
        final shareAmount = expense.amount / expense.splitWith.length;
        for (final memberId in expense.splitWith) {
          await txn.insert('expense_shares', {
            'id': const Uuid().v4(),
            'expense_id': expense.id,
            'member_id': memberId,
            'amount': shareAmount,
          });
        }
      }
    });

    final typeStr = expense.type == 'SETTLEMENT' ? 'Settled' : 'Added expense';
    await logActivity(expense.groupId, '$typeStr: ${expense.title} (₹${expense.amount.toInt()})', 'User');
  }

  Future<List<SplitExpense>> getExpenses(String groupId) async {
    final db = await _dbService.database;
    final maps = await db.query('split_expenses', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'date DESC');
    
    final expenses = <SplitExpense>[];
    for (var map in maps) {
      final expenseId = map['id'] as String;
      final shares = await db.query('expense_shares', where: 'expense_id = ?', whereArgs: [expenseId]);
      final splitWith = shares.map((s) => s['member_id'] as String).toList();
      
      final expenseMap = Map<String, dynamic>.from(map);
      expenseMap['split_with'] = splitWith;
      expenseMap['is_paid_from_pool'] = (map['is_paid_from_pool'] as int?) == 1;
      expenseMap['type'] = map['type'] ?? 'EXPENSE';
      
      expenses.add(SplitExpense.fromJson(expenseMap));
    }
    return expenses;
  }

  Future<List<GroupContribution>> getContributions(String groupId) async {
    final db = await _dbService.database;
    final maps = await db.query('group_contributions', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'date DESC');
    return maps.map((e) => GroupContribution.fromJson(e)).toList();
  }

  Future<void> addContribution(GroupContribution contribution) async {
    final db = await _dbService.database;
    await db.insert('group_contributions', contribution.toJson());
  }

  Future<Map<String, double>> getBalances(String groupId) async {
    final db = await _dbService.database;
    final members = await getMembers(groupId);
    final expenses = await getExpenses(groupId);
    
    // This calculates DIRECT DEBT balances (ignoring pool expenses for settlement logic, maybe?)
    // Actually, if paid from pool, we shouldn't calculate "Owes Payer" relative to a person.
    // If paid from pool, the "Payer" is the Pool. Everyone owes the Pool. 
    // But since they "own" the pool, it effectively reduces their pool share.
    
    final balances = <String, double>{};
    for (var member in members) {
      balances[member.id] = 0.0;
    }

    for (var expense in expenses) {
      if (expense.isPaidFromPool) continue; // Skip pool expenses for direct settlements

      // Payer gets positive balance
      balances[expense.paidByMemberId] = (balances[expense.paidByMemberId] ?? 0) + expense.amount;

      if (expense.splitWith.isNotEmpty) {
        final share = expense.amount / expense.splitWith.length;
        for (var memberId in expense.splitWith) {
          balances[memberId] = (balances[memberId] ?? 0) - share;
        }
      }
    }

    return balances;
  }


  Future<void> deleteExpense(String expenseId) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      await txn.delete('expense_shares', where: 'expense_id = ?', whereArgs: [expenseId]);
      await txn.delete('split_expenses', where: 'id = ?', whereArgs: [expenseId]);
    });
  }

  Future<void> deleteMember(String memberId) async {
    final db = await _dbService.database;
    await db.transaction((txn) async {
      // Logic: If member is deleted, what happens to expenses?
      // 1. Delete their contributions
      await txn.delete('group_contributions', where: 'member_id = ?', whereArgs: [memberId]);
      
      // 2. Delete shares they are part of
      await txn.delete('expense_shares', where: 'member_id = ?', whereArgs: [memberId]);
      
      // 3. For expenses PAID by this member, we might need to delete the expense or reassign.
      // For now, simpler to delete expenses paid by them to avoid corrupt state.
      // Alternatively, block deletion if they have paid expenses.
      // Let's cascade delete expenses paid by them (Standard behavior for simple apps)
      final paidExpenses = await txn.query('split_expenses', where: 'paid_by_member_id = ?', whereArgs: [memberId]);
      for (var e in paidExpenses) {
        final eId = e['id'] as String;
        await txn.delete('expense_shares', where: 'expense_id = ?', whereArgs: [eId]);
        await txn.delete('split_expenses', where: 'id = ?', whereArgs: [eId]);
      }

      // 4. Finally delete member
      await txn.delete('group_members', where: 'id = ?', whereArgs: [memberId]);
    });
  }

  Future<void> deleteContribution(String contributionId) async {
    final db = await _dbService.database;
    await db.delete('group_contributions', where: 'id = ?', whereArgs: [contributionId]);
  }
  Future<void> logActivity(String groupId, String description, String userName) async {
    final db = await _dbService.database;
    final activity = ActivityLog(
      id: const Uuid().v4(),
      groupId: groupId,
      description: description,
      timestamp: DateTime.now(),
      userName: userName,
    );
    await db.insert('group_activities', activity.toJson());
  }

  Future<List<ActivityLog>> getActivities(String groupId) async {
    final db = await _dbService.database;
    final maps = await db.query('group_activities', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'timestamp DESC');
    return maps.map((e) => ActivityLog.fromJson(e)).toList();
  }
}
