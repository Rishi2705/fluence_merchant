import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'onboarding_page.dart';

/// Sign up page that matches the provided design
class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Sign In heading
              Text(
                'Sign In',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.onBackground,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Logo
              Image.asset(
                'assets/images/fluence_logo_second.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image is not found
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.fluenceGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.business,
                      size: 60,
                      color: AppColors.white,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 80),
              
              // Sign in as Merchant button
              _buildMerchantSignInButton(context),
              
              const SizedBox(height: 40),
              
              // Divider with OR
              _buildOrDivider(),
              
              const SizedBox(height: 40),
              
              // Browse as guest button
              _buildGuestButton(context),
              
              const Spacer(),
              
              // Terms and Privacy at bottom
              _buildTermsText(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildMerchantSignInButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToOnboarding(context),
        child: Text(
          'Sign in as Merchant',
          textAlign: TextAlign.center,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Or',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.divider,
          ),
        ),
      ],
    );
  }

  Widget _buildGuestButton(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToOnboarding(context),
      child: Text(
        'Browse as guest',
        style: AppTextStyles.titleMedium.copyWith(
          color: AppColors.fluenceGold,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.fluenceGold,
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.fluenceGold,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.fluenceGold,
            ),
          ),
          const TextSpan(text: ' and\n'),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.fluenceGold,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.fluenceGold,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToOnboarding(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const OnboardingPage(),
      ),
    );
  }
}