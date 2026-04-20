import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/analytics_model.dart';

final logger = Logger();

class AnalyticsService {
  final ApiClient _apiClient;

  AnalyticsService(this._apiClient);

  /// Get adherence statistics for a patient
  Future<AdherenceStats> getAdherenceStats(int patientId) async {
    try {
      final path = ApiConstants.analyticsStats.replaceFirst('{patient_id}', '$patientId');
      return await _apiClient.get<AdherenceStats>(
        path,
        fromJson: (json) => AdherenceStats.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error fetching adherence stats: $e');
      rethrow;
    }
  }

  /// Predict skip risk for a patient
  Future<SkipRiskPrediction> predictSkipRisk(int patientId) async {
    try {
      return await _apiClient.post<SkipRiskPrediction>(
        ApiConstants.analyticsPredictSkipRisk,
        data: {'patient_id': patientId},
        fromJson: (json) => SkipRiskPrediction.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error predicting skip risk: $e');
      rethrow;
    }
  }

  /// Get adherence trend for a patient
  Future<List<AdherenceTrend>> getAdherenceTrend(int patientId) async {
    try {
      final path = ApiConstants.analyticsAdherenceTrend.replaceFirst('{patient_id}', '$patientId');
      final response = await _apiClient.get<List>(
        path,
        fromJson: (json) => json as List,
      );
      
      return response
          .map((item) => AdherenceTrend.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.e('Error fetching adherence trend: $e');
      rethrow;
    }
  }
}
