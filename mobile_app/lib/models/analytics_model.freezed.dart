// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'analytics_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AdherenceStats _$AdherenceStatsFromJson(Map<String, dynamic> json) {
  return _AdherenceStats.fromJson(json);
}

/// @nodoc
mixin _$AdherenceStats {
  int get patientId => throw _privateConstructorUsedError;
  double get adherenceRate => throw _privateConstructorUsedError;
  int get totalIntakes => throw _privateConstructorUsedError;
  int get successfulIntakes => throw _privateConstructorUsedError;
  int get missedIntakes => throw _privateConstructorUsedError;
  int get wrongTimeIntakes => throw _privateConstructorUsedError;
  DateTime? get calculatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AdherenceStatsCopyWith<AdherenceStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdherenceStatsCopyWith<$Res> {
  factory $AdherenceStatsCopyWith(
          AdherenceStats value, $Res Function(AdherenceStats) then) =
      _$AdherenceStatsCopyWithImpl<$Res, AdherenceStats>;
  @useResult
  $Res call(
      {int patientId,
      double adherenceRate,
      int totalIntakes,
      int successfulIntakes,
      int missedIntakes,
      int wrongTimeIntakes,
      DateTime? calculatedAt});
}

/// @nodoc
class _$AdherenceStatsCopyWithImpl<$Res, $Val extends AdherenceStats>
    implements $AdherenceStatsCopyWith<$Res> {
  _$AdherenceStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? adherenceRate = null,
    Object? totalIntakes = null,
    Object? successfulIntakes = null,
    Object? missedIntakes = null,
    Object? wrongTimeIntakes = null,
    Object? calculatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      adherenceRate: null == adherenceRate
          ? _value.adherenceRate
          : adherenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalIntakes: null == totalIntakes
          ? _value.totalIntakes
          : totalIntakes // ignore: cast_nullable_to_non_nullable
              as int,
      successfulIntakes: null == successfulIntakes
          ? _value.successfulIntakes
          : successfulIntakes // ignore: cast_nullable_to_non_nullable
              as int,
      missedIntakes: null == missedIntakes
          ? _value.missedIntakes
          : missedIntakes // ignore: cast_nullable_to_non_nullable
              as int,
      wrongTimeIntakes: null == wrongTimeIntakes
          ? _value.wrongTimeIntakes
          : wrongTimeIntakes // ignore: cast_nullable_to_non_nullable
              as int,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdherenceStatsImplCopyWith<$Res>
    implements $AdherenceStatsCopyWith<$Res> {
  factory _$$AdherenceStatsImplCopyWith(_$AdherenceStatsImpl value,
          $Res Function(_$AdherenceStatsImpl) then) =
      __$$AdherenceStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int patientId,
      double adherenceRate,
      int totalIntakes,
      int successfulIntakes,
      int missedIntakes,
      int wrongTimeIntakes,
      DateTime? calculatedAt});
}

