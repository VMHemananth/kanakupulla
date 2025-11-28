import 'package:freezed_annotation/freezed_annotation.dart';

part 'salary_model.freezed.dart';
part 'salary_model.g.dart';

@freezed
class SalaryModel with _$SalaryModel {
  const factory SalaryModel({
    required String id,
    required double amount,
    required DateTime date,
    @Default('Salary') String source,
    String? title,
  }) = _SalaryModel;

  factory SalaryModel.fromJson(Map<String, dynamic> json) =>
      _$SalaryModelFromJson(json);
}
