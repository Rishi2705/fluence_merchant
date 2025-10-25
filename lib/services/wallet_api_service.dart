import 'package:dio/dio.dart';
import '../models/wallet_model.dart';
import '../core/constants/api_constants.dart';
import 'api_service_new.dart';

class WalletApiService {
  final ApiService _apiService;

  WalletApiService(this._apiService);

  /// Get wallet balance
  Future<WalletBalance> getBalance() async {
    try {
      final response = await _apiService.get(
        ApiConstants.walletBalance,
        service: 'wallet',
      );

      if (response.statusCode == 200) {
        return WalletBalance.fromJson(response.data['data']);
      } else {
        throw Exception('Failed to fetch balance');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get wallet transactions
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.walletTransactions,
        service: 'wallet',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null) 'type': type,
          if (status != null) 'status': status,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['transactions'] as List;
        return data
            .map((json) => WalletTransaction.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch transactions');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get cashback transactions
  Future<List<CashbackTransaction>> getCashbackTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        ApiConstants.transactions,
        service: 'cashback',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data']['transactions'] as List;
        return data
            .map((json) => CashbackTransaction.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch cashback transactions');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Transfer funds
  Future<WalletTransaction> transfer({
    required String recipientId,
    required double amount,
    String? description,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.walletTransfer,
        service: 'wallet',
        data: {
          'recipientId': recipientId,
          'amount': amount,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WalletTransaction.fromJson(response.data['data']);
      } else {
        throw Exception('Transfer failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Withdraw funds
  Future<WalletTransaction> withdraw({
    required double amount,
    required String bankAccountId,
    String? description,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.walletWithdraw,
        service: 'wallet',
        data: {
          'amount': amount,
          'bankAccountId': bankAccountId,
          if (description != null) 'description': description,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return WalletTransaction.fromJson(response.data['data']);
      } else {
        throw Exception('Withdrawal failed');
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Check balance sufficiency
  Future<Map<String, dynamic>> checkBalance(double amount) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.walletBalance}/check-balance',
        service: 'wallet',
        data: {'amount': amount},
      );

      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Balance check failed');
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
      return 'Connection timeout';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout';
    } else {
      return 'Network error: ${error.message}';
    }
  }
}
