import 'package:freezed_annotation/freezed_annotation.dart';

part 'split_models.freezed.dart';
part 'split_models.g.dart';

@freezed
class SplitGroup with _$SplitGroup {
  const factory SplitGroup({
    required String id,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SplitGroup;

  factory SplitGroup.fromJson(Map<String, dynamic> json) => _$SplitGroupFromJson(json);
}

@freezed
class GroupMember with _$GroupMember {
  const factory GroupMember({
    required String id,
    @JsonKey(name: 'group_id') required String groupId,
    required String name,
  }) = _GroupMember;

  factory GroupMember.fromJson(Map<String, dynamic> json) => _$GroupMemberFromJson(json);
}

@freezed
class SplitExpense with _$SplitExpense {
  const factory SplitExpense({
    required String id,
    @JsonKey(name: 'group_id') required String groupId,
    required String title,
    required double amount,
    @JsonKey(name: 'paid_by_member_id') required String paidByMemberId,
    required DateTime date,
    @Default([]) @JsonKey(name: 'split_with') List<String> splitWith,
    @Default(false) @JsonKey(name: 'is_paid_from_pool') bool isPaidFromPool,
    @Default('EXPENSE') String type, // 'EXPENSE' or 'SETTLEMENT'
  }) = _SplitExpense;

  factory SplitExpense.fromJson(Map<String, dynamic> json) => _$SplitExpenseFromJson(json);
}

@freezed
class ActivityLog with _$ActivityLog {
  const factory ActivityLog({
    required String id,
    @JsonKey(name: 'group_id') required String groupId,
    required String description,
    required DateTime timestamp,
    @JsonKey(name: 'user_name') required String userName,
  }) = _ActivityLog;

  factory ActivityLog.fromJson(Map<String, dynamic> json) => _$ActivityLogFromJson(json);
}
