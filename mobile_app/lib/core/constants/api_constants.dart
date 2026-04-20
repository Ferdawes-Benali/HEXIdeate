/// API Constants for HexIdeate Gateway Communication

class ApiConstants {
  // Base URL - Change based on environment
  static const String baseUrl = 'http://192.168.56.1'; // Android emulator gateway
  // static const String baseUrl = 'http://localhost'; // iOS simulator
  // static const String baseUrl = 'http://192.168.x.x'; // Real device (change IP)

  // Gateway port
  static const int gatewayPort = 8080;

  // API Routes
  static const String apiPrefix = '/api';

  // Patient endpoints
  static const String patients = '$apiPrefix/patients';
  static const String patientById = '$apiPrefix/patients/{id}';
  static const String patientMedications = '$apiPrefix/patients/{id}/medications';

  // Agent/Chat endpoints
  static const String agentChat = '$apiPrefix/agent/chat';
  static const String agentInvoke = '$apiPrefix/agent/invoke';

  // Analytics endpoints
  static const String analytics = '$apiPrefix/analytics';
  static const String analyticsStats = '$apiPrefix/analytics/stats/{patient_id}';
  static const String analyticsPredictSkipRisk =
      '$apiPrefix/analytics/predict/skip-risk';
  static const String analyticsAdherenceTrend =
      '$apiPrefix/analytics/adherence-trend/{patient_id}';

  // Notification endpoints
  static const String notifications = '$apiPrefix/notifications';
  static const String notificationsDispatch = '$apiPrefix/notifications/dispatch';
  static const String notificationsPatientAlerts =
      '$apiPrefix/notifications/patient/{patient_id}/alerts';
  static const String notificationMarkRead = '$apiPrefix/notifications/alert/{alert_id}/read';
  static const String notificationAcknowledge =
      '$apiPrefix/notifications/alert/{alert_id}/acknowledge';

  // Voice endpoints
  static const String voiceTranscribe = '$apiPrefix/voice/transcribe';
  static const String voiceTts = '$apiPrefix/voice/tts';
  static const String voiceUploadTranscribe = '$apiPrefix/voice/upload-transcribe';
  static const String voiceEmergencyAlert = '$apiPrefix/voice/emergency-alert';

  // Health check
  static const String health = '/health';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
