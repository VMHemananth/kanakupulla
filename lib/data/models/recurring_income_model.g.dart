// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_income_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecurringIncomeModelImpl _$$RecurringIncomeModelImplFromJson(
  Map<String, dynamic> json,
) => _$RecurringIncomeModelImpl(
  id: json['id'] as String,
  source: json['source'] as String,
  amount: (json['amount'] as num).toDouble(),
  dayOfMonth: (json['dayOfMonth'] as num).toInt(),
  isAutoAdd: json['isAutoAdd'] == null
      ? true
      : const BoolIntConverter().fromJson((json['isAutoAdd'] as num).toInt()),
);

Map<String, dynamic> _$$RecurringIncomeModelImplToJson(
  _$RecurringIncomeModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'source': instance.source,
  'amount': instance.amount,
  'dayOfMonth': instance.dayOfMonth,
  'isAutoAdd': const BoolIntConverter().toJson(instance.isAutoAdd),
};
