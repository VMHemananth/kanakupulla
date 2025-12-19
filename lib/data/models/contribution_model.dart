import 'package:freezed_annotation/freezed_annotation.dart';

part 'contribution_model.freezed.dart';
part 'contribution_model.g.dart';

@freezed
class GroupContribution with _$GroupContribution {
  const factory GroupContribution({
    required String id,
    @JsonKey(name: 'group_id') required String groupId,
    @JsonKey(name: 'member_id') required String memberId,
    required double amount,
    required DateTime date,
  }) = _GroupContribution;

  factory GroupContribution.fromJson(Map<String, dynamic> json) => _$GroupContributionFromJson(json);
}
