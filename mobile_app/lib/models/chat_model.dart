import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String role,
    required String content,
    DateTime? timestamp,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class AgentRequest with _$AgentRequest {
  const factory AgentRequest({
    required int userId,
    required String message,
    String? videoInput,
  }) = _AgentRequest;

  factory AgentRequest.fromJson(Map<String, dynamic> json) =>
      _$AgentRequestFromJson(json);
}

@freezed
class AgentResponse with _$AgentResponse {
  const factory AgentResponse({
    required List<ChatMessage> messages,
    String? status,
    String? expectedPill,
    @Default([]) List<String> identifiedPills,
    bool? safetyAlert,
  }) = _AgentResponse;

  factory AgentResponse.fromJson(Map<String, dynamic> json) =>
      _$AgentResponseFromJson(json);
}

@freezed
class ChatRequest with _$ChatRequest {
  const factory ChatRequest({
    required String message,
    String? videoInput,
  }) = _ChatRequest;

  factory ChatRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatRequestFromJson(json);
}

@freezed
class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    required String reply,
    String? status,
    bool? safetyAlert,
  }) = _ChatResponse;

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);
}
