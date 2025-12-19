// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'contribution_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GroupContribution _$GroupContributionFromJson(Map<String, dynamic> json) {
  return _GroupContribution.fromJson(json);
}

/// @nodoc
mixin _$GroupContribution {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_id')
  String get groupId => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_id')
  String get memberId => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;

  /// Serializes this GroupContribution to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupContribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupContributionCopyWith<GroupContribution> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupContributionCopyWith<$Res> {
  factory $GroupContributionCopyWith(
    GroupContribution value,
    $Res Function(GroupContribution) then,
  ) = _$GroupContributionCopyWithImpl<$Res, GroupContribution>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'group_id') String groupId,
    @JsonKey(name: 'member_id') String memberId,
    double amount,
    DateTime date,
  });
}

/// @nodoc
class _$GroupContributionCopyWithImpl<$Res, $Val extends GroupContribution>
    implements $GroupContributionCopyWith<$Res> {
  _$GroupContributionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupContribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? memberId = null,
    Object? amount = null,
    Object? date = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            groupId: null == groupId
                ? _value.groupId
                : groupId // ignore: cast_nullable_to_non_nullable
                      as String,
            memberId: null == memberId
                ? _value.memberId
                : memberId // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupContributionImplCopyWith<$Res>
    implements $GroupContributionCopyWith<$Res> {
  factory _$$GroupContributionImplCopyWith(
    _$GroupContributionImpl value,
    $Res Function(_$GroupContributionImpl) then,
  ) = __$$GroupContributionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'group_id') String groupId,
    @JsonKey(name: 'member_id') String memberId,
    double amount,
    DateTime date,
  });
}

/// @nodoc
class __$$GroupContributionImplCopyWithImpl<$Res>
    extends _$GroupContributionCopyWithImpl<$Res, _$GroupContributionImpl>
    implements _$$GroupContributionImplCopyWith<$Res> {
  __$$GroupContributionImplCopyWithImpl(
    _$GroupContributionImpl _value,
    $Res Function(_$GroupContributionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupContribution
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? memberId = null,
    Object? amount = null,
    Object? date = null,
  }) {
    return _then(
      _$GroupContributionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        memberId: null == memberId
            ? _value.memberId
            : memberId // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupContributionImpl implements _GroupContribution {
  const _$GroupContributionImpl({
    required this.id,
    @JsonKey(name: 'group_id') required this.groupId,
    @JsonKey(name: 'member_id') required this.memberId,
    required this.amount,
    required this.date,
  });

  factory _$GroupContributionImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupContributionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'group_id')
  final String groupId;
  @override
  @JsonKey(name: 'member_id')
  final String memberId;
  @override
  final double amount;
  @override
  final DateTime date;

  @override
  String toString() {
    return 'GroupContribution(id: $id, groupId: $groupId, memberId: $memberId, amount: $amount, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupContributionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, groupId, memberId, amount, date);

  /// Create a copy of GroupContribution
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupContributionImplCopyWith<_$GroupContributionImpl> get copyWith =>
      __$$GroupContributionImplCopyWithImpl<_$GroupContributionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupContributionImplToJson(this);
  }
}

abstract class _GroupContribution implements GroupContribution {
  const factory _GroupContribution({
    required final String id,
    @JsonKey(name: 'group_id') required final String groupId,
    @JsonKey(name: 'member_id') required final String memberId,
    required final double amount,
    required final DateTime date,
  }) = _$GroupContributionImpl;

  factory _GroupContribution.fromJson(Map<String, dynamic> json) =
      _$GroupContributionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'group_id')
  String get groupId;
  @override
  @JsonKey(name: 'member_id')
  String get memberId;
  @override
  double get amount;
  @override
  DateTime get date;

  /// Create a copy of GroupContribution
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupContributionImplCopyWith<_$GroupContributionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
