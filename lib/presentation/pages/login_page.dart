import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'password_page.dart';

/// Login page that matches the provided design with Material Design 3
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background image - stretched to cover entire screen
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_background.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.background,
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Space to push image to 25% from top
                  SizedBox(height: screenHeight * 0.25),

                  // Illustration image
                  Image.asset(
                    'assets/images/login_image.png',
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.25,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: screenWidth * 0.85,
                        height: screenHeight * 0.25,
                        color: Colors.transparent,
                      );
                    },
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Login heading
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Login',
                      style: AppTextStyles.displayMedium.copyWith(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.08,
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.008),

                  // Subtitle with heart emoji
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontSize: screenWidth * 0.038,
                        ),
                        children: [
                          const TextSpan(text: 'Good to see you back! '),
                          TextSpan(
                            text: '♥',
                            style: TextStyle(
                              color: AppColors.onBackground,
                              fontSize: screenWidth * 0.038,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Email field with dropdown icon
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: screenWidth * 0.038,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.grey400,
                          fontSize: screenWidth * 0.038,
                        ),
                        suffixIcon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.onSurfaceVariant,
                          size: screenWidth * 0.06,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: screenHeight * 0.022,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.07,
                    child: ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fluenceGold,
                        foregroundColor: AppColors.white,
                        elevation: 3,
                        shadowColor: AppColors.fluenceGold.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Next',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.04,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),

                  // Cancel button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth * 0.038,
                        ),
                      ),
                    ),
                  ),

                  // Bottom spacing
                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Please enter your email');
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar('Please enter a valid email address');
      return;
    }

    // Navigate to password screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordPage(
          userName: _extractNameFromEmail(email),
          email: email,
        ),
      ),
    );
  }

  String _extractNameFromEmail(String email) {
    // Extract name from email (e.g., "romina@example.com" -> "Romina")
    final username = email.split('@').first;
    if (username.isEmpty) return 'User';

    // Capitalize first letter
    return username[0].toUpperCase() + username.substring(1);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}