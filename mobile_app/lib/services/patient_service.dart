import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/patient_model.dart';

final logger = Logger();

class PatientService {
  final ApiClient _apiClient;

  PatientService(this._apiClient);

  /// Fetch a patient by ID
  Future<Patient> getPatient(int patientId) async {
    try {
      return await _apiClient.get<Patient>(
        ApiConstants.patients,
        queryParameters: {'id': patientId},
        fromJson: (json) => Patient.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error fetching patient: $e');
      rethrow;
    }
  }

  /// Create a new patient
  Future<Patient> createPatient(PatientCreateRequest request) async {
    try {
      return await _apiClient.post<Patient>(
        ApiConstants.patients,
        data: request.toJson(),
        fromJson: (json) => Patient.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error creating patient: $e');
      rethrow;
    }
  }

  /// Get medications for a patient
  Future<List<dynamic>> getPatientMedications(int patientId) async {
    try {
      final path = ApiConstants.patientMedications.replaceFirst('{id}', '$patientId');
      final response = await _apiClient.get<List>(
        path,
        fromJson: (json) => json as List,
      );
      return response;
    } catch (e) {
      logger.e('Error fetching patient medications: $e');
      rethrow;
    }
  }
}
