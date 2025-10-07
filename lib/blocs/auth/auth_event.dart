import 'package:equatable/equatable.dart';

/// Base class for all events in the authentication BLoC.
/// All auth events should extend this class.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when user attempts to login.
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event triggered when user attempts to logout.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event triggered to check authentication status.
class AuthStatusRequested extends AuthEvent {
  const AuthStatusRequested();
}

/// Event triggered when user attempts to register.
class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}