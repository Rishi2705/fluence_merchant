import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository_impl.dart';
import '../../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// BLoC that manages authentication state and handles auth-related events.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl _authRepository;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInWithFirebase>(_onSignInWithFirebase);
    on<AuthCompleteProfile>(_onCompleteProfile);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  /// Checks if user is authenticated
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final isAuth = _authRepository.isAuthenticated;
      if (isAuth) {
        // User is authenticated, emit authenticated state
        emit(const AuthAuthenticated(user: null));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles Firebase sign-in
  Future<void> _onSignInWithFirebase(
    AuthSignInWithFirebase event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final authResponse = await _authRepository.signInWithFirebase(
        idToken: event.idToken,
        referralCode: event.referralCode,
      );
      
      if (authResponse.needsProfileCompletion) {
        emit(AuthNeedsProfileCompletion(user: authResponse.user));
      } else {
        emit(AuthAuthenticated(user: authResponse.user));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles profile completion
  Future<void> _onCompleteProfile(
    AuthCompleteProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final user = await _authRepository.completeProfile(
        name: event.name,
        phone: event.phone,
        dateOfBirth: event.dateOfBirth,
      );
      
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  /// Handles logout
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
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
}