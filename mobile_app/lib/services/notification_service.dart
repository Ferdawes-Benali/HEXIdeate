import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/alert_model.dart';

final logger = Logger();

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  /// Get alerts for a patient
  Future<AlertResponse> getPatientAlerts(int patientId) async {
    try {
      final path = ApiConstants.notificationsPatientAlerts.replaceFirst(
        '{patient_id}',
        '$patientId',
      );
      return await _apiClient.get<AlertResponse>(
        path,
        fromJson: (json) => AlertResponse.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error fetching patient alerts: $e');
      rethrow;
    }
  }

  /// Dispatch an alert
  Future<Alert> dispatchAlert(DispatchAlertRequest request) async {
    try {
      return await _apiClient.post<Alert>(
        ApiConstants.notificationsDispatch,
        data: request.toJson(),
        fromJson: (json) => Alert.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error dispatching alert: $e');
      rethrow;
    }
  }

  /// Mark an alert as read
  Future<Alert> markAlertAsRead(int alertId) async {
    try {
      final path = ApiConstants.notificationMarkRead.replaceFirst('{alert_id}', '$alertId');
      return await _apiClient.put<Alert>(
        path,
        fromJson: (json) => Alert.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error marking alert as read: $e');
      rethrow;
    }
  }

  /// Acknowledge an alert
  Future<Alert> acknowledgeAlert(int alertId) async {
    try {
      final path =
          ApiConstants.notificationAcknowledge.replaceFirst('{alert_id}', '$alertId');
      return await _apiClient.put<Alert>(
        path,
        fromJson: (json) => Alert.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error acknowledging alert: $e');
      rethrow;
    }
  }
}
