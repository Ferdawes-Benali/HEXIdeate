// mobile_app/lib/blocs/agent/agent_bloc.dart
// ──────────────────────────────────────────────
// Agent BLoC - Chat and medicine management
// Connects to backend agent service via gateway
// ──────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/api_client.dart';

// Events
abstract class AgentEvent extends Equatable {
  const AgentEvent();

  @override
  List<Object?> get props => [];
}

class AgentSendMessage extends AgentEvent {
  final String message;
  final String? videoBase64;

  const AgentSendMessage({
    required this.message,
    this.videoBase64,
  });

  @override
  List<Object?> get props => [message, videoBase64];
}

class AgentLoadContext extends AgentEvent {
  final int patientId;

  const AgentLoadContext({required this.patientId});

  @override
  List<Object?> get props => [patientId];
}

class AgentClearHistory extends AgentEvent {
  const AgentClearHistory();
}

// States
abstract class AgentState extends Equatable {
  const AgentState();

  @override
  List<Object?> get props => [];
}

class AgentInitial extends AgentState {
  const AgentInitial();
}

class AgentLoading extends AgentState {
  const AgentLoading();
}

class AgentLoaded extends AgentState {
  final List<AgentMessage> messages;
  final AgentContext? context;
  final String? safetyAlert;
  final List<Medication>? currentMedications;

  const AgentLoaded({
    required this.messages,
    this.context,
    this.safetyAlert,
    this.currentMedications,
  });

  AgentLoaded copyWith({
    List<AgentMessage>? messages,
    AgentContext? context,
    String? safetyAlert,
    List<Medication>? currentMedications,
  }) {
    return AgentLoaded(
      messages: messages ?? this.messages,
      context: context ?? this.context,
      safetyAlert: safetyAlert ?? this.safetyAlert,
      currentMedications: currentMedications ?? this.currentMedications,
    );
  }

  @override
  List<Object?> get props => [messages, context, safetyAlert, currentMedications];
}

class AgentError extends AgentState {
  final String message;

  const AgentError(this.message);

  @override
  List<Object?> get props => [message];
}

// Data Models
class AgentMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;

  const AgentMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.type = MessageType.text,
  });

  @override
  List<Object?> get props => [id, content, isUser, timestamp, type];
}

enum MessageType { text, warning, medication, success }

class AgentContext extends Equatable {
  final int patientId;
  final List<Medication> scheduledMedications;
  final DateTime lastIntake;
  final double adherenceRate;

  const AgentContext({
    required this.patientId,
    required this.scheduledMedications,
    required this.lastIntake,
    required this.adherenceRate,
  });

  @override
  List<Object?> get props => [patientId, scheduledMedications, lastIntake, adherenceRate];
}

class Medication extends Equatable {
  final String id;
  final String name;
  final String dosage;
  final String frequency;
  final String? instructions;
  final DateTime? nextDose;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.instructions,
    this.nextDose,
  });

  @override
  List<Object?> get props => [id, name, dosage, frequency, instructions, nextDose];
}

// BLoC
class AgentBloc extends Bloc<AgentEvent, AgentState> {
  final ApiClient apiClient;

  AgentBloc({required this.apiClient}) : super(const AgentInitial()) {
    on<AgentSendMessage>(_onSendMessage);
    on<AgentLoadContext>(_onLoadContext);
    on<AgentClearHistory>(_onClearHistory);
  }

  Future<void> _onSendMessage(
    AgentSendMessage event,
    Emitter<AgentState> emit,
  ) async {
    final currentState = state;
    List<AgentMessage> currentMessages = [];

    if (currentState is AgentLoaded) {
      currentMessages = List.from(currentState.messages);
    }

    // Add user message
    final userMessage = AgentMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    currentMessages.add(userMessage);

    emit(AgentLoaded(
      messages: currentMessages,
      context: currentState is AgentLoaded ? currentState.context : null,
    ));

    try {
      // Call backend agent service
      // Backend returns: { reply: str, status: Optional[str], safety_alert: Optional[bool] }
      final response = await apiClient.sendChatMessage(
        message: event.message,
        videoBase64: event.videoBase64,
      );

      // Parse agent response - backend returns single 'reply' string
      final agentMessage = AgentMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response.reply,
        isUser: false,
        timestamp: DateTime.now(),
        type: _parseStatusToMessageType(response.status),
      );
      currentMessages.add(agentMessage);

      emit(AgentLoaded(
        messages: currentMessages,
        context: currentState is AgentLoaded ? currentState.context : null,
        safetyAlert: response.hasSafetyAlert ? 'تحذير: تفاعلات دوائية محتملة!' : null,
      ));
    } catch (e) {
      // Add error message in Derja
      final errorMessage = AgentMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: 'عذراً، حدث خطأ. يرجى المحاولة مرة أخرى.',
        isUser: false,
        timestamp: DateTime.now(),
        type: MessageType.warning,
      );
      currentMessages.add(errorMessage);

      emit(AgentLoaded(
        messages: currentMessages,
        context: currentState is AgentLoaded ? currentState.context : null,
      ));
    }
  }

  Future<void> _onLoadContext(
    AgentLoadContext event,
    Emitter<AgentState> emit,
  ) async {
    emit(const AgentLoading());

    try {
      // Get patient info - backend expects int patient_id
      final patientData = await apiClient.getPatient(event.patientId.toString());
      final medicationsData = await apiClient.getMedications(event.patientId.toString());

      final medications = medicationsData.map((m) => Medication(
        id: m['id']?.toString() ?? '',
        name: m['name'] ?? '',
        dosage: m['dosage'] ?? '',
        frequency: m['frequency'] ?? '',
        instructions: m['instructions'],
      )).toList();

      final context = AgentContext(
        patientId: event.patientId,
        scheduledMedications: medications,
        lastIntake: DateTime.now().subtract(const Duration(hours: 2)),
        adherenceRate: (patientData['adherence_rate'] ?? 0.85) as double,
      );

      emit(AgentLoaded(
        messages: const [],
        context: context,
        currentMedications: medications,
      ));
    } catch (e) {
      emit(AgentError('Failed to load context: ${e.toString()}'));
    }
  }

  void _onClearHistory(
    AgentClearHistory event,
    Emitter<AgentState> emit,
  ) {
    final currentState = state;
    if (currentState is AgentLoaded) {
      emit(currentState.copyWith(messages: []));
    }
  }

  MessageType _parseMessageType(String? type) {
    switch (type) {
      case 'warning':
        return MessageType.warning;
      case 'medication':
        return MessageType.medication;
      case 'success':
        return MessageType.success;
      default:
        return MessageType.text;
    }
  }

  /// Convert backend status to message type
  /// Backend returns: 'success', 'wrong_time', 'wrong_pill', 'identified', etc.
  MessageType _parseStatusToMessageType(String? status) {
    switch (status) {
      case 'success':
      case 'intake_confirmed':
        return MessageType.success;
      case 'wrong_time':
      case 'wrong_pill':
        return MessageType.warning;
      case 'identified':
        return MessageType.medication;
      default:
        return MessageType.text;
    }
  }
}