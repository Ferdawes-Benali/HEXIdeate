// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PatientImpl _$$PatientImplFromJson(Map<String, dynamic> json) =>
    _$PatientImpl(
      id: (json['id'] as num).toInt(),
      fullName: json['fullName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      emergencyContact: json['emergencyContact'] as String,
      emergencyContactPhone: json['emergencyContactPhone'] as String,
      languagePreference: json['languagePreference'] as String? ?? 'ar',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$PatientImplToJson(_$PatientImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'emergencyContact': instance.emergencyContact,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'languagePreference': instance.languagePreference,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$PatientCreateRequestImpl _$$PatientCreateRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$PatientCreateRequestImpl(
      fullName: json['fullName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      emergencyContact: json['emergencyContact'] as String,
      emergencyContactPhone: json['emergencyContactPhone'] as String,
      languagePreference: json['languagePreference'] as String? ?? 'ar',
    );

Map<String, dynamic> _$$PatientCreateRequestImplToJson(
        _$PatientCreateRequestImpl instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'emergencyContact': instance.emergencyContact,
      'emergencyContactPhone': instance.emergencyContactPhone,
      'languagePreference': instance.languagePreference,
    };
