// mobile_app/lib/core/config/app_config.dart
// ──────────────────────────────────────────────
// App Configuration - Centralized settings
// ──────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppConfig {
  AppConfig._();

  // ──────────────────────────────────────────────
  // App Info
  // ──────────────────────────────────────────────
  static const String appName = 'DwaFi';
  static const String appVersion = '1.0.0';

  // ──────────────────────────────────────────────
  // API Configuration
  // ──────────────────────────────────────────────
  // Update this to your actual backend URL
  static const String apiBaseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ──────────────────────────────────────────────
  // Colors - Healthcare theme
  // ──────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF2E7D32); // Green - health
  static const Color secondaryColor = Color(0xFF00897B); // Teal
  static const Color accentColor = Color(0xFF43A047); // Light green
  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color warningColor = Color(0xFFF57C00); // Orange
  static const Color successColor = Color(0xFF388E3C); // Dark green
  static const Color infoColor = Color(0xFF1976D2); // Blue

  // Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // ──────────────────────────────────────────────
  // UI Constants
  // ──────────────────────────────────────────────
  // Large touch targets for elderly users
  static const double buttonHeight = 56.0;
  static const double inputHeight = 56.0;
  static const double iconSize = 28.0;
  static const double borderRadius = 16.0;
  static const double cardElevation = 2.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // ──────────────────────────────────────────────
  // Feature Flags
  // ──────────────────────────────────────────────
  static const bool enableVoiceInput = true;
  static const bool enableVoiceOutput = true;
  static const bool enableCamera = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = true;

  // ──────────────────────────────────────────────
  // Derja (Tunisian Arabic) Settings
  // ──────────────────────────────────────────────
  static const String defaultLocale = 'ar_TN';
  static const List<String> supportedLocales = ['en', 'fr', 'ar', 'ar_TN'];

  // ──────────────────────────────────────────────
  // Cache Settings
  // ──────────────────────────────────────────────
  static const Duration cacheDuration = Duration(hours: 24);
  static const int maxCacheSize = 50; // MB

  // ──────────────────────────────────────────────
  // Security
  // ──────────────────────────────────────────────
  static const Duration tokenExpiry = Duration(days: 7);
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
}