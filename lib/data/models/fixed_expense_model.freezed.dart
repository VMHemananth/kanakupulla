// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fixed_expense_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FixedExpenseModel _$FixedExpenseModelFromJson(Map<String, dynamic> json) {
  return _FixedExpenseModel.fromJson(json);
}

/// @nodoc
mixin _$FixedExpenseModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  int get dayOfMonth => throw _privateConstructorUsedError; // 1-31
  @BoolIntConverter()
  bool get isAutoAdd => throw _privateConstructorUsedError;

  /// Serializes this FixedExpenseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FixedExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FixedExpenseModelCopyWith<FixedExpenseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FixedExpenseModelCopyWith<$Res> {
  factory $FixedExpenseModelCopyWith(
    FixedExpenseModel value,
    $Res Function(FixedExpenseModel) then,
  ) = _$FixedExpenseModelCopyWithImpl<$Res, FixedExpenseModel>;
  @useResult
  $Res call({
    String id,
    String title,
    double amount,
    String category,
    int dayOfMonth,
    @BoolIntConverter() bool isAutoAdd,
  });
}

/// @nodoc
class _$FixedExpenseModelCopyWithImpl<$Res, $Val extends FixedExpenseModel>
    implements $FixedExpenseModelCopyWith<$Res> {
  _$FixedExpenseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FixedExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? category = null,
    Object? dayOfMonth = null,
    Object? isAutoAdd = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$FixedExpenseModelImplCopyWith<$Res>
    implements $FixedExpenseModelCopyWith<$Res> {
  factory _$$FixedExpenseModelImplCopyWith(
    _$FixedExpenseModelImpl value,
    $Res Function(_$FixedExpenseModelImpl) then,
  ) = __$$FixedExpenseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    double amount,
    String category,
    int dayOfMonth,
    @BoolIntConverter() bool isAutoAdd,
  });
}

/// @nodoc
class __$$FixedExpenseModelImplCopyWithImpl<$Res>
    extends _$FixedExpenseModelCopyWithImpl<$Res, _$FixedExpenseModelImpl>
    implements _$$FixedExpenseModelImplCopyWith<$Res> {
  __$$FixedExpenseModelImplCopyWithImpl(
    _$FixedExpenseModelImpl _value,
    $Res Function(_$FixedExpenseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FixedExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? category = null,
    Object? dayOfMonth = null,
    Object? isAutoAdd = null,
  }) {
    return _then(
      _$FixedExpenseModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$FixedExpenseModelImpl implements _FixedExpenseModel {
  const _$FixedExpenseModelImpl({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    this.dayOfMonth = 1,
    @BoolIntConverter() this.isAutoAdd = false,
  });

  factory _$FixedExpenseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FixedExpenseModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final double amount;
  @override
  final String category;
  @override
  @JsonKey()
  final int dayOfMonth;
  // 1-31
  @override
  @JsonKey()
  @BoolIntConverter()
  final bool isAutoAdd;

  @override
  String toString() {
    return 'FixedExpenseModel(id: $id, title: $title, amount: $amount, category: $category, dayOfMonth: $dayOfMonth, isAutoAdd: $isAutoAdd)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FixedExpenseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.isAutoAdd, isAutoAdd) ||
                other.isAutoAdd == isAutoAdd));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    amount,
    category,
    dayOfMonth,
    isAutoAdd,
  );

  /// Create a copy of FixedExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FixedExpenseModelImplCopyWith<_$FixedExpenseModelImpl> get copyWith =>
      __$$FixedExpenseModelImplCopyWithImpl<_$FixedExpenseModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FixedExpenseModelImplToJson(this);
  }
}

abstract class _FixedExpenseModel implements FixedExpenseModel {
  const factory _FixedExpenseModel({
    required final String id,
    required final String title,
    required final double amount,
    required final String category,
    final int dayOfMonth,
    @BoolIntConverter() final bool isAutoAdd,
  }) = _$FixedExpenseModelImpl;

  factory _FixedExpenseModel.fromJson(Map<String, dynamic> json) =
      _$FixedExpenseModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  double get amount;
  @override
  String get category;
  @override
  int get dayOfMonth; // 1-31
  @override
  @BoolIntConverter()
  bool get isAutoAdd;

  /// Create a copy of FixedExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FixedExpenseModelImplCopyWith<_$FixedExpenseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