/// @nodoc
class __$$AdherenceStatsImplCopyWithImpl<$Res>
    extends _$AdherenceStatsCopyWithImpl<$Res, _$AdherenceStatsImpl>
    implements _$$AdherenceStatsImplCopyWith<$Res> {
  __$$AdherenceStatsImplCopyWithImpl(
      _$AdherenceStatsImpl _value, $Res Function(_$AdherenceStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? adherenceRate = null,
    Object? totalIntakes = null,
    Object? successfulIntakes = null,
    Object? missedIntakes = null,
    Object? wrongTimeIntakes = null,
    Object? calculatedAt = freezed,
  }) {
    return _then(_$AdherenceStatsImpl(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      adherenceRate: null == adherenceRate
          ? _value.adherenceRate
          : adherenceRate // ignore: cast_nullable_to_non_nullable
              as double,
      totalIntakes: null == totalIntakes
          ? _value.totalIntakes
          : totalIntakes // ignore: cast_nullable_to_non_nullable
              as int,
      successfulIntakes: null == successfulIntakes
          ? _value.successfulIntakes
          : successfulIntakes // ignore: cast_nullable_to_non_nullable
              as int,
      missedIntakes: null == missedIntakes
          ? _value.missedIntakes
          : missedIntakes // ignore: cast_nullable_to_non_nullable
              as int,
      wrongTimeIntakes: null == wrongTimeIntakes
          ? _value.wrongTimeIntakes
          : wrongTimeIntakes // ignore: cast_nullable_to_non_nullable
              as int,
      calculatedAt: freezed == calculatedAt
          ? _value.calculatedAt
          : calculatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdherenceStatsImpl implements _AdherenceStats {
  const _$AdherenceStatsImpl(
      {required this.patientId,
      required this.adherenceRate,
      required this.totalIntakes,
      required this.successfulIntakes,
      required this.missedIntakes,
      required this.wrongTimeIntakes,
      this.calculatedAt});

  factory _$AdherenceStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdherenceStatsImplFromJson(json);

  @override
  final int patientId;
  @override
  final double adherenceRate;
  @override
  final int totalIntakes;
  @override
  final int successfulIntakes;
  @override
  final int missedIntakes;
  @override
  final int wrongTimeIntakes;
  @override
  final DateTime? calculatedAt;

  @override
  String toString() {
    return 'AdherenceStats(patientId: $patientId, adherenceRate: $adherenceRate, totalIntakes: $totalIntakes, successfulIntakes: $successfulIntakes, missedIntakes: $missedIntakes, wrongTimeIntakes: $wrongTimeIntakes, calculatedAt: $calculatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdherenceStatsImpl &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.adherenceRate, adherenceRate) ||
                other.adherenceRate == adherenceRate) &&
            (identical(other.totalIntakes, totalIntakes) ||
                other.totalIntakes == totalIntakes) &&
            (identical(other.successfulIntakes, successfulIntakes) ||
                other.successfulIntakes == successfulIntakes) &&
            (identical(other.missedIntakes, missedIntakes) ||
                other.missedIntakes == missedIntakes) &&
            (identical(other.wrongTimeIntakes, wrongTimeIntakes) ||
                other.wrongTimeIntakes == wrongTimeIntakes) &&
            (identical(other.calculatedAt, calculatedAt) ||
                other.calculatedAt == calculatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      patientId,
      adherenceRate,
      totalIntakes,
      successfulIntakes,
      missedIntakes,
      wrongTimeIntakes,
      calculatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AdherenceStatsImplCopyWith<_$AdherenceStatsImpl> get copyWith =>
      __$$AdherenceStatsImplCopyWithImpl<_$AdherenceStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdherenceStatsImplToJson(
      this,
    );
  }
}

abstract class _AdherenceStats implements AdherenceStats {
  const factory _AdherenceStats(
      {required final int patientId,
      required final double adherenceRate,
      required final int totalIntakes,
      required final int successfulIntakes,
      required final int missedIntakes,
      required final int wrongTimeIntakes,
      final DateTime? calculatedAt}) = _$AdherenceStatsImpl;

  factory _AdherenceStats.fromJson(Map<String, dynamic> json) =
      _$AdherenceStatsImpl.fromJson;

  @override
  int get patientId;
  @override
  double get adherenceRate;
  @override
  int get totalIntakes;
  @override
  int get successfulIntakes;
  @override
  int get missedIntakes;
  @override
  int get wrongTimeIntakes;
  @override
  DateTime? get calculatedAt;
  @override
  @JsonKey(ignore: true)
  _$$AdherenceStatsImplCopyWith<_$AdherenceStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SkipRiskPrediction _$SkipRiskPredictionFromJson(Map<String, dynamic> json) {
  return _SkipRiskPrediction.fromJson(json);
}

/// @nodoc
mixin _$SkipRiskPrediction {
  int get patientId => throw _privateConstructorUsedError;
  double get skipRiskScore => throw _privateConstructorUsedError;
  String get riskLevel => throw _privateConstructorUsedError;
  List<String> get riskFactors => throw _privateConstructorUsedError;
  String get recommendation => throw _privateConstructorUsedError;
  DateTime? get predictedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SkipRiskPredictionCopyWith<SkipRiskPrediction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkipRiskPredictionCopyWith<$Res> {
  factory $SkipRiskPredictionCopyWith(
          SkipRiskPrediction value, $Res Function(SkipRiskPrediction) then) =
      _$SkipRiskPredictionCopyWithImpl<$Res, SkipRiskPrediction>;
  @useResult
  $Res call(
      {int patientId,
      double skipRiskScore,
      String riskLevel,
      List<String> riskFactors,
      String recommendation,
      DateTime? predictedAt});
}

/// @nodoc
class _$SkipRiskPredictionCopyWithImpl<$Res, $Val extends SkipRiskPrediction>
    implements $SkipRiskPredictionCopyWith<$Res> {
  _$SkipRiskPredictionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? skipRiskScore = null,
    Object? riskLevel = null,
    Object? riskFactors = null,
    Object? recommendation = null,
    Object? predictedAt = freezed,
  }) {
    return _then(_value.copyWith(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      skipRiskScore: null == skipRiskScore
          ? _value.skipRiskScore
          : skipRiskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      riskFactors: null == riskFactors
          ? _value.riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
      predictedAt: freezed == predictedAt
          ? _value.predictedAt
          : predictedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SkipRiskPredictionImplCopyWith<$Res>
    implements $SkipRiskPredictionCopyWith<$Res> {
  factory _$$SkipRiskPredictionImplCopyWith(_$SkipRiskPredictionImpl value,
          $Res Function(_$SkipRiskPredictionImpl) then) =
      __$$SkipRiskPredictionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int patientId,
      double skipRiskScore,
      String riskLevel,
      List<String> riskFactors,
      String recommendation,
      DateTime? predictedAt});
}

/// @nodoc
class __$$SkipRiskPredictionImplCopyWithImpl<$Res>
    extends _$SkipRiskPredictionCopyWithImpl<$Res, _$SkipRiskPredictionImpl>
    implements _$$SkipRiskPredictionImplCopyWith<$Res> {
  __$$SkipRiskPredictionImplCopyWithImpl(_$SkipRiskPredictionImpl _value,
      $Res Function(_$SkipRiskPredictionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? skipRiskScore = null,
    Object? riskLevel = null,
    Object? riskFactors = null,
    Object? recommendation = null,
    Object? predictedAt = freezed,
  }) {
    return _then(_$SkipRiskPredictionImpl(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      skipRiskScore: null == skipRiskScore
          ? _value.skipRiskScore
          : skipRiskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      riskFactors: null == riskFactors
          ? _value._riskFactors
          : riskFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      recommendation: null == recommendation
          ? _value.recommendation
          : recommendation // ignore: cast_nullable_to_non_nullable
              as String,
      predictedAt: freezed == predictedAt
          ? _value.predictedAt
          : predictedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SkipRiskPredictionImpl implements _SkipRiskPrediction {
  const _$SkipRiskPredictionImpl(
      {required this.patientId,
      required this.skipRiskScore,
      required this.riskLevel,
      required final List<String> riskFactors,
      required this.recommendation,
      this.predictedAt})
      : _riskFactors = riskFactors;

  factory _$SkipRiskPredictionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkipRiskPredictionImplFromJson(json);

  @override
  final int patientId;
  @override
  final double skipRiskScore;
  @override
  final String riskLevel;
  final List<String> _riskFactors;
  @override
  List<String> get riskFactors {
    if (_riskFactors is EqualUnmodifiableListView) return _riskFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_riskFactors);
  }

  @override
  final String recommendation;
  @override
  final DateTime? predictedAt;

  @override
  String toString() {
    return 'SkipRiskPrediction(patientId: $patientId, skipRiskScore: $skipRiskScore, riskLevel: $riskLevel, riskFactors: $riskFactors, recommendation: $recommendation, predictedAt: $predictedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkipRiskPredictionImpl &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.skipRiskScore, skipRiskScore) ||
                other.skipRiskScore == skipRiskScore) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            const DeepCollectionEquality()
                .equals(other._riskFactors, _riskFactors) &&
            (identical(other.recommendation, recommendation) ||
                other.recommendation == recommendation) &&
            (identical(other.predictedAt, predictedAt) ||
                other.predictedAt == predictedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      patientId,
      skipRiskScore,
      riskLevel,
      const DeepCollectionEquality().hash(_riskFactors),
      recommendation,
      predictedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SkipRiskPredictionImplCopyWith<_$SkipRiskPredictionImpl> get copyWith =>
      __$$SkipRiskPredictionImplCopyWithImpl<_$SkipRiskPredictionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkipRiskPredictionImplToJson(
      this,
    );
  }
}

abstract class _SkipRiskPrediction implements SkipRiskPrediction {
  const factory _SkipRiskPrediction(
      {required final int patientId,
      required final double skipRiskScore,
      required final String riskLevel,
      required final List<String> riskFactors,
      required final String recommendation,
      final DateTime? predictedAt}) = _$SkipRiskPredictionImpl;

  factory _SkipRiskPrediction.fromJson(Map<String, dynamic> json) =
      _$SkipRiskPredictionImpl.fromJson;

  @override
  int get patientId;
  @override
  double get skipRiskScore;
  @override
  String get riskLevel;
  @override
  List<String> get riskFactors;
  @override
  String get recommendation;
  @override
  DateTime? get predictedAt;
  @override
  @JsonKey(ignore: true)
  _$$SkipRiskPredictionImplCopyWith<_$SkipRiskPredictionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AdherenceTrend _$AdherenceTrendFromJson(Map<String, dynamic> json) {
  return _AdherenceTrend.fromJson(json);
}

/// @nodoc
mixin _$AdherenceTrend {
  int get patientId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get adherancePercentage => throw _privateConstructorUsedError;
  int get intakesCompleted => throw _privateConstructorUsedError;
  int get intakesScheduled => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AdherenceTrendCopyWith<AdherenceTrend> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdherenceTrendCopyWith<$Res> {
  factory $AdherenceTrendCopyWith(
          AdherenceTrend value, $Res Function(AdherenceTrend) then) =
      _$AdherenceTrendCopyWithImpl<$Res, AdherenceTrend>;
  @useResult
  $Res call(
      {int patientId,
      DateTime date,
      double adherancePercentage,
      int intakesCompleted,
      int intakesScheduled});
}

/// @nodoc
class _$AdherenceTrendCopyWithImpl<$Res, $Val extends AdherenceTrend>
    implements $AdherenceTrendCopyWith<$Res> {
  _$AdherenceTrendCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? date = null,
    Object? adherancePercentage = null,
    Object? intakesCompleted = null,
    Object? intakesScheduled = null,
  }) {
    return _then(_value.copyWith(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      adherancePercentage: null == adherancePercentage
          ? _value.adherancePercentage
          : adherancePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      intakesCompleted: null == intakesCompleted
          ? _value.intakesCompleted
          : intakesCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      intakesScheduled: null == intakesScheduled
          ? _value.intakesScheduled
          : intakesScheduled // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdherenceTrendImplCopyWith<$Res>
    implements $AdherenceTrendCopyWith<$Res> {
  factory _$$AdherenceTrendImplCopyWith(_$AdherenceTrendImpl value,
          $Res Function(_$AdherenceTrendImpl) then) =
      __$$AdherenceTrendImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int patientId,
      DateTime date,
      double adherancePercentage,
      int intakesCompleted,
      int intakesScheduled});
}

/// @nodoc
class __$$AdherenceTrendImplCopyWithImpl<$Res>
    extends _$AdherenceTrendCopyWithImpl<$Res, _$AdherenceTrendImpl>
    implements _$$AdherenceTrendImplCopyWith<$Res> {
  __$$AdherenceTrendImplCopyWithImpl(
      _$AdherenceTrendImpl _value, $Res Function(_$AdherenceTrendImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? date = null,
    Object? adherancePercentage = null,
    Object? intakesCompleted = null,
    Object? intakesScheduled = null,
  }) {
    return _then(_$AdherenceTrendImpl(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      adherancePercentage: null == adherancePercentage
          ? _value.adherancePercentage
          : adherancePercentage // ignore: cast_nullable_to_non_nullable
              as double,
      intakesCompleted: null == intakesCompleted
          ? _value.intakesCompleted
          : intakesCompleted // ignore: cast_nullable_to_non_nullable
              as int,
      intakesScheduled: null == intakesScheduled
          ? _value.intakesScheduled
          : intakesScheduled // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AdherenceTrendImpl implements _AdherenceTrend {
  const _$AdherenceTrendImpl(
      {required this.patientId,
      required this.date,
      required this.adherancePercentage,
      required this.intakesCompleted,
      required this.intakesScheduled});

  factory _$AdherenceTrendImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdherenceTrendImplFromJson(json);

  @override
  final int patientId;
  @override
  final DateTime date;
  @override
  final double adherancePercentage;
  @override
  final int intakesCompleted;
  @override
  final int intakesScheduled;

  @override
  String toString() {
    return 'AdherenceTrend(patientId: $patientId, date: $date, adherancePercentage: $adherancePercentage, intakesCompleted: $intakesCompleted, intakesScheduled: $intakesScheduled)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdherenceTrendImpl &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.adherancePercentage, adherancePercentage) ||
                other.adherancePercentage == adherancePercentage) &&
            (identical(other.intakesCompleted, intakesCompleted) ||
                other.intakesCompleted == intakesCompleted) &&
            (identical(other.intakesScheduled, intakesScheduled) ||
                other.intakesScheduled == intakesScheduled));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, patientId, date,
      adherancePercentage, intakesCompleted, intakesScheduled);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AdherenceTrendImplCopyWith<_$AdherenceTrendImpl> get copyWith =>
      __$$AdherenceTrendImplCopyWithImpl<_$AdherenceTrendImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdherenceTrendImplToJson(
      this,
    );
  }
}

abstract class _AdherenceTrend implements AdherenceTrend {
  const factory _AdherenceTrend(
      {required final int patientId,
      required final DateTime date,
      required final double adherancePercentage,
      required final int intakesCompleted,
      required final int intakesScheduled}) = _$AdherenceTrendImpl;

  factory _AdherenceTrend.fromJson(Map<String, dynamic> json) =
      _$AdherenceTrendImpl.fromJson;

  @override
  int get patientId;
  @override
  DateTime get date;
  @override
  double get adherancePercentage;
  @override
  int get intakesCompleted;
  @override
  int get intakesScheduled;
  @override
  @JsonKey(ignore: true)
  _$$AdherenceTrendImplCopyWith<_$AdherenceTrendImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PredictionResponse _$PredictionResponseFromJson(Map<String, dynamic> json) {
  return _PredictionResponse.fromJson(json);
}

/// @nodoc
mixin _$PredictionResponse {
  int get patientId => throw _privateConstructorUsedError;
  double get skipRiskScore => throw _privateConstructorUsedError;
  String get riskLevel => throw _privateConstructorUsedError;
  List<String> get contributingFactors => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PredictionResponseCopyWith<PredictionResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PredictionResponseCopyWith<$Res> {
  factory $PredictionResponseCopyWith(
          PredictionResponse value, $Res Function(PredictionResponse) then) =
      _$PredictionResponseCopyWithImpl<$Res, PredictionResponse>;
  @useResult
  $Res call(
      {int patientId,
      double skipRiskScore,
      String riskLevel,
      List<String> contributingFactors});
}

/// @nodoc
class _$PredictionResponseCopyWithImpl<$Res, $Val extends PredictionResponse>
    implements $PredictionResponseCopyWith<$Res> {
  _$PredictionResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? skipRiskScore = null,
    Object? riskLevel = null,
    Object? contributingFactors = null,
  }) {
    return _then(_value.copyWith(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      skipRiskScore: null == skipRiskScore
          ? _value.skipRiskScore
          : skipRiskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      contributingFactors: null == contributingFactors
          ? _value.contributingFactors
          : contributingFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PredictionResponseImplCopyWith<$Res>
    implements $PredictionResponseCopyWith<$Res> {
  factory _$$PredictionResponseImplCopyWith(_$PredictionResponseImpl value,
          $Res Function(_$PredictionResponseImpl) then) =
      __$$PredictionResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int patientId,
      double skipRiskScore,
      String riskLevel,
      List<String> contributingFactors});
}

/// @nodoc
class __$$PredictionResponseImplCopyWithImpl<$Res>
    extends _$PredictionResponseCopyWithImpl<$Res, _$PredictionResponseImpl>
    implements _$$PredictionResponseImplCopyWith<$Res> {
  __$$PredictionResponseImplCopyWithImpl(_$PredictionResponseImpl _value,
      $Res Function(_$PredictionResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? patientId = null,
    Object? skipRiskScore = null,
    Object? riskLevel = null,
    Object? contributingFactors = null,
  }) {
    return _then(_$PredictionResponseImpl(
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      skipRiskScore: null == skipRiskScore
          ? _value.skipRiskScore
          : skipRiskScore // ignore: cast_nullable_to_non_nullable
              as double,
      riskLevel: null == riskLevel
          ? _value.riskLevel
          : riskLevel // ignore: cast_nullable_to_non_nullable
              as String,
      contributingFactors: null == contributingFactors
          ? _value._contributingFactors
          : contributingFactors // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PredictionResponseImpl implements _PredictionResponse {
  const _$PredictionResponseImpl(
      {required this.patientId,
      required this.skipRiskScore,
      required this.riskLevel,
      required final List<String> contributingFactors})
      : _contributingFactors = contributingFactors;

  factory _$PredictionResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PredictionResponseImplFromJson(json);

  @override
  final int patientId;
  @override
  final double skipRiskScore;
  @override
  final String riskLevel;
  final List<String> _contributingFactors;
  @override
  List<String> get contributingFactors {
    if (_contributingFactors is EqualUnmodifiableListView)
      return _contributingFactors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_contributingFactors);
  }

  @override
  String toString() {
    return 'PredictionResponse(patientId: $patientId, skipRiskScore: $skipRiskScore, riskLevel: $riskLevel, contributingFactors: $contributingFactors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PredictionResponseImpl &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.skipRiskScore, skipRiskScore) ||
                other.skipRiskScore == skipRiskScore) &&
            (identical(other.riskLevel, riskLevel) ||
                other.riskLevel == riskLevel) &&
            const DeepCollectionEquality()
                .equals(other._contributingFactors, _contributingFactors));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, patientId, skipRiskScore,
      riskLevel, const DeepCollectionEquality().hash(_contributingFactors));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PredictionResponseImplCopyWith<_$PredictionResponseImpl> get copyWith =>
      __$$PredictionResponseImplCopyWithImpl<_$PredictionResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PredictionResponseImplToJson(
      this,
    );
  }
}

abstract class _PredictionResponse implements PredictionResponse {
  const factory _PredictionResponse(
          {required final int patientId,
          required final double skipRiskScore,
          required final String riskLevel,
          required final List<String> contributingFactors}) =
      _$PredictionResponseImpl;

  factory _PredictionResponse.fromJson(Map<String, dynamic> json) =
      _$PredictionResponseImpl.fromJson;

  @override
  int get patientId;
  @override
  double get skipRiskScore;
  @override
  String get riskLevel;
  @override
  List<String> get contributingFactors;
  @override
  @JsonKey(ignore: true)
  _$$PredictionResponseImplCopyWith<_$PredictionResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
