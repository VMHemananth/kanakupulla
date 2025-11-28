// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'salary_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SalaryModel _$SalaryModelFromJson(Map<String, dynamic> json) {
  return _SalaryModel.fromJson(json);
}

/// @nodoc
mixin _$SalaryModel {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;

  /// Serializes this SalaryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SalaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SalaryModelCopyWith<SalaryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SalaryModelCopyWith<$Res> {
  factory $SalaryModelCopyWith(
    SalaryModel value,
    $Res Function(SalaryModel) then,
  ) = _$SalaryModelCopyWithImpl<$Res, SalaryModel>;
  @useResult
  $Res call({
    String id,
    double amount,
    DateTime date,
    String source,
    String? title,
  });
}

/// @nodoc
class _$SalaryModelCopyWithImpl<$Res, $Val extends SalaryModel>
    implements $SalaryModelCopyWith<$Res> {
  _$SalaryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SalaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? date = null,
    Object? source = null,
    Object? title = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SalaryModelImplCopyWith<$Res>
    implements $SalaryModelCopyWith<$Res> {
  factory _$$SalaryModelImplCopyWith(
    _$SalaryModelImpl value,
    $Res Function(_$SalaryModelImpl) then,
  ) = __$$SalaryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    double amount,
    DateTime date,
    String source,
    String? title,
  });
}

/// @nodoc
class __$$SalaryModelImplCopyWithImpl<$Res>
    extends _$SalaryModelCopyWithImpl<$Res, _$SalaryModelImpl>
    implements _$$SalaryModelImplCopyWith<$Res> {
  __$$SalaryModelImplCopyWithImpl(
    _$SalaryModelImpl _value,
    $Res Function(_$SalaryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SalaryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? date = null,
    Object? source = null,
    Object? title = freezed,
  }) {
    return _then(
      _$SalaryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SalaryModelImpl implements _SalaryModel {
  const _$SalaryModelImpl({
    required this.id,
    required this.amount,
    required this.date,
    this.source = 'Salary',
    this.title,
  });

  factory _$SalaryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SalaryModelImplFromJson(json);

  @override
  final String id;
  @override
  final double amount;
  @override
  final DateTime date;
  @override
  @JsonKey()
  final String source;
  @override
  final String? title;

  @override
  String toString() {
    return 'SalaryModel(id: $id, amount: $amount, date: $date, source: $source, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SalaryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, amount, date, source, title);

  /// Create a copy of SalaryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SalaryModelImplCopyWith<_$SalaryModelImpl> get copyWith =>
      __$$SalaryModelImplCopyWithImpl<_$SalaryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SalaryModelImplToJson(this);
  }
}

abstract class _SalaryModel implements SalaryModel {
  const factory _SalaryModel({
    required final String id,
    required final double amount,
    required final DateTime date,
    final String source,
    final String? title,
  }) = _$SalaryModelImpl;

  factory _SalaryModel.fromJson(Map<String, dynamic> json) =
      _$SalaryModelImpl.fromJson;

  @override
  String get id;
  @override
  double get amount;
  @override
  DateTime get date;
  @override
  String get source;
  @override
  String? get title;

  /// Create a copy of SalaryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SalaryModelImplCopyWith<_$SalaryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
