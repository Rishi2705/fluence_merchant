import 'package:equatable/equatable.dart';

/// Base class for all events in the authentication BLoC.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check if user is authenticated
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event triggered when user signs in with Firebase
class AuthSignInWithFirebase extends AuthEvent {
  final String idToken;
  final String? referralCode;

  const AuthSignInWithFirebase({
    required this.idToken,
    this.referralCode,
  });

  @override
  List<Object?> get props => [idToken, referralCode];
}

/// Event triggered when user completes profile
class AuthCompleteProfile extends AuthEvent {
  final String name;
  final String phone;
  final String dateOfBirth;

  const AuthCompleteProfile({
    required this.name,
    required this.phone,
    required this.dateOfBirth,
  });

  @override
  List<Object?> get props => [name, phone, dateOfBirth];
}

/// Event triggered when user logs out
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}