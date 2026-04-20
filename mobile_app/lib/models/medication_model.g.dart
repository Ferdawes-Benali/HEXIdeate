// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MedicationImpl _$$MedicationImplFromJson(Map<String, dynamic> json) =>
    _$MedicationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      patientId: (json['patientId'] as num).toInt(),
      genericName: json['genericName'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      indication: json['indication'] as String?,
      sideEffects: json['sideEffects'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$MedicationImplToJson(_$MedicationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'patientId': instance.patientId,
      'genericName': instance.genericName,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'startDate': instance.startDate?.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'indication': instance.indication,
      'sideEffects': instance.sideEffects,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$MedicationScheduleImpl _$$MedicationScheduleImplFromJson(
        Map<String, dynamic> json) =>
    _$MedicationScheduleImpl(
      id: (json['id'] as num).toInt(),
      medicationId: (json['medicationId'] as num).toInt(),
      timeOfDay: json['timeOfDay'] as String,
      sunday: json['sunday'] as bool? ?? false,
      monday: json['monday'] as bool? ?? false,
      tuesday: json['tuesday'] as bool? ?? false,
      wednesday: json['wednesday'] as bool? ?? false,
      thursday: json['thursday'] as bool? ?? false,
      friday: json['friday'] as bool? ?? false,
      saturday: json['saturday'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$MedicationScheduleImplToJson(
        _$MedicationScheduleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationId': instance.medicationId,
      'timeOfDay': instance.timeOfDay,
      'sunday': instance.sunday,
      'monday': instance.monday,
      'tuesday': instance.tuesday,
      'wednesday': instance.wednesday,
      'thursday': instance.thursday,
      'friday': instance.friday,
      'saturday': instance.saturday,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$IntakeHistoryImpl _$$IntakeHistoryImplFromJson(Map<String, dynamic> json) =>
    _$IntakeHistoryImpl(
      id: (json['id'] as num).toInt(),
      medicationId: (json['medicationId'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      videoPath: json['videoPath'] as String?,
    );

Map<String, dynamic> _$$IntakeHistoryImplToJson(_$IntakeHistoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationId': instance.medicationId,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': instance.status,
      'videoPath': instance.videoPath,
    };
