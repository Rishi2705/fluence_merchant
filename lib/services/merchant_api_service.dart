import 'package:dio/dio.dart';
import '../models/merchant_model.dart';
import '../core/constants/api_constants.dart';
import '../utils/logger.dart';
import 'api_service_new.dart';

/// Exception thrown when merchant profile is not found (404)
class ProfileNotFoundException implements Exception {
  final String message;
  ProfileNotFoundException(this.message);
  
  @override
  String toString() => message;
}

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
    AppLogger.step(1, 'MerchantApiService: Fetching merchant profile');
    AppLogger.api('Profile request', data: {
      'endpoint': ApiConstants.merchantProfile,
      'baseUrl': ApiConstants.merchantBaseUrl,
      'fullUrl': '${ApiConstants.merchantBaseUrl}${ApiConstants.merchantProfile}',
    });

    try {
      final response = await _apiService.get(
        ApiConstants.merchantProfile,
        service: 'merchant',
      );

      AppLogger.api('Profile response', data: {
        'statusCode': response.statusCode,
        'data': response.data,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          AppLogger.success('MerchantApiService: Profile fetched successfully');
          AppLogger.info('MerchantApiService: Profile data from backend', data: data['data']);
          return MerchantProfile.fromJson(data['data']);
        } else {
          AppLogger.error('MerchantApiService: Invalid response format', data: data);
          throw Exception(data['message'] ?? 'Failed to fetch profile');
        }
      } else {
        AppLogger.error('MerchantApiService: Profile fetch failed', data: {
          'statusCode': response.statusCode,
          'response': response.data,
        });
        throw Exception('Failed to fetch profile');
      }
    } on DioException catch (e) {
      AppLogger.error('MerchantApiService: DioException', error: e, data: {
        'type': e.type.toString(),
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      });
      
      // Handle 404 specifically for profile not found
      if (e.response?.statusCode == 404) {
        AppLogger.warning('MerchantApiService: Profile not found (404) - user needs to complete onboarding');
        throw ProfileNotFoundException('Profile not found. Please complete your merchant application.');
      }
      
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

  /// Get merchant analytics (comprehensive)
  Future<MerchantAnalytics> getMerchantAnalytics() async {
    AppLogger.step(1, 'MerchantApiService: Fetching merchant analytics');
    
    try {
      MerchantApplicationStats? applicationStats;
      MerchantProfileStats? profileStats;
      MerchantPerformanceMetrics? performanceMetrics;
      SocialMediaPerformance? socialPerformance;

      try {
        applicationStats = await getApplicationStats();
      } catch (e) {
        AppLogger.warning('MerchantApiService: Failed to fetch application stats', data: e);
      }

      try {
        profileStats = await getProfileStats();
      } catch (e) {
        AppLogger.warning('MerchantApiService: Failed to fetch profile stats', data: e);
      }

      try {
        performanceMetrics = await getPerformanceMetrics();
      } catch (e) {
        AppLogger.warning('MerchantApiService: Failed to fetch performance metrics', data: e);
      }

      try {
        socialPerformance = await getSocialPerformance();
      } catch (e) {
        AppLogger.warning('MerchantApiService: Failed to fetch social performance', data: e);
      }

      AppLogger.success('MerchantApiService: Merchant analytics compiled', data: {
        'hasApplicationStats': applicationStats != null,
        'hasProfileStats': profileStats != null,
        'hasPerformanceMetrics': performanceMetrics != null,
        'hasSocialPerformance': socialPerformance != null,
      });

      return MerchantAnalytics(
        applicationStats: applicationStats,
        profileStats: profileStats,
        performanceMetrics: performanceMetrics,
        socialPerformance: socialPerformance,
      );
    } catch (e, stackTrace) {
      AppLogger.error('MerchantApiService: Failed to fetch merchant analytics', error: e, stackTrace: stackTrace);
      return MerchantAnalytics.empty();
    }
  }

  Future<MerchantApplicationStats> getApplicationStats() async {
    final response = await _apiService.get(ApiConstants.merchantApplicationStats, service: 'merchant');
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        // Backend returns array, we need to aggregate it
        if (data['data'] is List) {
          final List<dynamic> statsArray = data['data'];
          int total = 0;
          int approved = 0;
          int pending = 0;
          int rejected = 0;
          
          for (var item in statsArray) {
            final count = int.tryParse(item['count']?.toString() ?? '0') ?? 0;
            total += count;
            
            final status = item['status']?.toString().toLowerCase() ?? '';
            if (status == 'approved') approved = count;
            else if (status == 'pending') pending = count;
            else if (status == 'rejected') rejected = count;
          }
          
          return MerchantApplicationStats(
            totalApplications: total,
            approvedApplications: approved,
            pendingApplications: pending,
            rejectedApplications: rejected,
            approvalRate: total > 0 ? (approved / total * 100) : 0.0,
            averageProcessingDays: 0,
          );
        }
        return MerchantApplicationStats.fromJson(data['data']);
      }
    }
    throw Exception('Failed to fetch application stats');
  }

  Future<MerchantProfileStats> getProfileStats() async {
    final response = await _apiService.get(ApiConstants.merchantProfileStats, service: 'merchant');
    if (response.statusCode == 200) {
      final data = response.data;
      if (data['success'] == true && data['data'] != null) {
        return MerchantProfileStats.fromJson(data['data']);
      }
    }
    throw Exception('Failed to fetch profile stats');
  }

  Future<MerchantPerformanceMetrics> getPerformanceMetrics() async {
    AppLogger.step(1, 'MerchantApiService: Fetching performance metrics from cashback service');
    
    try {
      final response = await _apiService.get(ApiConstants.transactionAnalytics, service: 'cashback');
      
      AppLogger.api('Performance metrics response', data: {
        'statusCode': response.statusCode,
        'hasData': response.data != null,
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final analyticsData = data['data'] as Map<String, dynamic>;
          
          AppLogger.info('MerchantApiService: Raw analytics data', data: analyticsData);
          
          // Extract metrics from cashback transaction analytics
          final totalRevenue = _parseToDouble(analyticsData['total_volume'] ?? analyticsData['totalVolume'] ?? 0.0);
          final totalTransactions = _parseToInt(analyticsData['total_transactions'] ?? analyticsData['totalTransactions'] ?? 0);
          final averageTransactionValue = _parseToDouble(analyticsData['average_transaction_value'] ?? analyticsData['averageTransactionValue'] ?? 0.0);
          
          // Calculate monthly revenue (if not provided, use total for now)
          final monthlyRevenue = _parseToDouble(analyticsData['monthlyRevenue'] ?? analyticsData['monthly_revenue'] ?? totalRevenue);
          
          // Get customer metrics
          final totalCustomers = _parseToInt(analyticsData['totalCustomers'] ?? analyticsData['total_customers'] ?? analyticsData['uniqueCustomers'] ?? analyticsData['unique_customers'] ?? 0);
          final activeCustomers = _parseToInt(analyticsData['activeCustomers'] ?? analyticsData['active_customers'] ?? totalCustomers);
          
          // Calculate retention rate if not provided
          double retentionRate = _parseToDouble(analyticsData['customerRetentionRate'] ?? analyticsData['customer_retention_rate'] ?? 0.0);
          if (retentionRate == 0.0 && totalCustomers > 0 && activeCustomers > 0) {
            retentionRate = (activeCustomers / totalCustomers * 100);
          }
          
          final metrics = MerchantPerformanceMetrics(
            totalRevenue: totalRevenue,
            monthlyRevenue: monthlyRevenue,
            totalTransactions: totalTransactions,
            monthlyTransactions: _parseToInt(analyticsData['monthlyTransactions'] ?? analyticsData['monthly_transactions'] ?? totalTransactions),
            averageTransactionValue: averageTransactionValue,
            customerSatisfactionScore: _parseToDouble(analyticsData['customerSatisfactionScore'] ?? analyticsData['customer_satisfaction_score'] ?? 0.0),
            totalCustomers: totalCustomers,
            activeCustomers: activeCustomers,
            customerRetentionRate: retentionRate,
          );
          
          AppLogger.success('MerchantApiService: Performance metrics parsed successfully', data: {
            'totalRevenue': metrics.totalRevenue,
            'totalTransactions': metrics.totalTransactions,
            'totalCustomers': metrics.totalCustomers,
          });
          
          return metrics;
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('MerchantApiService: Failed to fetch performance metrics', error: e, stackTrace: stackTrace);
    }
    
    AppLogger.warning('MerchantApiService: Using fallback performance metrics');
    return MerchantPerformanceMetrics(
      totalRevenue: 0.0, monthlyRevenue: 0.0, totalTransactions: 0, monthlyTransactions: 0,
      averageTransactionValue: 0.0, customerSatisfactionScore: 0.0, totalCustomers: 0,
      activeCustomers: 0, customerRetentionRate: 0.0,
    );
  }
  
  static int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.round();
    return 0;
  }

  static double _parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<SocialMediaPerformance> getSocialPerformance() async {
    try {
      final response = await _apiService.get(ApiConstants.socialMerchantReports, service: 'social');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return SocialMediaPerformance.fromJson(data['data']);
        }
      }
    } catch (e) {
      AppLogger.warning('MerchantApiService: Social service unavailable, using fallback performance');
    }
    return SocialMediaPerformance(
      totalPosts: 0, totalLikes: 0, totalShares: 0, totalComments: 0,
      engagementRate: 0.0, followers: 0, reachGrowth: 0.0,
    );
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
