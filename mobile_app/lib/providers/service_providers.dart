import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../services/patient_service.dart';
import '../services/agent_service.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
import '../services/voice_assistant_service.dart';
import '../services/medication_alarm_service.dart';
import '../services/mismatch_alert_service.dart';
import '../services/local_database_service.dart';
final localDatabaseProvider = FutureProvider<LocalDatabaseService>((ref) async {
  final service = LocalDatabaseService();
  await service.init();
  return service;
});

/// Shared Preferences provider
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// API Client provider (singleton)
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Patient Service provider
final patientServiceProvider = Provider<PatientService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PatientService(apiClient);
});

/// Agent Service provider
final agentServiceProvider = Provider<AgentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AgentService(apiClient);
});

/// Analytics Service provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AnalyticsService(apiClient);
});

/// Notification Service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationService(apiClient);
});

/// Voice Assistant Service provider
final voiceAssistantProvider = Provider<VoiceAssistantService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  // Create a Dio instance for voice service to bypass ApiClient wrapper
  final dio = apiClient.createDioInstance();
  return VoiceAssistantService(dio);
});

/// Medication Alarm Service provider (singleton)
final medicationAlarmProvider = Provider<MedicationAlarmService>((ref) {
  return MedicationAlarmService();
});

/// Mismatch Alert Service provider
final mismatchAlertProvider = Provider<MismatchAlertService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  // Create a Dio instance for mismatch alert service
  final dio = apiClient.createDioInstance();
  return MismatchAlertService(dio);
});

/// Initialize medication alarms on app startup
final medicationAlarmsInitProvider = FutureProvider<void>((ref) async {
  final alarmService = ref.watch(medicationAlarmProvider);
  await alarmService.initialize();
});

/// Current patient ID provider (state)
final currentPatientIdProvider = StateProvider<int?>((ref) {
  return null;
});

/// Current auth token provider (state)
final authTokenProvider = StateProvider<String?>((ref) {
  return null;
});

/// User session provider (state)
final userSessionProvider = StateProvider<Map<String, dynamic>?>((ref) {
  return null;
});

/// Is logged in provider (computed)
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authTokenProvider) != null;
});

/// Is loading provider (state) - for UI loading states
final isLoadingProvider = StateProvider<bool>((ref) {
  return false;
});

/// Error message provider (state)
final errorMessageProvider = StateProvider<String?>((ref) {
  return null;
});
