// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CreditCardModelImpl _$$CreditCardModelImplFromJson(
  Map<String, dynamic> json,
) => _$CreditCardModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  billingDay: (json['billingDay'] as num).toInt(),
  lastBillGeneratedMonth: json['lastBillGeneratedMonth'] as String?,
);

Map<String, dynamic> _$$CreditCardModelImplToJson(
  _$CreditCardModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'billingDay': instance.billingDay,
  'lastBillGeneratedMonth': instance.lastBillGeneratedMonth,
};
