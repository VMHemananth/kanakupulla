// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) {
  return _ExpenseModel.fromJson(json);
}

/// @nodoc
mixin _$ExpenseModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String? get paymentMethod => throw _privateConstructorUsedError;
  String? get creditCardId => throw _privateConstructorUsedError;
  bool get isCreditCardBill => throw _privateConstructorUsedError;

  /// Serializes this ExpenseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseModelCopyWith<ExpenseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseModelCopyWith<$Res> {
  factory $ExpenseModelCopyWith(
    ExpenseModel value,
    $Res Function(ExpenseModel) then,
  ) = _$ExpenseModelCopyWithImpl<$Res, ExpenseModel>;
  @useResult
  $Res call({
    String id,
    String title,
    double amount,
    DateTime date,
    String category,
    String? paymentMethod,
    String? creditCardId,
    bool isCreditCardBill,
  });
}

/// @nodoc
class _$ExpenseModelCopyWithImpl<$Res, $Val extends ExpenseModel>
    implements $ExpenseModelCopyWith<$Res> {
  _$ExpenseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? date = null,
    Object? category = null,
    Object? paymentMethod = freezed,
    Object? creditCardId = freezed,
    Object? isCreditCardBill = null,
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
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            paymentMethod: freezed == paymentMethod
                ? _value.paymentMethod
                : paymentMethod // ignore: cast_nullable_to_non_nullable
                      as String?,
            creditCardId: freezed == creditCardId
                ? _value.creditCardId
                : creditCardId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isCreditCardBill: null == isCreditCardBill
                ? _value.isCreditCardBill
                : isCreditCardBill // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseModelImplCopyWith<$Res>
    implements $ExpenseModelCopyWith<$Res> {
  factory _$$ExpenseModelImplCopyWith(
    _$ExpenseModelImpl value,
    $Res Function(_$ExpenseModelImpl) then,
  ) = __$$ExpenseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    double amount,
    DateTime date,
    String category,
    String? paymentMethod,
    String? creditCardId,
    bool isCreditCardBill,
  });
}

/// @nodoc
class __$$ExpenseModelImplCopyWithImpl<$Res>
    extends _$ExpenseModelCopyWithImpl<$Res, _$ExpenseModelImpl>
    implements _$$ExpenseModelImplCopyWith<$Res> {
  __$$ExpenseModelImplCopyWithImpl(
    _$ExpenseModelImpl _value,
    $Res Function(_$ExpenseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? amount = null,
    Object? date = null,
    Object? category = null,
    Object? paymentMethod = freezed,
    Object? creditCardId = freezed,
    Object? isCreditCardBill = null,
  }) {
    return _then(
      _$ExpenseModelImpl(
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
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        paymentMethod: freezed == paymentMethod
            ? _value.paymentMethod
            : paymentMethod // ignore: cast_nullable_to_non_nullable
                  as String?,
        creditCardId: freezed == creditCardId
            ? _value.creditCardId
            : creditCardId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isCreditCardBill: null == isCreditCardBill
            ? _value.isCreditCardBill
            : isCreditCardBill // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseModelImpl implements _ExpenseModel {
  const _$ExpenseModelImpl({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.paymentMethod,
    this.creditCardId,
    this.isCreditCardBill = false,
  });

  factory _$ExpenseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final double amount;
  @override
  final DateTime date;
  @override
  final String category;
  @override
  final String? paymentMethod;
  @override
  final String? creditCardId;
  @override
  @JsonKey()
  final bool isCreditCardBill;

  @override
  String toString() {
    return 'ExpenseModel(id: $id, title: $title, amount: $amount, date: $date, category: $category, paymentMethod: $paymentMethod, creditCardId: $creditCardId, isCreditCardBill: $isCreditCardBill)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.creditCardId, creditCardId) ||
                other.creditCardId == creditCardId) &&
            (identical(other.isCreditCardBill, isCreditCardBill) ||
                other.isCreditCardBill == isCreditCardBill));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    amount,
    date,
    category,
    paymentMethod,
    creditCardId,
    isCreditCardBill,
  );

  /// Create a copy of ExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseModelImplCopyWith<_$ExpenseModelImpl> get copyWith =>
      __$$ExpenseModelImplCopyWithImpl<_$ExpenseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseModelImplToJson(this);
  }
}

abstract class _ExpenseModel implements ExpenseModel {
  const factory _ExpenseModel({
    required final String id,
    required final String title,
    required final double amount,
    required final DateTime date,
    required final String category,
    final String? paymentMethod,
    final String? creditCardId,
    final bool isCreditCardBill,
  }) = _$ExpenseModelImpl;

  factory _ExpenseModel.fromJson(Map<String, dynamic> json) =
      _$ExpenseModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  double get amount;
  @override
  DateTime get date;
  @override
  String get category;
  @override
  String? get paymentMethod;
  @override
  String? get creditCardId;
  @override
  bool get isCreditCardBill;

  /// Create a copy of ExpenseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseModelImplCopyWith<_$ExpenseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
