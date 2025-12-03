// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DebtModelImpl _$$DebtModelImplFromJson(Map<String, dynamic> json) =>
    _$DebtModelImpl(
      id: json['id'] as String,
      personName: json['personName'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      description: json['description'] as String?,
      isSettled: json['isSettled'] == null
          ? false
          : const BoolIntConverter().fromJson(
              (json['isSettled'] as num).toInt(),
            ),
    );

Map<String, dynamic> _$$DebtModelImplToJson(_$DebtModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'personName': instance.personName,
      'amount': instance.amount,
      'type': instance.type,
      'date': instance.date.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'description': instance.description,
      'isSettled': const BoolIntConverter().toJson(instance.isSettled),
    };
