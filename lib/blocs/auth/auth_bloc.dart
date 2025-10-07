import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC that manages authentication state and handles auth-related events.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthStatusRequested>(_onAuthStatusRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  /// Handles login request event.
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      
      if (user != null) {
        emit(AuthAuthenticated(
          userId: user.id,
          email: user.email,
          name: user.name,
        ));
      } else {
        emit(const AuthError(message: 'Login failed. Please check your credentials.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles logout request event.
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles auth status check event.
  Future<void> _onAuthStatusRequested(
    AuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.getCurrentUser();
      
      if (user != null) {
        emit(AuthAuthenticated(
          userId: user.id,
          email: user.email,
          name: user.name,
        ));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles register request event.
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      
      if (user != null) {
        emit(AuthAuthenticated(
          userId: user.id,
          email: user.email,
          name: user.name,
        ));
      } else {
        emit(const AuthError(message: 'Registration failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}