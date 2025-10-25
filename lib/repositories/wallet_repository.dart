import '../models/wallet_model.dart';
import '../services/wallet_api_service.dart';

class WalletRepository {
  final WalletApiService _walletApiService;

  WalletRepository(this._walletApiService);

  Future<WalletBalance> getBalance() async {
    return await _walletApiService.getBalance();
  }

  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
  }) async {
    return await _walletApiService.getTransactions(
      page: page,
      limit: limit,
      type: type,
      status: status,
    );
  }

  Future<List<CashbackTransaction>> getCashbackTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    return await _walletApiService.getCashbackTransactions(
      page: page,
      limit: limit,
    );
  }

  Future<WalletTransaction> transfer({
    required String recipientId,
    required double amount,
    String? description,
  }) async {
    return await _walletApiService.transfer(
      recipientId: recipientId,
      amount: amount,
      description: description,
    );
  }

  Future<WalletTransaction> withdraw({
    required double amount,
    required String bankAccountId,
    String? description,
  }) async {
    return await _walletApiService.withdraw(
      amount: amount,
      bankAccountId: bankAccountId,
      description: description,
    );
  }

  Future<Map<String, dynamic>> checkBalance(double amount) async {
    return await _walletApiService.checkBalance(amount);
  }
}
