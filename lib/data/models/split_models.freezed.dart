// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'split_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SplitGroup _$SplitGroupFromJson(Map<String, dynamic> json) {
  return _SplitGroup.fromJson(json);
}

/// @nodoc
mixin _$SplitGroup {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this SplitGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SplitGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SplitGroupCopyWith<SplitGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SplitGroupCopyWith<$Res> {
  factory $SplitGroupCopyWith(
    SplitGroup value,
    $Res Function(SplitGroup) then,
  ) = _$SplitGroupCopyWithImpl<$Res, SplitGroup>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class _$SplitGroupCopyWithImpl<$Res, $Val extends SplitGroup>
    implements $SplitGroupCopyWith<$Res> {
  _$SplitGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SplitGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
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
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SplitGroupImplCopyWith<$Res>
    implements $SplitGroupCopyWith<$Res> {
  factory _$$SplitGroupImplCopyWith(
    _$SplitGroupImpl value,
    $Res Function(_$SplitGroupImpl) then,
  ) = __$$SplitGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'created_at') DateTime createdAt,
  });
}

/// @nodoc
class __$$SplitGroupImplCopyWithImpl<$Res>
    extends _$SplitGroupCopyWithImpl<$Res, _$SplitGroupImpl>
    implements _$$SplitGroupImplCopyWith<$Res> {
  __$$SplitGroupImplCopyWithImpl(
    _$SplitGroupImpl _value,
    $Res Function(_$SplitGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SplitGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$SplitGroupImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SplitGroupImpl implements _SplitGroup {
  const _$SplitGroupImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$SplitGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$SplitGroupImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'SplitGroup(id: $id, name: $name, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SplitGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, createdAt);

  /// Create a copy of SplitGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SplitGroupImplCopyWith<_$SplitGroupImpl> get copyWith =>
      __$$SplitGroupImplCopyWithImpl<_$SplitGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SplitGroupImplToJson(this);
  }
}

abstract class _SplitGroup implements SplitGroup {
  const factory _SplitGroup({
    required final String id,
    required final String name,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
  }) = _$SplitGroupImpl;

  factory _SplitGroup.fromJson(Map<String, dynamic> json) =
      _$SplitGroupImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of SplitGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SplitGroupImplCopyWith<_$SplitGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) {
  return _GroupMember.fromJson(json);
}

/// @nodoc
mixin _$GroupMember {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_id')
  String get groupId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this GroupMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupMemberCopyWith<GroupMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMemberCopyWith<$Res> {
  factory $GroupMemberCopyWith(
    GroupMember value,
    $Res Function(GroupMember) then,
  ) = _$GroupMemberCopyWithImpl<$Res, GroupMember>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'group_id') String groupId,
    String name,
  });
}

/// @nodoc
class _$GroupMemberCopyWithImpl<$Res, $Val extends GroupMember>
    implements $GroupMemberCopyWith<$Res> {
  _$GroupMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? groupId = null, Object? name = null}) {
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
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GroupMemberImplCopyWith<$Res>
    implements $GroupMemberCopyWith<$Res> {
  factory _$$GroupMemberImplCopyWith(
    _$GroupMemberImpl value,
    $Res Function(_$GroupMemberImpl) then,
  ) = __$$GroupMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'group_id') String groupId,
    String name,
  });
}

/// @nodoc
class __$$GroupMemberImplCopyWithImpl<$Res>
    extends _$GroupMemberCopyWithImpl<$Res, _$GroupMemberImpl>
    implements _$$GroupMemberImplCopyWith<$Res> {
  __$$GroupMemberImplCopyWithImpl(
    _$GroupMemberImpl _value,
    $Res Function(_$GroupMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? groupId = null, Object? name = null}) {
    return _then(
      _$GroupMemberImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupMemberImpl implements _GroupMember {
  const _$GroupMemberImpl({
    required this.id,
    @JsonKey(name: 'group_id') required this.groupId,
    required this.name,
  });

  factory _$GroupMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupMemberImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'group_id')
  final String groupId;
  @override
  final String name;

  @override
  String toString() {
    return 'GroupMember(id: $id, groupId: $groupId, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMemberImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, groupId, name);

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMemberImplCopyWith<_$GroupMemberImpl> get copyWith =>
      __$$GroupMemberImplCopyWithImpl<_$GroupMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupMemberImplToJson(this);
  }
}

abstract class _GroupMember implements GroupMember {
  const factory _GroupMember({
    required final String id,
    @JsonKey(name: 'group_id') required final String groupId,
    required final String name,
  }) = _$GroupMemberImpl;

  factory _GroupMember.fromJson(Map<String, dynamic> json) =
      _$GroupMemberImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'group_id')
  String get groupId;
  @override
  String get name;

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupMemberImplCopyWith<_$GroupMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SplitExpense _$SplitExpenseFromJson(Map<String, dynamic> json) {
  return _SplitExpense.fromJson(json);
}

/// @nodoc
mixin _$SplitExpense {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_id')
  String get groupId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  @JsonKey(name: 'paid_by_member_id')
  String get paidByMemberId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'split_with')
  List<String> get splitWith => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_paid_from_pool')
  bool get isPaidFromPool => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  /// Serializes this SplitExpense to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SplitExpense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SplitExpenseCopyWith<SplitExpense> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SplitExpenseCopyWith<$Res> {
  factory $SplitExpenseCopyWith(
    SplitExpense value,
    $Res Function(SplitExpense) then,
  ) = _$SplitExpenseCopyWithImpl<$Res, SplitExpense>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'group_id') String groupId,
    String title,
    double amount,
    @JsonKey(name: 'paid_by_member_id') String paidByMemberId,
    DateTime date,
    @JsonKey(name: 'split_with') List<String> splitWith,
    @JsonKey(name: 'is_paid_from_pool') bool isPaidFromPool,
    String type,
  });
}

