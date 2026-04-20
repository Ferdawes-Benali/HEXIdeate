// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdherenceStatsImpl _$$AdherenceStatsImplFromJson(Map<String, dynamic> json) =>
    _$AdherenceStatsImpl(
      patientId: (json['patientId'] as num).toInt(),
      adherenceRate: (json['adherenceRate'] as num).toDouble(),
      totalIntakes: (json['totalIntakes'] as num).toInt(),
      successfulIntakes: (json['successfulIntakes'] as num).toInt(),
      missedIntakes: (json['missedIntakes'] as num).toInt(),
      wrongTimeIntakes: (json['wrongTimeIntakes'] as num).toInt(),
      calculatedAt: json['calculatedAt'] == null
          ? null
          : DateTime.parse(json['calculatedAt'] as String),
    );

Map<String, dynamic> _$$AdherenceStatsImplToJson(
        _$AdherenceStatsImpl instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'adherenceRate': instance.adherenceRate,
      'totalIntakes': instance.totalIntakes,
      'successfulIntakes': instance.successfulIntakes,
      'missedIntakes': instance.missedIntakes,
      'wrongTimeIntakes': instance.wrongTimeIntakes,
      'calculatedAt': instance.calculatedAt?.toIso8601String(),
    };

_$SkipRiskPredictionImpl _$$SkipRiskPredictionImplFromJson(
        Map<String, dynamic> json) =>
    _$SkipRiskPredictionImpl(
      patientId: (json['patientId'] as num).toInt(),
      skipRiskScore: (json['skipRiskScore'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendation: json['recommendation'] as String,
      predictedAt: json['predictedAt'] == null
          ? null
          : DateTime.parse(json['predictedAt'] as String),
    );

Map<String, dynamic> _$$SkipRiskPredictionImplToJson(
        _$SkipRiskPredictionImpl instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'skipRiskScore': instance.skipRiskScore,
      'riskLevel': instance.riskLevel,
      'riskFactors': instance.riskFactors,
      'recommendation': instance.recommendation,
      'predictedAt': instance.predictedAt?.toIso8601String(),
    };

_$AdherenceTrendImpl _$$AdherenceTrendImplFromJson(Map<String, dynamic> json) =>
    _$AdherenceTrendImpl(
      patientId: (json['patientId'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      adherancePercentage: (json['adherancePercentage'] as num).toDouble(),
      intakesCompleted: (json['intakesCompleted'] as num).toInt(),
      intakesScheduled: (json['intakesScheduled'] as num).toInt(),
    );

Map<String, dynamic> _$$AdherenceTrendImplToJson(
        _$AdherenceTrendImpl instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'date': instance.date.toIso8601String(),
      'adherancePercentage': instance.adherancePercentage,
      'intakesCompleted': instance.intakesCompleted,
      'intakesScheduled': instance.intakesScheduled,
    };

_$PredictionResponseImpl _$$PredictionResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PredictionResponseImpl(
      patientId: (json['patientId'] as num).toInt(),
      skipRiskScore: (json['skipRiskScore'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
      contributingFactors: (json['contributingFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$PredictionResponseImplToJson(
        _$PredictionResponseImpl instance) =>
    <String, dynamic>{
      'patientId': instance.patientId,
      'skipRiskScore': instance.skipRiskScore,
      'riskLevel': instance.riskLevel,
      'contributingFactors': instance.contributingFactors,
    };
