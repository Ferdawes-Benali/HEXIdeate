import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../core/constants/api_constants.dart';

final logger = Logger();

class MismatchAlertService {
  final Dio _dio;

  MismatchAlertService(this._dio);

  /// Check for drug interactions
  /// [medications]: List of medication names
  Future<List<Map<String, dynamic>>> checkDrugInteractions(
    List<String> medications,
  ) async {
    try {
      if (medications.length < 2) {
        return [];
      }

      final response = await _dio.post(
        ApiConstants.analyticsStats, // Using notifications endpoint
        data: {
          'medications': medications,
        },
      );

      if (response.statusCode == 200) {
        final interactions = response.data['interactions'] as List?;
        if (interactions == null) return [];

        return List<Map<String, dynamic>>.from(interactions);
      } else {
        throw Exception('Failed to check interactions: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Drug interaction check error: $e');
      return [];
    }
  }

  /// Dispatch a mismatch alert to patient
  /// [patientId]: Patient ID
  /// [alertType]: Type of alert (wrong_pill, drug_interaction, missed_dose)
  /// [message]: Alert message
  /// [severity]: Alert severity (low, medium, high)
  Future<bool> dispatchAlert({
    required int patientId,
    required String alertType,
    required String message,
    required String severity,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.notificationsDispatch,
        data: {
          'patient_id': patientId,
          'alert_type': alertType,
          'message': message,
          'severity': severity,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      logger.e('Alert dispatch error: $e');
      return false;
    }
  }

  /// Check if detected pill matches patient's medications
  /// Uses fuzzy matching from backend
  /// [patientId]: Patient ID
  /// [detectedPillName]: Detected pill name from OCR/Vision
  /// [patientMedications]: Patient's current medications
  Future<Map<String, dynamic>> fuzzyMatchPill({
    required int patientId,
    required String detectedPillName,
    required List<String> patientMedications,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.apiPrefix}/agent/verify-pill',
        data: {
          'patient_id': patientId,
          'detected_pill': detectedPillName,
          'patient_medications': patientMedications,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to verify pill: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Pill verification error: $e');
      return {
        'status': 'error',
        'match_type': 'UNKNOWN',
        'message': 'Unable to verify pill',
      };
    }
  }

  /// Handle wrong pill detection with immediate alert
  /// [patientId]: Patient ID
  /// [detectedPill]: Wrong pill detected
  /// [expectedPills]: List of expected pills at this time
  Future<void> handleWrongPillDetected({
    required int patientId,
    required String detectedPill,
    required List<String> expectedPills,
  }) async {
    try {
      final message =
          'Attention! Vous avez pris $detectedPill mais vous deviez prendre ${expectedPills.join(" ou ")}';

      await dispatchAlert(
        patientId: patientId,
        alertType: 'wrong_pill',
        message: message,
        severity: 'high',
      );

      logger.w('Wrong pill alert dispatched for patient $patientId');
    } catch (e) {
      logger.e('Error handling wrong pill: $e');
    }
  }

  /// Handle missed dose detection
  /// [patientId]: Patient ID
  /// [medication]: Medication name
  /// [scheduledTime]: Scheduled time for medication
  Future<void> handleMissedDose({
    required int patientId,
    required String medication,
    required String scheduledTime,
  }) async {
    try {
      final message =
          'Vous avez manqué votre dose de $medication à $scheduledTime. Prennez-la dès que possible si pas contre-indiqué.';

      await dispatchAlert(
        patientId: patientId,
        alertType: 'missed_dose',
        message: message,
        severity: 'medium',
      );

      logger.i('Missed dose alert dispatched for patient $patientId');
    } catch (e) {
      logger.e('Error handling missed dose: $e');
    }
  }

  /// Get recent alerts for patient
  Future<List<Map<String, dynamic>>> getPatientAlerts(int patientId) async {
    try {
      final response = await _dio.get(
        ApiConstants.notificationsPatientAlerts.replaceFirst(
          '{patient_id}',
          patientId.toString(),
        ),
      );

      if (response.statusCode == 200) {
        final alerts = response.data['alerts'] as List?;
        if (alerts == null) return [];

        return List<Map<String, dynamic>>.from(alerts);
      }

      return [];
    } catch (e) {
      logger.e('Error fetching alerts: $e');
      return [];
    }
  }

  /// Acknowledge an alert
  Future<bool> acknowledgeAlert(int alertId) async {
    try {
      final response = await _dio.post(
        ApiConstants.notificationAcknowledge.replaceFirst(
          '{alert_id}',
          alertId.toString(),
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      logger.e('Error acknowledging alert: $e');
      return false;
    }
  }
}
