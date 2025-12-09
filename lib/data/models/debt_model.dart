import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/converters.dart';

part 'debt_model.freezed.dart';
part 'debt_model.g.dart';

@freezed
class LoanPayment with _$LoanPayment {
  const factory LoanPayment({
    required String id,
    required double amount,
    required DateTime date,
    required double principalComponent,
    required double interestComponent,
    @Default(false) bool isPartPayment,
  }) = _LoanPayment;

  factory LoanPayment.fromJson(Map<String, dynamic> json) =>
      _$LoanPaymentFromJson(json);
}

@freezed
class DebtModel with _$DebtModel {
  const factory DebtModel({
    required String id,
    required String personName,
    required double amount, // Current Outstanding Amount
    required String type, // 'Lent' or 'Borrowed'
    required DateTime date,
    DateTime? dueDate,
    String? description,
    @BoolIntConverter() @Default(false) bool isSettled,
    
    // Loan Specific Fields
    @Default(0.0) double roi,
    @Default('Fixed') String interestType, // 'Fixed' or 'Floating'
    @Default(0) int tenureMonths,
    @Default(0.0) double principalAmount, // Original Loan Amount
    @Default([]) List<LoanPayment> payments,
  }) = _DebtModel;

  factory DebtModel.fromJson(Map<String, dynamic> json) =>
      _$DebtModelFromJson(json);
}
