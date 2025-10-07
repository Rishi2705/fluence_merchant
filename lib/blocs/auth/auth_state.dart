import 'package:equatable/equatable.dart';

/// Base class for all states in the authentication BLoC.
/// All auth states should extend this class.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial state when the BLoC is first created.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is successfully authenticated.
class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;
  final String name;

  const AuthAuthenticated({
    required this.userId,
    required this.email,
    required this.name,
  });

  @override
  List<Object> get props => [userId, email, name];
}

/// State when user is not authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when there's an authentication error.
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}