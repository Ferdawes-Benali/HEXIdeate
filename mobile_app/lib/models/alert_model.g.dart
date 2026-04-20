// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertImpl _$$AlertImplFromJson(Map<String, dynamic> json) => _$AlertImpl(
      id: (json['id'] as num).toInt(),
      patientId: (json['patientId'] as num).toInt(),
      type: json['type'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      acknowledgedAt: json['acknowledgedAt'] == null
          ? null
          : DateTime.parse(json['acknowledgedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AlertImplToJson(_$AlertImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patientId': instance.patientId,
      'type': instance.type,
      'severity': instance.severity,
      'message': instance.message,
      'isRead': instance.isRead,
      'isAcknowledged': instance.isAcknowledged,
      'readAt': instance.readAt?.toIso8601String(),
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$AlertResponseImpl _$$AlertResponseImplFromJson(Map<String, dynamic> json) =>
    _$AlertResponseImpl(
      alerts: (json['alerts'] as List<dynamic>)
          .map((e) => Alert.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toInt(),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );

Map<String, dynamic> _$$AlertResponseImplToJson(_$AlertResponseImpl instance) =>
    <String, dynamic>{
      'alerts': instance.alerts,
      'total': instance.total,
      'unreadCount': instance.unreadCount,
    };

_$DispatchAlertRequestImpl _$$DispatchAlertRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$DispatchAlertRequestImpl(
      patientId: (json['patientId'] as num).toInt(),
      type: json['type'] as String,
      severity: json['severity'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$$DispatchAlertRequestImplToJson(
        _$DispatchAlertRequestImpl instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'type': instance.type,
      'severity': instance.severity,
      'message': instance.message,
    };
