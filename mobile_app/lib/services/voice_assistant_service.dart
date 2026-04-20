import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';

final logger = Logger();

class VoiceAssistantService {
  final Dio _dio;

  VoiceAssistantService(this._dio);

  /// Convert speech audio (base64) to text
  /// [audioBase64]: Base64 encoded audio data
  /// [language]: Language code (default: 'ar' for Arabic/Tunisian)
  Future<String> transcribeAudio({
    required String audioBase64,
    String language = 'ar',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.voiceTranscribe,
        data: {
          'audio_base64': audioBase64,
          'language': language,
        },
      );

      if (response.statusCode == 200) {
        return response.data['text'] as String;
      } else {
        throw Exception('Failed to transcribe: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Transcribe error: $e');
      rethrow;
    }
  }

  /// Convert text to speech audio (returns base64)
  /// [text]: Text to convert to speech
  /// [language]: Language code (default: 'ar' for Arabic/Tunisian)
  /// [voice]: Optional specific voice ID
  Future<String> textToSpeech({
    required String text,
    String language = 'ar',
    String? voice,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.voiceTts,
        data: {
          'text': text,
          'language': language,
          if (voice != null) 'voice': voice,
        },
      );

      if (response.statusCode == 200) {
        return response.data['audio_base64'] as String;
      } else {
        throw Exception('Failed to generate speech: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Text-to-speech error: $e');
      rethrow;
    }
  }

  /// Process emergency "appeler à l'aide" call
  /// Records audio and triggers emergency protocol
  Future<Map<String, dynamic>> triggerEmergencyAlert(
    String audioBase64,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.voiceEmergencyAlert,
        data: {
          'audio_base64': audioBase64,
          'language': 'ar',
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Failed to trigger emergency: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Emergency alert error: $e');
      rethrow;
    }
  }

  /// Transcribe uploaded audio file
  /// Returns transcribed text
  Future<String> transcribeUploadedFile({
    required String filePath,
    String language = 'ar',
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'language': language,
      });

      final response = await _dio.post(
        ApiConstants.voiceUploadTranscribe,
        data: formData,
      );

      if (response.statusCode == 200) {
        return response.data['text'] as String;
      } else {
        throw Exception('Failed to transcribe file: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('File transcribe error: $e');
      rethrow;
    }
  }
}
