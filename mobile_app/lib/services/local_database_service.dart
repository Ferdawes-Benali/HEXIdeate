import 'package:hexideate/services/hive_adapters.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medication_model.dart';
import '../models/patient_model.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();
  static const String medicationsBoxName = 'medications';
  static const String patientsBoxName = 'patients';
  static const String intakeHistoryBoxName = 'intake_history';

  late Box<Medication> _medicationsBox;
  late Box<Patient> _patientsBox;
  late Box<IntakeHistory> _intakeHistoryBox;

  Future<void> init() async {
    if (Hive.isBoxOpen(medicationsBoxName)) {
    logger.i('Database already initialized, skipping');
    return;
  }
  
    await Hive.initFlutter();
    
    // 1. Register Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicationAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PatientAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(IntakeHistoryAdapter());
    }

    // 2. OPEN AND ASSIGN THE BOXES (This is the crucial fix)
    _medicationsBox = await Hive.openBox<Medication>(medicationsBoxName);
    _patientsBox = await Hive.openBox<Patient>(patientsBoxName);
    _intakeHistoryBox = await Hive.openBox<IntakeHistory>(intakeHistoryBoxName);

    logger.i('💡 Local database initialized and all boxes opened');
  }


  /// Cache medications locally
  Future<void> cacheMedications(List<Medication> medications, int patientId) async {
    try {
      await _medicationsBox.clear();
      for (var med in medications) {
        await _medicationsBox.put(med.id, med);
      }
      logger.i('Cached ${medications.length} medications for patient $patientId');
    } catch (e) {
      logger.e('Error caching medications: $e');
      rethrow;
    }
  }

  /// Get cached medications
  List<Medication> getCachedMedications() {
    try {
      return _medicationsBox.values.toList();
    } catch (e) {
      logger.e('Error retrieving cached medications: $e');
      return [];
    }
  }

  /// Get single medication by ID
  Medication? getMedicationById(int id) {
    try {
      return _medicationsBox.get(id);
    } catch (e) {
      logger.e('Error retrieving medication $id: $e');
      return null;
    }
  }

  /// Cache patient data
  Future<void> cachePatient(Patient patient) async {
    try {
      await _patientsBox.put(patient.id, patient);
      logger.i('Cached patient ${patient.id}');
    } catch (e) {
      logger.e('Error caching patient: $e');
      rethrow;
    }
  }

  /// Get cached patient
  Patient? getCachedPatient(int patientId) {
    try {
      return _patientsBox.get(patientId);
    } catch (e) {
      logger.e('Error retrieving cached patient: $e');
      return null;
    }
  }

  /// Record medication intake
  Future<void> recordIntake(IntakeHistory history) async {
    try {
      await _intakeHistoryBox.put(history.id, history);
      logger.i('Recorded intake for medication ${history.medicationId}');
    } catch (e) {
      logger.e('Error recording intake: $e');
      rethrow;
    }
  }

  /// Get intake history for a medication
  List<IntakeHistory> getIntakeHistory(int medicationId) {
    try {
      return _intakeHistoryBox.values
          .where((h) => h.medicationId == medicationId)
          .toList();
    } catch (e) {
      logger.e('Error retrieving intake history: $e');
      return [];
    }
  }

  /// Clear all cached data
  Future<void> clearAll() async {
    try {
      await _medicationsBox.clear();
      await _patientsBox.clear();
      await _intakeHistoryBox.clear();
      logger.i('Cleared all local database');
    } catch (e) {
      logger.e('Error clearing database: $e');
      rethrow;
    }
  }
}
