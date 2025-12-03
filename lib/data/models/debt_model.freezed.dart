// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debt_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DebtModel _$DebtModelFromJson(Map<String, dynamic> json) {
  return _DebtModel.fromJson(json);
}

/// @nodoc
mixin _$DebtModel {
  String get id => throw _privateConstructorUsedError;
  String get personName => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError; // 'Lent' or 'Borrowed'
  DateTime get date => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @BoolIntConverter()
  bool get isSettled => throw _privateConstructorUsedError;

  /// Serializes this DebtModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DebtModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DebtModelCopyWith<DebtModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DebtModelCopyWith<$Res> {
  factory $DebtModelCopyWith(DebtModel value, $Res Function(DebtModel) then) =
      _$DebtModelCopyWithImpl<$Res, DebtModel>;
  @useResult
  $Res call({
    String id,
    String personName,
    double amount,
    String type,
    DateTime date,
    DateTime? dueDate,
    String? description,
    @BoolIntConverter() bool isSettled,
  });
}

/// @nodoc
class _$DebtModelCopyWithImpl<$Res, $Val extends DebtModel>
    implements $DebtModelCopyWith<$Res> {
  _$DebtModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DebtModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? personName = null,
    Object? amount = null,
    Object? type = null,
    Object? date = null,
    Object? dueDate = freezed,
    Object? description = freezed,
    Object? isSettled = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            personName: null == personName
                ? _value.personName
                : personName // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dueDate: freezed == dueDate
                ? _value.dueDate
                : dueDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            isSettled: null == isSettled
                ? _value.isSettled
                : isSettled // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DebtModelImplCopyWith<$Res>
    implements $DebtModelCopyWith<$Res> {
  factory _$$DebtModelImplCopyWith(
    _$DebtModelImpl value,
    $Res Function(_$DebtModelImpl) then,
  ) = __$$DebtModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String personName,
    double amount,
    String type,
    DateTime date,
    DateTime? dueDate,
    String? description,
    @BoolIntConverter() bool isSettled,
  });
}

/// @nodoc
class __$$DebtModelImplCopyWithImpl<$Res>
    extends _$DebtModelCopyWithImpl<$Res, _$DebtModelImpl>
    implements _$$DebtModelImplCopyWith<$Res> {
  __$$DebtModelImplCopyWithImpl(
    _$DebtModelImpl _value,
    $Res Function(_$DebtModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DebtModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? personName = null,
    Object? amount = null,
    Object? type = null,
    Object? date = null,
    Object? dueDate = freezed,
    Object? description = freezed,
    Object? isSettled = null,
  }) {
    return _then(
      _$DebtModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        personName: null == personName
            ? _value.personName
            : personName // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dueDate: freezed == dueDate
            ? _value.dueDate
            : dueDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        isSettled: null == isSettled
            ? _value.isSettled
            : isSettled // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DebtModelImpl implements _DebtModel {
  const _$DebtModelImpl({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    required this.date,
    this.dueDate,
    this.description,
    @BoolIntConverter() this.isSettled = false,
  });

  factory _$DebtModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DebtModelImplFromJson(json);

  @override
  final String id;
  @override
  final String personName;
  @override
  final double amount;
  @override
  final String type;
  // 'Lent' or 'Borrowed'
  @override
  final DateTime date;
  @override
  final DateTime? dueDate;
  @override
  final String? description;
  @override
  @JsonKey()
  @BoolIntConverter()
  final bool isSettled;

  @override
  String toString() {
    return 'DebtModel(id: $id, personName: $personName, amount: $amount, type: $type, date: $date, dueDate: $dueDate, description: $description, isSettled: $isSettled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DebtModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.personName, personName) ||
                other.personName == personName) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isSettled, isSettled) ||
                other.isSettled == isSettled));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    personName,
    amount,
    type,
    date,
    dueDate,
    description,
    isSettled,
  );

  /// Create a copy of DebtModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DebtModelImplCopyWith<_$DebtModelImpl> get copyWith =>
      __$$DebtModelImplCopyWithImpl<_$DebtModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DebtModelImplToJson(this);
  }
}

abstract class _DebtModel implements DebtModel {
  const factory _DebtModel({
    required final String id,
    required final String personName,
    required final double amount,
    required final String type,
    required final DateTime date,
    final DateTime? dueDate,
    final String? description,
    @BoolIntConverter() final bool isSettled,
  }) = _$DebtModelImpl;

  factory _DebtModel.fromJson(Map<String, dynamic> json) =
      _$DebtModelImpl.fromJson;

  @override
  String get id;
  @override
  String get personName;
  @override
  double get amount;
  @override
  String get type; // 'Lent' or 'Borrowed'
  @override
  DateTime get date;
  @override
  DateTime? get dueDate;
  @override
  String? get description;
  @override
  @BoolIntConverter()
  bool get isSettled;

  /// Create a copy of DebtModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebtModelImplCopyWith<_$DebtModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
