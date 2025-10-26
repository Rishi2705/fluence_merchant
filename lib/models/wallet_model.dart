class WalletBalance {
  final String userId;
  final double availableBalance;
  final double pendingBalance;
  final double totalEarned;
  final double totalRedeemed;
  final double totalExpired;
  final DateTime lastUpdated;

  WalletBalance({
    required this.userId,
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.totalExpired,
    required this.lastUpdated,
  });

  // Total balance is available + pending
  double get totalBalance => availableBalance + pendingBalance;

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numeric values
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return WalletBalance(
      userId: json['userId'] as String,
      availableBalance: _parseDouble(json['availableBalance']),
      pendingBalance: _parseDouble(json['pendingBalance']),
      totalEarned: _parseDouble(json['totalEarned']),
      totalRedeemed: _parseDouble(json['totalRedeemed']),
      totalExpired: _parseDouble(json['totalExpired']),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'availableBalance': availableBalance,
      'pendingBalance': pendingBalance,
      'totalEarned': totalEarned,
      'totalRedeemed': totalRedeemed,
      'totalExpired': totalExpired,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class WalletTransaction {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final String status;
  final String? description;
  final String? reference;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  WalletTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    this.reference,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      userId: json['user_id'] as String,  // Backend uses snake_case
      amount: (json['amount'] as num).toDouble(),
      type: json['transaction_type'] as String,  // Backend field name
      status: json['status'] as String,
      description: json['description'] as String?,
      reference: json['reference_id'] as String?,  // Backend field name
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),  // Backend uses snake_case
      completedAt: json['processed_at'] != null  // Backend field name
          ? DateTime.parse(json['processed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'status': status,
      'description': description,
      'reference': reference,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

class CashbackTransaction {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final String status;
  final String? description;
  final String? merchantId;
  final String? merchantName;
  final String? campaignId;
  final double? cashbackAmount;
  final double? cashbackPercentage;
  final DateTime createdAt;

  CashbackTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.status,
    this.description,
    this.merchantId,
    this.merchantName,
    this.campaignId,
    this.cashbackAmount,
    this.cashbackPercentage,
    required this.createdAt,
  });

  factory CashbackTransaction.fromJson(Map<String, dynamic> json) {
    return CashbackTransaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      merchantId: json['merchantId'] as String?,
      merchantName: json['merchantName'] as String?,
      campaignId: json['campaignId'] as String?,
      cashbackAmount: json['cashbackAmount'] != null
          ? (json['cashbackAmount'] as num).toDouble()
          : null,
      cashbackPercentage: json['cashbackPercentage'] != null
          ? (json['cashbackPercentage'] as num).toDouble()
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'status': status,
      'description': description,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'campaignId': campaignId,
      'cashbackAmount': cashbackAmount,
      'cashbackPercentage': cashbackPercentage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Balance history point for charts
class BalanceHistoryPoint {
  final DateTime date;
  final double balance;
  final double earned;
  final double redeemed;

  BalanceHistoryPoint({
    required this.date,
    required this.balance,
    required this.earned,
    required this.redeemed,
  });

  factory BalanceHistoryPoint.fromJson(Map<String, dynamic> json) {
    return BalanceHistoryPoint(
      date: DateTime.parse(json['date'] ?? json['timestamp'] ?? DateTime.now().toIso8601String()),
      balance: (json['balance'] ?? 0.0).toDouble(),
      earned: (json['earned'] ?? 0.0).toDouble(),
      redeemed: (json['redeemed'] ?? 0.0).toDouble(),
    );
  }
}

/// Lifetime wallet statistics
class LifetimeWalletStats {
  final double totalEarned;
  final double totalRedeemed;
  final double totalExpired;
  final double currentBalance;
  final int totalTransactions;
  final double averageTransaction;

  LifetimeWalletStats({
    required this.totalEarned,
    required this.totalRedeemed,
    required this.totalExpired,
    required this.currentBalance,
    required this.totalTransactions,
    required this.averageTransaction,
  });

  factory LifetimeWalletStats.fromJson(Map<String, dynamic> json) {
    return LifetimeWalletStats(
      totalEarned: (json['totalEarned'] ?? json['total_earned'] ?? 0.0).toDouble(),
      totalRedeemed: (json['totalRedeemed'] ?? json['total_redeemed'] ?? 0.0).toDouble(),
      totalExpired: (json['totalExpired'] ?? json['total_expired'] ?? 0.0).toDouble(),
      currentBalance: (json['currentBalance'] ?? json['current_balance'] ?? 0.0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? json['total_transactions'] ?? 0,
      averageTransaction: (json['averageTransaction'] ?? json['average_transaction'] ?? 0.0).toDouble(),
    );
  }

  double get netEarnings => totalEarned - totalRedeemed - totalExpired;
  double get redemptionRate => totalEarned > 0 ? (totalRedeemed / totalEarned) * 100 : 0.0;
  double get savingsRate => totalEarned > 0 ? (currentBalance / totalEarned) * 100 : 0.0;
}

/// Transaction detail model with enhanced information
class TransactionDetail {
  final String id;
  final String userId;
  final String type;
  final double amount;
  final String description;
  final String? referenceId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  final String? campaignId;
  final String? campaignName;
  final double? cashbackPercentage;

  TransactionDetail({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    this.referenceId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
    this.campaignId,
    this.campaignName,
    this.cashbackPercentage,
  });

  factory TransactionDetail.fromJson(Map<String, dynamic> json) {
    return TransactionDetail(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      type: json['type'] ?? 'unknown',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      referenceId: json['referenceId'] ?? json['reference_id'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(
        json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null || json['updated_at'] != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      campaignId: json['campaignId'] ?? json['campaign_id'],
      campaignName: json['campaignName'] ?? json['campaign_name'],
      cashbackPercentage: json['cashbackPercentage'] != null
          ? (json['cashbackPercentage'] as num).toDouble()
          : null,
    );
  }
}

/// Daily transaction summary
class DailyTransactionSummary {
  final DateTime date;
  final double totalEarned;
  final double totalRedeemed;
  final int transactionCount;
  final double netChange;

  DailyTransactionSummary({
    required this.date,
    required this.totalEarned,
    required this.totalRedeemed,
    required this.transactionCount,
    required this.netChange,
  });

  factory DailyTransactionSummary.fromJson(Map<String, dynamic> json) {
    return DailyTransactionSummary(
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      totalEarned: (json['totalEarned'] ?? json['total_earned'] ?? 0.0).toDouble(),
      totalRedeemed: (json['totalRedeemed'] ?? json['total_redeemed'] ?? 0.0).toDouble(),
      transactionCount: json['transactionCount'] ?? json['transaction_count'] ?? 0,
      netChange: (json['netChange'] ?? json['net_change'] ?? 0.0).toDouble(),
    );
  }
}
