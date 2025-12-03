import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/split_models.dart';

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
  }

  Future<List<GroupMember>> getMembers(String groupId) async {
    final db = await _dbService.database;
    final maps = await db.query('group_members', where: 'group_id = ?', whereArgs: [groupId]);
    return maps.map((e) => GroupMember.fromJson(e)).toList();
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
  }

  Future<List<SplitExpense>> getExpenses(String groupId) async {
    final db = await _dbService.database;
    final maps = await db.query('split_expenses', where: 'group_id = ?', whereArgs: [groupId], orderBy: 'date DESC');
    
    final expenses = <SplitExpense>[];
    for (var map in maps) {
      final expenseId = map['id'] as String;
      final shares = await db.query('expense_shares', where: 'expense_id = ?', whereArgs: [expenseId]);
      final splitWith = shares.map((s) => s['member_id'] as String).toList();
      
      // Create a mutable map to add split_with
      final expenseMap = Map<String, dynamic>.from(map);
      expenseMap['split_with'] = splitWith;
      
      expenses.add(SplitExpense.fromJson(expenseMap));
    }
    return expenses;
  }

  Future<Map<String, double>> getBalances(String groupId) async {
    final db = await _dbService.database;
    final members = await getMembers(groupId);
    final expenses = await getExpenses(groupId);

    final balances = <String, double>{};
    for (var member in members) {
      balances[member.id] = 0.0;
    }

    for (var expense in expenses) {
      // Payer gets positive balance
      balances[expense.paidByMemberId] = (balances[expense.paidByMemberId] ?? 0) + expense.amount;

      if (expense.splitWith.isNotEmpty) {
        // New logic: split among specific members
        final share = expense.amount / expense.splitWith.length;
        for (var memberId in expense.splitWith) {
          balances[memberId] = (balances[memberId] ?? 0) - share;
        }
      } else {
        // Legacy logic: split equally among all members
        if (members.isNotEmpty) {
          final share = expense.amount / members.length;
          for (var member in members) {
            balances[member.id] = (balances[member.id] ?? 0) - share;
          }
        }
      }
    }

    return balances;
  }
}
