// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Patient _$PatientFromJson(Map<String, dynamic> json) {
  return _Patient.fromJson(json);
}

/// @nodoc
mixin _$Patient {
  int get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  String get emergencyContact => throw _privateConstructorUsedError;
  String get emergencyContactPhone => throw _privateConstructorUsedError;
  String get languagePreference => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PatientCopyWith<Patient> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientCopyWith<$Res> {
  factory $PatientCopyWith(Patient value, $Res Function(Patient) then) =
      _$PatientCopyWithImpl<$Res, Patient>;
  @useResult
  $Res call(
      {int id,
      String fullName,
      DateTime dateOfBirth,
      String emergencyContact,
      String emergencyContactPhone,
      String languagePreference,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PatientCopyWithImpl<$Res, $Val extends Patient>
    implements $PatientCopyWith<$Res> {
  _$PatientCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? dateOfBirth = null,
    Object? emergencyContact = null,
    Object? emergencyContactPhone = null,
    Object? languagePreference = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      emergencyContact: null == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String,
      emergencyContactPhone: null == emergencyContactPhone
          ? _value.emergencyContactPhone
          : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      languagePreference: null == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientImplCopyWith<$Res> implements $PatientCopyWith<$Res> {
  factory _$$PatientImplCopyWith(
          _$PatientImpl value, $Res Function(_$PatientImpl) then) =
      __$$PatientImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String fullName,
      DateTime dateOfBirth,
      String emergencyContact,
      String emergencyContactPhone,
      String languagePreference,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PatientImplCopyWithImpl<$Res>
    extends _$PatientCopyWithImpl<$Res, _$PatientImpl>
    implements _$$PatientImplCopyWith<$Res> {
  __$$PatientImplCopyWithImpl(
      _$PatientImpl _value, $Res Function(_$PatientImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? dateOfBirth = null,
    Object? emergencyContact = null,
    Object? emergencyContactPhone = null,
    Object? languagePreference = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PatientImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      emergencyContact: null == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String,
      emergencyContactPhone: null == emergencyContactPhone
          ? _value.emergencyContactPhone
          : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      languagePreference: null == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientImpl implements _Patient {
  const _$PatientImpl(
      {required this.id,
      required this.fullName,
      required this.dateOfBirth,
      required this.emergencyContact,
      required this.emergencyContactPhone,
      this.languagePreference = 'ar',
      required this.createdAt,
      this.updatedAt});

  factory _$PatientImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientImplFromJson(json);

  @override
  final int id;
  @override
  final String fullName;
  @override
  final DateTime dateOfBirth;
  @override
  final String emergencyContact;
  @override
  final String emergencyContactPhone;
  @override
  @JsonKey()
  final String languagePreference;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Patient(id: $id, fullName: $fullName, dateOfBirth: $dateOfBirth, emergencyContact: $emergencyContact, emergencyContactPhone: $emergencyContactPhone, languagePreference: $languagePreference, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.emergencyContact, emergencyContact) ||
                other.emergencyContact == emergencyContact) &&
            (identical(other.emergencyContactPhone, emergencyContactPhone) ||
                other.emergencyContactPhone == emergencyContactPhone) &&
            (identical(other.languagePreference, languagePreference) ||
                other.languagePreference == languagePreference) &&
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
      fullName,
      dateOfBirth,
      emergencyContact,
      emergencyContactPhone,
      languagePreference,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      __$$PatientImplCopyWithImpl<_$PatientImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientImplToJson(
      this,
    );
  }
}

abstract class _Patient implements Patient {
  const factory _Patient(
      {required final int id,
      required final String fullName,
      required final DateTime dateOfBirth,
      required final String emergencyContact,
      required final String emergencyContactPhone,
      final String languagePreference,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$PatientImpl;

  factory _Patient.fromJson(Map<String, dynamic> json) = _$PatientImpl.fromJson;

  @override
  int get id;
  @override
  String get fullName;
  @override
  DateTime get dateOfBirth;
  @override
  String get emergencyContact;
  @override
  String get emergencyContactPhone;
  @override
  String get languagePreference;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$PatientImplCopyWith<_$PatientImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PatientCreateRequest _$PatientCreateRequestFromJson(Map<String, dynamic> json) {
  return _PatientCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$PatientCreateRequest {
  String get fullName => throw _privateConstructorUsedError;
  DateTime get dateOfBirth => throw _privateConstructorUsedError;
  String get emergencyContact => throw _privateConstructorUsedError;
  String get emergencyContactPhone => throw _privateConstructorUsedError;
  String get languagePreference => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PatientCreateRequestCopyWith<PatientCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientCreateRequestCopyWith<$Res> {
  factory $PatientCreateRequestCopyWith(PatientCreateRequest value,
          $Res Function(PatientCreateRequest) then) =
      _$PatientCreateRequestCopyWithImpl<$Res, PatientCreateRequest>;
  @useResult
  $Res call(
      {String fullName,
      DateTime dateOfBirth,
      String emergencyContact,
      String emergencyContactPhone,
      String languagePreference});
}

/// @nodoc
class _$PatientCreateRequestCopyWithImpl<$Res,
        $Val extends PatientCreateRequest>
    implements $PatientCreateRequestCopyWith<$Res> {
  _$PatientCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? dateOfBirth = null,
    Object? emergencyContact = null,
    Object? emergencyContactPhone = null,
    Object? languagePreference = null,
  }) {
    return _then(_value.copyWith(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      emergencyContact: null == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String,
      emergencyContactPhone: null == emergencyContactPhone
          ? _value.emergencyContactPhone
          : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      languagePreference: null == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientCreateRequestImplCopyWith<$Res>
    implements $PatientCreateRequestCopyWith<$Res> {
  factory _$$PatientCreateRequestImplCopyWith(_$PatientCreateRequestImpl value,
          $Res Function(_$PatientCreateRequestImpl) then) =
      __$$PatientCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fullName,
      DateTime dateOfBirth,
      String emergencyContact,
      String emergencyContactPhone,
      String languagePreference});
}

/// @nodoc
class __$$PatientCreateRequestImplCopyWithImpl<$Res>
    extends _$PatientCreateRequestCopyWithImpl<$Res, _$PatientCreateRequestImpl>
    implements _$$PatientCreateRequestImplCopyWith<$Res> {
  __$$PatientCreateRequestImplCopyWithImpl(_$PatientCreateRequestImpl _value,
      $Res Function(_$PatientCreateRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? dateOfBirth = null,
    Object? emergencyContact = null,
    Object? emergencyContactPhone = null,
    Object? languagePreference = null,
  }) {
    return _then(_$PatientCreateRequestImpl(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfBirth: null == dateOfBirth
          ? _value.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime,
      emergencyContact: null == emergencyContact
          ? _value.emergencyContact
          : emergencyContact // ignore: cast_nullable_to_non_nullable
              as String,
      emergencyContactPhone: null == emergencyContactPhone
          ? _value.emergencyContactPhone
          : emergencyContactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      languagePreference: null == languagePreference
          ? _value.languagePreference
          : languagePreference // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PatientCreateRequestImpl implements _PatientCreateRequest {
  const _$PatientCreateRequestImpl(
      {required this.fullName,
      required this.dateOfBirth,
      required this.emergencyContact,
      required this.emergencyContactPhone,
      this.languagePreference = 'ar'});

  factory _$PatientCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$PatientCreateRequestImplFromJson(json);

  @override
  final String fullName;
  @override
  final DateTime dateOfBirth;
  @override
  final String emergencyContact;
  @override
  final String emergencyContactPhone;
  @override
  @JsonKey()
  final String languagePreference;

  @override
  String toString() {
    return 'PatientCreateRequest(fullName: $fullName, dateOfBirth: $dateOfBirth, emergencyContact: $emergencyContact, emergencyContactPhone: $emergencyContactPhone, languagePreference: $languagePreference)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientCreateRequestImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.emergencyContact, emergencyContact) ||
                other.emergencyContact == emergencyContact) &&
            (identical(other.emergencyContactPhone, emergencyContactPhone) ||
                other.emergencyContactPhone == emergencyContactPhone) &&
            (identical(other.languagePreference, languagePreference) ||
                other.languagePreference == languagePreference));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, fullName, dateOfBirth,
      emergencyContact, emergencyContactPhone, languagePreference);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientCreateRequestImplCopyWith<_$PatientCreateRequestImpl>
      get copyWith =>
          __$$PatientCreateRequestImplCopyWithImpl<_$PatientCreateRequestImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PatientCreateRequestImplToJson(
      this,
    );
  }
}

abstract class _PatientCreateRequest implements PatientCreateRequest {
  const factory _PatientCreateRequest(
      {required final String fullName,
      required final DateTime dateOfBirth,
      required final String emergencyContact,
      required final String emergencyContactPhone,
      final String languagePreference}) = _$PatientCreateRequestImpl;

  factory _PatientCreateRequest.fromJson(Map<String, dynamic> json) =
      _$PatientCreateRequestImpl.fromJson;

  @override
  String get fullName;
  @override
  DateTime get dateOfBirth;
  @override
  String get emergencyContact;
  @override
  String get emergencyContactPhone;
  @override
  String get languagePreference;
  @override
  @JsonKey(ignore: true)
  _$$PatientCreateRequestImplCopyWith<_$PatientCreateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
