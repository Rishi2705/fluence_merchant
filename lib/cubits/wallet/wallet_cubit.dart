import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/wallet_model.dart';
import '../../repositories/wallet_repository.dart';
import '../../utils/logger.dart';
import 'wallet_state.dart';

/// Cubit that manages wallet-related state and operations
class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _walletRepository;

  WalletCubit(this._walletRepository) : super(const WalletInitial());

  /// Load wallet balance
  Future<void> loadBalance() async {
    AppLogger.step(1, 'WalletCubit: Loading wallet balance');
    emit(const WalletLoading());

    try {
      final balance = await _walletRepository.getBalance();
      AppLogger.success('WalletCubit: Balance loaded successfully', data: {
        'totalBalance': balance.totalBalance,
        'availableBalance': balance.availableBalance,
        'userId': balance.userId,
      });
      emit(WalletBalanceLoaded(balance: balance));
    } catch (e, stackTrace) {
      AppLogger.error('WalletCubit: Failed to load balance', error: e, stackTrace: stackTrace);
      emit(WalletError(message: e.toString()));
    }
  }

  /// Load wallet transactions
  Future<void> loadTransactions({
    int limit = 20,
    int offset = 0,
    String? type,
    String? status,
  }) async {
    AppLogger.step(1, 'WalletCubit: Loading wallet transactions');
    
    // Don't show loading if we already have data (pagination)
    if (state is! WalletTransactionsLoaded || offset == 0) {
      emit(const WalletLoading());
    }

    try {
      final transactions = await _walletRepository.getTransactions(
        limit: limit,
        offset: offset,
        type: type,
        status: status,
      );
      
      AppLogger.success('WalletCubit: Transactions loaded successfully', data: {
        'count': transactions.length,
        'offset': offset,
        'limit': limit,
      });

      // If pagination, append to existing transactions
      if (state is WalletTransactionsLoaded && offset > 0) {
        final currentState = state as WalletTransactionsLoaded;
        final allTransactions = [...currentState.transactions, ...transactions];
        emit(WalletTransactionsLoaded(
          transactions: allTransactions,
          hasMore: transactions.length == limit,
          currentPage: (offset / limit).floor() + 1,
        ));
      } else {
        emit(WalletTransactionsLoaded(
          transactions: transactions,
          hasMore: transactions.length == limit,
          currentPage: 1,
        ));
      }
    } catch (e, stackTrace) {
      AppLogger.error('WalletCubit: Failed to load transactions', error: e, stackTrace: stackTrace);
      emit(WalletError(message: e.toString()));
    }
  }

  /// Load cashback transactions
  Future<void> loadCashbackTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    AppLogger.step(1, 'WalletCubit: Loading cashback transactions');
    emit(const WalletLoading());

    try {
      final transactions = await _walletRepository.getCashbackTransactions(
        limit: limit,
        offset: offset,
      );
      
      AppLogger.success('WalletCubit: Cashback transactions loaded successfully', data: {
        'count': transactions.length,
        'offset': offset,
        'limit': limit,
      });
      
      emit(WalletCashbackTransactionsLoaded(transactions: transactions));
    } catch (e, stackTrace) {
      AppLogger.error('WalletCubit: Failed to load cashback transactions', error: e, stackTrace: stackTrace);
      emit(WalletError(message: e.toString()));
    }
  }

  /// Award points to user
  Future<void> awardPoints({
    required double amount,
    required String transactionType,
    required String description,
    String? referenceId,
    bool socialPostRequired = false,
  }) async {
    AppLogger.step(1, 'WalletCubit: Awarding points');
    AppLogger.api('Award points request', data: {
      'amount': amount,
      'transactionType': transactionType,
      'description': description,
      'referenceId': referenceId,
      'socialPostRequired': socialPostRequired,
    });
    
    emit(const WalletLoading());

    try {
      final transaction = await _walletRepository.awardPoints(
        amount: amount,
        transactionType: transactionType,
        description: description,
        referenceId: referenceId,
        socialPostRequired: socialPostRequired,
      );
      
      AppLogger.success('WalletCubit: Points awarded successfully', data: {
        'transactionId': transaction.id,
        'amount': transaction.amount,
        'status': transaction.status,
      });
      
      emit(WalletPointsAwarded(transaction: transaction));
      
      // Reload balance after successful award
      await loadBalance();
    } catch (e, stackTrace) {
      AppLogger.error('WalletCubit: Points award failed', error: e, stackTrace: stackTrace);
      emit(WalletError(message: e.toString()));
    }
  }

  /// Redeem points
  Future<void> redeemPoints({
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    AppLogger.step(1, 'WalletCubit: Redeeming points');
    AppLogger.api('Redeem points request', data: {
      'amount': amount,
      'description': description,
      'referenceId': referenceId,
    });
    
    emit(const WalletLoading());

    try {
      final transaction = await _walletRepository.redeemPoints(
        amount: amount,
        description: description,
        referenceId: referenceId,
      );
      
      AppLogger.success('WalletCubit: Points redeemed successfully', data: {
        'transactionId': transaction.id,
        'amount': transaction.amount,
        'status': transaction.status,
      });
      
      emit(WalletPointsRedeemed(transaction: transaction));
      
      // Reload balance after successful redemption
      await loadBalance();
    } catch (e, stackTrace) {
      AppLogger.error('WalletCubit: Points redemption failed', error: e, stackTrace: stackTrace);
      emit(WalletError(message: e.toString()));
    }
  }

  /// Submit social media post for verification
  Future<void> submitSocialPost({
    required String transactionId,
    required String socialPostUrl,
  }) async {
    AppLogger.step(1, 'WalletCubit: Submitting social post');
    AppLogger.api('Social post submission', data: {
      'transactionId': transactionId,
      'socialPostUrl': socialPostUrl,
    });
    
    emit(const WalletLoading());

    try {
      final result = await _walletRepository.submitSocialPost(
        transactionId: transactionId,
        socialPostUrl: socialPostUrl,
      );
      
      AppLogger.success('WalletCubit: Social post submitted successfully', data: result);
      
      emit(WalletSocialPostSubmitted(result: result));
    } catch (e, stackTrace) {
      AppLogger.error('WalletCubit: Social post submission failed', error: e, stackTrace: stackTrace);
      emit(WalletError(message: e.toString()));
    }
  }

  /// Load points statistics
  Future<void> loadPointsStatistics() async {
    AppLogger.step(1, 'WalletCubit: Loading points statistics');
    emit(const WalletLoading());

    try {
      final statistics = await _walletRepository.getPointsStatistics();
      
      AppLogger.success('WalletCubit: Points statistics loaded successfully', data: statistics);
      
      emit(WalletStatisticsLoaded(statistics: statistics));
    } catch (e, stackTrace) {
      AppLogger.error('WalletCubit: Failed to load points statistics', error: e, stackTrace: stackTrace);
      emit(WalletError(message: e.toString()));
    }
  }

  /// Load complete wallet data (balance + transactions + analytics)
  Future<void> loadWalletData() async {
    AppLogger.step(1, 'WalletCubit: Loading complete wallet data with analytics');
    emit(const WalletLoading());

    try {
      // Load core data first (balance and transactions)
      final results = await Future.wait([
        _walletRepository.getBalance(),
        _walletRepository.getTransactions(limit: 10, offset: 0),
      ]);

      final balance = results[0] as WalletBalance;
      final transactions = results[1] as List<WalletTransaction>;

      // Load analytics data (non-blocking - don't fail if unavailable)
      List<BalanceHistoryPoint>? balanceHistory;
      LifetimeWalletStats? lifetimeStats;
      DailyTransactionSummary? dailySummary;

      try {
        final analyticsResults = await Future.wait([
          _walletRepository.getBalanceHistory(days: 30),
          _walletRepository.getLifetimeStats(),
          _walletRepository.getDailySummary(),
        ]);
        
        balanceHistory = analyticsResults[0] as List<BalanceHistoryPoint>;
        lifetimeStats = analyticsResults[1] as LifetimeWalletStats;
        dailySummary = analyticsResults[2] as DailyTransactionSummary?;
        
        AppLogger.success('WalletCubit: Analytics data loaded', data: {
          'historyPoints': balanceHistory.length,
          'lifetimeEarned': lifetimeStats.totalEarned,
          'hasDailySummary': dailySummary != null,
        });
      } catch (e) {
        AppLogger.warning('WalletCubit: Analytics data failed, using basic data only', data: e);
      }

      AppLogger.success('WalletCubit: Complete wallet data loaded', data: {
        'totalBalance': balance.totalBalance,
        'availableBalance': balance.availableBalance,
        'transactionCount': transactions.length,
        'hasHistory': balanceHistory != null,
        'hasLifetimeStats': lifetimeStats != null,
        'hasDailySummary': dailySummary != null,
      });

      emit(WalletDataLoaded(
        balance: balance,
        recentTransactions: transactions,
        balanceHistory: balanceHistory,
        lifetimeStats: lifetimeStats,
        dailySummary: dailySummary,
      ));
    } catch (e, stackTrace) {
      AppLogger.error('WalletCubit: Failed to load wallet data', error: e, stackTrace: stackTrace);
      emit(WalletError(message: e.toString()));
    }
  }

  /// Refresh wallet data
  Future<void> refresh() async {
    AppLogger.step(1, 'WalletCubit: Refreshing wallet data');
    await loadWalletData();
  }
}