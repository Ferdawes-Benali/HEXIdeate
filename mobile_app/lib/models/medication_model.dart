import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_model.freezed.dart';
part 'medication_model.g.dart';

@freezed
class Medication with _$Medication {
  const factory Medication({
    required String id,
    required String name,
    required int patientId,
    required String genericName,
    required String dosage,
    required String frequency,
    DateTime? startDate,
    DateTime? endDate,
    String? indication,
    String? sideEffects,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Medication;

  factory Medication.fromJson(Map<String, dynamic> json) =>
      _$MedicationFromJson(json);
}

@freezed
class MedicationSchedule with _$MedicationSchedule {
  const factory MedicationSchedule({
    required int id,
    required int medicationId,
    required String timeOfDay,
    @Default(false) bool sunday,
    @Default(false) bool monday,
    @Default(false) bool tuesday,
    @Default(false) bool wednesday,
    @Default(false) bool thursday,
    @Default(false) bool friday,
    @Default(false) bool saturday,
    DateTime? createdAt,
  }) = _MedicationSchedule;

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) =>
      _$MedicationScheduleFromJson(json);
}

@freezed
class IntakeHistory with _$IntakeHistory {
  const factory IntakeHistory({
    required int id,
    required int medicationId,
    required DateTime timestamp,
    required String status,
    String? videoPath,
  }) = _IntakeHistory;

  factory IntakeHistory.fromJson(Map<String, dynamic> json) =>
      _$IntakeHistoryFromJson(json);
}
