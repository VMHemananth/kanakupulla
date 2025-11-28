// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FixedExpenseModelImpl _$$FixedExpenseModelImplFromJson(
  Map<String, dynamic> json,
) => _$FixedExpenseModelImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  amount: (json['amount'] as num).toDouble(),
  category: json['category'] as String,
  dayOfMonth: (json['dayOfMonth'] as num?)?.toInt() ?? 1,
  isAutoAdd: json['isAutoAdd'] == null
      ? false
      : const BoolIntConverter().fromJson((json['isAutoAdd'] as num).toInt()),
);

Map<String, dynamic> _$$FixedExpenseModelImplToJson(
  _$FixedExpenseModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'amount': instance.amount,
  'category': instance.category,
  'dayOfMonth': instance.dayOfMonth,
  'isAutoAdd': const BoolIntConverter().toJson(instance.isAutoAdd),
};
