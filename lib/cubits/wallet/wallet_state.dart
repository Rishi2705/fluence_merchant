import 'package:equatable/equatable.dart';
import '../../models/wallet_model.dart';

/// Base class for all wallet states
abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

/// Initial state when wallet cubit is first created
class WalletInitial extends WalletState {
  const WalletInitial();
}

/// Loading state for any wallet operation
class WalletLoading extends WalletState {
  const WalletLoading();
}

/// State when wallet balance is successfully loaded
class WalletBalanceLoaded extends WalletState {
  final WalletBalance balance;

  const WalletBalanceLoaded({required this.balance});

  @override
  List<Object?> get props => [balance];
}

/// State when wallet transactions are successfully loaded
class WalletTransactionsLoaded extends WalletState {
  final List<WalletTransaction> transactions;
  final bool hasMore;
  final int currentPage;

  const WalletTransactionsLoaded({
    required this.transactions,
    this.hasMore = false,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [transactions, hasMore, currentPage];
}

/// State when cashback transactions are successfully loaded
class WalletCashbackTransactionsLoaded extends WalletState {
  final List<CashbackTransaction> transactions;

  const WalletCashbackTransactionsLoaded({required this.transactions});

  @override
  List<Object?> get props => [transactions];
}

/// State when complete wallet data (balance + transactions) is loaded
class WalletDataLoaded extends WalletState {
  final WalletBalance balance;
  final List<WalletTransaction> recentTransactions;
  final List<BalanceHistoryPoint>? balanceHistory;
  final LifetimeWalletStats? lifetimeStats;
  final DailyTransactionSummary? dailySummary;

  const WalletDataLoaded({
    required this.balance,
    required this.recentTransactions,
    this.balanceHistory,
    this.lifetimeStats,
    this.dailySummary,
  });

  @override
  List<Object?> get props => [balance, recentTransactions, balanceHistory, lifetimeStats, dailySummary];
}

/// State when points are successfully awarded
class WalletPointsAwarded extends WalletState {
  final WalletTransaction transaction;

  const WalletPointsAwarded({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// State when points are successfully redeemed
class WalletPointsRedeemed extends WalletState {
  final WalletTransaction transaction;

  const WalletPointsRedeemed({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// State when social post is successfully submitted
class WalletSocialPostSubmitted extends WalletState {
  final Map<String, dynamic> result;

  const WalletSocialPostSubmitted({required this.result});

  @override
  List<Object?> get props => [result];
}

/// State when points statistics are loaded
class WalletStatisticsLoaded extends WalletState {
  final Map<String, dynamic> statistics;

  const WalletStatisticsLoaded({required this.statistics});

  @override
  List<Object?> get props => [statistics];
}

/// State when balance check is completed
class WalletBalanceChecked extends WalletState {
  final bool hasSufficientBalance;
  final double requiredAmount;

  const WalletBalanceChecked({
    required this.hasSufficientBalance,
    required this.requiredAmount,
  });

  @override
  List<Object?> get props => [hasSufficientBalance, requiredAmount];
}

/// State when transfer is completed (legacy - keeping for compatibility)
class WalletTransferCompleted extends WalletState {
  final WalletTransaction transaction;

  const WalletTransferCompleted({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// State when withdrawal is completed (legacy - keeping for compatibility)
class WalletWithdrawalCompleted extends WalletState {
  final WalletTransaction transaction;

  const WalletWithdrawalCompleted({required this.transaction});

  @override
  List<Object?> get props => [transaction];
}

/// Error state for any wallet operation failure
class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}