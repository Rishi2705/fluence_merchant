class WalletBalance {
  final String userId;
  final double balance;
  final String currency;
  final DateTime lastUpdated;

  WalletBalance({
    required this.userId,
    required this.balance,
    required this.currency,
    required this.lastUpdated,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      userId: json['userId'] as String,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'AED',
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'balance': balance,
      'currency': currency,
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
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
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
