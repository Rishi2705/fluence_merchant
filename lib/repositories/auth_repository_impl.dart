import '../models/user_model.dart';
import '../services/auth_api_service.dart';

/// Implementation of AuthRepository that handles authentication operations.
class AuthRepositoryImpl {
  final AuthApiService _authApiService;

  AuthRepositoryImpl(this._authApiService);

  Future<AuthResponse> signInWithFirebase({
    required String idToken,
    String? referralCode,
  }) async {
    return await _authApiService.firebaseAuth(
      idToken: idToken,
      referralCode: referralCode,
    );
  }

  Future<MerchantUser> completeProfile({
    required String name,
    required String phone,
    required String dateOfBirth,
  }) async {
    return await _authApiService.completeProfile(
      name: name,
      phone: phone,
      dateOfBirth: dateOfBirth,
    );
  }

  Future<void> updateAccountStatus(String status) async {
    return await _authApiService.updateAccountStatus(status);
  }

  Future<void> logout() async {
    return await _authApiService.logout();
  }

  bool get isAuthenticated => _authApiService.isAuthenticated;
}