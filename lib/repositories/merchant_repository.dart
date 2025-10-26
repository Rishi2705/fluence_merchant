import '../models/merchant_model.dart';
import '../services/merchant_api_service.dart';
import '../utils/logger.dart';

class MerchantRepository {
  final MerchantApiService _merchantApiService;

  MerchantRepository(this._merchantApiService);

  Future<MerchantApplication> submitApplication({
    required String businessName,
    required String businessType,
    required String contactEmail,
    required String contactPhone,
    required BusinessAddress businessAddress,
    required String businessDescription,
    double? expectedMonthlyVolume,
    BankingInfo? bankingInfo,
  }) async {
    AppLogger.auth('Repository: Starting merchant application submission');
    try {
      final result = await _merchantApiService.submitApplication(
        businessName: businessName,
        businessType: businessType,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        businessAddress: businessAddress,
        businessDescription: businessDescription,
        expectedMonthlyVolume: expectedMonthlyVolume,
        bankingInfo: bankingInfo,
      );
      AppLogger.success('Repository: Merchant application submission completed successfully');
      return result;
    } catch (e, stackTrace) {
      AppLogger.error('Repository: Merchant application submission failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<MerchantApplication>> getApplications() async {
    return await _merchantApiService.getApplications();
  }

  Future<MerchantApplication> getApplication(String applicationId) async {
    return await _merchantApiService.getApplication(applicationId);
  }

  Future<MerchantApplication> updateApplication({
    required String applicationId,
    required Map<String, dynamic> updates,
  }) async {
    return await _merchantApiService.updateApplication(
      applicationId: applicationId,
      updates: updates,
    );
  }

  Future<MerchantProfile> getProfile() async {
    return await _merchantApiService.getProfile();
  }

  Future<MerchantProfile> updateProfile(Map<String, dynamic> updates) async {
    return await _merchantApiService.updateProfile(updates);
  }

  Future<List<MerchantProfile>> getActiveProfiles({
    int page = 1,
    int limit = 10,
  }) async {
    return await _merchantApiService.getActiveProfiles(
      page: page,
      limit: limit,
    );
  }

  Future<MerchantAnalytics> getAnalytics() async {
    AppLogger.step(1, 'MerchantRepository: Fetching merchant analytics');
    try {
      final analytics = await _merchantApiService.getMerchantAnalytics();
      AppLogger.success('MerchantRepository: Analytics fetched successfully');
      return analytics;
    } catch (e, stackTrace) {
      AppLogger.error('MerchantRepository: Failed to fetch analytics', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
