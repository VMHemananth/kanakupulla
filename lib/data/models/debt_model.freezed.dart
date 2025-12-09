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

LoanPayment _$LoanPaymentFromJson(Map<String, dynamic> json) {
  return _LoanPayment.fromJson(json);
}

/// @nodoc
mixin _$LoanPayment {
  String get id => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get principalComponent => throw _privateConstructorUsedError;
  double get interestComponent => throw _privateConstructorUsedError;
  bool get isPartPayment => throw _privateConstructorUsedError;

  /// Serializes this LoanPayment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LoanPaymentCopyWith<LoanPayment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoanPaymentCopyWith<$Res> {
  factory $LoanPaymentCopyWith(
    LoanPayment value,
    $Res Function(LoanPayment) then,
  ) = _$LoanPaymentCopyWithImpl<$Res, LoanPayment>;
  @useResult
  $Res call({
    String id,
    double amount,
    DateTime date,
    double principalComponent,
    double interestComponent,
    bool isPartPayment,
  });
}

/// @nodoc
class _$LoanPaymentCopyWithImpl<$Res, $Val extends LoanPayment>
    implements $LoanPaymentCopyWith<$Res> {
  _$LoanPaymentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? date = null,
    Object? principalComponent = null,
    Object? interestComponent = null,
    Object? isPartPayment = null,
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
            principalComponent: null == principalComponent
                ? _value.principalComponent
                : principalComponent // ignore: cast_nullable_to_non_nullable
                      as double,
            interestComponent: null == interestComponent
                ? _value.interestComponent
                : interestComponent // ignore: cast_nullable_to_non_nullable
                      as double,
            isPartPayment: null == isPartPayment
                ? _value.isPartPayment
                : isPartPayment // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LoanPaymentImplCopyWith<$Res>
    implements $LoanPaymentCopyWith<$Res> {
  factory _$$LoanPaymentImplCopyWith(
    _$LoanPaymentImpl value,
    $Res Function(_$LoanPaymentImpl) then,
  ) = __$$LoanPaymentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    double amount,
    DateTime date,
    double principalComponent,
    double interestComponent,
    bool isPartPayment,
  });
}

/// @nodoc
class __$$LoanPaymentImplCopyWithImpl<$Res>
    extends _$LoanPaymentCopyWithImpl<$Res, _$LoanPaymentImpl>
    implements _$$LoanPaymentImplCopyWith<$Res> {
  __$$LoanPaymentImplCopyWithImpl(
    _$LoanPaymentImpl _value,
    $Res Function(_$LoanPaymentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? amount = null,
    Object? date = null,
    Object? principalComponent = null,
    Object? interestComponent = null,
    Object? isPartPayment = null,
  }) {
    return _then(
      _$LoanPaymentImpl(
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
        principalComponent: null == principalComponent
            ? _value.principalComponent
            : principalComponent // ignore: cast_nullable_to_non_nullable
                  as double,
        interestComponent: null == interestComponent
            ? _value.interestComponent
            : interestComponent // ignore: cast_nullable_to_non_nullable
                  as double,
        isPartPayment: null == isPartPayment
            ? _value.isPartPayment
            : isPartPayment // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LoanPaymentImpl implements _LoanPayment {
  const _$LoanPaymentImpl({
    required this.id,
    required this.amount,
    required this.date,
    required this.principalComponent,
    required this.interestComponent,
    this.isPartPayment = false,
  });

  factory _$LoanPaymentImpl.fromJson(Map<String, dynamic> json) =>
      _$$LoanPaymentImplFromJson(json);

  @override
  final String id;
  @override
  final double amount;
  @override
  final DateTime date;
  @override
  final double principalComponent;
  @override
  final double interestComponent;
  @override
  @JsonKey()
  final bool isPartPayment;

  @override
  String toString() {
    return 'LoanPayment(id: $id, amount: $amount, date: $date, principalComponent: $principalComponent, interestComponent: $interestComponent, isPartPayment: $isPartPayment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoanPaymentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.principalComponent, principalComponent) ||
                other.principalComponent == principalComponent) &&
            (identical(other.interestComponent, interestComponent) ||
                other.interestComponent == interestComponent) &&
            (identical(other.isPartPayment, isPartPayment) ||
                other.isPartPayment == isPartPayment));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    amount,
    date,
    principalComponent,
    interestComponent,
    isPartPayment,
  );

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LoanPaymentImplCopyWith<_$LoanPaymentImpl> get copyWith =>
      __$$LoanPaymentImplCopyWithImpl<_$LoanPaymentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LoanPaymentImplToJson(this);
  }
}

abstract class _LoanPayment implements LoanPayment {
  const factory _LoanPayment({
    required final String id,
    required final double amount,
    required final DateTime date,
    required final double principalComponent,
    required final double interestComponent,
    final bool isPartPayment,
  }) = _$LoanPaymentImpl;

  factory _LoanPayment.fromJson(Map<String, dynamic> json) =
      _$LoanPaymentImpl.fromJson;

  @override
  String get id;
  @override
  double get amount;
  @override
  DateTime get date;
  @override
  double get principalComponent;
  @override
  double get interestComponent;
  @override
  bool get isPartPayment;

  /// Create a copy of LoanPayment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LoanPaymentImplCopyWith<_$LoanPaymentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DebtModel _$DebtModelFromJson(Map<String, dynamic> json) {
  return _DebtModel.fromJson(json);
}

