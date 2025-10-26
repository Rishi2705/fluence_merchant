/// Analytics and dashboard data models

/// Dashboard statistics model
class DashboardStats {
  final int activeUsers;
  final int todayTransactions;
  final double trendingPercentage;
  final double totalRevenue;
  final double todayRevenue;
  final int totalPosts;
  final int totalLikes;

  DashboardStats({
    required this.activeUsers,
    required this.todayTransactions,
    required this.trendingPercentage,
    required this.totalRevenue,
    required this.todayRevenue,
    this.totalPosts = 0,
    this.totalLikes = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      activeUsers: _parseToInt(json['activeUsers'] ?? json['active_users'] ?? 0),
      todayTransactions: _parseToInt(json['todayTransactions'] ?? json['today_transactions'] ?? 0),
      trendingPercentage: _parseToDouble(json['trendingPercentage'] ?? json['trending_percentage'] ?? 0.0),
      totalRevenue: _parseToDouble(json['totalRevenue'] ?? json['total_revenue'] ?? 0.0),
      todayRevenue: _parseToDouble(json['todayRevenue'] ?? json['today_revenue'] ?? 0.0),
      totalPosts: _parseToInt(json['totalPosts'] ?? json['total_posts'] ?? 0),
      totalLikes: _parseToInt(json['totalLikes'] ?? json['total_likes'] ?? 0),
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

  Map<String, dynamic> toJson() {
    return {
      'activeUsers': activeUsers,
      'todayTransactions': todayTransactions,
      'trendingPercentage': trendingPercentage,
      'totalRevenue': totalRevenue,
      'todayRevenue': todayRevenue,
      'totalPosts': totalPosts,
      'totalLikes': totalLikes,
    };
  }
}

/// Transaction statistics model
class TransactionStats {
  final int totalTransactions;
  final int todayTransactions;
  final double totalAmount;
  final double todayAmount;
  final double averageTransactionValue;
  final List<DailyTransactionSummary> dailySummary;

  TransactionStats({
    required this.totalTransactions,
    required this.todayTransactions,
    required this.totalAmount,
    required this.todayAmount,
    required this.averageTransactionValue,
    required this.dailySummary,
  });

  factory TransactionStats.fromJson(Map<String, dynamic> json) {
    final dailySummaryData = json['dailySummary'] ?? json['daily_summary'] ?? [];
    
    return TransactionStats(
      totalTransactions: _parseToInt(json['totalTransactions'] ?? json['total_transactions'] ?? json['total'] ?? 0),
      todayTransactions: _parseToInt(json['todayTransactions'] ?? json['today_transactions'] ?? json['completed'] ?? 0),
      totalAmount: _parseToDouble(json['totalAmount'] ?? json['total_amount'] ?? json['total_volume'] ?? 0.0),
      todayAmount: _parseToDouble(json['todayAmount'] ?? json['today_amount'] ?? 0.0),
      averageTransactionValue: _parseToDouble(json['averageTransactionValue'] ?? json['average_transaction_value'] ?? 0.0),
      dailySummary: (dailySummaryData as List)
          .map((item) => DailyTransactionSummary.fromJson(item as Map<String, dynamic>))
          .toList(),
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

  Map<String, dynamic> toJson() {
    return {
      'totalTransactions': totalTransactions,
      'todayTransactions': todayTransactions,
      'totalAmount': totalAmount,
      'todayAmount': todayAmount,
      'averageTransactionValue': averageTransactionValue,
      'dailySummary': dailySummary.map((item) => item.toJson()).toList(),
    };
  }
}

/// Daily transaction summary
class DailyTransactionSummary {
  final DateTime date;
  final int transactionCount;
  final double totalAmount;

  DailyTransactionSummary({
    required this.date,
    required this.transactionCount,
    required this.totalAmount,
  });

  factory DailyTransactionSummary.fromJson(Map<String, dynamic> json) {
    return DailyTransactionSummary(
      date: DateTime.parse(json['date'] as String),
      transactionCount: _parseToInt(json['transactionCount'] ?? json['transaction_count'] ?? 0),
      totalAmount: _parseToDouble(json['totalAmount'] ?? json['total_amount'] ?? 0.0),
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

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'transactionCount': transactionCount,
      'totalAmount': totalAmount,
    };
  }
}

/// Balance summary model
class BalanceSummary {
  final double totalBalance;
  final double availableBalance;
  final double pendingBalance;
  final double totalEarned;
  final double totalRedeemed;

  BalanceSummary({
    required this.totalBalance,
    required this.availableBalance,
    required this.pendingBalance,
    required this.totalEarned,
    required this.totalRedeemed,
  });

  factory BalanceSummary.fromJson(Map<String, dynamic> json) {
    return BalanceSummary(
      totalBalance: _parseToDouble(json['totalBalance'] ?? json['total_balance'] ?? 0.0),
      availableBalance: _parseToDouble(json['availableBalance'] ?? json['available_balance'] ?? 0.0),
      pendingBalance: _parseToDouble(json['pendingBalance'] ?? json['pending_balance'] ?? 0.0),
      totalEarned: _parseToDouble(json['totalEarned'] ?? json['total_earned'] ?? 0.0),
      totalRedeemed: _parseToDouble(json['totalRedeemed'] ?? json['total_redeemed'] ?? 0.0),
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'availableBalance': availableBalance,
      'pendingBalance': pendingBalance,
      'totalEarned': totalEarned,
      'totalRedeemed': totalRedeemed,
    };
  }
}

/// Recent activity item
class RecentActivity {
  final String id;
  final String userName;
  final String userInitial;
  final String action;
  final String timeAgo;
  final double amount;
  final String type;
  final DateTime timestamp;

  RecentActivity({
    required this.id,
    required this.userName,
    required this.userInitial,
    required this.action,
    required this.timeAgo,
    required this.amount,
    required this.type,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    final userName = json['userName'] ?? json['user_name'] ?? 'Unknown User';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    
    return RecentActivity(
      id: json['id'] ?? json['transaction_id'] ?? '',
      userName: userName,
      userInitial: userInitial,
      action: json['action'] ?? json['description'] ?? 'made a transaction',
      timeAgo: json['timeAgo'] ?? json['time_ago'] ?? _calculateTimeAgo(json['timestamp'] ?? json['created_at']),
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: json['type'] ?? 'transaction',
      timestamp: DateTime.parse(json['timestamp'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  static String _calculateTimeAgo(String? timestampStr) {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userInitial': userInitial,
      'action': action,
      'timeAgo': timeAgo,
      'amount': amount,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Active campaign model
class ActiveCampaign {
  final String id;
  final String name;
  final String description;
  final double cashbackPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double budgetUsed;
  final double budgetTotal;

  ActiveCampaign({
    required this.id,
    required this.name,
    required this.description,
    required this.cashbackPercentage,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.budgetUsed,
    required this.budgetTotal,
  });

  factory ActiveCampaign.fromJson(Map<String, dynamic> json) {
    // Helper to parse numeric values that might be strings
    double _parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return ActiveCampaign(
      id: json['id'] ?? '',
      name: json['campaign_name'] ?? json['name'] ?? 'Campaign',
      description: json['description'] ?? '',
      cashbackPercentage: _parseDouble(
        json['cashback_percentage'] ?? json['cashbackPercentage'],
        0.0,
      ),
      startDate: DateTime.parse(json['start_date'] ?? json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date'] ?? json['endDate'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'active',
      budgetUsed: _parseDouble(json['budget_used'] ?? json['budgetUsed'], 0.0),
      budgetTotal: _parseDouble(json['budget_total'] ?? json['budgetTotal'], 0.0),
    );
  }

  int get daysLeft {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.inDays.clamp(0, 999);
  }

  double get budgetPercentage {
    if (budgetTotal == 0) return 0.0;
    return (budgetUsed / budgetTotal).clamp(0.0, 1.0);
  }
}

/// Top customer model
class TopCustomer {
  final String id;
  final String name;
  final String initial;
  final double totalSpent;
  final int transactionCount;

  TopCustomer({
    required this.id,
    required this.name,
    required this.initial,
    required this.totalSpent,
    required this.transactionCount,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) {
    final name = json['name'] ?? json['customer_name'] ?? 'Customer';
    return TopCustomer(
      id: json['id'] ?? json['customer_id'] ?? '',
      name: name,
      initial: name.isNotEmpty ? name[0].toUpperCase() : 'C',
      totalSpent: _parseToDouble(json['totalSpent'] ?? json['total_spent'] ?? 0.0),
      transactionCount: _parseToInt(json['transactionCount'] ?? json['transaction_count'] ?? 0),
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
}

/// Complete dashboard data
class DashboardData {
  final DashboardStats stats;
  final TransactionStats transactionStats;
  final BalanceSummary balanceSummary;
  final List<RecentActivity> recentActivities;
  final ActiveCampaign? activeCampaign;
  final List<TopCustomer> topCustomers;

  DashboardData({
    required this.stats,
    required this.transactionStats,
    required this.balanceSummary,
    required this.recentActivities,
    this.activeCampaign,
    this.topCustomers = const [],
  });

  factory DashboardData.empty() {
    return DashboardData(
      stats: DashboardStats(
        activeUsers: 0,
        todayTransactions: 0,
        trendingPercentage: 0.0,
        totalRevenue: 0.0,
        todayRevenue: 0.0,
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
