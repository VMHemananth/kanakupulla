// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SplitGroupImpl _$$SplitGroupImplFromJson(Map<String, dynamic> json) =>
    _$SplitGroupImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SplitGroupImplToJson(_$SplitGroupImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$GroupMemberImpl _$$GroupMemberImplFromJson(Map<String, dynamic> json) =>
    _$GroupMemberImpl(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$$GroupMemberImplToJson(_$GroupMemberImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'name': instance.name,
    };

_$SplitExpenseImpl _$$SplitExpenseImplFromJson(Map<String, dynamic> json) =>
    _$SplitExpenseImpl(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidByMemberId: json['paid_by_member_id'] as String,
      date: DateTime.parse(json['date'] as String),
      splitWith:
          (json['split_with'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isPaidFromPool: json['is_paid_from_pool'] as bool? ?? false,
      type: json['type'] as String? ?? 'EXPENSE',
    );

Map<String, dynamic> _$$SplitExpenseImplToJson(_$SplitExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'title': instance.title,
      'amount': instance.amount,
      'paid_by_member_id': instance.paidByMemberId,
      'date': instance.date.toIso8601String(),
      'split_with': instance.splitWith,
      'is_paid_from_pool': instance.isPaidFromPool,
      'type': instance.type,
    };

_$ActivityLogImpl _$$ActivityLogImplFromJson(Map<String, dynamic> json) =>
    _$ActivityLogImpl(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userName: json['user_name'] as String,
    );

Map<String, dynamic> _$$ActivityLogImplToJson(_$ActivityLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'description': instance.description,
      'timestamp': instance.timestamp.toIso8601String(),
      'user_name': instance.userName,
    };
