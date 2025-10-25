import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../core/constants/api_constants.dart';
import 'api_service_new.dart';

class AuthApiService {
  final ApiService _apiService;

  AuthApiService(this._apiService);

  /// Firebase authentication
  Future<AuthResponse> firebaseAuth({
    required String idToken,
    String? referralCode,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.authFirebase,
        service: 'auth',
        data: {
          'idToken': idToken,
          if (referralCode != null) 'referralCode': referralCode,
        },
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data);
        await _apiService.setToken(authResponse.token);
        return authResponse;
      } else {
        throw Exception('Authentication failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete user profile
  Future<MerchantUser> completeProfile({
    required String name,
    required String phone,
    required String dateOfBirth,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.authCompleteProfile,
        service: 'auth',
        data: {
          'name': name,
          'phone': phone,
          'dateOfBirth': dateOfBirth,
        },
      );

      if (response.statusCode == 200) {
        return MerchantUser.fromJson(response.data['user']);
      } else {
        throw Exception('Profile completion failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update account status
  Future<void> updateAccountStatus(String status) async {
    try {
      final response = await _apiService.post(
        ApiConstants.authAccountStatus,
        service: 'auth',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        throw Exception('Status update failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    await _apiService.clearToken();
  }

  /// Check if authenticated
  bool get isAuthenticated => _apiService.isAuthenticated;

  /// Handle errors
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Server error: ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout - Server took too long to respond. Please check your internet connection and ensure the backend server is running.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout - Server is taking too long to send data. Please try again.';
    } else if (error.type == DioExceptionType.sendTimeout) {
      return 'Send timeout - Request took too long to send. Please check your internet connection.';
    } else if (error.type == DioExceptionType.cancel) {
      return 'Request was cancelled';
    } else if (error.type == DioExceptionType.badResponse) {
      return 'Bad response from server: ${error.response?.statusCode}';
    } else {
      return 'Network error: ${error.message}';
    }
  }
}
