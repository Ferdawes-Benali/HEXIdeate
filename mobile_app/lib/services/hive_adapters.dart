import 'package:hive/hive.dart';
import '../models/medication_model.dart';
import '../models/patient_model.dart';

/// Register all Hive adapters for models
void registerHiveAdapters() {
  // Register Medication adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(MedicationAdapter());
  }
  // Register Patient adapter
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(PatientAdapter());
  }
  // Register IntakeHistory adapter
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(IntakeHistoryAdapter());
  }
}

// Hive Adapters for serialization

class MedicationAdapter extends TypeAdapter<Medication> {
  @override
  final int typeId = 0;

  @override
  Medication read(BinaryReader reader) {
    return Medication(
      id: reader.readString(),
      patientId: reader.readInt(),
      name: reader.readString(),
      genericName: reader.readString(),
      dosage: reader.readString(),
      frequency: reader.readString(),
      startDate: reader.readString().isEmpty ? null : DateTime.parse(reader.readString()),
      endDate: reader.readString().isEmpty ? null : DateTime.parse(reader.readString()),
      indication: reader.readString().isEmpty ? null : reader.readString(),
      sideEffects: reader.readString().isEmpty ? null : reader.readString(),
      createdAt: reader.readString().isEmpty ? null : DateTime.parse(reader.readString()),
      updatedAt: reader.readString().isEmpty ? null : DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, Medication obj) {
    writer.writeString(obj.id);
    writer.writeInt(obj.patientId);
    writer.writeString(obj.name);
    writer.writeString(obj.genericName);
    writer.writeString(obj.dosage);
    writer.writeString(obj.frequency);
    writer.writeString(obj.startDate?.toString() ?? '');
    writer.writeString(obj.endDate?.toString() ?? '');
    writer.writeString(obj.indication ?? '');
    writer.writeString(obj.sideEffects ?? '');
    writer.writeString(obj.createdAt?.toString() ?? '');
    writer.writeString(obj.updatedAt?.toString() ?? '');
  }
}

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 1;

  @override
  Patient read(BinaryReader reader) {
    return Patient(
      id: reader.readInt(),
      fullName: reader.readString(),
      dateOfBirth: DateTime.parse(reader.readString()),
      emergencyContact: reader.readString(),
      emergencyContactPhone: reader.readString(),
      languagePreference: reader.readString(),
      createdAt: DateTime.parse(reader.readString()),
      updatedAt: reader.readString().isEmpty ? null : DateTime.parse(reader.readString()),
    );
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.fullName);
    writer.writeString(obj.dateOfBirth.toString());
    writer.writeString(obj.emergencyContact);
    writer.writeString(obj.emergencyContactPhone);
    writer.writeString(obj.languagePreference);
    writer.writeString(obj.createdAt.toString());
    writer.writeString(obj.updatedAt?.toString() ?? '');
  }
}

class IntakeHistoryAdapter extends TypeAdapter<IntakeHistory> {
  @override
  final int typeId = 2;

  @override
  IntakeHistory read(BinaryReader reader) {
    return IntakeHistory(
      id: reader.readInt(),
      medicationId: reader.readInt(),
      timestamp: DateTime.parse(reader.readString()),
      status: reader.readString(),
      videoPath: reader.readString().isEmpty ? null : reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, IntakeHistory obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.medicationId);
    writer.writeString(obj.timestamp.toString());
    writer.writeString(obj.status);
    writer.writeString(obj.videoPath ?? '');
  }
}