/// @nodoc
class _$SplitExpenseCopyWithImpl<$Res, $Val extends SplitExpense>
    implements $SplitExpenseCopyWith<$Res> {
  _$SplitExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SplitExpense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? title = null,
    Object? amount = null,
    Object? paidByMemberId = null,
    Object? date = null,
    Object? splitWith = null,
    Object? isPaidFromPool = null,
    Object? type = null,
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
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as double,
            paidByMemberId: null == paidByMemberId
                ? _value.paidByMemberId
                : paidByMemberId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            splitWith: null == splitWith
                ? _value.splitWith
                : splitWith // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isPaidFromPool: null == isPaidFromPool
                ? _value.isPaidFromPool
                : isPaidFromPool // ignore: cast_nullable_to_non_nullable
                      as bool,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SplitExpenseImplCopyWith<$Res>
    implements $SplitExpenseCopyWith<$Res> {
  factory _$$SplitExpenseImplCopyWith(
    _$SplitExpenseImpl value,
    $Res Function(_$SplitExpenseImpl) then,
  ) = __$$SplitExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'group_id') String groupId,
    String title,
    double amount,
    @JsonKey(name: 'paid_by_member_id') String paidByMemberId,
    DateTime date,
    @JsonKey(name: 'split_with') List<String> splitWith,
    @JsonKey(name: 'is_paid_from_pool') bool isPaidFromPool,
    String type,
  });
}

/// @nodoc
class __$$SplitExpenseImplCopyWithImpl<$Res>
    extends _$SplitExpenseCopyWithImpl<$Res, _$SplitExpenseImpl>
    implements _$$SplitExpenseImplCopyWith<$Res> {
  __$$SplitExpenseImplCopyWithImpl(
    _$SplitExpenseImpl _value,
    $Res Function(_$SplitExpenseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SplitExpense
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? title = null,
    Object? amount = null,
    Object? paidByMemberId = null,
    Object? date = null,
    Object? splitWith = null,
    Object? isPaidFromPool = null,
    Object? type = null,
  }) {
    return _then(
      _$SplitExpenseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as double,
        paidByMemberId: null == paidByMemberId
            ? _value.paidByMemberId
            : paidByMemberId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        splitWith: null == splitWith
            ? _value._splitWith
            : splitWith // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isPaidFromPool: null == isPaidFromPool
            ? _value.isPaidFromPool
            : isPaidFromPool // ignore: cast_nullable_to_non_nullable
                  as bool,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SplitExpenseImpl implements _SplitExpense {
  const _$SplitExpenseImpl({
    required this.id,
    @JsonKey(name: 'group_id') required this.groupId,
    required this.title,
    required this.amount,
    @JsonKey(name: 'paid_by_member_id') required this.paidByMemberId,
    required this.date,
    @JsonKey(name: 'split_with') final List<String> splitWith = const [],
    @JsonKey(name: 'is_paid_from_pool') this.isPaidFromPool = false,
    this.type = 'EXPENSE',
  }) : _splitWith = splitWith;

  factory _$SplitExpenseImpl.fromJson(Map<String, dynamic> json) =>
      _$$SplitExpenseImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'group_id')
  final String groupId;
  @override
  final String title;
  @override
  final double amount;
  @override
  @JsonKey(name: 'paid_by_member_id')
  final String paidByMemberId;
  @override
  final DateTime date;
  final List<String> _splitWith;
  @override
  @JsonKey(name: 'split_with')
  List<String> get splitWith {
    if (_splitWith is EqualUnmodifiableListView) return _splitWith;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_splitWith);
  }

  @override
  @JsonKey(name: 'is_paid_from_pool')
  final bool isPaidFromPool;
  @override
  @JsonKey()
  final String type;

  @override
  String toString() {
    return 'SplitExpense(id: $id, groupId: $groupId, title: $title, amount: $amount, paidByMemberId: $paidByMemberId, date: $date, splitWith: $splitWith, isPaidFromPool: $isPaidFromPool, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SplitExpenseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.paidByMemberId, paidByMemberId) ||
                other.paidByMemberId == paidByMemberId) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
              other._splitWith,
              _splitWith,
            ) &&
            (identical(other.isPaidFromPool, isPaidFromPool) ||
                other.isPaidFromPool == isPaidFromPool) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    groupId,
    title,
    amount,
    paidByMemberId,
    date,
    const DeepCollectionEquality().hash(_splitWith),
    isPaidFromPool,
    type,
  );

  /// Create a copy of SplitExpense
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SplitExpenseImplCopyWith<_$SplitExpenseImpl> get copyWith =>
      __$$SplitExpenseImplCopyWithImpl<_$SplitExpenseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SplitExpenseImplToJson(this);
  }
}

