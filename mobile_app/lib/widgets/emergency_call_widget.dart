import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:hexideate/theme/app_theme.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../providers/service_providers.dart';

final logger = Logger();

class EmergencyCallWidget extends ConsumerStatefulWidget {
  final int patientId;
  final VoidCallback? onSuccess;

  const EmergencyCallWidget({
    Key? key,
    required this.patientId,
    this.onSuccess,
  }) : super(key: key);

  @override
  ConsumerState<EmergencyCallWidget> createState() => _EmergencyCallWidgetState();
}

class _EmergencyCallWidgetState extends ConsumerState<EmergencyCallWidget> {
  late final AudioRecorder _audioRecorder;
  bool _isRecording = false;
  String? _recordingPath;
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    _requestPermissions();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        logger.w('Microphone permission not granted');
      }
    } catch (e) {
      logger.e('Permission check error: $e');
    }
  }

  Future<void> _startRecording() async {
  try {
    if (await _audioRecorder.isRecording()) {
      _showSnackBar('Already recording');
      return;
    }

    final directory = await Directory.systemTemp.createTemp();
    final path = '${directory.path}/emergency_audio.m4a';

    await _audioRecorder.start(const RecordConfig(), path: path);

    _recordingPath = path; // Fix #2: was null

    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });

    // Fix #3: start the timer
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });
    });

  } catch (e) {
    logger.e('Start recording error: $e');
    if (mounted) {
      _showSnackBar('Failed to start recording');
    }
  }
}

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();

      final path = await _audioRecorder.stop();
      
      // Safety check: if the user closed the widget while recording stopped
      if (!mounted) return;

      setState(() {
        _isRecording = false;
      });

      logger.i('Recording stopped: $path');

      if (path == null) {
        _showSnackBar('Failed to save recording');
        return;
      }

      // Show loading
      _showLoadingDialog();

      // Process the emergency call - use path! because we checked for null above
      await _processEmergencyCall(path);

    } catch (e) {
      logger.e('Stop recording error: $e');
      if (mounted) {
        _showSnackBar('Failed to stop recording');
      }
    }
  }

  Future<void> _processEmergencyCall(String audioPath) async {
    try {
      // Read audio file and convert to base64
      final audioFile = await _readAudioFile(audioPath);
      if (audioFile == null) {
        _closeLoadingDialog();
        _showSnackBar('Failed to read audio file');
        return;
      }

      // Trigger emergency alert via voice service
      final voiceService = ref.read(voiceAssistantProvider);
      final response = await voiceService.triggerEmergencyAlert(audioFile);

      _closeLoadingDialog();

      // Show success response
      _showSuccessDialog(response);
    } catch (e) {
      logger.e('Emergency call error: $e');
      _closeLoadingDialog();
      _showSnackBar('Emergency alert failed: $e');
    }
  }

  Future<String?> _readAudioFile(String path) async {
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      return base64String;
    } catch (e) {
      logger.e('Error reading audio file: $e');
      return null;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Envoi de l\'alerte d\'urgence...'),
          ],
        ),
      ),
    );
  }

  void _closeLoadingDialog() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _showSuccessDialog(Map<String, dynamic> response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alerte d\'urgence envoyée'),
        content: Text(response['message'] ?? 'Votre demande d\'aide a été enregistrée.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSuccess?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isRecording ? 'Enregistrement en cours...' : 'Appuyez et parlez',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Text(
                    '${_recordingSeconds}s',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Parlez votre message...'),
                ],
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isRecording ? _stopRecording : _startRecording,
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            label: Text(_isRecording ? 'Arrêter' : 'Commencer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isRecording ? Colors.red : AppColors.persianGreen,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }
}
