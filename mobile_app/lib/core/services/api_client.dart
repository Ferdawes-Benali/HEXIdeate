// mobile_app/lib/core/services/api_client.dart
// ──────────────────────────────────────────────
// API Client - HTTP client for gateway communication
// ──────────────────────────────────────────────

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'storage_service.dart';

/// API Client wrapper around Dio
/// Handles authentication, error handling, and request/response formatting
class ApiClient {
  late final Dio _dio;
  final StorageService _storage;
  final String _baseUrl;

  ApiClient({
    required String baseUrl,
    required StorageService storageService,
  })  : _baseUrl = baseUrl,
        _storage = storageService {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: AppConfig.connectionTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );

    // Debug logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  /// Add authentication token to requests
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from storage
    final token = await _storage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  /// Handle responses
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  /// Handle errors with custom exception mapping
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    String message;
    int? statusCode = err.response?.statusCode;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet.';
        statusCode = 408;
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        statusCode = 503;
        break;
      case DioExceptionType.badResponse:
        message = _handleBadResponse(err.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      default:
        message = 'An unexpected error occurred.';
    }

    // Create a custom error response
    final errorResponse = err.response ?? Response(
      requestOptions: err.requestOptions,
      statusCode: statusCode,
      data: {'detail': message},
    );

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: errorResponse,
        type: err.type,
        error: message,
      ),
    );
  }

  String _handleBadResponse(Response? response) {
    if (response == null) return 'Unknown error';

    final data = response.data;
    if (data is Map && data.containsKey('detail')) {
      return data['detail'].toString();
    }

    switch (response.statusCode) {
      case 400:
        return 'Invalid request.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 422:
        return 'Validation error.';
      case 429:
        return 'Too many requests. Please wait.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred.';
    }
  }

  // ──────────────────────────────────────────────
  // Public API Methods
  // ──────────────────────────────────────────────

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Upload file with progress
  Future<Response<T>> uploadFile<T>(
    String path, {
    required FormData formData,
    void Function(int, int)? onSendProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
  }

  /// Download file with progress
  Future<Response> downloadFile(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // ──────────────────────────────────────────────
  // Convenience Methods for Agent Service
  // ──────────────────────────────────────────────

  /// Send chat message to agent
  /// Backend expects: { message: str, video_input: Optional[str] }
  /// Backend returns: { reply: str, status: Optional[str], safety_alert: Optional[bool] }
  Future<AgentChatResponse> sendChatMessage({
    required String message,
    String? videoBase64,
  }) async {
    final response = await post(
      '/agent/chat',
      data: {
        'message': message,
        if (videoBase64 != null) 'video_input': videoBase64,
      },
    );
    return AgentChatResponse.fromJson(response.data);
  }

  /// Get patient info
  Future<Map<String, dynamic>> getPatient(String patientId) async {
    final response = await get('/patients/$patientId');
    return response.data as Map<String, dynamic>;
  }

  /// Get patient medications
  Future<List<dynamic>> getMedications(String patientId) async {
    final response = await get('/patients/$patientId/medications');
    return response.data as List<dynamic>;
  }

  /// Get adherence stats
  Future<Map<String, dynamic>> getAdherenceStats(String patientId) async {
    final response = await get('/analytics/stats/$patientId');
    return response.data as Map<String, dynamic>;
  }

  /// Predict skip risk
  Future<Map<String, dynamic>> predictSkipRisk(String patientId) async {
    final response = await post(
      '/analytics/predict/skip-risk',
      data: {'patient_id': patientId},
    );
    return response.data as Map<String, dynamic>;
  }

  /// Send notification
  Future<void> sendNotification({
    required String patientId,
    required String title,
    required String body,
  }) async {
    await post(
      '/notifications/dispatch',
      data: {
        'patient_id': patientId,
        'title': title,
        'body': body,
      },
    );
  }

  /// STT - Transcribe audio
  Future<Map<String, dynamic>> transcribeAudio(String audioBase64) async {
    final response = await post(
      'http://localhost:8004/transcribe', // Voice service port
      data: {'audio_base64': audioBase64},
    );
    return response.data as Map<String, dynamic>;
  }

  /// TTS - Synthesize speech
  Future<String> synthesizeSpeech(String text, {String? language}) async {
    final response = await post(
      'http://localhost:8005/synthesize', // Voice service port
      data: {
        'text': text,
        'language': language ?? 'ar',
      },
    );
    return response.data['audio_base64'] as String;
  }
}

/// Response model for agent chat
class AgentChatResponse {
  final String reply;
  final String? status;
  final bool? safetyAlert;

  AgentChatResponse({
    required this.reply,
    this.status,
    this.safetyAlert,
  });

  factory AgentChatResponse.fromJson(Map<String, dynamic> json) {
    return AgentChatResponse(
      reply: json['reply'] ?? '',
      status: json['status'],
      safetyAlert: json['safety_alert'],
    );
  }

  bool get hasSafetyAlert => safetyAlert == true;

  String get statusType => status ?? 'unknown';
}