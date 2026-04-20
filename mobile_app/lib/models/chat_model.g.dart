// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      role: json['role'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

_$AgentRequestImpl _$$AgentRequestImplFromJson(Map<String, dynamic> json) =>
    _$AgentRequestImpl(
      userId: (json['userId'] as num).toInt(),
      message: json['message'] as String,
      videoInput: json['videoInput'] as String?,
    );

Map<String, dynamic> _$$AgentRequestImplToJson(_$AgentRequestImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'message': instance.message,
      'videoInput': instance.videoInput,
    };

_$AgentResponseImpl _$$AgentResponseImplFromJson(Map<String, dynamic> json) =>
    _$AgentResponseImpl(
      messages: (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String?,
      expectedPill: json['expectedPill'] as String?,
      identifiedPills: (json['identifiedPills'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      safetyAlert: json['safetyAlert'] as bool?,
    );

Map<String, dynamic> _$$AgentResponseImplToJson(_$AgentResponseImpl instance) =>
    <String, dynamic>{
      'messages': instance.messages,
      'status': instance.status,
      'expectedPill': instance.expectedPill,
      'identifiedPills': instance.identifiedPills,
      'safetyAlert': instance.safetyAlert,
    };

_$ChatRequestImpl _$$ChatRequestImplFromJson(Map<String, dynamic> json) =>
    _$ChatRequestImpl(
      message: json['message'] as String,
      videoInput: json['videoInput'] as String?,
    );

Map<String, dynamic> _$$ChatRequestImplToJson(_$ChatRequestImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'videoInput': instance.videoInput,
    };

_$ChatResponseImpl _$$ChatResponseImplFromJson(Map<String, dynamic> json) =>
    _$ChatResponseImpl(
      reply: json['reply'] as String,
      status: json['status'] as String?,
      safetyAlert: json['safetyAlert'] as bool?,
    );

Map<String, dynamic> _$$ChatResponseImplToJson(_$ChatResponseImpl instance) =>
    <String, dynamic>{
      'reply': instance.reply,
      'status': instance.status,
      'safetyAlert': instance.safetyAlert,
    };
