import 'package:logger/logger.dart';
import '../core/network/api_client.dart';

final logger = Logger();

class VisionServiceRequest {
  final String base64Frame;
  final String? videoBase64;

  VisionServiceRequest({
    required this.base64Frame,
    this.videoBase64,
  });

  Map<String, dynamic> toJson() => {
    'frame': base64Frame,
    if (videoBase64 != null) 'video': videoBase64,
  };
}

class VisionServiceResponse {
  final String phase;
  final String? identifiedMedicine;
  final bool? isCorrect;
  final String? alertMessage;
  final List<String>? identifiedPills;
  final bool? safetyAlert;

  VisionServiceResponse({
    required this.phase,
    this.identifiedMedicine,
    this.isCorrect,
    this.alertMessage,
    this.identifiedPills,
    this.safetyAlert,
  });

  factory VisionServiceResponse.fromJson(Map<String, dynamic> json) {
    return VisionServiceResponse(
      phase: json['phase'] as String? ?? 'IDENTIFYING',
      identifiedMedicine: json['identified_medicine'] as String?,
      isCorrect: json['is_correct'] as bool?,
      alertMessage: json['alert_message'] as String?,
      identifiedPills: List<String>.from((json['identified_pills'] as List?) ?? []),
      safetyAlert: json['safety_alert'] as bool?,
    );
  }
}

class VisionService {
  final ApiClient _apiClient;

  VisionService(this._apiClient);

  /// Verify medication intake using a single frame
  Future<VisionServiceResponse> verifyFrame(String base64Frame) async {
    try {
      final request = VisionServiceRequest(base64Frame: base64Frame);
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/verify-frame',
        data: request.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return VisionServiceResponse.fromJson(response);
    } catch (e) {
      logger.e('Error verifying frame: $e');
      rethrow;
    }
  }

  /// Full medication verification session with video
  Future<VisionServiceResponse> verifyIntake({
    required String videoBase64,
    String? frameBase64,
  }) async {
    try {
      final request = VisionServiceRequest(
        base64Frame: frameBase64 ?? '',
        videoBase64: videoBase64,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/verify-intake',
        data: request.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      return VisionServiceResponse.fromJson(response);
    } catch (e) {
      logger.e('Error verifying intake: $e');
      rethrow;
    }
  }

  /// Check vision service health
  Future<bool> checkHealth() async {
    try {
      await _apiClient.get<Map<String, dynamic>>(
        '/health',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      return true;
    } catch (e) {
      logger.e('Vision service health check failed: $e');
      return false;
    }
  }
}
