import 'package:dio/dio.dart';
import '../models/merchant_model.dart';
import '../core/constants/api_constants.dart';
import '../utils/logger.dart';
import 'api_service_new.dart';

class MerchantApiService {
  final ApiService _apiService;

  MerchantApiService(this._apiService);

  /// Submit merchant application
  Future<MerchantApplication> submitApplication({
    required String businessName,
    required String businessType,
    required String contactEmail,
    required String contactPhone,
    required BusinessAddress businessAddress,
    required String businessDescription,
    double? expectedMonthlyVolume,
    BankingInfo? bankingInfo,
  }) async {
    AppLogger.step(1, 'Starting merchant application submission');
    AppLogger.api('Application submission request initiated', data: {
      'businessName': businessName,
      'businessType': businessType,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'businessDescription': businessDescription.length > 50 ? '${businessDescription.substring(0, 50)}...' : businessDescription,
      'hasExpectedVolume': expectedMonthlyVolume != null,
      'expectedMonthlyVolume': expectedMonthlyVolume,
      'hasBankingInfo': bankingInfo != null,
      'endpoint': '${ApiConstants.merchantBaseUrl}${ApiConstants.merchantApplications}',
    });

    try {
      // Convert BusinessAddress to string format expected by backend
      final addressString = '${businessAddress.street}, ${businessAddress.city}, ${businessAddress.state} ${businessAddress.zipCode}, ${businessAddress.country}';
      
      final requestData = {
        'businessName': businessName,
        'businessType': businessType,
        'contactPerson': businessName, // Use business name as contact person for now
        'email': contactEmail, // Backend expects 'email' not 'contactEmail'
        'phone': contactPhone, // Backend expects 'phone' not 'contactPhone'
        'businessAddress': addressString, // Backend expects string, not object
        if (bankingInfo != null) 'bankAccountDetails': {
          'accountNumber': bankingInfo.accountNumber,
          'routingNumber': bankingInfo.routingNumber,
        },
      };

      AppLogger.networkRequest(
        method: 'POST',
        url: '${ApiConstants.merchantBaseUrl}${ApiConstants.merchantApplications}',
        body: {
          'businessName': businessName,
          'businessType': businessType,
          'contactPerson': businessName,
          'email': contactEmail,
          'phone': contactPhone,
          'businessAddress': addressString,
          if (bankingInfo != null) 'bankAccountDetails': 'BANKING_INFO_PROVIDED',
        },
      );

      final stopwatch = Stopwatch()..start();
      final response = await _apiService.post(
        ApiConstants.merchantApplications,
        service: 'merchant',
        data: requestData,
      );
      stopwatch.stop();

      AppLogger.networkResponse(
        statusCode: response.statusCode ?? 0,
        url: '${ApiConstants.merchantBaseUrl}${ApiConstants.merchantApplications}',
        body: response.data,
        duration: stopwatch.elapsed,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        AppLogger.step(2, 'Application submission successful, parsing response');
        
        try {
          final application = MerchantApplication.fromJson(response.data['data']);
          AppLogger.success('Merchant application parsed successfully', data: {
            'applicationId': application.id,
            'businessName': application.businessName,
            'status': application.status,
          });
          return application;
        } catch (parseError, stackTrace) {
          AppLogger.error('Failed to parse merchant application', error: parseError, stackTrace: stackTrace);
          AppLogger.error('Raw response data for debugging', data: response.data);
          throw Exception('Failed to parse application response: $parseError');
        }
      } else {
        AppLogger.error('Application submission failed with status code: ${response.statusCode}', data: response.data);
        throw Exception('Application submission failed with status: ${response.statusCode}');
      }
    } on DioException catch (e, stackTrace) {
      AppLogger.error('DioException during application submission', error: e, stackTrace: stackTrace);
      AppLogger.error('DioException details', data: {
        'type': e.type.toString(),
        'message': e.message,
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      });
      throw _handleError(e);
    } catch (e, stackTrace) {
      AppLogger.error('Unexpected error during application submission', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get user applications
  Future<List<MerchantApplication>> getApplications() async {
    try {
      final response = await _apiService.get(
        ApiConstants.merchantApplications,
        service: 'merchant',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List;
        return data
            .map((json) => MerchantApplication.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch applications');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get specific application
  Future<MerchantApplication> getApplication(String applicationId) async {
    try {
      final response = await _apiService.get(
        '${ApiConstants.merchantApplications}/$applicationId',
        service: 'merchant',
      );

      if (response.statusCode == 200) {
        return MerchantApplication.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch application');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update application
  Future<MerchantApplication> updateApplication({
    required String applicationId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiConstants.merchantApplications}/$applicationId',
        service: 'merchant',
        data: updates,
      );

      if (response.statusCode == 200) {
        return MerchantApplication.fromJson(response.data['data']);
      } else {
        throw Exception('Application update failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get merchant profile
  Future<MerchantProfile> getProfile() async {
    try {
      final response = await _apiService.get(
        ApiConstants.merchantProfile,
        service: 'merchant',
      );

      if (response.statusCode == 200) {
        return MerchantProfile.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch profile');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update merchant profile
  Future<MerchantProfile> updateProfile(Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.put(
        ApiConstants.merchantProfile,
        service: 'merchant',
        data: updates,
      );

      if (response.statusCode == 200) {
        return MerchantProfile.fromJson(response.data['data']);
      } else {
        throw Exception('Profile update failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get active merchant profiles (public)
  Future<List<MerchantProfile>> getActiveProfiles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.merchantProfiles,
        service: 'merchant',
        queryParameters: {
          'page': page,
          'limit': limit,
          'status': 'active',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] as List;
        return data
            .map((json) => MerchantProfile.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch profiles');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
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
