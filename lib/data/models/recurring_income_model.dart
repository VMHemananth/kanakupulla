import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/converters.dart';

part 'recurring_income_model.freezed.dart';
part 'recurring_income_model.g.dart';

@freezed
class RecurringIncomeModel with _$RecurringIncomeModel {
  const factory RecurringIncomeModel({
    required String id,
    required String source,
    required double amount,
    required int dayOfMonth,
    @BoolIntConverter() @Default(true) bool isAutoAdd,
  }) = _RecurringIncomeModel;

  factory RecurringIncomeModel.fromJson(Map<String, dynamic> json) =>
      _$RecurringIncomeModelFromJson(json);
}
