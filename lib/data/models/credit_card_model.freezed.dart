// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CreditCardModel _$CreditCardModelFromJson(Map<String, dynamic> json) {
  return _CreditCardModel.fromJson(json);
}

/// @nodoc
mixin _$CreditCardModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get billingDay => throw _privateConstructorUsedError; // 1-31
  String? get lastBillGeneratedMonth => throw _privateConstructorUsedError;

  /// Serializes this CreditCardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreditCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditCardModelCopyWith<CreditCardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditCardModelCopyWith<$Res> {
  factory $CreditCardModelCopyWith(
    CreditCardModel value,
    $Res Function(CreditCardModel) then,
  ) = _$CreditCardModelCopyWithImpl<$Res, CreditCardModel>;
  @useResult
  $Res call({
    String id,
    String name,
    int billingDay,
    String? lastBillGeneratedMonth,
  });
}

/// @nodoc
class _$CreditCardModelCopyWithImpl<$Res, $Val extends CreditCardModel>
    implements $CreditCardModelCopyWith<$Res> {
  _$CreditCardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreditCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? billingDay = null,
    Object? lastBillGeneratedMonth = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            billingDay: null == billingDay
                ? _value.billingDay
                : billingDay // ignore: cast_nullable_to_non_nullable
                      as int,
            lastBillGeneratedMonth: freezed == lastBillGeneratedMonth
                ? _value.lastBillGeneratedMonth
                : lastBillGeneratedMonth // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditCardModelImplCopyWith<$Res>
    implements $CreditCardModelCopyWith<$Res> {
  factory _$$CreditCardModelImplCopyWith(
    _$CreditCardModelImpl value,
    $Res Function(_$CreditCardModelImpl) then,
  ) = __$$CreditCardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    int billingDay,
    String? lastBillGeneratedMonth,
  });
}

/// @nodoc
class __$$CreditCardModelImplCopyWithImpl<$Res>
    extends _$CreditCardModelCopyWithImpl<$Res, _$CreditCardModelImpl>
    implements _$$CreditCardModelImplCopyWith<$Res> {
  __$$CreditCardModelImplCopyWithImpl(
    _$CreditCardModelImpl _value,
    $Res Function(_$CreditCardModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreditCardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? billingDay = null,
    Object? lastBillGeneratedMonth = freezed,
  }) {
    return _then(
      _$CreditCardModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        billingDay: null == billingDay
            ? _value.billingDay
            : billingDay // ignore: cast_nullable_to_non_nullable
                  as int,
        lastBillGeneratedMonth: freezed == lastBillGeneratedMonth
            ? _value.lastBillGeneratedMonth
            : lastBillGeneratedMonth // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditCardModelImpl implements _CreditCardModel {
  const _$CreditCardModelImpl({
    required this.id,
    required this.name,
    required this.billingDay,
    this.lastBillGeneratedMonth,
  });

  factory _$CreditCardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditCardModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int billingDay;
  // 1-31
  @override
  final String? lastBillGeneratedMonth;

  @override
  String toString() {
    return 'CreditCardModel(id: $id, name: $name, billingDay: $billingDay, lastBillGeneratedMonth: $lastBillGeneratedMonth)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditCardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.billingDay, billingDay) ||
                other.billingDay == billingDay) &&
            (identical(other.lastBillGeneratedMonth, lastBillGeneratedMonth) ||
                other.lastBillGeneratedMonth == lastBillGeneratedMonth));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, billingDay, lastBillGeneratedMonth);

  /// Create a copy of CreditCardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditCardModelImplCopyWith<_$CreditCardModelImpl> get copyWith =>
      __$$CreditCardModelImplCopyWithImpl<_$CreditCardModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditCardModelImplToJson(this);
  }
}

abstract class _CreditCardModel implements CreditCardModel {
  const factory _CreditCardModel({
    required final String id,
    required final String name,
    required final int billingDay,
    final String? lastBillGeneratedMonth,
  }) = _$CreditCardModelImpl;

  factory _CreditCardModel.fromJson(Map<String, dynamic> json) =
      _$CreditCardModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get billingDay; // 1-31
  @override
  String? get lastBillGeneratedMonth;

  /// Create a copy of CreditCardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditCardModelImplCopyWith<_$CreditCardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
