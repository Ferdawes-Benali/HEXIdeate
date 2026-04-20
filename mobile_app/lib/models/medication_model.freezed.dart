// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Medication _$MedicationFromJson(Map<String, dynamic> json) {
  return _Medication.fromJson(json);
}

/// @nodoc
mixin _$Medication {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get patientId => throw _privateConstructorUsedError;
  String get genericName => throw _privateConstructorUsedError;
  String get dosage => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  String? get indication => throw _privateConstructorUsedError;
  String? get sideEffects => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MedicationCopyWith<Medication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationCopyWith<$Res> {
  factory $MedicationCopyWith(
          Medication value, $Res Function(Medication) then) =
      _$MedicationCopyWithImpl<$Res, Medication>;
  @useResult
  $Res call(
      {String id,
      String name,
      int patientId,
      String genericName,
      String dosage,
      String frequency,
      DateTime? startDate,
      DateTime? endDate,
      String? indication,
      String? sideEffects,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$MedicationCopyWithImpl<$Res, $Val extends Medication>
    implements $MedicationCopyWith<$Res> {
  _$MedicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? patientId = null,
    Object? genericName = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? indication = freezed,
    Object? sideEffects = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      genericName: null == genericName
          ? _value.genericName
          : genericName // ignore: cast_nullable_to_non_nullable
              as String,
      dosage: null == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      indication: freezed == indication
          ? _value.indication
          : indication // ignore: cast_nullable_to_non_nullable
              as String?,
      sideEffects: freezed == sideEffects
          ? _value.sideEffects
          : sideEffects // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MedicationImplCopyWith<$Res>
    implements $MedicationCopyWith<$Res> {
  factory _$$MedicationImplCopyWith(
          _$MedicationImpl value, $Res Function(_$MedicationImpl) then) =
      __$$MedicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      int patientId,
      String genericName,
      String dosage,
      String frequency,
      DateTime? startDate,
      DateTime? endDate,
      String? indication,
      String? sideEffects,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$MedicationImplCopyWithImpl<$Res>
    extends _$MedicationCopyWithImpl<$Res, _$MedicationImpl>
    implements _$$MedicationImplCopyWith<$Res> {
  __$$MedicationImplCopyWithImpl(
      _$MedicationImpl _value, $Res Function(_$MedicationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? patientId = null,
    Object? genericName = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? indication = freezed,
    Object? sideEffects = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MedicationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      patientId: null == patientId
          ? _value.patientId
          : patientId // ignore: cast_nullable_to_non_nullable
              as int,
      genericName: null == genericName
          ? _value.genericName
          : genericName // ignore: cast_nullable_to_non_nullable
              as String,
      dosage: null == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      indication: freezed == indication
          ? _value.indication
          : indication // ignore: cast_nullable_to_non_nullable
              as String?,
      sideEffects: freezed == sideEffects
          ? _value.sideEffects
          : sideEffects // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationImpl implements _Medication {
  const _$MedicationImpl(
      {required this.id,
      required this.name,
      required this.patientId,
      required this.genericName,
      required this.dosage,
      required this.frequency,
      this.startDate,
      this.endDate,
      this.indication,
      this.sideEffects,
      this.createdAt,
      this.updatedAt});

  factory _$MedicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final int patientId;
  @override
  final String genericName;
  @override
  final String dosage;
  @override
  final String frequency;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final String? indication;
  @override
  final String? sideEffects;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, patientId: $patientId, genericName: $genericName, dosage: $dosage, frequency: $frequency, startDate: $startDate, endDate: $endDate, indication: $indication, sideEffects: $sideEffects, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.patientId, patientId) ||
                other.patientId == patientId) &&
            (identical(other.genericName, genericName) ||
                other.genericName == genericName) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.indication, indication) ||
                other.indication == indication) &&
            (identical(other.sideEffects, sideEffects) ||
                other.sideEffects == sideEffects) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      patientId,
      genericName,
      dosage,
      frequency,
      startDate,
      endDate,
      indication,
      sideEffects,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationImplCopyWith<_$MedicationImpl> get copyWith =>
      __$$MedicationImplCopyWithImpl<_$MedicationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationImplToJson(
      this,
    );
  }
}

abstract class _Medication implements Medication {
  const factory _Medication(
      {required final String id,
      required final String name,
      required final int patientId,
      required final String genericName,
      required final String dosage,
      required final String frequency,
      final DateTime? startDate,
      final DateTime? endDate,
      final String? indication,
      final String? sideEffects,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$MedicationImpl;

  factory _Medication.fromJson(Map<String, dynamic> json) =
      _$MedicationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get patientId;
  @override
  String get genericName;
  @override
  String get dosage;
  @override
  String get frequency;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  String? get indication;
  @override
  String? get sideEffects;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MedicationImplCopyWith<_$MedicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MedicationSchedule _$MedicationScheduleFromJson(Map<String, dynamic> json) {
  return _MedicationSchedule.fromJson(json);
}

/// @nodoc
mixin _$MedicationSchedule {
  int get id => throw _privateConstructorUsedError;
  int get medicationId => throw _privateConstructorUsedError;
  String get timeOfDay => throw _privateConstructorUsedError;
  bool get sunday => throw _privateConstructorUsedError;
  bool get monday => throw _privateConstructorUsedError;
  bool get tuesday => throw _privateConstructorUsedError;
  bool get wednesday => throw _privateConstructorUsedError;
  bool get thursday => throw _privateConstructorUsedError;
  bool get friday => throw _privateConstructorUsedError;
  bool get saturday => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MedicationScheduleCopyWith<MedicationSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationScheduleCopyWith<$Res> {
  factory $MedicationScheduleCopyWith(
          MedicationSchedule value, $Res Function(MedicationSchedule) then) =
      _$MedicationScheduleCopyWithImpl<$Res, MedicationSchedule>;
  @useResult
  $Res call(
      {int id,
      int medicationId,
      String timeOfDay,
      bool sunday,
      bool monday,
      bool tuesday,
      bool wednesday,
      bool thursday,
      bool friday,
      bool saturday,
      DateTime? createdAt});
}

/// @nodoc
class _$MedicationScheduleCopyWithImpl<$Res, $Val extends MedicationSchedule>
    implements $MedicationScheduleCopyWith<$Res> {
  _$MedicationScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicationId = null,
    Object? timeOfDay = null,
    Object? sunday = null,
    Object? monday = null,
    Object? tuesday = null,
    Object? wednesday = null,
    Object? thursday = null,
    Object? friday = null,
    Object? saturday = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      medicationId: null == medicationId
          ? _value.medicationId
          : medicationId // ignore: cast_nullable_to_non_nullable
              as int,
      timeOfDay: null == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as String,
      sunday: null == sunday
          ? _value.sunday
          : sunday // ignore: cast_nullable_to_non_nullable
              as bool,
      monday: null == monday
          ? _value.monday
          : monday // ignore: cast_nullable_to_non_nullable
              as bool,
      tuesday: null == tuesday
          ? _value.tuesday
          : tuesday // ignore: cast_nullable_to_non_nullable
              as bool,
      wednesday: null == wednesday
          ? _value.wednesday
          : wednesday // ignore: cast_nullable_to_non_nullable
              as bool,
      thursday: null == thursday
          ? _value.thursday
          : thursday // ignore: cast_nullable_to_non_nullable
              as bool,
      friday: null == friday
          ? _value.friday
          : friday // ignore: cast_nullable_to_non_nullable
              as bool,
      saturday: null == saturday
          ? _value.saturday
          : saturday // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MedicationScheduleImplCopyWith<$Res>
    implements $MedicationScheduleCopyWith<$Res> {
  factory _$$MedicationScheduleImplCopyWith(_$MedicationScheduleImpl value,
          $Res Function(_$MedicationScheduleImpl) then) =
      __$$MedicationScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int medicationId,
      String timeOfDay,
      bool sunday,
      bool monday,
      bool tuesday,
      bool wednesday,
      bool thursday,
      bool friday,
      bool saturday,
      DateTime? createdAt});
}

/// @nodoc
class __$$MedicationScheduleImplCopyWithImpl<$Res>
    extends _$MedicationScheduleCopyWithImpl<$Res, _$MedicationScheduleImpl>
    implements _$$MedicationScheduleImplCopyWith<$Res> {
  __$$MedicationScheduleImplCopyWithImpl(_$MedicationScheduleImpl _value,
      $Res Function(_$MedicationScheduleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicationId = null,
    Object? timeOfDay = null,
    Object? sunday = null,
    Object? monday = null,
    Object? tuesday = null,
    Object? wednesday = null,
    Object? thursday = null,
    Object? friday = null,
    Object? saturday = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$MedicationScheduleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      medicationId: null == medicationId
          ? _value.medicationId
          : medicationId // ignore: cast_nullable_to_non_nullable
              as int,
      timeOfDay: null == timeOfDay
          ? _value.timeOfDay
          : timeOfDay // ignore: cast_nullable_to_non_nullable
              as String,
      sunday: null == sunday
          ? _value.sunday
          : sunday // ignore: cast_nullable_to_non_nullable
              as bool,
      monday: null == monday
          ? _value.monday
          : monday // ignore: cast_nullable_to_non_nullable
              as bool,
      tuesday: null == tuesday
          ? _value.tuesday
          : tuesday // ignore: cast_nullable_to_non_nullable
              as bool,
      wednesday: null == wednesday
          ? _value.wednesday
          : wednesday // ignore: cast_nullable_to_non_nullable
              as bool,
      thursday: null == thursday
          ? _value.thursday
          : thursday // ignore: cast_nullable_to_non_nullable
              as bool,
      friday: null == friday
          ? _value.friday
          : friday // ignore: cast_nullable_to_non_nullable
              as bool,
      saturday: null == saturday
          ? _value.saturday
          : saturday // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationScheduleImpl implements _MedicationSchedule {
  const _$MedicationScheduleImpl(
      {required this.id,
      required this.medicationId,
      required this.timeOfDay,
      this.sunday = false,
      this.monday = false,
      this.tuesday = false,
      this.wednesday = false,
      this.thursday = false,
      this.friday = false,
      this.saturday = false,
      this.createdAt});

  factory _$MedicationScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationScheduleImplFromJson(json);

  @override
  final int id;
  @override
  final int medicationId;
  @override
  final String timeOfDay;
  @override
  @JsonKey()
  final bool sunday;
  @override
  @JsonKey()
  final bool monday;
  @override
  @JsonKey()
  final bool tuesday;
  @override
  @JsonKey()
  final bool wednesday;
  @override
  @JsonKey()
  final bool thursday;
  @override
  @JsonKey()
  final bool friday;
  @override
  @JsonKey()
  final bool saturday;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'MedicationSchedule(id: $id, medicationId: $medicationId, timeOfDay: $timeOfDay, sunday: $sunday, monday: $monday, tuesday: $tuesday, wednesday: $wednesday, thursday: $thursday, friday: $friday, saturday: $saturday, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.medicationId, medicationId) ||
                other.medicationId == medicationId) &&
            (identical(other.timeOfDay, timeOfDay) ||
                other.timeOfDay == timeOfDay) &&
            (identical(other.sunday, sunday) || other.sunday == sunday) &&
            (identical(other.monday, monday) || other.monday == monday) &&
            (identical(other.tuesday, tuesday) || other.tuesday == tuesday) &&
            (identical(other.wednesday, wednesday) ||
                other.wednesday == wednesday) &&
            (identical(other.thursday, thursday) ||
                other.thursday == thursday) &&
            (identical(other.friday, friday) || other.friday == friday) &&
            (identical(other.saturday, saturday) ||
                other.saturday == saturday) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      medicationId,
      timeOfDay,
      sunday,
      monday,
      tuesday,
      wednesday,
      thursday,
      friday,
      saturday,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationScheduleImplCopyWith<_$MedicationScheduleImpl> get copyWith =>
      __$$MedicationScheduleImplCopyWithImpl<_$MedicationScheduleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationScheduleImplToJson(
      this,
    );
  }
}

abstract class _MedicationSchedule implements MedicationSchedule {
  const factory _MedicationSchedule(
      {required final int id,
      required final int medicationId,
      required final String timeOfDay,
      final bool sunday,
      final bool monday,
      final bool tuesday,
      final bool wednesday,
      final bool thursday,
      final bool friday,
      final bool saturday,
      final DateTime? createdAt}) = _$MedicationScheduleImpl;

  factory _MedicationSchedule.fromJson(Map<String, dynamic> json) =
      _$MedicationScheduleImpl.fromJson;

  @override
  int get id;
  @override
  int get medicationId;
  @override
  String get timeOfDay;
  @override
  bool get sunday;
  @override
  bool get monday;
  @override
  bool get tuesday;
  @override
  bool get wednesday;
  @override
  bool get thursday;
  @override
  bool get friday;
  @override
  bool get saturday;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$MedicationScheduleImplCopyWith<_$MedicationScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

IntakeHistory _$IntakeHistoryFromJson(Map<String, dynamic> json) {
  return _IntakeHistory.fromJson(json);
}

/// @nodoc
mixin _$IntakeHistory {
  int get id => throw _privateConstructorUsedError;
  int get medicationId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get videoPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IntakeHistoryCopyWith<IntakeHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IntakeHistoryCopyWith<$Res> {
  factory $IntakeHistoryCopyWith(
          IntakeHistory value, $Res Function(IntakeHistory) then) =
      _$IntakeHistoryCopyWithImpl<$Res, IntakeHistory>;
  @useResult
  $Res call(
      {int id,
      int medicationId,
      DateTime timestamp,
      String status,
      String? videoPath});
}

/// @nodoc
class _$IntakeHistoryCopyWithImpl<$Res, $Val extends IntakeHistory>
    implements $IntakeHistoryCopyWith<$Res> {
  _$IntakeHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicationId = null,
    Object? timestamp = null,
    Object? status = null,
    Object? videoPath = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      medicationId: null == medicationId
          ? _value.medicationId
          : medicationId // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      videoPath: freezed == videoPath
          ? _value.videoPath
          : videoPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IntakeHistoryImplCopyWith<$Res>
    implements $IntakeHistoryCopyWith<$Res> {
  factory _$$IntakeHistoryImplCopyWith(
          _$IntakeHistoryImpl value, $Res Function(_$IntakeHistoryImpl) then) =
      __$$IntakeHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int medicationId,
      DateTime timestamp,
      String status,
      String? videoPath});
}

/// @nodoc
class __$$IntakeHistoryImplCopyWithImpl<$Res>
    extends _$IntakeHistoryCopyWithImpl<$Res, _$IntakeHistoryImpl>
    implements _$$IntakeHistoryImplCopyWith<$Res> {
  __$$IntakeHistoryImplCopyWithImpl(
      _$IntakeHistoryImpl _value, $Res Function(_$IntakeHistoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicationId = null,
    Object? timestamp = null,
    Object? status = null,
    Object? videoPath = freezed,
  }) {
    return _then(_$IntakeHistoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      medicationId: null == medicationId
          ? _value.medicationId
          : medicationId // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      videoPath: freezed == videoPath
          ? _value.videoPath
          : videoPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IntakeHistoryImpl implements _IntakeHistory {
  const _$IntakeHistoryImpl(
      {required this.id,
      required this.medicationId,
      required this.timestamp,
      required this.status,
      this.videoPath});

  factory _$IntakeHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$IntakeHistoryImplFromJson(json);

  @override
  final int id;
  @override
  final int medicationId;
  @override
  final DateTime timestamp;
  @override
  final String status;
  @override
  final String? videoPath;

  @override
  String toString() {
    return 'IntakeHistory(id: $id, medicationId: $medicationId, timestamp: $timestamp, status: $status, videoPath: $videoPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IntakeHistoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.medicationId, medicationId) ||
                other.medicationId == medicationId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.videoPath, videoPath) ||
                other.videoPath == videoPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, medicationId, timestamp, status, videoPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IntakeHistoryImplCopyWith<_$IntakeHistoryImpl> get copyWith =>
      __$$IntakeHistoryImplCopyWithImpl<_$IntakeHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IntakeHistoryImplToJson(
      this,
    );
  }
}

abstract class _IntakeHistory implements IntakeHistory {
  const factory _IntakeHistory(
      {required final int id,
      required final int medicationId,
      required final DateTime timestamp,
      required final String status,
      final String? videoPath}) = _$IntakeHistoryImpl;

  factory _IntakeHistory.fromJson(Map<String, dynamic> json) =
      _$IntakeHistoryImpl.fromJson;

  @override
  int get id;
  @override
  int get medicationId;
  @override
  DateTime get timestamp;
  @override
  String get status;
  @override
  String? get videoPath;
  @override
  @JsonKey(ignore: true)
  _$$IntakeHistoryImplCopyWith<_$IntakeHistoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
