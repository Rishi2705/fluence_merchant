import 'package:equatable/equatable.dart';
import '../../models/merchant_model.dart';

/// Base class for all merchant-related events
abstract class MerchantEvent extends Equatable {
  const MerchantEvent();

  @override
  List<Object?> get props => [];
}

/// Event to submit merchant application
class SubmitMerchantApplication extends MerchantEvent {
  final String businessName;
  final String businessType;
  final String contactEmail;
  final String contactPhone;
  final BusinessAddress businessAddress;
  final String businessDescription;
  final String? profileImagePath;
  final String? businessLicensePath;
  final String? tradeLicensePath;
  final double? expectedMonthlyVolume;
  final BankingInfo? bankingInfo;

  const SubmitMerchantApplication({
    required this.businessName,
    required this.businessType,
    required this.contactEmail,
    required this.contactPhone,
    required this.businessAddress,
    required this.businessDescription,
    this.profileImagePath,
    this.businessLicensePath,
    this.tradeLicensePath,
    this.expectedMonthlyVolume,
    this.bankingInfo,
  });

  @override
  List<Object?> get props => [
        businessName,
        businessType,
        contactEmail,
        contactPhone,
        businessAddress,
        businessDescription,
        profileImagePath,
        businessLicensePath,
        tradeLicensePath,
        expectedMonthlyVolume,
        bankingInfo,
      ];
}

/// Event to fetch merchant profile
class FetchMerchantProfile extends MerchantEvent {
  const FetchMerchantProfile();
}

/// Event to update merchant profile
class UpdateMerchantProfile extends MerchantEvent {
  final Map<String, dynamic> updates;

  const UpdateMerchantProfile({required this.updates});

  @override
  List<Object?> get props => [updates];
}

/// Event to fetch merchant applications
class FetchMerchantApplications extends MerchantEvent {
  const FetchMerchantApplications();
}

/// Event to fetch merchant analytics
class FetchMerchantAnalytics extends MerchantEvent {
  const FetchMerchantAnalytics();
}

/// Event to fetch profile with analytics
class FetchProfileWithAnalytics extends MerchantEvent {
  const FetchProfileWithAnalytics();
}
