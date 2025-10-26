import 'package:dio/dio.dart';
import '../models/analytics_model.dart';
import '../models/wallet_model.dart';
import '../core/constants/api_constants.dart';
import '../utils/logger.dart';
import 'api_service_new.dart';

class AnalyticsApiService {
  final ApiService _apiService;

  AnalyticsApiService(this._apiService);

  /// Get complete dashboard data
  Future<DashboardData> getDashboardData() async {
    AppLogger.step(1, 'AnalyticsApiService: Fetching complete dashboard data');
    
    try {
      // Fetch all data individually with error handling for each
      BalanceSummary balanceSummary;
      TransactionStats transactionStats;
      List<RecentActivity> recentActivities;
      Map<String, dynamic>? socialAnalytics;
      ActiveCampaign? activeCampaign;
      List<TopCustomer> topCustomers = [];

      try {
        balanceSummary = await getBalanceSummary().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            AppLogger.warning('AnalyticsApiService: Balance fetch timed out');
            return BalanceSummary(
              totalBalance: 0.0,
              availableBalance: 0.0,
              pendingBalance: 0.0,
              totalEarned: 0.0,
              totalRedeemed: 0.0,
            );
          },
        );
      } catch (e) {
        AppLogger.warning('AnalyticsApiService: Failed to fetch balance, using empty data', data: e);
        balanceSummary = BalanceSummary(
          totalBalance: 0.0,
          availableBalance: 0.0,
          pendingBalance: 0.0,
          totalEarned: 0.0,
          totalRedeemed: 0.0,
        );
      }

      try {
        transactionStats = await getTransactionStats();
        AppLogger.success('AnalyticsApiService: Transaction stats loaded successfully');
      } catch (e, stackTrace) {
        AppLogger.error('AnalyticsApiService: Failed to fetch transaction stats, using fallback data', error: e, stackTrace: stackTrace);
        transactionStats = TransactionStats(
          totalTransactions: 0,
          todayTransactions: 0,
          totalAmount: 0.0,
          todayAmount: 0.0,
          averageTransactionValue: 0.0,
          dailySummary: [],
        );
      }

      try {
        recentActivities = await getRecentTransactions(limit: 10);
      } catch (e) {
        AppLogger.warning('AnalyticsApiService: Failed to fetch recent transactions, using empty data', data: e);
        recentActivities = [];
      }

      try {
        socialAnalytics = await getSocialAnalytics();
      } catch (e) {
        AppLogger.warning('AnalyticsApiService: Failed to fetch social analytics, using empty data', data: e);
        socialAnalytics = null;
      }

