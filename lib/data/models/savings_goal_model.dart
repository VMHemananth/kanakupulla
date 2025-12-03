import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal_model.freezed.dart';
part 'savings_goal_model.g.dart';

@freezed
class SavingsGoalModel with _$SavingsGoalModel {
  const factory SavingsGoalModel({
    required String id,
    required String name,
    required double targetAmount,
    required double currentAmount,
    DateTime? deadline,
    String? icon, // Store icon code point or name if needed
    int? color, // Store color value
  }) = _SavingsGoalModel;

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalModelFromJson(json);
}
