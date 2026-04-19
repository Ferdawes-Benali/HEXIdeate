// mobile_app/lib/blocs/voice/voice_bloc.dart
// ──────────────────────────────────────────────
// Voice BLoC - STT/TTS for voice interactions
// Connects to backend voice service
// ──────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/api_client.dart';

// Events
abstract class VoiceEvent extends Equatable {
  const VoiceEvent();

  @override
  List<Object?> get props => [];
}

class VoiceStartRecording extends VoiceEvent {
  const VoiceStartRecording();
}

class VoiceStopRecording extends VoiceEvent {
  const VoiceStopRecording();
}

class VoiceTranscribe extends VoiceEvent {
  final String audioBase64;
  final String? language;

  const VoiceTranscribe({
    required this.audioBase64,
    this.language,
  });

  @override
  List<Object?> get props => [audioBase64, language];
}

class VoiceSynthesize extends VoiceEvent {
  final String text;
  final String? language;
  final String? voiceId;

  const VoiceSynthesize({
    required this.text,
    this.language,
    this.voiceId,
  });

  @override
  List<Object?> get props => [text, language, voiceId];
}

class VoicePlayAudio extends VoiceEvent {
  final String audioBase64;

  const VoicePlayAudio({required this.audioBase64});

  @override
  List<Object?> get props => [audioBase64];
}

class VoiceStopPlayback extends VoiceEvent {
  const VoiceStopPlayback();
}

class VoiceReset extends VoiceEvent {
  const VoiceReset();
}

// States
abstract class VoiceState extends Equatable {
  const VoiceState();

  @override
  List<Object?> get props => [];
}

class VoiceInitial extends VoiceState {
  const VoiceInitial();
}

class VoiceReady extends VoiceState {
  const VoiceReady();
}

class VoiceRecording extends VoiceState {
  final Duration duration;

  const VoiceRecording({this.duration = Duration.zero});

  @override
  List<Object?> get props => [duration];
}

class VoiceTranscribing extends VoiceState {
  const VoiceTranscribing();
}

class VoiceTranscribed extends VoiceState {
  final String text;
  final String language;

  const VoiceTranscribed({
    required this.text,
    required this.language,
  });

  @override
  List<Object?> get props => [text, language];
}

class VoiceSynthesizing extends VoiceState {
  const VoiceSynthesizing();
}

class VoicePlaying extends VoiceState {
  final String text;

  const VoicePlaying({required this.text});

  @override
  List<Object?> get props => [text];
}

class VoiceError extends VoiceState {
  final String message;

  const VoiceError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  final ApiClient apiClient;

  VoiceBloc({required this.apiClient}) : super(const VoiceInitial()) {
    on<VoiceStartRecording>(_onStartRecording);
    on<VoiceStopRecording>(_onStopRecording);
    on<VoiceTranscribe>(_onTranscribe);
    on<VoiceSynthesize>(_onSynthesize);
    on<VoicePlayAudio>(_onPlayAudio);
    on<VoiceStopPlayback>(_onStopPlayback);
    on<VoiceReset>(_onReset);
  }

  Future<void> _onStartRecording(
    VoiceStartRecording event,
    Emitter<VoiceState> emit,
  ) async {
    // Start recording - placeholder
    // In real implementation, would use record package
    emit(const VoiceRecording());
  }

  Future<void> _onStopRecording(
    VoiceStopRecording event,
    Emitter<VoiceState> emit,
  ) async {
    // Stop recording and get audio data - placeholder
    emit(const VoiceTranscribing());

    // TODO: Get actual audio data from recorder
    // For now, emit ready state
    emit(const VoiceReady());
  }

  Future<void> _onTranscribe(
    VoiceTranscribe event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceTranscribing());

    try {
      // Call STT service
      final response = await apiClient.transcribeAudio(event.audioBase64);

      emit(VoiceTranscribed(
        text: response['text'] ?? '',
        language: response['language'] ?? 'ar',
      ));
    } catch (e) {
      emit(VoiceError('Transcription failed: ${e.toString()}'));
    }
  }

  Future<void> _onSynthesize(
    VoiceSynthesize event,
    Emitter<VoiceState> emit,
  ) async {
    emit(const VoiceSynthesizing());

    try {
      // Call TTS service
      final audioBase64 = await apiClient.synthesizeSpeech(
        event.text,
        language: event.language,
      );

      // Emit playing state with the text
      emit(VoicePlaying(text: event.text));

      // TODO: Actually play the audio
      // For now, just transition back to ready after a delay
      await Future.delayed(const Duration(seconds: 2));
      emit(const VoiceReady());
    } catch (e) {
      emit(VoiceError('Synthesis failed: ${e.toString()}'));
    }
  }

  Future<void> _onPlayAudio(
    VoicePlayAudio event,
    Emitter<VoiceState> emit,
  ) async {
    // Play audio - placeholder
    emit(const VoicePlaying(text: 'Playing...'));
    await Future.delayed(const Duration(seconds: 1));
    emit(const VoiceReady());
  }

  void _onStopPlayback(
    VoiceStopPlayback event,
    Emitter<VoiceState> emit,
  ) {
    // Stop playback - placeholder
    emit(const VoiceReady());
  }

  void _onReset(
    VoiceReset event,
    Emitter<VoiceState> emit,
  ) {
    emit(const VoiceReady());
  }
}