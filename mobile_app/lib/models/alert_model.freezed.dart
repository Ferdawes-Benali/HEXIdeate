// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alert_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Alert _$AlertFromJson(Map<String, dynamic> json) {
  return _Alert.fromJson(json);
}

/// @nodoc
mixin _$Alert {
  int get id => throw _privateConstructorUsedError;
  int get patientId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isAcknowledged => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime? get acknowledgedAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AlertCopyWith<Alert> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertCopyWith<$Res> {
  factory $AlertCopyWith(Alert value, $Res Function(Alert) then) =
      _$AlertCopyWithImpl<$Res, Alert>;
  @useResult
  $Res call(
      {int id,
      int patientId,
      String type,
      String severity,
      String message,
      bool isRead,
      bool isAcknowledged,
      DateTime? readAt,
      DateTime? acknowledgedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$AlertCopyWithImpl<$Res, $Val extends Alert>
    implements $AlertCopyWith<$Res> {
  _$AlertCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? type = null,
    Object? severity = null,
    Object? message = null,
    Object? isRead = null,
    Object? isAcknowledged = null,
    Object? readAt = freezed,
    Object? acknowledgedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isAcknowledged: null == isAcknowledged
          ? _value.isAcknowledged
          : isAcknowledged // ignore: cast_nullable_to_non_nullable
              as bool,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      acknowledgedAt: freezed == acknowledgedAt
          ? _value.acknowledgedAt
          : acknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlertImplCopyWith<$Res> implements $AlertCopyWith<$Res> {
  factory _$$AlertImplCopyWith(
          _$AlertImpl value, $Res Function(_$AlertImpl) then) =
      __$$AlertImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int patientId,
      String type,
      String severity,
      String message,
      bool isRead,
      bool isAcknowledged,
      DateTime? readAt,
      DateTime? acknowledgedAt,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$AlertImplCopyWithImpl<$Res>
    extends _$AlertCopyWithImpl<$Res, _$AlertImpl>
    implements _$$AlertImplCopyWith<$Res> {
  __$$AlertImplCopyWithImpl(
      _$AlertImpl _value, $Res Function(_$AlertImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? patientId = null,
    Object? type = null,
    Object? severity = null,
    Object? message = null,
    Object? isRead = null,
    Object? isAcknowledged = null,
    Object? readAt = freezed,
    Object? acknowledgedAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$AlertImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isAcknowledged: null == isAcknowledged
          ? _value.isAcknowledged
          : isAcknowledged // ignore: cast_nullable_to_non_nullable
              as bool,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      acknowledgedAt: freezed == acknowledgedAt
          ? _value.acknowledgedAt
          : acknowledgedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertImpl implements _Alert {
  const _$AlertImpl(
      {required this.id,
      required this.patientId,
      required this.type,
      required this.severity,
      required this.message,
      this.isRead = false,
      this.isAcknowledged = false,
      this.readAt,
      this.acknowledgedAt,
      required this.createdAt,
      this.updatedAt});

  factory _$AlertImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertImplFromJson(json);

  @override
  final int id;
  @override
  final int patientId;
  @override
  final String type;
  @override
  final String severity;
  @override
  final String message;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isAcknowledged;
  @override
  final DateTime? readAt;
  @override
  final DateTime? acknowledgedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Alert(id: $id, patientId: $patientId, type: $type, severity: $severity, message: $message, isRead: $isRead, isAcknowledged: $isAcknowledged, readAt: $readAt, acknowledgedAt: $acknowledgedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isAcknowledged, isAcknowledged) ||
                other.isAcknowledged == isAcknowledged) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.acknowledgedAt, acknowledgedAt) ||
                other.acknowledgedAt == acknowledgedAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      patientId,
      type,
      severity,
      message,
      isRead,
      isAcknowledged,
      readAt,
      acknowledgedAt,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      __$$AlertImplCopyWithImpl<_$AlertImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertImplToJson(
      this,
    );
  }
}

abstract class _Alert implements Alert {
  const factory _Alert(
      {required final int id,
      required final int patientId,
      required final String type,
      required final String severity,
      required final String message,
      final bool isRead,
      final bool isAcknowledged,
      final DateTime? readAt,
      final DateTime? acknowledgedAt,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$AlertImpl;

  factory _Alert.fromJson(Map<String, dynamic> json) = _$AlertImpl.fromJson;

  @override
  int get id;
  @override
  int get patientId;
  @override
  String get type;
  @override
  String get severity;
  @override
  String get message;
  @override
  bool get isRead;
  @override
  bool get isAcknowledged;
  @override
  DateTime? get readAt;
  @override
  DateTime? get acknowledgedAt;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$AlertImplCopyWith<_$AlertImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AlertResponse _$AlertResponseFromJson(Map<String, dynamic> json) {
  return _AlertResponse.fromJson(json);
}

/// @nodoc
mixin _$AlertResponse {
  List<Alert> get alerts => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AlertResponseCopyWith<AlertResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlertResponseCopyWith<$Res> {
  factory $AlertResponseCopyWith(
          AlertResponse value, $Res Function(AlertResponse) then) =
      _$AlertResponseCopyWithImpl<$Res, AlertResponse>;
  @useResult
  $Res call({List<Alert> alerts, int total, int unreadCount});
}

/// @nodoc
class _$AlertResponseCopyWithImpl<$Res, $Val extends AlertResponse>
    implements $AlertResponseCopyWith<$Res> {
  _$AlertResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alerts = null,
    Object? total = null,
    Object? unreadCount = null,
  }) {
    return _then(_value.copyWith(
      alerts: null == alerts
          ? _value.alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<Alert>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AlertResponseImplCopyWith<$Res>
    implements $AlertResponseCopyWith<$Res> {
  factory _$$AlertResponseImplCopyWith(
          _$AlertResponseImpl value, $Res Function(_$AlertResponseImpl) then) =
      __$$AlertResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Alert> alerts, int total, int unreadCount});
}

/// @nodoc
class __$$AlertResponseImplCopyWithImpl<$Res>
    extends _$AlertResponseCopyWithImpl<$Res, _$AlertResponseImpl>
    implements _$$AlertResponseImplCopyWith<$Res> {
  __$$AlertResponseImplCopyWithImpl(
      _$AlertResponseImpl _value, $Res Function(_$AlertResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? alerts = null,
    Object? total = null,
    Object? unreadCount = null,
  }) {
    return _then(_$AlertResponseImpl(
      alerts: null == alerts
          ? _value._alerts
          : alerts // ignore: cast_nullable_to_non_nullable
              as List<Alert>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlertResponseImpl implements _AlertResponse {
  const _$AlertResponseImpl(
      {required final List<Alert> alerts,
      required this.total,
      required this.unreadCount})
      : _alerts = alerts;

  factory _$AlertResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlertResponseImplFromJson(json);

  final List<Alert> _alerts;
  @override
  List<Alert> get alerts {
    if (_alerts is EqualUnmodifiableListView) return _alerts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alerts);
  }

  @override
  final int total;
  @override
  final int unreadCount;

  @override
  String toString() {
    return 'AlertResponse(alerts: $alerts, total: $total, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlertResponseImpl &&
            const DeepCollectionEquality().equals(other._alerts, _alerts) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_alerts), total, unreadCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlertResponseImplCopyWith<_$AlertResponseImpl> get copyWith =>
      __$$AlertResponseImplCopyWithImpl<_$AlertResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlertResponseImplToJson(
      this,
    );
  }
}

abstract class _AlertResponse implements AlertResponse {
  const factory _AlertResponse(
      {required final List<Alert> alerts,
      required final int total,
      required final int unreadCount}) = _$AlertResponseImpl;

  factory _AlertResponse.fromJson(Map<String, dynamic> json) =
      _$AlertResponseImpl.fromJson;

  @override
  List<Alert> get alerts;
  @override
  int get total;
  @override
  int get unreadCount;
  @override
  @JsonKey(ignore: true)
  _$$AlertResponseImplCopyWith<_$AlertResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DispatchAlertRequest _$DispatchAlertRequestFromJson(Map<String, dynamic> json) {
  return _DispatchAlertRequest.fromJson(json);
}

/// @nodoc
mixin _$DispatchAlertRequest {
  int get patientId => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DispatchAlertRequestCopyWith<DispatchAlertRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DispatchAlertRequestCopyWith<$Res> {
  factory $DispatchAlertRequestCopyWith(DispatchAlertRequest value,
          $Res Function(DispatchAlertRequest) then) =
      _$DispatchAlertRequestCopyWithImpl<$Res, DispatchAlertRequest>;
  @useResult
  $Res call({int patientId, String type, String severity, String message});
}

/// @nodoc
class _$DispatchAlertRequestCopyWithImpl<$Res,
        $Val extends DispatchAlertRequest>
    implements $DispatchAlertRequestCopyWith<$Res> {
  _$DispatchAlertRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? type = null,
    Object? severity = null,
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DispatchAlertRequestImplCopyWith<$Res>
    implements $DispatchAlertRequestCopyWith<$Res> {
  factory _$$DispatchAlertRequestImplCopyWith(_$DispatchAlertRequestImpl value,
          $Res Function(_$DispatchAlertRequestImpl) then) =
      __$$DispatchAlertRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int patientId, String type, String severity, String message});
}

/// @nodoc
class __$$DispatchAlertRequestImplCopyWithImpl<$Res>
    extends _$DispatchAlertRequestCopyWithImpl<$Res, _$DispatchAlertRequestImpl>
    implements _$$DispatchAlertRequestImplCopyWith<$Res> {
  __$$DispatchAlertRequestImplCopyWithImpl(_$DispatchAlertRequestImpl _value,
      $Res Function(_$DispatchAlertRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? type = null,
    Object? severity = null,
    Object? message = null,
  }) {
    return _then(_$DispatchAlertRequestImpl(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DispatchAlertRequestImpl implements _DispatchAlertRequest {
  const _$DispatchAlertRequestImpl(
      {required this.patientId,
      required this.type,
      required this.severity,
      required this.message});

  factory _$DispatchAlertRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$DispatchAlertRequestImplFromJson(json);

  @override
  final int patientId;
  @override
  final String type;
  @override
  final String severity;
  @override
  final String message;

  @override
  String toString() {
    return 'DispatchAlertRequest(patientId: $patientId, type: $type, severity: $severity, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DispatchAlertRequestImpl &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, patientId, type, severity, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DispatchAlertRequestImplCopyWith<_$DispatchAlertRequestImpl>
      get copyWith =>
          __$$DispatchAlertRequestImplCopyWithImpl<_$DispatchAlertRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DispatchAlertRequestImplToJson(
      this,
    );
  }
}

abstract class _DispatchAlertRequest implements DispatchAlertRequest {
  const factory _DispatchAlertRequest(
      {required final int patientId,
      required final String type,
      required final String severity,
      required final String message}) = _$DispatchAlertRequestImpl;

  factory _DispatchAlertRequest.fromJson(Map<String, dynamic> json) =
      _$DispatchAlertRequestImpl.fromJson;

  @override
  int get patientId;
  @override
  String get type;
  @override
  String get severity;
  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$DispatchAlertRequestImplCopyWith<_$DispatchAlertRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
