import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_card_model.freezed.dart';
part 'credit_card_model.g.dart';

@freezed
class CreditCardModel with _$CreditCardModel {
  const factory CreditCardModel({
    required String id,
    required String name,
    required int billingDay, // 1-31
    String? lastBillGeneratedMonth, // Format: "YYYY-MM"
  }) = _CreditCardModel;

  factory CreditCardModel.fromJson(Map<String, dynamic> json) =>
      _$CreditCardModelFromJson(json);
}
