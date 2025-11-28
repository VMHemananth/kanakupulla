import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String name,
    required String email,
    required List<String> categories,
    @Default(22) int workingDaysPerMonth,
    @Default(8) int workingHoursPerDay,
    String? profilePicPath,
    String? phoneNumber,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}
