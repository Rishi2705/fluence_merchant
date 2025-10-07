import '../models/user.dart';

/// Repository interface for authentication-related operations.
/// This defines the contract for authentication data operations.
abstract class AuthRepository {
  /// Attempts to log in a user with email and password.
  /// Returns a [User] object if successful, null otherwise.
  Future<User?> login({
    required String email,
    required String password,
  });

  /// Registers a new user with the provided information.
  /// Returns a [User] object if successful, null otherwise.
  Future<User?> register({
    required String email,
    required String password,
    required String name,
  });

  /// Logs out the current user.
  /// Clears any stored authentication tokens.
  Future<void> logout();

  /// Gets the currently authenticated user.
  /// Returns a [User] object if authenticated, null otherwise.
  Future<User?> getCurrentUser();

  /// Checks if a user is currently authenticated.
  /// Returns true if authenticated, false otherwise.
  Future<bool> isAuthenticated();

  /// Refreshes the authentication token.
  /// Returns true if successful, false otherwise.
  Future<bool> refreshToken();
}