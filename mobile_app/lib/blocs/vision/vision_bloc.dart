// mobile_app/lib/blocs/vision/vision_bloc.dart
// ──────────────────────────────────────────────
// Vision BLoC - Camera and pill verification
// Connects to backend vision service via gateway
// ──────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/api_client.dart';

// Events
abstract class VisionEvent extends Equatable {
  const VisionEvent();

  @override
  List<Object?> get props => [];
}

class VisionInitialize extends VisionEvent {
  const VisionInitialize();
}

class VisionCaptureFrame extends VisionEvent {
  final String frameBase64;

  const VisionCaptureFrame({required this.frameBase64});

  @override
  List<Object?> get props => [frameBase64];
}

class VisionVerifyIntake extends VisionEvent {
  final String videoBase64;

  const VisionVerifyIntake({required this.videoBase64});

  @override
  List<Object?> get props => [videoBase64];
}

class VisionReset extends VisionEvent {
  const VisionReset();
}

// States
abstract class VisionState extends Equatable {
  const VisionState();

  @override
  List<Object?> get props => [];
}

class VisionInitial extends VisionState {
  const VisionInitial();
}

class VisionReady extends VisionState {
  const VisionReady();
}

class VisionProcessing extends VisionState {
  final String status;

  const VisionProcessing(this.status);

  @override
  List<Object?> get props => [status];
}

class VisionSuccess extends VisionState {
  final String pillName;
  final String pillDose;
  final String phase; // IDENTIFYING or INTAKE
  final double confidence;
  final bool confirmed;
  final String feedback;

  const VisionSuccess({
    required this.pillName,
    required this.pillDose,
    required this.phase,
    required this.confidence,
    required this.confirmed,
    required this.feedback,
  });

  @override
  List<Object?> get props => [pillName, pillDose, phase, confidence, confirmed, feedback];
}

class VisionError extends VisionState {
  final String message;

  const VisionError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class VisionBloc extends Bloc<VisionEvent, VisionState> {
  final ApiClient apiClient;

  VisionBloc({required this.apiClient}) : super(const VisionInitial()) {
    on<VisionInitialize>(_onInitialize);
    on<VisionCaptureFrame>(_onCaptureFrame);
    on<VisionVerifyIntake>(_onVerifyIntake);
    on<VisionReset>(_onReset);
  }

  Future<void> _onInitialize(
    VisionInitialize event,
    Emitter<VisionState> emit,
  ) async {
    // Initialize camera - placeholder
    // In real implementation, would initialize camera controller
    emit(const VisionReady());
  }

  Future<void> _onCaptureFrame(
    VisionCaptureFrame event,
    Emitter<VisionState> emit,
  ) async {
    emit(const VisionProcessing('جاري التحليل...'));

    try {
      // Call vision service - frame endpoint
      // Backend expects: { frame: str, phase: str, behavior_score: int }
      // Backend returns: FrameResponse with id_label, id_confidence, id_matched_name, etc.
      final response = await apiClient.post(
        'http://localhost:8003/verify-frame', // Vision service direct call
        data: {
          'frame': event.frameBase64,
          'phase': 'IDENTIFYING',
          'behavior_score': 0,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Check if medication was identified
      if (data['id_label'] != 'unknown' && data['id_confidence'] > 0.5) {
        emit(VisionSuccess(
          pillName: data['id_matched_name'] ?? data['id_label'] ?? 'Unknown',
          pillDose: data['id_med_dose'] ?? '',
          phase: data['phase'] ?? 'IDENTIFYING',
          confidence: (data['id_confidence'] as num?)?.toDouble() ?? 0.0,
          confirmed: data['confirmed'] ?? false,
          feedback: data['id_feedback'] ?? '',
        ));
      } else {
        emit(const VisionError('لم يتم التعرف على الدواء'));
      }
    } catch (e) {
      emit(VisionError('فشل التحليل: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyIntake(
    VisionVerifyIntake event,
    Emitter<VisionState> emit,
  ) async {
    emit(const VisionProcessing('جاري التحقق من تناول الدواء...'));

    try {
      // Call vision service - full intake verification
      // Backend expects: { video: str, frame: Optional[str], duration_s: float }
      // Backend returns: IntakeResponse with id_* and intake_* fields
      final response = await apiClient.post(
        'http://localhost:8003/verify-intake', // Vision service direct call
        data: {
          'video': event.videoBase64,
          'duration_s': 15.0,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Check intake confirmation
      if (data['intake_label'] == 'intake_confirmed' || data['confirmed'] == true) {
        emit(VisionSuccess(
          pillName: data['id_med_name'] ?? 'الدواء',
          pillDose: data['id_med_dose'] ?? '',
          phase: data['session_phase'] ?? 'INTAKE',
          confidence: (data['intake_conf'] as num?)?.toDouble() ?? 0.0,
          confirmed: data['confirmed'] ?? false,
          feedback: data['intake_feedback'] ?? '',
        ));
      } else if (data['id_label'] != 'unknown') {
        // Medication identified but intake not confirmed
        emit(VisionSuccess(
          pillName: data['id_med_name'] ?? data['id_label'] ?? 'Unknown',
          pillDose: data['id_med_dose'] ?? '',
          phase: data['session_phase'] ?? 'IDENTIFYING',
          confidence: (data['id_confidence'] as num?)?.toDouble() ?? 0.0,
          confirmed: false,
          feedback: data['id_feedback'] ?? 'تم التعرف على الدواء',
        ));
      } else {
        emit(const VisionError('لم يتم التحقق من تناول الدواء'));
      }
    } catch (e) {
      emit(VisionError('فشل التحقق: ${e.toString()}'));
    }
  }
          confidence: (data['confidence'] as num?)?.toDouble(),
        ));
      } else if (data['status'] == 'identified') {
        emit(VisionSuccess(
          pillName: data['medication_name'] ?? 'Unknown',
          status: 'identified',
          confidence: (data['confidence'] as num?)?.toDouble(),
        ));
      } else {
        emit(const VisionError('Could not verify intake'));
      }
    } catch (e) {
      emit(VisionError('Verification failed: ${e.toString()}'));
    }
  }

  void _onReset(
    VisionReset event,
    Emitter<VisionState> emit,
  ) {
    emit(const VisionReady());
  }
}