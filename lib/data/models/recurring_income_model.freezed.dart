// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recurring_income_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RecurringIncomeModel _$RecurringIncomeModelFromJson(Map<String, dynamic> json) {
  return _RecurringIncomeModel.fromJson(json);
}

/// @nodoc
mixin _$RecurringIncomeModel {
  String get id => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  int get dayOfMonth => throw _privateConstructorUsedError;
  @BoolIntConverter()
  bool get isAutoAdd => throw _privateConstructorUsedError;

  /// Serializes this RecurringIncomeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecurringIncomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecurringIncomeModelCopyWith<RecurringIncomeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecurringIncomeModelCopyWith<$Res> {
  factory $RecurringIncomeModelCopyWith(
    RecurringIncomeModel value,
    $Res Function(RecurringIncomeModel) then,
  ) = _$RecurringIncomeModelCopyWithImpl<$Res, RecurringIncomeModel>;
  @useResult
  $Res call({
    String id,
    String source,
    double amount,
    int dayOfMonth,
    @BoolIntConverter() bool isAutoAdd,
  });
}

/// @nodoc
class _$RecurringIncomeModelCopyWithImpl<
  $Res,
  $Val extends RecurringIncomeModel
>
    implements $RecurringIncomeModelCopyWith<$Res> {
  _$RecurringIncomeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecurringIncomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? amount = null,
    Object? dayOfMonth = null,
    Object? isAutoAdd = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            dayOfMonth: null == dayOfMonth
                ? _value.dayOfMonth
                : dayOfMonth // ignore: cast_nullable_to_non_nullable
                      as int,
            isAutoAdd: null == isAutoAdd
                ? _value.isAutoAdd
                : isAutoAdd // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecurringIncomeModelImplCopyWith<$Res>
    implements $RecurringIncomeModelCopyWith<$Res> {
  factory _$$RecurringIncomeModelImplCopyWith(
    _$RecurringIncomeModelImpl value,
    $Res Function(_$RecurringIncomeModelImpl) then,
  ) = __$$RecurringIncomeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String source,
    double amount,
    int dayOfMonth,
    @BoolIntConverter() bool isAutoAdd,
  });
}

/// @nodoc
class __$$RecurringIncomeModelImplCopyWithImpl<$Res>
    extends _$RecurringIncomeModelCopyWithImpl<$Res, _$RecurringIncomeModelImpl>
    implements _$$RecurringIncomeModelImplCopyWith<$Res> {
  __$$RecurringIncomeModelImplCopyWithImpl(
    _$RecurringIncomeModelImpl _value,
    $Res Function(_$RecurringIncomeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecurringIncomeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? source = null,
    Object? amount = null,
    Object? dayOfMonth = null,
    Object? isAutoAdd = null,
  }) {
    return _then(
      _$RecurringIncomeModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        dayOfMonth: null == dayOfMonth
            ? _value.dayOfMonth
            : dayOfMonth // ignore: cast_nullable_to_non_nullable
                  as int,
        isAutoAdd: null == isAutoAdd
            ? _value.isAutoAdd
            : isAutoAdd // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RecurringIncomeModelImpl implements _RecurringIncomeModel {
  const _$RecurringIncomeModelImpl({
    required this.id,
    required this.source,
    required this.amount,
    required this.dayOfMonth,
    @BoolIntConverter() this.isAutoAdd = true,
  });

  factory _$RecurringIncomeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecurringIncomeModelImplFromJson(json);

  @override
  final String id;
  @override
  final String source;
  @override
  final double amount;
  @override
  final int dayOfMonth;
  @override
  @JsonKey()
  @BoolIntConverter()
  final bool isAutoAdd;

  @override
  String toString() {
    return 'RecurringIncomeModel(id: $id, source: $source, amount: $amount, dayOfMonth: $dayOfMonth, isAutoAdd: $isAutoAdd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecurringIncomeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.isAutoAdd, isAutoAdd) ||
                other.isAutoAdd == isAutoAdd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, source, amount, dayOfMonth, isAutoAdd);

  /// Create a copy of RecurringIncomeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecurringIncomeModelImplCopyWith<_$RecurringIncomeModelImpl>
  get copyWith =>
      __$$RecurringIncomeModelImplCopyWithImpl<_$RecurringIncomeModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RecurringIncomeModelImplToJson(this);
  }
}

abstract class _RecurringIncomeModel implements RecurringIncomeModel {
  const factory _RecurringIncomeModel({
    required final String id,
    required final String source,
    required final double amount,
    required final int dayOfMonth,
    @BoolIntConverter() final bool isAutoAdd,
  }) = _$RecurringIncomeModelImpl;

  factory _RecurringIncomeModel.fromJson(Map<String, dynamic> json) =
      _$RecurringIncomeModelImpl.fromJson;

  @override
  String get id;
  @override
  String get source;
  @override
  double get amount;
  @override
  int get dayOfMonth;
  @override
  @BoolIntConverter()
  bool get isAutoAdd;

  /// Create a copy of RecurringIncomeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecurringIncomeModelImplCopyWith<_$RecurringIncomeModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
