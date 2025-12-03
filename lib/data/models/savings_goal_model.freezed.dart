// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'savings_goal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SavingsGoalModel _$SavingsGoalModelFromJson(Map<String, dynamic> json) {
  return _SavingsGoalModel.fromJson(json);
}

/// @nodoc
mixin _$SavingsGoalModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get targetAmount => throw _privateConstructorUsedError;
  double get currentAmount => throw _privateConstructorUsedError;
  DateTime? get deadline => throw _privateConstructorUsedError;
  String? get icon =>
      throw _privateConstructorUsedError; // Store icon code point or name if needed
  int? get color => throw _privateConstructorUsedError;

  /// Serializes this SavingsGoalModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SavingsGoalModelCopyWith<SavingsGoalModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SavingsGoalModelCopyWith<$Res> {
  factory $SavingsGoalModelCopyWith(
    SavingsGoalModel value,
    $Res Function(SavingsGoalModel) then,
  ) = _$SavingsGoalModelCopyWithImpl<$Res, SavingsGoalModel>;
  @useResult
  $Res call({
    String id,
    String name,
    double targetAmount,
    double currentAmount,
    DateTime? deadline,
    String? icon,
    int? color,
  });
}

/// @nodoc
class _$SavingsGoalModelCopyWithImpl<$Res, $Val extends SavingsGoalModel>
    implements $SavingsGoalModelCopyWith<$Res> {
  _$SavingsGoalModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? deadline = freezed,
    Object? icon = freezed,
    Object? color = freezed,
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
            targetAmount: null == targetAmount
                ? _value.targetAmount
                : targetAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            currentAmount: null == currentAmount
                ? _value.currentAmount
                : currentAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            deadline: freezed == deadline
                ? _value.deadline
                : deadline // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            icon: freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: freezed == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SavingsGoalModelImplCopyWith<$Res>
    implements $SavingsGoalModelCopyWith<$Res> {
  factory _$$SavingsGoalModelImplCopyWith(
    _$SavingsGoalModelImpl value,
    $Res Function(_$SavingsGoalModelImpl) then,
  ) = __$$SavingsGoalModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    double targetAmount,
    double currentAmount,
    DateTime? deadline,
    String? icon,
    int? color,
  });
}

/// @nodoc
class __$$SavingsGoalModelImplCopyWithImpl<$Res>
    extends _$SavingsGoalModelCopyWithImpl<$Res, _$SavingsGoalModelImpl>
    implements _$$SavingsGoalModelImplCopyWith<$Res> {
  __$$SavingsGoalModelImplCopyWithImpl(
    _$SavingsGoalModelImpl _value,
    $Res Function(_$SavingsGoalModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? targetAmount = null,
    Object? currentAmount = null,
    Object? deadline = freezed,
    Object? icon = freezed,
    Object? color = freezed,
  }) {
    return _then(
      _$SavingsGoalModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        targetAmount: null == targetAmount
            ? _value.targetAmount
            : targetAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        currentAmount: null == currentAmount
            ? _value.currentAmount
            : currentAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        deadline: freezed == deadline
            ? _value.deadline
            : deadline // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        icon: freezed == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: freezed == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SavingsGoalModelImpl implements _SavingsGoalModel {
  const _$SavingsGoalModelImpl({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    this.icon,
    this.color,
  });

  factory _$SavingsGoalModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SavingsGoalModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double targetAmount;
  @override
  final double currentAmount;
  @override
  final DateTime? deadline;
  @override
  final String? icon;
  // Store icon code point or name if needed
  @override
  final int? color;

  @override
  String toString() {
    return 'SavingsGoalModel(id: $id, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, deadline: $deadline, icon: $icon, color: $color)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SavingsGoalModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.targetAmount, targetAmount) ||
                other.targetAmount == targetAmount) &&
            (identical(other.currentAmount, currentAmount) ||
                other.currentAmount == currentAmount) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    targetAmount,
    currentAmount,
    deadline,
    icon,
    color,
  );

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SavingsGoalModelImplCopyWith<_$SavingsGoalModelImpl> get copyWith =>
      __$$SavingsGoalModelImplCopyWithImpl<_$SavingsGoalModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SavingsGoalModelImplToJson(this);
  }
}

abstract class _SavingsGoalModel implements SavingsGoalModel {
  const factory _SavingsGoalModel({
    required final String id,
    required final String name,
    required final double targetAmount,
    required final double currentAmount,
    final DateTime? deadline,
    final String? icon,
    final int? color,
  }) = _$SavingsGoalModelImpl;

  factory _SavingsGoalModel.fromJson(Map<String, dynamic> json) =
      _$SavingsGoalModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get targetAmount;
  @override
  double get currentAmount;
  @override
  DateTime? get deadline;
  @override
  String? get icon; // Store icon code point or name if needed
  @override
  int? get color;

  /// Create a copy of SavingsGoalModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SavingsGoalModelImplCopyWith<_$SavingsGoalModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
