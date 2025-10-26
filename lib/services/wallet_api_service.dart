import 'package:dio/dio.dart';
import '../models/wallet_model.dart';
import '../core/constants/api_constants.dart';
import '../utils/logger.dart';
import 'api_service_new.dart';

class WalletApiService {
  final ApiService _apiService;

  WalletApiService(this._apiService);

  /// Get wallet balance
  Future<WalletBalance> getBalance() async {
    AppLogger.step(1, 'WalletApiService: Fetching wallet balance');
    AppLogger.api('Balance request', data: {
      'endpoint': ApiConstants.walletBalance,
      'baseUrl': ApiConstants.walletBaseUrl,
      'fullUrl': '${ApiConstants.walletBaseUrl}${ApiConstants.walletBalance}',
    });

    try {
      final response = await _apiService.get(
        ApiConstants.walletBalance,
        service: 'wallet',
      );

      AppLogger.api('Balance response', data: {
        'statusCode': response.statusCode,
        'hasData': response.data != null,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          AppLogger.success('WalletApiService: Balance fetched successfully', data: {
            'availableBalance': data['data']['availableBalance'],
            'pendingBalance': data['data']['pendingBalance'],
          });
          return WalletBalance.fromJson(data['data']);
        } else {
          AppLogger.error('WalletApiService: Invalid balance response format', data: data);
          throw Exception(data['message'] ?? 'Failed to fetch balance');
        }
      } else {
        AppLogger.error('WalletApiService: Balance fetch failed', data: {
          'statusCode': response.statusCode,
          'response': response.data,
        });
        throw Exception('Failed to fetch balance');
      }
    } on DioException catch (e) {
      AppLogger.error('WalletApiService: DioException fetching balance', error: e, data: {
        'type': e.type.toString(),
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      });
      throw _handleError(e);
    }
  }

  /// Get wallet transactions (points transactions)
  Future<List<WalletTransaction>> getTransactions({
    int limit = 20,
    int offset = 0,
    String? type,
    String? status,
  }) async {
    AppLogger.step(1, 'WalletApiService: Fetching transactions');
    AppLogger.api('Transactions request', data: {
      'endpoint': ApiConstants.pointsTransactions,
      'limit': limit,
      'offset': offset,
      'type': type,
      'status': status,
    });

    try {
      final response = await _apiService.get(
        ApiConstants.pointsTransactions,
        service: 'wallet',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (type != null) 'type': type,
          if (status != null) 'status': status,
        },
      );

      AppLogger.api('Transactions response', data: {
        'statusCode': response.statusCode,
        'hasData': response.data != null,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          // Backend returns array directly in 'data', not nested in 'transactions'
          final dynamic transactionsData = data['data'];
          
          // Handle both array directly or nested in 'transactions' key
          final List<dynamic> transactions = transactionsData is List 
              ? transactionsData 
              : (transactionsData['transactions'] as List? ?? []);
          
          AppLogger.success('WalletApiService: Transactions fetched successfully', data: {
            'count': transactions.length,
          });
          
          return transactions
              .map((json) => WalletTransaction.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          AppLogger.error('WalletApiService: Invalid transactions response format', data: data);
          throw Exception(data['message'] ?? 'Failed to fetch transactions');
        }
      } else {
        AppLogger.error('WalletApiService: Transactions fetch failed', data: {
          'statusCode': response.statusCode,
          'response': response.data,
        });
        throw Exception('Failed to fetch transactions');
      }
    } on DioException catch (e) {
      AppLogger.error('WalletApiService: DioException fetching transactions', error: e, data: {
        'type': e.type.toString(),
        'statusCode': e.response?.statusCode,
        'responseData': e.response?.data,
      });
      throw _handleError(e);
    }
  }

