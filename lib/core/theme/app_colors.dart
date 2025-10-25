import 'package:flutter/material.dart';

/// Centralized color definitions for the Fluence Merchant app.
/// All colors used throughout the app should be defined here.
/// Colors are based on the Fluence Pay brand identity with golden/bronze theme.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors - Fluence Pay Golden/Yellow
  static const Color primary = Color(0xFFFDB913); // Fluence Gold
  static const Color primaryLight = Color(0xFFFFD54F); // Light gold
  static const Color primaryDark = Color(0xFFE5A620); // Dark gold
  static const Color primaryVariant = Color(0xFFD4A428); // Gold variant

  // Secondary colors - Complementary tones
  static const Color secondary = Color(0xFFCD853F); // Peru
  static const Color secondaryLight = Color(0xFFDEB887); // Burlywood
  static const Color secondaryDark = Color(0xFFA0522D); // Sienna
  static const Color secondaryVariant = Color(0xFF8B4513); // Saddle brown

  // Background colors - Clean and minimal
  static const Color background = Color(0xFFF5F5F5); // Light grey
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFFAFAFA); // Off white
  static const Color lightCream = Color(0xFFFFF8F0); // Light cream for password page

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF); // White on gold
  static const Color onSecondary = Color(0xFFFFFFFF); // White on secondary
  static const Color onBackground = Color(0xFF000000); // Black on light background
  static const Color onSurface = Color(0xFF2C1810); // Dark brown
  static const Color onSurfaceVariant = Color(0xFF757575); // Medium grey

  // Status colors
  static const Color success = Color(0xFF2E7D32); // Green
  static const Color warning = Color(0xFFED6C02); // Orange
  static const Color error = Color(0xFFD32F2F); // Red
  static const Color info = Color(0xFF0288D1); // Blue

  // Neutral colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Additional utility colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1F000000);

  // Fluence Pay specific colors
  static const Color fluenceGold = Color(0xFFFDB913); // Main Fluence gold
  static const Color fluenceGoldLight = Color(0xFFFFD54F); // Light gold
  static const Color fluenceGoldDark = Color(0xFFE5A620); // Dark gold
  static const Color fluenceBronze = Color(0xFFCD853F);
  static const Color fluenceAccent = Color(0xFFDEB887);

  // Pink accent for profile borders
  static const Color pinkAccent = Color(0xFFE91E63);

  // Gradient colors for Fluence Pay theme
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFD4A428), Color(0xFFF5C842)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [fluenceBronze, fluenceAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Splash screen specific gradient
  static const LinearGradient splashGradient = LinearGradient(
    colors: [background, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Card gradient for Fluence card
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFD4A428), Color(0xFFF5C842)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}