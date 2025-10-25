/// API constants for Fluence Pay Backend Services
class ApiConstants {
  // Base URLs for microservices - Running backend on localhost
  // Physical device MUST use PC's IP address (not 'localhost')
  // 'localhost' on phone = phone itself, NOT your PC
  static const String _baseHost = '172.20.10.2'; // Your PC's IP on local network
  
  static const String authBaseUrl = 'http://$_baseHost:4001';           // Auth Service
  static const String merchantBaseUrl = 'http://$_baseHost:4002';       // Merchant Service (your setup)
  static const String cashbackBaseUrl = 'http://$_baseHost:4003';       // Cashback Service
  static const String notificationBaseUrl = 'http://$_baseHost:4004';   // Notification Service
  static const String walletBaseUrl = 'http://$_baseHost:4005';         // Points Wallet Service
  static const String referralBaseUrl = 'http://$_baseHost:4006';       // Referral Service
  static const String socialBaseUrl = 'http://$_baseHost:4007';         // Social Features Service

  // Auth Service Endpoints
  static const String authFirebase = '/api/auth/firebase';
  static const String authCompleteProfile = '/api/auth/complete-profile';
  static const String authAccountStatus = '/api/auth/account/status';

  // Merchant Service Endpoints
  static const String merchantApplications = '/api/applications';
  static const String merchantProfile = '/api/profiles/me';
  static const String merchantProfiles = '/api/profiles';

  // Cashback Service Endpoints
  static const String budgets = '/api/budgets';
  static const String campaigns = '/api/campaigns';
  static const String transactions = '/api/transactions';
  static const String disputes = '/api/disputes';

  // Wallet Service Endpoints
  static const String walletBalance = '/api/wallet/balance';
  static const String walletTransactions = '/api/wallet/transactions';
  static const String walletTransfer = '/api/wallet/transfer';
  static const String walletWithdraw = '/api/wallet/withdraw';

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

  // Request timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
