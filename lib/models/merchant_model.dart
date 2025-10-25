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
    return MerchantProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      businessName: json['businessName'] as String,
      businessType: json['businessType'] as String,
      contactEmail: json['contactEmail'] as String,
      contactPhone: json['contactPhone'] as String,
      businessAddress: BusinessAddress.fromJson(
        json['businessAddress'] as Map<String, dynamic>,
      ),
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalSales: json['totalSales'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
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
