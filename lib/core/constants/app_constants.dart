/// Utility class for app-wide constants.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'Fluence Merchant';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.fluencepay.com/v1';
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_completed';
  static const String themeKey = 'theme_mode';

  // Animation Durations
  static const int splashDuration = 3000; // 3 seconds
  static const int shortAnimationDuration = 300; // 300ms
  static const int mediumAnimationDuration = 500; // 500ms
  static const int longAnimationDuration = 1000; // 1 second

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 48.0;
  static const String defaultUserName = "Rishi";

  // Demo Data
  static const int defaultPoints = 1250;
  static const double defaultCashback = 245.0;
  static const String demoImagePath = 'assets/images/demo_merchant.png';

  // Error Messages
  static const String generalErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'Please check your internet connection.';
  static const String timeoutErrorMessage = 'Request timed out. Please try again.';
  static const String unauthorizedErrorMessage = 'Unauthorized access. Please login again.';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int maxNameLength = 50;

  // Regular Expressions
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phoneRegex = r'^\+?[1-9]\d{1,14}$';

  // Asset Paths
  static const String logoPath = 'assets/images/fluence_logo.png';
  static const String placeholderImagePath = 'assets/images/placeholder.png';

  // Route Names
  static const String splashRoute = '/splash';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
}