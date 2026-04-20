import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_model.freezed.dart';
part 'patient_model.g.dart';

@freezed
class Patient with _$Patient {
  const factory Patient({
    required int id,
    required String fullName,
    required DateTime dateOfBirth,
    required String emergencyContact,
    required String emergencyContactPhone,
    @Default('ar') String languagePreference,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Patient;

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
}

@freezed
class PatientCreateRequest with _$PatientCreateRequest {
  const factory PatientCreateRequest({
    required String fullName,
    required DateTime dateOfBirth,
    required String emergencyContact,
    required String emergencyContactPhone,
    @Default('ar') String languagePreference,
  }) = _PatientCreateRequest;

  factory PatientCreateRequest.fromJson(Map<String, dynamic> json) =>
      _$PatientCreateRequestFromJson(json);
}