  /// Get cashback transactions
  Future<List<CashbackTransaction>> getCashbackTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.transactions,
        service: 'cashback',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> transactions = data['data']['transactions'] as List;
          return transactions
              .map((json) => CashbackTransaction.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch cashback transactions');
        }
      } else {
        throw Exception('Failed to fetch cashback transactions');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Award points to user (earn points)
  Future<WalletTransaction> awardPoints({
    required double amount,
    required String transactionType,
    required String description,
    String? referenceId,
    bool socialPostRequired = false,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.pointsEarn,
        service: 'wallet',
        data: {
          'points': amount.toInt(), // Backend expects 'points' not 'amount'
          'source': transactionType, // Backend expects 'source' not 'transactionType'
          'description': description,
          if (referenceId != null) 'referenceId': referenceId,
          'socialPostRequired': socialPostRequired,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return WalletTransaction.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to award points');
        }
      } else {
        throw Exception('Award points failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Redeem points (using negative earn for now since no redeem endpoint exists)
  Future<WalletTransaction> redeemPoints({
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    try {
      // Use earn endpoint with negative points for redemption
      final response = await _apiService.post(
        ApiConstants.pointsEarn,
        service: 'wallet',
        data: {
          'points': -amount.toInt(), // Negative points for redemption
          'source': 'redemption',
          'description': description,
          if (referenceId != null) 'referenceId': referenceId,
          'socialPostRequired': false,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return WalletTransaction.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to redeem points');
        }
      } else {
        throw Exception('Redeem points failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update social post status for a transaction
  Future<Map<String, dynamic>> submitSocialPost({
    required String transactionId,
    required String socialPostUrl,
  }) async {
    try {
      final response = await _apiService.put(
        '/api/points/transactions/$transactionId/social-post',
        service: 'wallet',
        data: {
          'socialPostUrl': socialPostUrl,
          'socialPostMade': true,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to submit social post');
        }
      } else {
        throw Exception('Social post submission failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get points statistics
  Future<Map<String, dynamic>> getPointsStatistics() async {
    try {
      final response = await _apiService.get(
        ApiConstants.pointsStats,
        service: 'wallet',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch points statistics');
        }
      } else {
        throw Exception('Failed to fetch points statistics');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get balance history for charts
  Future<List<BalanceHistoryPoint>> getBalanceHistory({int days = 30}) async {
    AppLogger.step(1, 'WalletApiService: Fetching balance history');
    AppLogger.api('Balance history request', data: {
      'endpoint': ApiConstants.walletBalanceHistory,
      'days': days,
    });

    try {
      final response = await _apiService.get(
        ApiConstants.walletBalanceHistory,
        service: 'wallet',
        queryParameters: {
          'days': days,
        },
      );

      AppLogger.api('Balance history response', data: {
        'statusCode': response.statusCode,
        'hasData': response.data != null,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final historyData = data['data'] as List;
          AppLogger.success('WalletApiService: Balance history fetched successfully', data: {
            'count': historyData.length,
          });
          return historyData
              .map((item) => BalanceHistoryPoint.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      
      AppLogger.warning('WalletApiService: No balance history data');
      return [];
    } on DioException catch (e) {
      AppLogger.error('WalletApiService: DioException fetching balance history', error: e, data: {
        'type': e.type.toString(),
        'statusCode': e.response?.statusCode,
      });
      return [];
    }
  }

  /// Get lifetime wallet statistics
  Future<LifetimeWalletStats> getLifetimeStats() async {
    AppLogger.step(1, 'WalletApiService: Fetching lifetime stats');
    
    try {
      final results = await Future.wait([
        _apiService.get(ApiConstants.pointsStatsTotalEarned, service: 'wallet'),
        _apiService.get(ApiConstants.pointsStatsTotalRedeemed, service: 'wallet'),
        _apiService.get(ApiConstants.pointsStats, service: 'wallet'),
      ]);

      final earnedResponse = results[0];
      final redeemedResponse = results[1];
      final statsResponse = results[2];

      double totalEarned = 0.0;
      double totalRedeemed = 0.0;
      int totalTransactions = 0;
      double averageTransaction = 0.0;

      if (earnedResponse.statusCode == 200 && earnedResponse.data['success'] == true) {
        totalEarned = (earnedResponse.data['data']['total'] ?? 0.0).toDouble();
      }

      if (redeemedResponse.statusCode == 200 && redeemedResponse.data['success'] == true) {
        totalRedeemed = (redeemedResponse.data['data']['total'] ?? 0.0).toDouble();
      }

      if (statsResponse.statusCode == 200 && statsResponse.data['success'] == true) {
        final statsData = statsResponse.data['data'];
        totalTransactions = statsData['totalTransactions'] ?? statsData['total_transactions'] ?? 0;
        averageTransaction = (statsData['averageTransaction'] ?? statsData['average_transaction'] ?? 0.0).toDouble();
      }

      final currentBalance = await getBalance();

      final lifetimeStats = LifetimeWalletStats(
        totalEarned: totalEarned,
        totalRedeemed: totalRedeemed,
        totalExpired: 0.0, // TODO: Get from backend if available
        currentBalance: currentBalance.availableBalance,
        totalTransactions: totalTransactions,
        averageTransaction: averageTransaction,
      );

      AppLogger.success('WalletApiService: Lifetime stats calculated', data: {
        'totalEarned': totalEarned,
        'totalRedeemed': totalRedeemed,
        'totalTransactions': totalTransactions,
      });

      return lifetimeStats;
    } catch (e) {
      AppLogger.error('WalletApiService: Failed to fetch lifetime stats', error: e);
      return LifetimeWalletStats(
        totalEarned: 0.0,
        totalRedeemed: 0.0,
        totalExpired: 0.0,
        currentBalance: 0.0,
        totalTransactions: 0,
        averageTransaction: 0.0,
      );
    }
  }

  /// Get transaction details by ID
  Future<TransactionDetail?> getTransactionDetails(String transactionId) async {
    AppLogger.step(1, 'WalletApiService: Fetching transaction details');
    AppLogger.api('Transaction details request', data: {
      'transactionId': transactionId,
    });

    try {
      final response = await _apiService.get(
        '${ApiConstants.pointsTransactionById}/$transactionId',
        service: 'wallet',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          AppLogger.success('WalletApiService: Transaction details fetched successfully');
          return TransactionDetail.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      
      return null;
    } on DioException catch (e) {
      AppLogger.error('WalletApiService: Failed to fetch transaction details', error: e);
      return null;
    }
  }

  /// Get daily transaction summary
  Future<DailyTransactionSummary?> getDailySummary() async {
    AppLogger.step(1, 'WalletApiService: Fetching daily summary');
    
    // Calculate date range (last 30 days)
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 30));
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];
    
    AppLogger.api('Daily summary request', data: {
      'startDate': startDateStr,
      'endDate': endDateStr,
    });
    
    try {
      final response = await _apiService.get(
        '${ApiConstants.pointsDailySummary}?startDate=$startDateStr&endDate=$endDateStr',
        service: 'wallet',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          AppLogger.success('WalletApiService: Daily summary fetched successfully');
          return DailyTransactionSummary.fromJson(data['data'] as Map<String, dynamic>);
        }
      }
      
      return null;
    } on DioException catch (e) {
      AppLogger.error('WalletApiService: Failed to fetch daily summary', error: e);
      return null;
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
      return 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout';
    } else {
      return 'Network error: ${error.message}';
    }
  }
}
