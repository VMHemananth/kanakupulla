import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_model.freezed.dart';
part 'expense_model.g.dart';

@freezed
class ExpenseModel with _$ExpenseModel {
  const factory ExpenseModel({
    required String id,
    required String title,
    required double amount,
    required DateTime date,
    required String category,
    String? paymentMethod,
    String? creditCardId,
    @Default(false) bool isCreditCardBill,
    String? savingsGoalId,
    @Default(true) bool isNeed,
  }) = _ExpenseModel;

  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);
}
