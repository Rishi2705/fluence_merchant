import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../utils/logger.dart';

/// Implementation of AuthRepository that handles authentication operations.
class AuthRepositoryImpl {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  Future<AuthResponse> signInWithFirebase({
    required String idToken,
    String? referralCode,
  }) async {
    AppLogger.auth('Repository: Starting Firebase sign in');
    try {
      final result = await _authApiService.firebaseAuth(
        idToken: idToken,
        referralCode: referralCode,
      );
      AppLogger.success('Repository: Firebase sign in completed successfully');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Repository: Firebase sign in failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<MerchantUser> completeProfile({
    required String name,
    required String phone,
    required String dateOfBirth,
  }) async {
    AppLogger.auth('Repository: Starting profile completion');
    try {
      final result = await _authApiService.completeProfile(
        name: name,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );
      AppLogger.success('Repository: Profile completion completed successfully');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Repository: Profile completion failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateAccountStatus(String status) async {
    return await _authApiService.updateAccountStatus(status);
  }

  Future<void> logout() async {
    return await _authApiService.logout();
  }

  bool get isAuthenticated {
    final isAuth = _authApiService.isAuthenticated;
    AppLogger.auth('Repository: Checking authentication status', data: {'isAuthenticated': isAuth});
    return isAuth;
  }
}