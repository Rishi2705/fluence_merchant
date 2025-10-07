import 'package:flutter/material.dart';

/// Centralized color definitions for the Fluence Merchant app.
/// All colors used throughout the app should be defined here.
/// Colors are based on the Fluence Pay brand identity with golden/bronze theme.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors - Fluence Pay Golden/Bronze
  static const Color primary = Color(0xFFB8860B); // Dark golden rod
  static const Color primaryLight = Color(0xFFDAA520); // Golden rod
  static const Color primaryDark = Color(0xFF996633); // Darker bronze
  static const Color primaryVariant = Color(0xFF8B4513); // Saddle brown

  // Secondary colors - Complementary tones
  static const Color secondary = Color(0xFFCD853F); // Peru
  static const Color secondaryLight = Color(0xFFDEB887); // Burlywood
  static const Color secondaryDark = Color(0xFFA0522D); // Sienna
  static const Color secondaryVariant = Color(0xFF8B4513); // Saddle brown

  // Background colors - Clean and minimal
  static const Color background = Color(0xFFFFFDF7); // Cream white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFFAF7F0); // Very light cream

  // Text colors
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF2C1810); // Dark brown
  static const Color onSurface = Color(0xFF2C1810);
  static const Color onSurfaceVariant = Color(0xFF5D4037); // Medium brown

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
  static const Color fluenceGold = Color(0xFFB8860B);
  static const Color fluenceGoldLight = Color(0xFFDAA520);
  static const Color fluenceGoldDark = Color(0xFF996633);
  static const Color fluenceBronze = Color(0xFFCD853F);
  static const Color fluenceAccent = Color(0xFFDEB887);

  // Gradient colors for Fluence Pay theme
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [fluenceGold, fluenceGoldLight],
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
}