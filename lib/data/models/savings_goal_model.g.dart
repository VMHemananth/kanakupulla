// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_goal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SavingsGoalModelImpl _$$SavingsGoalModelImplFromJson(
  Map<String, dynamic> json,
) => _$SavingsGoalModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  targetAmount: (json['targetAmount'] as num).toDouble(),
  currentAmount: (json['currentAmount'] as num).toDouble(),
  deadline: json['deadline'] == null
      ? null
      : DateTime.parse(json['deadline'] as String),
  icon: json['icon'] as String?,
  color: (json['color'] as num?)?.toInt(),
);

Map<String, dynamic> _$$SavingsGoalModelImplToJson(
  _$SavingsGoalModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'targetAmount': instance.targetAmount,
  'currentAmount': instance.currentAmount,
  'deadline': instance.deadline?.toIso8601String(),
  'icon': instance.icon,
  'color': instance.color,
};
