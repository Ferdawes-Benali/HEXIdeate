import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';

final logger = Logger();

class ApiClient {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _authToken;

  ApiClient() {
    _setupDio();
  }

  void _setupDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: '${ApiConstants.baseUrl}:${ApiConstants.gatewayPort}',
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          logger.i('📤 [${options.method}] ${options.path}');

          // Add auth token if available
          _authToken ??= await _secureStorage.read(key: 'auth_token');
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.i('✅ [${response.statusCode}] ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          logger.e('❌ [${error.response?.statusCode}] ${error.requestOptions.path}');
          logger.e('Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Set the auth token for subsequent requests
  Future<void> setAuthToken(String token) async {
    _authToken = token;
    await _secureStorage.write(key: 'auth_token', value: token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear the auth token
  Future<void> clearAuthToken() async {
    _authToken = null;
    await _secureStorage.delete(key: 'auth_token');
    _dio.options.headers.remove('Authorization');
  }

  /// Get current auth token
  Future<String?> getAuthToken() async {
    _authToken ??= await _secureStorage.read(key: 'auth_token');
    return _authToken;
  }

  /// GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      rethrow;
    }
  }

  /// POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      rethrow;
    }
  }

  /// PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      rethrow;
    }
  }

  /// DELETE request
  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        throw _handleError(e);
      }
      rethrow;
    }
  }

  /// Get the Dio instance (for services that need direct Dio access)
  Dio getDioInstance() {
    return _dio;
  }

  /// Create a new Dio instance (useful for services that need separate HTTP client)
  Dio createDioInstance() {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${ApiConstants.baseUrl}:${ApiConstants.gatewayPort}',
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add same interceptors
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          logger.i('📤 [${options.method}] ${options.path}');
          _authToken ??= await _secureStorage.read(key: 'auth_token');
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          logger.i('✅ [${response.statusCode}] ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) {
          logger.e('❌ [${error.response?.statusCode}] ${error.requestOptions.path}');
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Handle Dio errors and convert to meaningful exceptions
  Exception _handleError(DioException error) {
    logger.e('DioException: ${error.message}');

    if (error.response != null) {
      final message =
          error.response?.data?['detail'] ?? error.response?.statusMessage ?? 'Unknown error';
      return ApiException(
        message: message,
        statusCode: error.response?.statusCode ?? 500,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your network.',
          statusCode: -1,
        );
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Server response timeout. Please try again.',
          statusCode: -1,
        );
      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Request send timeout. Please try again.',
          statusCode: -1,
        );
      case DioExceptionType.badResponse:
        return ApiException(
          message: 'Invalid server response.',
          statusCode: error.response?.statusCode ?? 500,
        );
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request cancelled.',
          statusCode: -1,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'No internet connection.',
          statusCode: -1,
        );
      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'SSL certificate error.',
          statusCode: -1,
        );
      case DioExceptionType.unknown:
        return ApiException(
          message: error.message ?? 'An unknown error occurred.',
          statusCode: -1,
        );
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}
