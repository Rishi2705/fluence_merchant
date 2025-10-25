import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication check
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication is in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated
class AuthAuthenticated extends AuthState {
  final MerchantUser? user;

  const AuthAuthenticated({this.user});

  @override
  List<Object?> get props => [user];
}

/// State when user is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when user needs to complete profile
class AuthNeedsProfileCompletion extends AuthState {
  final MerchantUser? user;

  const AuthNeedsProfileCompletion({this.user});

  @override
  List<Object?> get props => [user];
}

/// State when there's an authentication error
class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}