abstract class _SplitExpense implements SplitExpense {
  const factory _SplitExpense({
    required final String id,
    @JsonKey(name: 'group_id') required final String groupId,
    required final String title,
    required final double amount,
    @JsonKey(name: 'paid_by_member_id') required final String paidByMemberId,
    required final DateTime date,
    @JsonKey(name: 'split_with') final List<String> splitWith,
    @JsonKey(name: 'is_paid_from_pool') final bool isPaidFromPool,
    final String type,
  }) = _$SplitExpenseImpl;

  factory _SplitExpense.fromJson(Map<String, dynamic> json) =
      _$SplitExpenseImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'group_id')
  String get groupId;
  @override
  String get title;
  @override
  double get amount;
  @override
  @JsonKey(name: 'paid_by_member_id')
  String get paidByMemberId;
  @override
  DateTime get date;
  @override
  @JsonKey(name: 'split_with')
  List<String> get splitWith;
  @override
  @JsonKey(name: 'is_paid_from_pool')
  bool get isPaidFromPool;
  @override
  String get type;

  /// Create a copy of SplitExpense
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SplitExpenseImplCopyWith<_$SplitExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ActivityLog _$ActivityLogFromJson(Map<String, dynamic> json) {
  return _ActivityLog.fromJson(json);
}

/// @nodoc
mixin _$ActivityLog {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'group_id')
  String get groupId => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_name')
  String get userName => throw _privateConstructorUsedError;

  /// Serializes this ActivityLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActivityLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityLogCopyWith<ActivityLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityLogCopyWith<$Res> {
  factory $ActivityLogCopyWith(
    ActivityLog value,
    $Res Function(ActivityLog) then,
  ) = _$ActivityLogCopyWithImpl<$Res, ActivityLog>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'group_id') String groupId,
    String description,
    DateTime timestamp,
    @JsonKey(name: 'user_name') String userName,
  });
}

/// @nodoc
class _$ActivityLogCopyWithImpl<$Res, $Val extends ActivityLog>
    implements $ActivityLogCopyWith<$Res> {
  _$ActivityLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? description = null,
    Object? timestamp = null,
    Object? userName = null,
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
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ActivityLogImplCopyWith<$Res>
    implements $ActivityLogCopyWith<$Res> {
  factory _$$ActivityLogImplCopyWith(
    _$ActivityLogImpl value,
    $Res Function(_$ActivityLogImpl) then,
  ) = __$$ActivityLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'group_id') String groupId,
    String description,
    DateTime timestamp,
    @JsonKey(name: 'user_name') String userName,
  });
}

/// @nodoc
class __$$ActivityLogImplCopyWithImpl<$Res>
    extends _$ActivityLogCopyWithImpl<$Res, _$ActivityLogImpl>
    implements _$$ActivityLogImplCopyWith<$Res> {
  __$$ActivityLogImplCopyWithImpl(
    _$ActivityLogImpl _value,
    $Res Function(_$ActivityLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? description = null,
    Object? timestamp = null,
    Object? userName = null,
  }) {
    return _then(
      _$ActivityLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        groupId: null == groupId
            ? _value.groupId
            : groupId // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActivityLogImpl implements _ActivityLog {
  const _$ActivityLogImpl({
    required this.id,
    @JsonKey(name: 'group_id') required this.groupId,
    required this.description,
    required this.timestamp,
    @JsonKey(name: 'user_name') required this.userName,
  });

  factory _$ActivityLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActivityLogImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'group_id')
  final String groupId;
  @override
  final String description;
  @override
  final DateTime timestamp;
  @override
  @JsonKey(name: 'user_name')
  final String userName;

  @override
  String toString() {
    return 'ActivityLog(id: $id, groupId: $groupId, description: $description, timestamp: $timestamp, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, groupId, description, timestamp, userName);

  /// Create a copy of ActivityLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityLogImplCopyWith<_$ActivityLogImpl> get copyWith =>
      __$$ActivityLogImplCopyWithImpl<_$ActivityLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ActivityLogImplToJson(this);
  }
}

abstract class _ActivityLog implements ActivityLog {
  const factory _ActivityLog({
    required final String id,
    @JsonKey(name: 'group_id') required final String groupId,
    required final String description,
    required final DateTime timestamp,
    @JsonKey(name: 'user_name') required final String userName,
  }) = _$ActivityLogImpl;

  factory _ActivityLog.fromJson(Map<String, dynamic> json) =
      _$ActivityLogImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'group_id')
  String get groupId;
  @override
  String get description;
  @override
  DateTime get timestamp;
  @override
  @JsonKey(name: 'user_name')
  String get userName;

  /// Create a copy of ActivityLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityLogImplCopyWith<_$ActivityLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
