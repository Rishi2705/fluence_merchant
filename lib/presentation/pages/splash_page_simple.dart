import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme.dart';
import '../../core/di/service_locator.dart';
import '../../services/api_service_new.dart';
import '../../utils/logger.dart';
import 'phone_auth_page.dart';
import 'onboarding_page.dart';
import 'main_container_page.dart';

/// Splash screen widget for the DonePay app.
/// Displays the DonePay logo with branding and automatically navigates to phone authentication.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    AppLogger.step(1, 'SplashPage: Checking authentication status');
    
    try {
      // Wait for splash screen display
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted) return;
      
      // Check if user has a saved auth token
      AppLogger.step(2, 'SplashPage: Checking for saved auth token');
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      
      AppLogger.info('SplashPage: Auth token check', data: {
        'hasToken': savedToken != null,
        'tokenLength': savedToken?.length,
      });
      
      // Check Firebase auth state
      AppLogger.step(3, 'SplashPage: Checking Firebase auth state');
      final currentUser = FirebaseAuth.instance.currentUser;
      
      AppLogger.firebase('SplashPage: Firebase user status', data: {
        'hasCurrentUser': currentUser != null,
        'uid': currentUser?.uid,
        'email': currentUser?.email,
        'isEmailVerified': currentUser?.emailVerified,
      });
      
      if (savedToken != null && currentUser != null) {
        AppLogger.success('SplashPage: User is authenticated, restoring session');
        
        // Restore token to API service
        AppLogger.step(4, 'SplashPage: Restoring token to API service');
        final apiService = getIt<ApiService>();
        await apiService.setToken(savedToken);
        
        AppLogger.success('SplashPage: Session restored, navigating to main app');
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainContainerPage()),
          );
        }
      } else {
        AppLogger.info('SplashPage: No valid session found, navigating to auth page', data: {
          'hasToken': savedToken != null,
          'hasFirebaseUser': currentUser != null,
        });
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PhoneAuthPage()),
          );
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('SplashPage: Error checking auth status', error: e, stackTrace: stackTrace);
      
      // On error, navigate to auth page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PhoneAuthPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo with white circular background
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/donepay_logo.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback if image is not found
                      return Icon(
                        Icons.account_balance_wallet,
                        size: 50,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // DonePay text
              Text(
                'DonePay',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'SECURE PAYMENTS, INSTANT REWARDS',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Let's get started button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OnboardingPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 2,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Let\'s get started',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // I already have an account link
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'I already have an account',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}