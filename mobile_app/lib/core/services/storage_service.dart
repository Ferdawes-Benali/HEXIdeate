// mobile_app/lib/core/services/storage_service.dart
// ──────────────────────────────────────────────
// Storage Service - Local storage for auth tokens and preferences
// ──────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage service for sensitive and non-sensitive data
class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _patientIdKey = 'patient_id';
  static const String _languageKey = 'language';
  static const String _themeKey = 'theme';
  static const String _onboardingKey = 'onboarding_complete';

  late SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  /// Initialize storage - must be called before use
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    debugPrint('StorageService initialized');
  }

  // ──────────────────────────────────────────────
  // Secure Storage (tokens, sensitive data)
  // ──────────────────────────────────────────────

  /// Save authentication token
  Future<void> setToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Delete authentication token (logout)
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ──────────────────────────────────────────────
  // Shared Preferences (non-sensitive settings)
  // ──────────────────────────────────────────────

  /// Save patient ID
  Future<void> setPatientId(String patientId) async {
    await _prefs.setString(_patientIdKey, patientId);
  }

  /// Get patient ID
  String? getPatientId() {
    return _prefs.getString(_patientIdKey);
  }

  /// Save language preference
  Future<void> setLanguage(String languageCode) async {
    await _prefs.setString(_languageKey, languageCode);
  }

  /// Get language preference
  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'ar_TN';
  }

  /// Save theme preference
  Future<void> setTheme(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  /// Get theme preference
  String getTheme() {
    return _prefs.getString(_themeKey) ?? 'light';
  }

  /// Mark onboarding as complete
  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs.setBool(_onboardingKey, complete);
  }

  /// Check if onboarding is complete
  bool isOnboardingComplete() {
    return _prefs.getBool(_onboardingKey) ?? false;
  }

  // ──────────────────────────────────────────────
  // Clear all data
  // ──────────────────────────────────────────────

  /// Clear all stored data (for logout)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
    debugPrint('Storage cleared');
  }

  /// Clear only authentication data
  Future<void> clearAuth() async {
    await _secureStorage.delete(key: _tokenKey);
    await _prefs.remove(_patientIdKey);
  }
}