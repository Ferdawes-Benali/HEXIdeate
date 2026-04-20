import 'package:freezed_annotation/freezed_annotation.dart';

part 'alert_model.freezed.dart';
part 'alert_model.g.dart';

@freezed
class Alert with _$Alert {
  const factory Alert({
    required int id,
    required int patientId,
    required String type,
    required String severity,
    required String message,
    @Default(false) bool isRead,
    @Default(false) bool isAcknowledged,
    DateTime? readAt,
    DateTime? acknowledgedAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Alert;

  factory Alert.fromJson(Map<String, dynamic> json) => _$AlertFromJson(json);
}

@freezed
class AlertResponse with _$AlertResponse {
  const factory AlertResponse({
    required List<Alert> alerts,
    required int total,
    required int unreadCount,
  }) = _AlertResponse;

  factory AlertResponse.fromJson(Map<String, dynamic> json) =>
      _$AlertResponseFromJson(json);
}

@freezed
class DispatchAlertRequest with _$DispatchAlertRequest {
  const factory DispatchAlertRequest({
    required int patientId,
    required String type,
    required String severity,
    required String message,
  }) = _DispatchAlertRequest;

  factory DispatchAlertRequest.fromJson(Map<String, dynamic> json) =>
      _$DispatchAlertRequestFromJson(json);
}
