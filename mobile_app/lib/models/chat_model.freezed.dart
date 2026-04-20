// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) {
  return _ChatMessage.fromJson(json);
}

/// @nodoc
mixin _$ChatMessage {
  String get role => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatMessageCopyWith<ChatMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatMessageCopyWith<$Res> {
  factory $ChatMessageCopyWith(
          ChatMessage value, $Res Function(ChatMessage) then) =
      _$ChatMessageCopyWithImpl<$Res, ChatMessage>;
  @useResult
  $Res call({String role, String content, DateTime? timestamp});
}

/// @nodoc
class _$ChatMessageCopyWithImpl<$Res, $Val extends ChatMessage>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? timestamp = freezed,
  }) {
    return _then(_value.copyWith(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatMessageImplCopyWith<$Res>
    implements $ChatMessageCopyWith<$Res> {
  factory _$$ChatMessageImplCopyWith(
          _$ChatMessageImpl value, $Res Function(_$ChatMessageImpl) then) =
      __$$ChatMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String role, String content, DateTime? timestamp});
}

/// @nodoc
class __$$ChatMessageImplCopyWithImpl<$Res>
    extends _$ChatMessageCopyWithImpl<$Res, _$ChatMessageImpl>
    implements _$$ChatMessageImplCopyWith<$Res> {
  __$$ChatMessageImplCopyWithImpl(
      _$ChatMessageImpl _value, $Res Function(_$ChatMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? role = null,
    Object? content = null,
    Object? timestamp = freezed,
  }) {
    return _then(_$ChatMessageImpl(
      role: null == role
          ? _value.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatMessageImpl implements _ChatMessage {
  const _$ChatMessageImpl(
      {required this.role, required this.content, this.timestamp});

  factory _$ChatMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatMessageImplFromJson(json);

  @override
  final String role;
  @override
  final String content;
  @override
  final DateTime? timestamp;

  @override
  String toString() {
    return 'ChatMessage(role: $role, content: $content, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatMessageImpl &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, role, content, timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      __$$ChatMessageImplCopyWithImpl<_$ChatMessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatMessageImplToJson(
      this,
    );
  }
}

abstract class _ChatMessage implements ChatMessage {
  const factory _ChatMessage(
      {required final String role,
      required final String content,
      final DateTime? timestamp}) = _$ChatMessageImpl;

  factory _ChatMessage.fromJson(Map<String, dynamic> json) =
      _$ChatMessageImpl.fromJson;

  @override
  String get role;
  @override
  String get content;
  @override
  DateTime? get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$ChatMessageImplCopyWith<_$ChatMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AgentRequest _$AgentRequestFromJson(Map<String, dynamic> json) {
  return _AgentRequest.fromJson(json);
}

/// @nodoc
mixin _$AgentRequest {
  int get userId => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  String? get videoInput => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AgentRequestCopyWith<AgentRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentRequestCopyWith<$Res> {
  factory $AgentRequestCopyWith(
          AgentRequest value, $Res Function(AgentRequest) then) =
      _$AgentRequestCopyWithImpl<$Res, AgentRequest>;
  @useResult
  $Res call({int userId, String message, String? videoInput});
}

/// @nodoc
class _$AgentRequestCopyWithImpl<$Res, $Val extends AgentRequest>
    implements $AgentRequestCopyWith<$Res> {
  _$AgentRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? message = null,
    Object? videoInput = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      videoInput: freezed == videoInput
          ? _value.videoInput
          : videoInput // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AgentRequestImplCopyWith<$Res>
    implements $AgentRequestCopyWith<$Res> {
  factory _$$AgentRequestImplCopyWith(
          _$AgentRequestImpl value, $Res Function(_$AgentRequestImpl) then) =
      __$$AgentRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int userId, String message, String? videoInput});
}

/// @nodoc
class __$$AgentRequestImplCopyWithImpl<$Res>
    extends _$AgentRequestCopyWithImpl<$Res, _$AgentRequestImpl>
    implements _$$AgentRequestImplCopyWith<$Res> {
  __$$AgentRequestImplCopyWithImpl(
      _$AgentRequestImpl _value, $Res Function(_$AgentRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? message = null,
    Object? videoInput = freezed,
  }) {
    return _then(_$AgentRequestImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      videoInput: freezed == videoInput
          ? _value.videoInput
          : videoInput // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AgentRequestImpl implements _AgentRequest {
  const _$AgentRequestImpl(
      {required this.userId, required this.message, this.videoInput});

  factory _$AgentRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentRequestImplFromJson(json);

  @override
  final int userId;
  @override
  final String message;
  @override
  final String? videoInput;

  @override
  String toString() {
    return 'AgentRequest(userId: $userId, message: $message, videoInput: $videoInput)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentRequestImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.videoInput, videoInput) ||
                other.videoInput == videoInput));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, message, videoInput);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentRequestImplCopyWith<_$AgentRequestImpl> get copyWith =>
      __$$AgentRequestImplCopyWithImpl<_$AgentRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentRequestImplToJson(
      this,
    );
  }
}

abstract class _AgentRequest implements AgentRequest {
  const factory _AgentRequest(
      {required final int userId,
      required final String message,
      final String? videoInput}) = _$AgentRequestImpl;

  factory _AgentRequest.fromJson(Map<String, dynamic> json) =
      _$AgentRequestImpl.fromJson;

  @override
  int get userId;
  @override
  String get message;
  @override
  String? get videoInput;
  @override
  @JsonKey(ignore: true)
  _$$AgentRequestImplCopyWith<_$AgentRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AgentResponse _$AgentResponseFromJson(Map<String, dynamic> json) {
  return _AgentResponse.fromJson(json);
}

/// @nodoc
mixin _$AgentResponse {
  List<ChatMessage> get messages => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get expectedPill => throw _privateConstructorUsedError;
  List<String> get identifiedPills => throw _privateConstructorUsedError;
  bool? get safetyAlert => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AgentResponseCopyWith<AgentResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AgentResponseCopyWith<$Res> {
  factory $AgentResponseCopyWith(
          AgentResponse value, $Res Function(AgentResponse) then) =
      _$AgentResponseCopyWithImpl<$Res, AgentResponse>;
  @useResult
  $Res call(
      {List<ChatMessage> messages,
      String? status,
      String? expectedPill,
      List<String> identifiedPills,
      bool? safetyAlert});
}

/// @nodoc
class _$AgentResponseCopyWithImpl<$Res, $Val extends AgentResponse>
    implements $AgentResponseCopyWith<$Res> {
  _$AgentResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? status = freezed,
    Object? expectedPill = freezed,
    Object? identifiedPills = null,
    Object? safetyAlert = freezed,
  }) {
    return _then(_value.copyWith(
      messages: null == messages
          ? _value.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedPill: freezed == expectedPill
          ? _value.expectedPill
          : expectedPill // ignore: cast_nullable_to_non_nullable
              as String?,
      identifiedPills: null == identifiedPills
          ? _value.identifiedPills
          : identifiedPills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      safetyAlert: freezed == safetyAlert
          ? _value.safetyAlert
          : safetyAlert // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AgentResponseImplCopyWith<$Res>
    implements $AgentResponseCopyWith<$Res> {
  factory _$$AgentResponseImplCopyWith(
          _$AgentResponseImpl value, $Res Function(_$AgentResponseImpl) then) =
      __$$AgentResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ChatMessage> messages,
      String? status,
      String? expectedPill,
      List<String> identifiedPills,
      bool? safetyAlert});
}

/// @nodoc
class __$$AgentResponseImplCopyWithImpl<$Res>
    extends _$AgentResponseCopyWithImpl<$Res, _$AgentResponseImpl>
    implements _$$AgentResponseImplCopyWith<$Res> {
  __$$AgentResponseImplCopyWithImpl(
      _$AgentResponseImpl _value, $Res Function(_$AgentResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? messages = null,
    Object? status = freezed,
    Object? expectedPill = freezed,
    Object? identifiedPills = null,
    Object? safetyAlert = freezed,
  }) {
    return _then(_$AgentResponseImpl(
      messages: null == messages
          ? _value._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<ChatMessage>,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      expectedPill: freezed == expectedPill
          ? _value.expectedPill
          : expectedPill // ignore: cast_nullable_to_non_nullable
              as String?,
      identifiedPills: null == identifiedPills
          ? _value._identifiedPills
          : identifiedPills // ignore: cast_nullable_to_non_nullable
              as List<String>,
      safetyAlert: freezed == safetyAlert
          ? _value.safetyAlert
          : safetyAlert // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AgentResponseImpl implements _AgentResponse {
  const _$AgentResponseImpl(
      {required final List<ChatMessage> messages,
      this.status,
      this.expectedPill,
      final List<String> identifiedPills = const [],
      this.safetyAlert})
      : _messages = messages,
        _identifiedPills = identifiedPills;

  factory _$AgentResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AgentResponseImplFromJson(json);

  final List<ChatMessage> _messages;
  @override
  List<ChatMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final String? status;
  @override
  final String? expectedPill;
  final List<String> _identifiedPills;
  @override
  @JsonKey()
  List<String> get identifiedPills {
    if (_identifiedPills is EqualUnmodifiableListView) return _identifiedPills;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_identifiedPills);
  }

  @override
  final bool? safetyAlert;

  @override
  String toString() {
    return 'AgentResponse(messages: $messages, status: $status, expectedPill: $expectedPill, identifiedPills: $identifiedPills, safetyAlert: $safetyAlert)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AgentResponseImpl &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.expectedPill, expectedPill) ||
                other.expectedPill == expectedPill) &&
            const DeepCollectionEquality()
                .equals(other._identifiedPills, _identifiedPills) &&
            (identical(other.safetyAlert, safetyAlert) ||
                other.safetyAlert == safetyAlert));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_messages),
      status,
      expectedPill,
      const DeepCollectionEquality().hash(_identifiedPills),
      safetyAlert);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AgentResponseImplCopyWith<_$AgentResponseImpl> get copyWith =>
      __$$AgentResponseImplCopyWithImpl<_$AgentResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AgentResponseImplToJson(
      this,
    );
  }
}

abstract class _AgentResponse implements AgentResponse {
  const factory _AgentResponse(
      {required final List<ChatMessage> messages,
      final String? status,
      final String? expectedPill,
      final List<String> identifiedPills,
      final bool? safetyAlert}) = _$AgentResponseImpl;

  factory _AgentResponse.fromJson(Map<String, dynamic> json) =
      _$AgentResponseImpl.fromJson;

  @override
  List<ChatMessage> get messages;
  @override
  String? get status;
  @override
  String? get expectedPill;
  @override
  List<String> get identifiedPills;
  @override
  bool? get safetyAlert;
  @override
  @JsonKey(ignore: true)
  _$$AgentResponseImplCopyWith<_$AgentResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatRequest _$ChatRequestFromJson(Map<String, dynamic> json) {
  return _ChatRequest.fromJson(json);
}

/// @nodoc
mixin _$ChatRequest {
  String get message => throw _privateConstructorUsedError;
  String? get videoInput => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatRequestCopyWith<ChatRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatRequestCopyWith<$Res> {
  factory $ChatRequestCopyWith(
          ChatRequest value, $Res Function(ChatRequest) then) =
      _$ChatRequestCopyWithImpl<$Res, ChatRequest>;
  @useResult
  $Res call({String message, String? videoInput});
}

/// @nodoc
class _$ChatRequestCopyWithImpl<$Res, $Val extends ChatRequest>
    implements $ChatRequestCopyWith<$Res> {
  _$ChatRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? videoInput = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      videoInput: freezed == videoInput
          ? _value.videoInput
          : videoInput // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatRequestImplCopyWith<$Res>
    implements $ChatRequestCopyWith<$Res> {
  factory _$$ChatRequestImplCopyWith(
          _$ChatRequestImpl value, $Res Function(_$ChatRequestImpl) then) =
      __$$ChatRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, String? videoInput});
}

/// @nodoc
class __$$ChatRequestImplCopyWithImpl<$Res>
    extends _$ChatRequestCopyWithImpl<$Res, _$ChatRequestImpl>
    implements _$$ChatRequestImplCopyWith<$Res> {
  __$$ChatRequestImplCopyWithImpl(
      _$ChatRequestImpl _value, $Res Function(_$ChatRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? videoInput = freezed,
  }) {
    return _then(_$ChatRequestImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      videoInput: freezed == videoInput
          ? _value.videoInput
          : videoInput // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatRequestImpl implements _ChatRequest {
  const _$ChatRequestImpl({required this.message, this.videoInput});

  factory _$ChatRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatRequestImplFromJson(json);

  @override
  final String message;
  @override
  final String? videoInput;

  @override
  String toString() {
    return 'ChatRequest(message: $message, videoInput: $videoInput)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatRequestImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.videoInput, videoInput) ||
                other.videoInput == videoInput));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, message, videoInput);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatRequestImplCopyWith<_$ChatRequestImpl> get copyWith =>
      __$$ChatRequestImplCopyWithImpl<_$ChatRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatRequestImplToJson(
      this,
    );
  }
}

abstract class _ChatRequest implements ChatRequest {
  const factory _ChatRequest(
      {required final String message,
      final String? videoInput}) = _$ChatRequestImpl;

  factory _ChatRequest.fromJson(Map<String, dynamic> json) =
      _$ChatRequestImpl.fromJson;

  @override
  String get message;
  @override
  String? get videoInput;
  @override
  @JsonKey(ignore: true)
  _$$ChatRequestImplCopyWith<_$ChatRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) {
  return _ChatResponse.fromJson(json);
}

/// @nodoc
mixin _$ChatResponse {
  String get reply => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  bool? get safetyAlert => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ChatResponseCopyWith<ChatResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatResponseCopyWith<$Res> {
  factory $ChatResponseCopyWith(
          ChatResponse value, $Res Function(ChatResponse) then) =
      _$ChatResponseCopyWithImpl<$Res, ChatResponse>;
  @useResult
  $Res call({String reply, String? status, bool? safetyAlert});
}

/// @nodoc
class _$ChatResponseCopyWithImpl<$Res, $Val extends ChatResponse>
    implements $ChatResponseCopyWith<$Res> {
  _$ChatResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reply = null,
    Object? status = freezed,
    Object? safetyAlert = freezed,
  }) {
    return _then(_value.copyWith(
      reply: null == reply
          ? _value.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      safetyAlert: freezed == safetyAlert
          ? _value.safetyAlert
          : safetyAlert // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatResponseImplCopyWith<$Res>
    implements $ChatResponseCopyWith<$Res> {
  factory _$$ChatResponseImplCopyWith(
          _$ChatResponseImpl value, $Res Function(_$ChatResponseImpl) then) =
      __$$ChatResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String reply, String? status, bool? safetyAlert});
}

/// @nodoc
class __$$ChatResponseImplCopyWithImpl<$Res>
    extends _$ChatResponseCopyWithImpl<$Res, _$ChatResponseImpl>
    implements _$$ChatResponseImplCopyWith<$Res> {
  __$$ChatResponseImplCopyWithImpl(
      _$ChatResponseImpl _value, $Res Function(_$ChatResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reply = null,
    Object? status = freezed,
    Object? safetyAlert = freezed,
  }) {
    return _then(_$ChatResponseImpl(
      reply: null == reply
          ? _value.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as String,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      safetyAlert: freezed == safetyAlert
          ? _value.safetyAlert
          : safetyAlert // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatResponseImpl implements _ChatResponse {
  const _$ChatResponseImpl(
      {required this.reply, this.status, this.safetyAlert});

  factory _$ChatResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatResponseImplFromJson(json);

  @override
  final String reply;
  @override
  final String? status;
  @override
  final bool? safetyAlert;

  @override
  String toString() {
    return 'ChatResponse(reply: $reply, status: $status, safetyAlert: $safetyAlert)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatResponseImpl &&
            (identical(other.reply, reply) || other.reply == reply) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.safetyAlert, safetyAlert) ||
                other.safetyAlert == safetyAlert));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, reply, status, safetyAlert);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatResponseImplCopyWith<_$ChatResponseImpl> get copyWith =>
      __$$ChatResponseImplCopyWithImpl<_$ChatResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatResponseImplToJson(
      this,
    );
  }
}

abstract class _ChatResponse implements ChatResponse {
  const factory _ChatResponse(
      {required final String reply,
      final String? status,
      final bool? safetyAlert}) = _$ChatResponseImpl;

  factory _ChatResponse.fromJson(Map<String, dynamic> json) =
      _$ChatResponseImpl.fromJson;

  @override
  String get reply;
  @override
  String? get status;
  @override
  bool? get safetyAlert;
  @override
  @JsonKey(ignore: true)
  _$$ChatResponseImplCopyWith<_$ChatResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
