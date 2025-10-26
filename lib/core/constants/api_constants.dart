import 'dart:io';

/// API constants for Fluence Pay Backend Services
class ApiConstants {
  // Base URLs for microservices - Running backend on localhost
  // Android Emulator: Use 10.0.2.2 to access host machine's localhost
  // Physical device: Use PC's IP address (not 'localhost')
  // 'localhost' on phone = phone itself, NOT your PC
  
  /// Manual override for host selection
  /// Set this to 'emulator' or 'physical' to force a specific host
  static const String? _hostOverride = 'physical'; // Change to 'emulator' or 'physical' if needed
  
  /// Get the appropriate host based on device type
  static String get _baseHost {
    // Manual override takes precedence
    if (_hostOverride == 'emulator') {
      return _emulatorHost;
    } else if (_hostOverride == 'physical') {
      return _physicalDeviceHost;
    }
    
    if (Platform.isAndroid) {
      // For now, default to emulator for development
      // You can enhance this with actual emulator detection if needed
      return _emulatorHost;
    } else if (Platform.isIOS) {
      return 'localhost'; // iOS simulator can use localhost
    } else {
      return 'localhost'; // Desktop/other platforms
    }
  }
  
  /// Get the appropriate host for physical devices
  static String get _physicalDeviceHost {
    return '192.168.0.180'; // Your PC's IP on local network
  }
  
  /// Get the appropriate host for emulators
  static String get _emulatorHost {
    return '10.0.2.2'; // Android emulator host mapping
  }
  
  /// Get current host being used
  static String get currentHost => _baseHost;
  
  /// Check if currently using emulator host
  static bool get isUsingEmulatorHost => _baseHost == _emulatorHost;
  
  /// Check if currently using physical device host
  static bool get isUsingPhysicalDeviceHost => _baseHost == _physicalDeviceHost;
  
  // Dynamic base URLs based on device type
  static String get authBaseUrl => 'http://$_baseHost:4001';           // Auth Service
  static String get merchantBaseUrl => 'http://$_baseHost:4003';       // Merchant Service (corrected port)
  static String get cashbackBaseUrl => 'http://$_baseHost:4002';       // Cashback Service (corrected port)
  static String get notificationBaseUrl => 'http://$_baseHost:4004';   // Notification Service
  static String get walletBaseUrl => 'http://$_baseHost:4005';         // Points Wallet Service
  static String get referralBaseUrl => 'http://$_baseHost:4006';       // Referral Service
  static String get socialBaseUrl => 'http://$_baseHost:4007';         // Social Features Service

  // Auth Service Endpoints
  static const String authFirebase = '/api/auth/firebase';
  static const String authCompleteProfile = '/api/auth/complete-profile';
  static const String authAccountStatus = '/api/auth/account/status';

  // Merchant Service Endpoints
  static const String merchantApplications = '/api/applications';
  static const String merchantApplicationStats = '/api/applications/stats';
  static const String merchantProfile = '/api/profiles/me';
  static const String merchantUpdateProfile = '/api/profiles/me';
  static const String merchantProfiles = '/api/profiles';
  static const String merchantProfileStats = '/api/profiles/stats';
  static const String merchantAdminStats = '/api/admin/stats';

  // Cashback Service Endpoints
  static const String budgets = '/api/budgets';
  static const String campaigns = '/api/campaigns';
  static const String transactions = '/api/transactions';
  static const String disputes = '/api/disputes';

  // Points Wallet Service Endpoints (Port 4005)
  // Wallet endpoints
  static const String walletBalance = '/api/wallet/balance';
  static const String walletBalanceSummary = '/api/wallet/balance/summary';
  static const String walletBalanceHistory = '/api/wallet/balance/history';
  static const String walletBalanceTrends = '/api/wallet/balance/trends';
  static const String walletBalanceAlerts = '/api/wallet/balance/alerts';
  static const String walletCheckBalance = '/api/wallet/check-balance';
  
  // Points endpoints
  static const String pointsTransactions = '/api/points/transactions';
  static const String pointsTransactionById = '/api/points/transactions'; // + /:id
  static const String pointsEarn = '/api/points/earn';
  static const String pointsStats = '/api/points/stats';
  static const String pointsStatsTotalEarned = '/api/points/stats/total-earned';
  static const String pointsStatsTotalRedeemed = '/api/points/stats/total-redeemed';
  static const String pointsDailySummary = '/api/points/stats/daily-summary';

  // Notification Service Endpoints
  static const String notifications = '/api/notifications';
  static const String notificationsUnreadCount = '/api/notifications/unread-count';
  static const String notificationsMarkRead = '/api/notifications/mark-read';
  static const String notificationsMarkAllRead = '/api/notifications/mark-all-read';
  static const String notificationPreferences = '/api/notifications/preferences';

  // Referral Service Endpoints
  static const String referralGenerate = '/api/referral/code/generate';
  static const String referralValidate = '/api/referral/code/validate';
  static const String referralComplete = '/api/referral/complete';
  static const String referralStats = '/api/referral/stats';

  // Social Service Endpoints
  static const String socialAnalytics = '/api/social/analytics';
  static const String socialMerchantAnalytics = '/api/social/merchant/analytics';
  static const String socialMerchantReports = '/api/social/merchant/reports';

  // Cashback Service Analytics Endpoints
  static const String campaignsActive = '/api/campaigns';
  static const String campaignAnalytics = '/api/campaigns'; // + /:id/analytics
  static const String transactionAnalytics = '/api/transactions/analytics';

  // Request timeout - Increased for better reliability
  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
