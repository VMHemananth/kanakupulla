// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SalaryModelImpl _$$SalaryModelImplFromJson(Map<String, dynamic> json) =>
    _$SalaryModelImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      source: json['source'] as String? ?? 'Salary',
      title: json['title'] as String?,
      workingDays: (json['workingDays'] as num?)?.toInt(),
      workingHours: (json['workingHours'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SalaryModelImplToJson(_$SalaryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'source': instance.source,
      'title': instance.title,
      'workingDays': instance.workingDays,
      'workingHours': instance.workingHours,
    };