/// @nodoc
mixin _$DebtModel {
  String get id => throw _privateConstructorUsedError;
  String get personName => throw _privateConstructorUsedError;
  double get amount =>
      throw _privateConstructorUsedError; // Current Outstanding Amount
  String get type => throw _privateConstructorUsedError; // 'Lent' or 'Borrowed'
  DateTime get date => throw _privateConstructorUsedError;
  DateTime? get dueDate => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @BoolIntConverter()
  bool get isSettled => throw _privateConstructorUsedError; // Loan Specific Fields
  double get roi => throw _privateConstructorUsedError;
  String get interestType =>
      throw _privateConstructorUsedError; // 'Fixed' or 'Floating'
  int get tenureMonths => throw _privateConstructorUsedError;
  double get principalAmount =>
      throw _privateConstructorUsedError; // Original Loan Amount
  List<LoanPayment> get payments => throw _privateConstructorUsedError;

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
    double roi,
    String interestType,
    int tenureMonths,
    double principalAmount,
    List<LoanPayment> payments,
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
    Object? roi = null,
    Object? interestType = null,
    Object? tenureMonths = null,
    Object? principalAmount = null,
    Object? payments = null,
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
            roi: null == roi
                ? _value.roi
                : roi // ignore: cast_nullable_to_non_nullable
                      as double,
            interestType: null == interestType
                ? _value.interestType
                : interestType // ignore: cast_nullable_to_non_nullable
                      as String,
            tenureMonths: null == tenureMonths
                ? _value.tenureMonths
                : tenureMonths // ignore: cast_nullable_to_non_nullable
                      as int,
            principalAmount: null == principalAmount
                ? _value.principalAmount
                : principalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            payments: null == payments
                ? _value.payments
                : payments // ignore: cast_nullable_to_non_nullable
                      as List<LoanPayment>,
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
    double roi,
    String interestType,
    int tenureMonths,
    double principalAmount,
    List<LoanPayment> payments,
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
    Object? roi = null,
    Object? interestType = null,
    Object? tenureMonths = null,
    Object? principalAmount = null,
    Object? payments = null,
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
        roi: null == roi
            ? _value.roi
            : roi // ignore: cast_nullable_to_non_nullable
                  as double,
        interestType: null == interestType
            ? _value.interestType
            : interestType // ignore: cast_nullable_to_non_nullable
                  as String,
        tenureMonths: null == tenureMonths
            ? _value.tenureMonths
            : tenureMonths // ignore: cast_nullable_to_non_nullable
                  as int,
        principalAmount: null == principalAmount
            ? _value.principalAmount
            : principalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        payments: null == payments
            ? _value._payments
            : payments // ignore: cast_nullable_to_non_nullable
                  as List<LoanPayment>,
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
    this.roi = 0.0,
    this.interestType = 'Fixed',
    this.tenureMonths = 0,
    this.principalAmount = 0.0,
    final List<LoanPayment> payments = const [],
  }) : _payments = payments;

  factory _$DebtModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DebtModelImplFromJson(json);

  @override
  final String id;
  @override
  final String personName;
  @override
  final double amount;
  // Current Outstanding Amount
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
  // Loan Specific Fields
  @override
  @JsonKey()
  final double roi;
  @override
  @JsonKey()
  final String interestType;
  // 'Fixed' or 'Floating'
  @override
  @JsonKey()
  final int tenureMonths;
  @override
  @JsonKey()
  final double principalAmount;
  // Original Loan Amount
  final List<LoanPayment> _payments;
  // Original Loan Amount
  @override
  @JsonKey()
  List<LoanPayment> get payments {
    if (_payments is EqualUnmodifiableListView) return _payments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payments);
  }

  @override
  String toString() {
    return 'DebtModel(id: $id, personName: $personName, amount: $amount, type: $type, date: $date, dueDate: $dueDate, description: $description, isSettled: $isSettled, roi: $roi, interestType: $interestType, tenureMonths: $tenureMonths, principalAmount: $principalAmount, payments: $payments)';
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
                other.isSettled == isSettled) &&
            (identical(other.roi, roi) || other.roi == roi) &&
            (identical(other.interestType, interestType) ||
                other.interestType == interestType) &&
            (identical(other.tenureMonths, tenureMonths) ||
                other.tenureMonths == tenureMonths) &&
            (identical(other.principalAmount, principalAmount) ||
                other.principalAmount == principalAmount) &&
            const DeepCollectionEquality().equals(other._payments, _payments));
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
    roi,
    interestType,
    tenureMonths,
    principalAmount,
    const DeepCollectionEquality().hash(_payments),
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
    final double roi,
    final String interestType,
    final int tenureMonths,
    final double principalAmount,
    final List<LoanPayment> payments,
  }) = _$DebtModelImpl;

  factory _DebtModel.fromJson(Map<String, dynamic> json) =
      _$DebtModelImpl.fromJson;

  @override
  String get id;
  @override
  String get personName;
  @override
  double get amount; // Current Outstanding Amount
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
  bool get isSettled; // Loan Specific Fields
  @override
  double get roi;
  @override
  String get interestType; // 'Fixed' or 'Floating'
  @override
  int get tenureMonths;
  @override
  double get principalAmount; // Original Loan Amount
  @override
  List<LoanPayment> get payments;

  /// Create a copy of DebtModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DebtModelImplCopyWith<_$DebtModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
