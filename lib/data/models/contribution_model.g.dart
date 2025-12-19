// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupContributionImpl _$$GroupContributionImplFromJson(
  Map<String, dynamic> json,
) => _$GroupContributionImpl(
  id: json['id'] as String,
  groupId: json['group_id'] as String,
  memberId: json['member_id'] as String,
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$$GroupContributionImplToJson(
  _$GroupContributionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'group_id': instance.groupId,
  'member_id': instance.memberId,
  'amount': instance.amount,
  'date': instance.date.toIso8601String(),
};
