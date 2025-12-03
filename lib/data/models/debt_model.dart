import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/converters.dart';

part 'debt_model.freezed.dart';
part 'debt_model.g.dart';

@freezed
class DebtModel with _$DebtModel {
  const factory DebtModel({
    required String id,
    required String personName,
    required double amount,
    required String type, // 'Lent' or 'Borrowed'
    required DateTime date,
    DateTime? dueDate,
    String? description,
    @BoolIntConverter() @Default(false) bool isSettled,
  }) = _DebtModel;

  factory DebtModel.fromJson(Map<String, dynamic> json) =>
      _$DebtModelFromJson(json);
}
