import 'package:freezed_annotation/freezed_annotation.dart';

part 'analytics_model.freezed.dart';
part 'analytics_model.g.dart';

@freezed
class AdherenceStats with _$AdherenceStats {
  const factory AdherenceStats({
    required int patientId,
    required double adherenceRate,
    required int totalIntakes,
    required int successfulIntakes,
    required int missedIntakes,
    required int wrongTimeIntakes,
    DateTime? calculatedAt,
  }) = _AdherenceStats;

  factory AdherenceStats.fromJson(Map<String, dynamic> json) =>
      _$AdherenceStatsFromJson(json);
}

@freezed
class SkipRiskPrediction with _$SkipRiskPrediction {
  const factory SkipRiskPrediction({
    required int patientId,
    required double skipRiskScore,
    required String riskLevel,
    required List<String> riskFactors,
    required String recommendation,
    DateTime? predictedAt,
  }) = _SkipRiskPrediction;

  factory SkipRiskPrediction.fromJson(Map<String, dynamic> json) =>
      _$SkipRiskPredictionFromJson(json);
}

@freezed
class AdherenceTrend with _$AdherenceTrend {
  const factory AdherenceTrend({
    required int patientId,
    required DateTime date,
    required double adherancePercentage,
    required int intakesCompleted,
    required int intakesScheduled,
  }) = _AdherenceTrend;

  factory AdherenceTrend.fromJson(Map<String, dynamic> json) =>
      _$AdherenceTrendFromJson(json);
}

@freezed
class PredictionResponse with _$PredictionResponse {
  const factory PredictionResponse({
    required int patientId,
    required double skipRiskScore,
    required String riskLevel,
    required List<String> contributingFactors,
  }) = _PredictionResponse;

  factory PredictionResponse.fromJson(Map<String, dynamic> json) =>
      _$PredictionResponseFromJson(json);
}
