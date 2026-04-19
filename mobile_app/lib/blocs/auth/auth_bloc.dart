// mobile_app/lib/blocs/auth/auth_bloc.dart
// ──────────────────────────────────────────────
// Auth BLoC - Authentication state management
// ──────────────────────────────────────────────

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/services/api_client.dart';
import '../../core/services/storage_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String phone;
  final String password;

  const AuthLoginRequested({
    required this.phone,
    required this.password,
  });

  @override
  List<Object?> get props => [phone, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthRefreshRequested extends AuthEvent {
  const AuthRefreshRequested();
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final int patientId;
  final String phone;

  const AuthAuthenticated({
    required this.patientId,
    required this.phone,
  });

  @override
  List<Object?> get props => [patientId, phone];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiClient apiClient;
  final StorageService storageService;

  AuthBloc({
    required this.apiClient,
    required this.storageService,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final isAuth = await storageService.isAuthenticated();
      final patientIdStr = storageService.getPatientId();

      if (isAuth && patientIdStr != null) {
        final patientId = int.tryParse(patientIdStr) ?? 1;
        emit(AuthAuthenticated(
          patientId: patientId,
          phone: '+21600000000', // Default for now
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // TODO: Replace with actual login API call
      // For now, simulate successful login
      await Future.delayed(const Duration(seconds: 1));

      // Save token and patient ID (backend expects int)
      const mockPatientId = 1;
      await storageService.setToken('mock_token_${DateTime.now().millisecondsSinceEpoch}');
      await storageService.setPatientId(mockPatientId.toString());

      emit(AuthAuthenticated(
        patientId: mockPatientId,
        phone: event.phone,
      ));
    } catch (e) {
      emit(AuthError('فشل تسجيل الدخول: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await storageService.clearAuth();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshRequested(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Implement token refresh
    try {
      final token = await storageService.getToken();
      if (token == null) {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(const AuthUnauthenticated());
    }
  }
}