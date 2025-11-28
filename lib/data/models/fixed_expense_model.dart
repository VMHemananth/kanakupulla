import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/converters.dart';

part 'fixed_expense_model.freezed.dart';
part 'fixed_expense_model.g.dart';

@freezed
class FixedExpenseModel with _$FixedExpenseModel {
  const factory FixedExpenseModel({
    required String id,
    required String title,
    required double amount,
    required String category,
    @Default(1) int dayOfMonth, // 1-31
    @BoolIntConverter() @Default(false) bool isAutoAdd, // For future automation
  }) = _FixedExpenseModel;

  factory FixedExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$FixedExpenseModelFromJson(json);
}
