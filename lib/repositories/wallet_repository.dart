import '../models/wallet_model.dart';
import '../services/wallet_api_service.dart';

class WalletRepository {
  final WalletApiService _walletApiService;

  WalletRepository(this._walletApiService);

  Future<WalletBalance> getBalance() async {
    return await _walletApiService.getBalance();
  }

  Future<List<WalletTransaction>> getTransactions({
    int limit = 20,
    int offset = 0,
    String? type,
    String? status,
  }) async {
    return await _walletApiService.getTransactions(
      limit: limit,
      offset: offset,
      type: type,
      status: status,
    );
  }

  Future<List<CashbackTransaction>> getCashbackTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    return await _walletApiService.getCashbackTransactions(
      limit: limit,
      offset: offset,
    );
  }

  Future<WalletTransaction> awardPoints({
    required double amount,
    required String transactionType,
    required String description,
    String? referenceId,
    bool socialPostRequired = false,
  }) async {
    return await _walletApiService.awardPoints(
      amount: amount,
      transactionType: transactionType,
      description: description,
      referenceId: referenceId,
      socialPostRequired: socialPostRequired,
    );
  }

  Future<WalletTransaction> redeemPoints({
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    return await _walletApiService.redeemPoints(
      amount: amount,
      description: description,
      referenceId: referenceId,
    );
  }

  Future<Map<String, dynamic>> submitSocialPost({
    required String transactionId,
    required String socialPostUrl,
  }) async {
    return await _walletApiService.submitSocialPost(
      transactionId: transactionId,
      socialPostUrl: socialPostUrl,
    );
  }

  Future<Map<String, dynamic>> getPointsStatistics() async {
    return await _walletApiService.getPointsStatistics();
  }

  Future<List<BalanceHistoryPoint>> getBalanceHistory({int days = 30}) async {
    return await _walletApiService.getBalanceHistory(days: days);
  }

  Future<LifetimeWalletStats> getLifetimeStats() async {
    return await _walletApiService.getLifetimeStats();
  }

  Future<TransactionDetail?> getTransactionDetails(String transactionId) async {
    return await _walletApiService.getTransactionDetails(transactionId);
  }

  Future<DailyTransactionSummary?> getDailySummary() async {
    return await _walletApiService.getDailySummary();
  }
}
