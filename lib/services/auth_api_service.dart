import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../core/constants/api_constants.dart';
import '../utils/logger.dart';
import 'api_service_new.dart';

class AuthApiService {
  final ApiService _apiService;

  AuthApiService(this._apiService);

  /// Firebase authentication
  Future<AuthResponse> firebaseAuth({
    required String idToken,
    String? referralCode,
  }) async {
    AppLogger.step(1, 'Starting Firebase authentication with backend');
    AppLogger.auth('Firebase auth request initiated', data: {
      'hasIdToken': idToken.isNotEmpty,
      'idTokenLength': idToken.length,
      'hasReferralCode': referralCode != null,
      'referralCode': referralCode,
      'endpoint': '${ApiConstants.authBaseUrl}${ApiConstants.authFirebase}',
    });

    try {
      final requestData = {
        'idToken': idToken,
        if (referralCode != null) 'referralCode': referralCode,
      };

      AppLogger.networkRequest(
        method: 'POST',
        url: '${ApiConstants.authBaseUrl}${ApiConstants.authFirebase}',
        body: {
          'idToken': '${idToken.substring(0, 20)}...', // Truncated for security
          if (referralCode != null) 'referralCode': referralCode,
        },
      );

      final stopwatch = Stopwatch()..start();
      final response = await _apiService.post(
        ApiConstants.authFirebase,
        service: 'auth',
        data: requestData,
      );
      stopwatch.stop();

      AppLogger.networkResponse(
        statusCode: response.statusCode ?? 0,
        url: '${ApiConstants.authBaseUrl}${ApiConstants.authFirebase}',
        body: response.data,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode == 200) {
        AppLogger.step(2, 'Backend authentication successful, parsing response');
        
        try {
          final authResponse = AuthResponse.fromJson(response.data);
          AppLogger.success('AuthResponse parsed successfully', data: {
            'hasUser': authResponse.user != null,
            'userId': authResponse.user.id,
            'userEmail': authResponse.user.email,
            'hasToken': authResponse.token.isNotEmpty,
            'tokenLength': authResponse.token.length,
            'needsProfileCompletion': authResponse.needsProfileCompletion,
          });

          AppLogger.step(3, 'Setting authentication token in API service');
          await _apiService.setToken(authResponse.token);
          AppLogger.success('Authentication token set successfully');

          return authResponse;
        } catch (parseError, stackTrace) {
          AppLogger.error('Failed to parse AuthResponse', error: parseError, stackTrace: stackTrace);
          AppLogger.error('Raw response data for debugging', data: response.data);
          throw Exception('Failed to parse authentication response: $parseError');
        }
      } else {
        AppLogger.error('Authentication failed with status code: ${response.statusCode}', data: response.data);
        throw Exception('Authentication failed with status: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.error('DioException during Firebase authentication', error: e, stackTrace: stackTrace);
      AppLogger.error('DioException details', data: {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      });
      throw _handleError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during Firebase authentication', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Complete user profile
  Future<MerchantUser> completeProfile({
    required String name,
    required String phone,
    required String dateOfBirth,
  }) async {
    AppLogger.step(1, 'Starting profile completion');
    AppLogger.auth('Profile completion request initiated', data: {
      'name': name,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'endpoint': '${ApiConstants.authBaseUrl}${ApiConstants.authCompleteProfile}',
    });

    try {
      final requestData = {
        'name': name,
        'phone': phone,
        'dateOfBirth': dateOfBirth,
      };

      AppLogger.networkRequest(
        method: 'POST',
        url: '${ApiConstants.authBaseUrl}${ApiConstants.authCompleteProfile}',
        body: requestData,
      );

      final stopwatch = Stopwatch()..start();
      final response = await _apiService.post(
        ApiConstants.authCompleteProfile,
        service: 'auth',
        data: requestData,
      );
      stopwatch.stop();

      AppLogger.networkResponse(
        statusCode: response.statusCode ?? 0,
        url: '${ApiConstants.authBaseUrl}${ApiConstants.authCompleteProfile}',
        body: response.data,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode == 200) {
        AppLogger.step(2, 'Profile completion successful, parsing user data');
        
        try {
          final user = MerchantUser.fromJson(response.data['user']);
          AppLogger.success('User profile parsed successfully', data: {
            'userId': user.id,
            'userName': user.name,
            'userEmail': user.email,
            'userStatus': user.status,
          });
          return user;
        } catch (parseError, stackTrace) {
          AppLogger.error('Failed to parse user profile', error: parseError, stackTrace: stackTrace);
          AppLogger.error('Raw response data for debugging', data: response.data);
          throw Exception('Failed to parse user profile: $parseError');
        }
      } else {
        AppLogger.error('Profile completion failed with status code: ${response.statusCode}', data: response.data);
        throw Exception('Profile completion failed with status: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.error('DioException during profile completion', error: e, stackTrace: stackTrace);
      AppLogger.error('DioException details', data: {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      });
      throw _handleError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during profile completion', error: e, stackTrace: stackTrace);
      rethrow;
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
    AppLogger.auth('Logging out user');
    await _apiService.clearToken();
    AppLogger.success('User logged out successfully');
  }

  /// Check if authenticated
  bool get isAuthenticated {
    final isAuth = _apiService.isAuthenticated;
    AppLogger.auth('Checking authentication status', data: {'isAuthenticated': isAuth});
    return isAuth;
  }

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
