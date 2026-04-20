import 'package:logger/logger.dart';
import '../core/constants/api_constants.dart';
import '../core/network/api_client.dart';
import '../models/chat_model.dart';

final logger = Logger();

class AgentService {
  final ApiClient _apiClient;

  AgentService(this._apiClient);

  /// Chat with the agent
  Future<ChatResponse> chat({
    required String message,
    String? videoInput,
  }) async {
    try {
      final request = ChatRequest(
        message: message,
        videoInput: videoInput,
      );

      return await _apiClient.post<ChatResponse>(
        ApiConstants.agentChat,
        data: request.toJson(),
        fromJson: (json) => ChatResponse.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error chatting with agent: $e');
      rethrow;
    }
  }

  /// Invoke the agent with full state
  Future<AgentResponse> invoke({
    required int userId,
    required String message,
    String? videoInput,
  }) async {
    try {
      final request = AgentRequest(
        userId: userId,
        message: message,
        videoInput: videoInput,
      );

      return await _apiClient.post<AgentResponse>(
        ApiConstants.agentInvoke,
        data: request.toJson(),
        fromJson: (json) => AgentResponse.fromJson(json as Map<String, dynamic>),
      );
    } catch (e) {
      logger.e('Error invoking agent: $e');
      rethrow;
    }
  }
}
