class MerchantApplication {
  final String id;
  final String businessName;
  final String businessType;
  final String contactEmail;
  final String contactPhone;
  final BusinessAddress businessAddress;
  final String businessDescription;
  final double? expectedMonthlyVolume;
  final BankingInfo? bankingInfo;
  final String status;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  MerchantApplication({
    required this.id,
    required this.businessName,
    required this.businessType,
    required this.contactEmail,
    required this.contactPhone,
    required this.businessAddress,
    required this.businessDescription,
    this.expectedMonthlyVolume,
    this.bankingInfo,
    required this.status,
    required this.submittedAt,
    this.reviewedAt,
    this.reviewNotes,
  });

  factory MerchantApplication.fromJson(Map<String, dynamic> json) {
    return MerchantApplication(
      id: json['id'] as String,
      businessName: json['businessName'] as String,
      businessType: json['businessType'] as String,
      contactEmail: json['contactEmail'] as String,
      contactPhone: json['contactPhone'] as String,
      businessAddress: BusinessAddress.fromJson(
        json['businessAddress'] as Map<String, dynamic>,
      ),
      businessDescription: json['businessDescription'] as String,
      expectedMonthlyVolume: json['expectedMonthlyVolume'] != null
          ? (json['expectedMonthlyVolume'] as num).toDouble()
          : null,
      bankingInfo: json['bankingInfo'] != null
          ? BankingInfo.fromJson(json['bankingInfo'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      reviewNotes: json['reviewNotes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessName': businessName,
      'businessType': businessType,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'businessAddress': businessAddress.toJson(),
      'businessDescription': businessDescription,
      'expectedMonthlyVolume': expectedMonthlyVolume,
      'bankingInfo': bankingInfo?.toJson(),
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
    };
  }
}

class BusinessAddress {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  BusinessAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory BusinessAddress.fromJson(Map<String, dynamic> json) {
    return BusinessAddress(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      country: json['country'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'country': country,
    };
  }
}

class BankingInfo {
  final String accountNumber;
  final String routingNumber;

  BankingInfo({
    required this.accountNumber,
    required this.routingNumber,
  });

  factory BankingInfo.fromJson(Map<String, dynamic> json) {
    return BankingInfo(
      accountNumber: json['accountNumber'] as String,
      routingNumber: json['routingNumber'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
    };
  }
}

class MerchantProfile {
  final String id;
  final String userId;
  final String businessName;
  final String businessType;
  final String contactEmail;
  final String contactPhone;
  final BusinessAddress businessAddress;
  final String? logo;
  final String? description;
  final bool isActive;
  final double? rating;
  final int? totalSales;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MerchantProfile({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.businessType,
    required this.contactEmail,
    required this.contactPhone,
    required this.businessAddress,
    this.logo,
    this.description,
    required this.isActive,
    this.rating,
    this.totalSales,
    required this.createdAt,
    this.updatedAt,
  });

  factory MerchantProfile.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case from backend
    final id = (json['id'] ?? json['id']) as String;
    final userId = (json['userId'] ?? json['user_id']) as String;
    final businessName = (json['businessName'] ?? json['business_name']) as String;
    final businessType = (json['businessType'] ?? json['business_type']) as String;
    final contactEmail = (json['contactEmail'] ?? json['email']) as String?;
    final contactPhone = (json['contactPhone'] ?? json['phone']) as String?;
    final businessAddressData = json['businessAddress'] ?? json['business_address'];
    final createdAtStr = (json['createdAt'] ?? json['created_at']) as String;
    final updatedAtStr = (json['updatedAt'] ?? json['updated_at']) as String?;
    
    // Parse business address - backend returns string, not object
    BusinessAddress address;
    if (businessAddressData is String) {
      // Parse address string like "123 Main St, City, State 12345, Country"
      final parts = businessAddressData.split(',').map((e) => e.trim()).toList();
      address = BusinessAddress(
        street: parts.isNotEmpty ? parts[0] : 'Not provided',
        city: parts.length > 1 ? parts[1] : 'Not provided',
        state: parts.length > 2 ? parts[2].split(' ').first : 'Not provided',
        zipCode: parts.length > 2 ? parts[2].split(' ').last : '000000',
        country: parts.length > 3 ? parts[3] : 'India',
      );
    } else if (businessAddressData is Map<String, dynamic>) {
      address = BusinessAddress.fromJson(businessAddressData);
    } else {
      address = BusinessAddress(
        street: 'Not provided',
        city: 'Not provided',
        state: 'Not provided',
        zipCode: '000000',
        country: 'India',
      );
    }
    
    return MerchantProfile(
      id: id,
      userId: userId,
      businessName: businessName,
      businessType: businessType,
      contactEmail: contactEmail ?? 'Not provided',
      contactPhone: contactPhone ?? 'Not provided',
      businessAddress: address,
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      isActive: (json['isActive'] ?? json['is_active'] ?? json['status'] == 'active') as bool? ?? true,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalSales: json['totalSales'] ?? json['total_sales'] as int?,
      createdAt: DateTime.parse(createdAtStr),
      updatedAt: updatedAtStr != null ? DateTime.parse(updatedAtStr) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessName': businessName,
      'businessType': businessType,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'businessAddress': businessAddress.toJson(),
      'logo': logo,
      'description': description,
      'isActive': isActive,
      'rating': rating,
      'totalSales': totalSales,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

/// Merchant application statistics
class MerchantApplicationStats {
  final int totalApplications;
  final int pendingApplications;
  final int approvedApplications;
  final int rejectedApplications;
  final double approvalRate;
  final DateTime? lastApplicationDate;
  final int averageProcessingDays;

  MerchantApplicationStats({
    required this.totalApplications,
    required this.pendingApplications,
    required this.approvedApplications,
    required this.rejectedApplications,
    required this.approvalRate,
    this.lastApplicationDate,
    required this.averageProcessingDays,
  });

  factory MerchantApplicationStats.fromJson(Map<String, dynamic> json) {
    return MerchantApplicationStats(
      totalApplications: json['totalApplications'] ?? json['total_applications'] ?? 0,
      pendingApplications: json['pendingApplications'] ?? json['pending_applications'] ?? 0,
      approvedApplications: json['approvedApplications'] ?? json['approved_applications'] ?? 0,
      rejectedApplications: json['rejectedApplications'] ?? json['rejected_applications'] ?? 0,
      approvalRate: (json['approvalRate'] ?? json['approval_rate'] ?? 0.0).toDouble(),
      lastApplicationDate: json['lastApplicationDate'] != null || json['last_application_date'] != null
          ? DateTime.parse(json['lastApplicationDate'] ?? json['last_application_date'])
          : null,
      averageProcessingDays: json['averageProcessingDays'] ?? json['average_processing_days'] ?? 0,
    );
  }
}

/// Merchant profile statistics
class MerchantProfileStats {
  final int totalProfiles;
  final int activeProfiles;
  final int suspendedProfiles;
  final double completionRate;
  final Map<String, int> businessTypeDistribution;

  MerchantProfileStats({
    required this.totalProfiles,
    required this.activeProfiles,
    required this.suspendedProfiles,
    required this.completionRate,
    required this.businessTypeDistribution,
  });

  factory MerchantProfileStats.fromJson(Map<String, dynamic> json) {
    // Helper to parse int values that might be strings
    int _parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      if (value is num) return value.toInt();
      return defaultValue;
    }

    // Helper to parse double values that might be strings
    double _parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return MerchantProfileStats(
      totalProfiles: _parseInt(json['total_profiles'] ?? json['totalProfiles'], 0),
      activeProfiles: _parseInt(json['active_profiles'] ?? json['activeProfiles'], 0),
      suspendedProfiles: _parseInt(json['suspended_profiles'] ?? json['suspendedProfiles'], 0),
      completionRate: _parseDouble(json['completion_rate'] ?? json['completionRate'], 0.0),
      businessTypeDistribution: Map<String, int>.from(
        json['businessTypeDistribution'] ?? json['business_type_distribution'] ?? {},
      ),
    );
  }
}

/// Merchant performance metrics
class MerchantPerformanceMetrics {
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalTransactions;
  final int monthlyTransactions;
  final double averageTransactionValue;
  final double customerSatisfactionScore;
  final int totalCustomers;
  final int activeCustomers;
  final double customerRetentionRate;

  MerchantPerformanceMetrics({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.totalTransactions,
    required this.monthlyTransactions,
    required this.averageTransactionValue,
    required this.customerSatisfactionScore,
    required this.totalCustomers,
    required this.activeCustomers,
    required this.customerRetentionRate,
  });

  factory MerchantPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return MerchantPerformanceMetrics(
      totalRevenue: (json['totalRevenue'] ?? json['total_revenue'] ?? 0.0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? json['monthly_revenue'] ?? 0.0).toDouble(),
      totalTransactions: json['totalTransactions'] ?? json['total_transactions'] ?? 0,
      monthlyTransactions: json['monthlyTransactions'] ?? json['monthly_transactions'] ?? 0,
      averageTransactionValue: (json['averageTransactionValue'] ?? json['average_transaction_value'] ?? 0.0).toDouble(),
      customerSatisfactionScore: (json['customerSatisfactionScore'] ?? json['customer_satisfaction_score'] ?? 0.0).toDouble(),
      totalCustomers: json['totalCustomers'] ?? json['total_customers'] ?? 0,
      activeCustomers: json['activeCustomers'] ?? json['active_customers'] ?? 0,
      customerRetentionRate: (json['customerRetentionRate'] ?? json['customer_retention_rate'] ?? 0.0).toDouble(),
    );
  }

  double get monthlyGrowthRate {
    if (totalRevenue == 0) return 0.0;
    return ((monthlyRevenue / (totalRevenue / 12)) - 1) * 100;
  }
}

/// Social media performance
class SocialMediaPerformance {
  final int totalPosts;
  final int totalLikes;
  final int totalShares;
  final int totalComments;
  final double engagementRate;
  final int followers;
  final double reachGrowth;

  SocialMediaPerformance({
    required this.totalPosts,
    required this.totalLikes,
    required this.totalShares,
    required this.totalComments,
    required this.engagementRate,
    required this.followers,
    required this.reachGrowth,
  });

  factory SocialMediaPerformance.fromJson(Map<String, dynamic> json) {
    return SocialMediaPerformance(
      totalPosts: json['totalPosts'] ?? json['total_posts'] ?? 0,
      totalLikes: json['totalLikes'] ?? json['total_likes'] ?? 0,
      totalShares: json['totalShares'] ?? json['total_shares'] ?? 0,
      totalComments: json['totalComments'] ?? json['total_comments'] ?? 0,
      engagementRate: (json['engagementRate'] ?? json['engagement_rate'] ?? 0.0).toDouble(),
      followers: json['followers'] ?? 0,
      reachGrowth: (json['reachGrowth'] ?? json['reach_growth'] ?? 0.0).toDouble(),
    );
  }

  int get totalEngagements => totalLikes + totalShares + totalComments;
}

/// Complete merchant analytics
class MerchantAnalytics {
  final MerchantApplicationStats? applicationStats;
  final MerchantProfileStats? profileStats;
  final MerchantPerformanceMetrics? performanceMetrics;
  final SocialMediaPerformance? socialPerformance;

  MerchantAnalytics({
    this.applicationStats,
    this.profileStats,
    this.performanceMetrics,
    this.socialPerformance,
  });

  factory MerchantAnalytics.empty() {
    return MerchantAnalytics();
  }
}