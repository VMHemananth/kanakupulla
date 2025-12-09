// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoanPaymentImpl _$$LoanPaymentImplFromJson(Map<String, dynamic> json) =>
    _$LoanPaymentImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      principalComponent: (json['principalComponent'] as num).toDouble(),
      interestComponent: (json['interestComponent'] as num).toDouble(),
      isPartPayment: json['isPartPayment'] as bool? ?? false,
    );

Map<String, dynamic> _$$LoanPaymentImplToJson(_$LoanPaymentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'principalComponent': instance.principalComponent,
      'interestComponent': instance.interestComponent,
      'isPartPayment': instance.isPartPayment,
    };

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
      roi: (json['roi'] as num?)?.toDouble() ?? 0.0,
      interestType: json['interestType'] as String? ?? 'Fixed',
      tenureMonths: (json['tenureMonths'] as num?)?.toInt() ?? 0,
      principalAmount: (json['principalAmount'] as num?)?.toDouble() ?? 0.0,
      payments:
          (json['payments'] as List<dynamic>?)
              ?.map((e) => LoanPayment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
      'roi': instance.roi,
      'interestType': instance.interestType,
      'tenureMonths': instance.tenureMonths,
      'principalAmount': instance.principalAmount,
      'payments': instance.payments,
    };