      try {
        activeCampaign = await getActiveCampaign().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            AppLogger.warning('AnalyticsApiService: Active campaign fetch timed out');
            return null;
          },
        );
      } catch (e) {
        AppLogger.warning('AnalyticsApiService: Failed to fetch active campaign, using empty data', data: e);
        activeCampaign = null;
      }

      try {
        topCustomers = await getTopCustomers().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            AppLogger.warning('AnalyticsApiService: Top customers fetch timed out');
            return _getFallbackTopCustomers();
          },
        );
      } catch (e) {
        AppLogger.warning('AnalyticsApiService: Failed to fetch top customers, using fallback data', data: e);
        topCustomers = _getFallbackTopCustomers();
      }

      // Calculate dashboard stats from the fetched data with safe parsing
      late DashboardStats stats;
      try {
        stats = DashboardStats(
          activeUsers: _parseToInt(socialAnalytics?['active_users'] ?? socialAnalytics?['activeUsers'] ?? 0),
          todayTransactions: transactionStats.todayTransactions,
          trendingPercentage: _calculateTrendingPercentage(transactionStats),
          totalRevenue: balanceSummary.totalEarned,
          todayRevenue: transactionStats.todayAmount,
          totalPosts: _parseToInt(socialAnalytics?['total_posts'] ?? socialAnalytics?['totalPosts'] ?? 0),
          totalLikes: _parseToInt(socialAnalytics?['total_likes'] ?? socialAnalytics?['totalLikes'] ?? 0),
        );
        AppLogger.success('AnalyticsApiService: Dashboard stats calculated successfully');
      } catch (e, stackTrace) {
        AppLogger.error('AnalyticsApiService: Failed to calculate dashboard stats, using fallback', error: e, stackTrace: stackTrace);
        stats = DashboardStats(
          activeUsers: 0,
          todayTransactions: 0,
          trendingPercentage: 0.0,
          totalRevenue: 0.0,
          todayRevenue: 0.0,
          totalPosts: 0,
          totalLikes: 0,
        );
      }

      final dashboardData = DashboardData(
        stats: stats,
        transactionStats: transactionStats,
        balanceSummary: balanceSummary,
        recentActivities: recentActivities,
        activeCampaign: activeCampaign,
        topCustomers: topCustomers,
      );

      AppLogger.success('AnalyticsApiService: Dashboard data fetched successfully', data: {
        'todayTransactions': stats.todayTransactions,
        'totalRevenue': stats.totalRevenue,
        'recentActivitiesCount': recentActivities.length,
        'hasActiveCampaign': activeCampaign != null,
        'activeUsers': stats.activeUsers,
      });

      return dashboardData;
    } catch (e, stackTrace) {
      AppLogger.error('AnalyticsApiService: Critical failure in getDashboardData, returning fallback data', error: e, stackTrace: stackTrace);
      
      // Return completely fallback data to prevent infinite loading
      return DashboardData(
        stats: DashboardStats(
          activeUsers: 0,
          todayTransactions: 0,
          trendingPercentage: 0.0,
          totalRevenue: 0.0,
          todayRevenue: 0.0,
          totalPosts: 0,
          totalLikes: 0,
        ),
        transactionStats: TransactionStats(
          totalTransactions: 0,
          todayTransactions: 0,
          totalAmount: 0.0,
          todayAmount: 0.0,
          averageTransactionValue: 0.0,
          dailySummary: [],
        ),
        balanceSummary: BalanceSummary(
          totalBalance: 0.0,
          availableBalance: 0.0,
          pendingBalance: 0.0,
          totalEarned: 0.0,
          totalRedeemed: 0.0,
        ),
        recentActivities: [],
        activeCampaign: null,
        topCustomers: [],
      );
    }
  }

  /// Get balance summary
  Future<BalanceSummary> getBalanceSummary() async {
    AppLogger.step(1, 'AnalyticsApiService: Fetching balance summary');
    AppLogger.api('Balance summary request', data: {
      'endpoint': ApiConstants.walletBalance,
    });

    try {
      // Use the regular balance endpoint since summary might not exist
      final response = await _apiService.get(
        ApiConstants.walletBalance,
        service: 'wallet',
      );

      AppLogger.api('Balance summary response', data: {
        'statusCode': response.statusCode,
        'hasData': response.data != null,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          AppLogger.success('AnalyticsApiService: Balance summary fetched successfully');
          
          // Convert wallet balance to balance summary
          final balanceData = data['data'];
          return BalanceSummary(
            totalBalance: (balanceData['totalBalance'] ?? balanceData['total_balance'] ?? 0.0).toDouble(),
            availableBalance: (balanceData['availableBalance'] ?? balanceData['available_balance'] ?? 0.0).toDouble(),
            pendingBalance: (balanceData['pendingBalance'] ?? balanceData['pending_balance'] ?? 0.0).toDouble(),
            totalEarned: (balanceData['totalEarned'] ?? balanceData['total_earned'] ?? 0.0).toDouble(),
            totalRedeemed: (balanceData['totalRedeemed'] ?? balanceData['total_redeemed'] ?? 0.0).toDouble(),
          );
        } else {
          AppLogger.error('AnalyticsApiService: Invalid balance summary response', data: data);
          throw Exception(data['message'] ?? 'Failed to fetch balance summary');
        }
      } else if (response.statusCode == 404) {
        AppLogger.warning('AnalyticsApiService: Balance not found - returning empty balance');
        // Return empty balance instead of throwing error
        return BalanceSummary(
          totalBalance: 0.0,
          availableBalance: 0.0,
          pendingBalance: 0.0,
          totalEarned: 0.0,
          totalRedeemed: 0.0,
        );
      } else {
        AppLogger.error('AnalyticsApiService: Balance summary fetch failed', data: {
          'statusCode': response.statusCode,
        });
        throw Exception('Failed to fetch balance summary');
      }
    } on DioException catch (e) {
      AppLogger.error('AnalyticsApiService: DioException fetching balance summary', error: e, data: {
        'type': e.type.toString(),
        'statusCode': e.response?.statusCode,
      });
      
      // If 404, return empty balance instead of throwing
      if (e.response?.statusCode == 404) {
        AppLogger.warning('AnalyticsApiService: Balance endpoint not found - returning empty balance');
        return BalanceSummary(
          totalBalance: 0.0,
          availableBalance: 0.0,
          pendingBalance: 0.0,
          totalEarned: 0.0,
          totalRedeemed: 0.0,
        );
      }
      
      throw _handleError(e);
    }
  }

  /// Get transaction statistics
  Future<TransactionStats> getTransactionStats() async {
    AppLogger.step(1, 'AnalyticsApiService: Fetching transaction stats');
    AppLogger.api('Transaction stats request', data: {
      'endpoint': '/api/points/stats',
    });

    try {
      final response = await _apiService.get(
        '/api/points/stats',
        service: 'wallet',
      );

      AppLogger.api('Transaction stats response', data: {
        'statusCode': response.statusCode,
        'hasData': response.data != null,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          AppLogger.success('AnalyticsApiService: Transaction stats fetched successfully');
          // Handle the backend response format which might have strings
          final responseData = data['data'] as Map<String, dynamic>;
          AppLogger.info('AnalyticsApiService: Raw transaction data', data: responseData);
          return TransactionStats.fromJson(responseData);
        } else {
          AppLogger.error('AnalyticsApiService: Invalid transaction stats response', data: data);
          throw Exception(data['message'] ?? 'Failed to fetch transaction stats');
        }
      } else if (response.statusCode == 404) {
        AppLogger.warning('AnalyticsApiService: Transaction stats not found - returning empty stats');
        // Return empty stats instead of throwing error
        return TransactionStats(
          totalTransactions: 0,
          todayTransactions: 0,
          totalAmount: 0.0,
          todayAmount: 0.0,
          averageTransactionValue: 0.0,
          dailySummary: [],
        );
      } else {
        AppLogger.error('AnalyticsApiService: Transaction stats fetch failed', data: {
          'statusCode': response.statusCode,
        });
        throw Exception('Failed to fetch transaction stats');
      }
    } on DioException catch (e) {
      AppLogger.error('AnalyticsApiService: DioException fetching transaction stats', error: e, data: {
        'type': e.type.toString(),
        'statusCode': e.response?.statusCode,
      });
      
      // If 404, return empty stats instead of throwing
      if (e.response?.statusCode == 404) {
        AppLogger.warning('AnalyticsApiService: Transaction stats endpoint not found - returning empty stats');
        return TransactionStats(
          totalTransactions: 0,
          todayTransactions: 0,
          totalAmount: 0.0,
          todayAmount: 0.0,
          averageTransactionValue: 0.0,
          dailySummary: [],
        );
      }
      
      throw _handleError(e);
    }
  }

  /// Get recent transactions as activities
  Future<List<RecentActivity>> getRecentTransactions({int limit = 10}) async {
    AppLogger.step(1, 'AnalyticsApiService: Fetching recent transactions');
    AppLogger.api('Recent transactions request', data: {
      'endpoint': ApiConstants.pointsTransactions,
      'limit': limit,
    });

    try {
      final response = await _apiService.get(
        ApiConstants.pointsTransactions,
        service: 'wallet',
        queryParameters: {
          'limit': limit,
          'offset': 0,
        },
      );

      AppLogger.api('Recent transactions response', data: {
        'statusCode': response.statusCode,
        'hasData': response.data != null,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final dynamic transactionsData = data['data'];
          final List<dynamic> transactions = transactionsData is List 
              ? transactionsData 
              : (transactionsData['transactions'] as List? ?? []);
          
          final activities = transactions
              .map((json) => _convertTransactionToActivity(json as Map<String, dynamic>))
              .toList();

          AppLogger.success('AnalyticsApiService: Recent transactions fetched successfully', data: {
            'count': activities.length,
          });

          return activities;
        } else {
          AppLogger.error('AnalyticsApiService: Invalid recent transactions response', data: data);
          throw Exception(data['message'] ?? 'Failed to fetch recent transactions');
        }
      } else {
        AppLogger.error('AnalyticsApiService: Recent transactions fetch failed', data: {
          'statusCode': response.statusCode,
        });
        throw Exception('Failed to fetch recent transactions');
      }
    } on DioException catch (e) {
      AppLogger.error('AnalyticsApiService: DioException fetching recent transactions', error: e, data: {
        'type': e.type.toString(),
        'statusCode': e.response?.statusCode,
      });
      throw _handleError(e);
    }
  }

  /// Convert transaction to activity
  RecentActivity _convertTransactionToActivity(Map<String, dynamic> transaction) {
    final type = transaction['type'] ?? 'transaction';
    String action;
    
    switch (type.toLowerCase()) {
      case 'earn':
      case 'earned':
        action = 'earned points';
        break;
      case 'redeem':
      case 'redeemed':
        action = 'redeemed points';
        break;
      case 'purchase':
        action = 'made a purchase';
        break;
      case 'refund':
        action = 'received a refund';
        break;
      default:
        action = 'made a transaction';
    }

    final timestampStr = transaction['created_at'] ?? transaction['timestamp'];
    final timeAgo = _calculateTimeAgo(timestampStr);

    return RecentActivity(
      id: transaction['id'] ?? transaction['transaction_id'] ?? '',
      userName: transaction['user_name'] ?? transaction['userName'] ?? 'Customer',
      userInitial: (transaction['user_name'] ?? transaction['userName'] ?? 'C')[0].toUpperCase(),
      action: action,
      timeAgo: timeAgo,
      amount: (transaction['amount'] ?? 0.0).toDouble().abs(),
      type: type,
      timestamp: DateTime.parse(timestampStr ?? DateTime.now().toIso8601String()),
    );
  }

  /// Calculate time ago from timestamp
  String _calculateTimeAgo(String? timestampStr) {
    if (timestampStr == null) return 'Just now';
    
    try {
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);
      
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${(difference.inDays / 7).floor()}w ago';
    } catch (e) {
      return 'Just now';
    }
  }

  /// Calculate trending percentage from transaction stats
  double _calculateTrendingPercentage(TransactionStats stats) {
    if (stats.dailySummary.isEmpty || stats.dailySummary.length < 2) {
      return 0.0;
    }

    // Compare today with yesterday
    final today = stats.dailySummary.first.totalAmount;
    final yesterday = stats.dailySummary.length > 1 ? stats.dailySummary[1].totalAmount : 0.0;

    if (yesterday == 0) return today > 0 ? 100.0 : 0.0;

    final percentage = ((today - yesterday) / yesterday) * 100;
    return double.parse(percentage.toStringAsFixed(1));
  }

  /// Get social/merchant analytics
  Future<Map<String, dynamic>?> getSocialAnalytics() async {
    AppLogger.step(1, 'AnalyticsApiService: Fetching social analytics');
    
    try {
      final response = await _apiService.get(
        ApiConstants.socialMerchantAnalytics,
        service: 'social',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          AppLogger.success('AnalyticsApiService: Social analytics fetched successfully');
          return data['data'] as Map<String, dynamic>;
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.warning('AnalyticsApiService: Social analytics not available', data: e);
      return null;
    }
  }

  /// Get active campaign
  Future<ActiveCampaign?> getActiveCampaign() async {
    AppLogger.step(1, 'AnalyticsApiService: Fetching active campaign');
    
    try {
      final response = await _apiService.get(
        ApiConstants.campaignsActive,
        service: 'cashback',
        queryParameters: {
          'status': 'active',
          'limit': 1,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final campaigns = data['data'] as List;
          if (campaigns.isNotEmpty) {
            AppLogger.success('AnalyticsApiService: Active campaign fetched successfully');
            return ActiveCampaign.fromJson(campaigns.first as Map<String, dynamic>);
          }
        }
      }
      
      return null;
    } catch (e) {
      AppLogger.warning('AnalyticsApiService: Active campaign not available', data: e);
      return null;
    }
  }

  /// Get top customers
  Future<List<TopCustomer>> getTopCustomers() async {
    AppLogger.step(1, 'AnalyticsApiService: Fetching top customers');
    
    try {
      final response = await _apiService.get(
        ApiConstants.transactionAnalytics,
        service: 'cashback',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final analyticsData = data['data'] as Map<String, dynamic>;
          
          // Check if top customers data exists
          if (analyticsData['topCustomers'] != null || analyticsData['top_customers'] != null) {
            final topCustomersData = analyticsData['topCustomers'] ?? analyticsData['top_customers'];
            if (topCustomersData is List && topCustomersData.isNotEmpty) {
              AppLogger.success('AnalyticsApiService: Top customers fetched successfully', data: {
                'count': topCustomersData.length,
              });
              
              return topCustomersData
                  .map((customer) => TopCustomer.fromJson(customer as Map<String, dynamic>))
                  .toList();
            }
          }
        }
      }
      
      AppLogger.info('AnalyticsApiService: No top customers data, using fallback');
      return _getFallbackTopCustomers();
    } catch (e) {
      AppLogger.warning('AnalyticsApiService: Failed to fetch top customers, using fallback', data: e);
      return _getFallbackTopCustomers();
    }
  }

  /// Get fallback top customers (hardcoded)
  List<TopCustomer> _getFallbackTopCustomers() {
    return [
      TopCustomer(
        id: '1',
        name: 'Tokyo',
        initial: 'T',
        totalSpent: 5420.0,
        transactionCount: 24,
      ),
      TopCustomer(
        id: '2',
        name: 'Walt',
        initial: 'W',
        totalSpent: 4890.0,
        transactionCount: 18,
      ),
      TopCustomer(
        id: '3',
        name: 'Mike',
        initial: 'M',
        totalSpent: 3650.0,
        transactionCount: 15,
      ),
      TopCustomer(
        id: '4',
        name: 'Oldiey',
        initial: 'O',
        totalSpent: 2980.0,
        transactionCount: 12,
      ),
    ];
  }

  /// Handle Dio errors
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      if (statusCode == 401) {
        return Exception('Unauthorized: Please log in again');
      } else if (statusCode == 404) {
        return Exception('Data not found');
      } else if (data != null && data['message'] != null) {
        return Exception(data['message']);
      }
    }

    if (error.type == DioExceptionType.connectionTimeout) {
      return Exception('Connection timeout');
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return Exception('Server response timeout');
    } else if (error.type == DioExceptionType.connectionError) {
      return Exception('No internet connection');
    }

    return Exception('Server error: ${error.response?.statusCode ?? 'Unknown'}');
  }

  /// Helper methods to safely parse backend data
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
}
