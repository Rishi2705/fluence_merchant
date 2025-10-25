import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import 'login_page.dart';

/// Sign up page that matches the provided design - Create Account
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final String _selectedCountryCode = '+44';
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background image in upper 40% of screen
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
            child: Image.asset(
              'assets/images/signup_background.png',
              fit: BoxFit.fill,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.white,
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Position Create Account at 20% from top
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                  // Create Account heading
                  Text(
                    'Create\nAccount',
                    style: AppTextStyles.displaySmall.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      fontSize: 36,
                    ),
                  ),

                  // Space to push input fields to 45% of screen
                  SizedBox(height: MediaQuery.of(context).size.height * 0.45 - MediaQuery.of(context).size.height * 0.15 - 100),

                  // Background image behind input fields
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Character illustration as background - positioned above text fields
                      Positioned(
                        top: -100,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            'assets/images/signup_background_image.png',
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: 280,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // Debug: Show what error occurred
                              print('Image error: $error');
                              return Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 280,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.people_outline,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Image not found',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Input fields on top
                      Column(
                        children: [
                          const SizedBox(height: 0),

                          // Email field
                          _buildTextField(
                            controller: _emailController,
                            hint: 'Email',
                            prefixIcon: Icons.email_outlined,
                          ),

                          SizedBox(height: MediaQuery.of(context).size.height * 0.015),

                          // Password field
                          _buildTextField(
                            controller: _passwordController,
                            hint: 'Password',
                            prefixIcon: Icons.lock_outline,
                            isPassword: true,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),

                          SizedBox(height: MediaQuery.of(context).size.height * 0.015),

                          // Phone number field with country code
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.grey200,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: AppColors.grey300,
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Row(
                                children: [
                                  // Country flag and code selector
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        // UK Flag
                                        Container(
                                          width: 28,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: AppColors.grey300,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(3),
                                            child: Image.asset(
                                              'assets/icons/uk_flag.png',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: AppColors.grey200,
                                                  child: const Center(
                                                    child: Text(
                                                      '🇬🇧',
                                                      style: TextStyle(fontSize: 12),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          color: AppColors.onSurfaceVariant,
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // Divider
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: AppColors.grey300,
                                  ),

                                  // Phone number input
                                  Expanded(
                                    child: TextField(
                                      controller: _phoneController,
                                      keyboardType: TextInputType.phone,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        fontSize: 14,
                                        color: AppColors.onBackground,
                                      ),
                                      decoration: InputDecoration(
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        hintText: 'Your number',
                                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.grey400.withOpacity(0.6),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Done button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.fluenceGold,
                        foregroundColor: AppColors.white,
                        elevation: 2,
                        shadowColor: AppColors.fluenceGold.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Done',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.015),

                  // Cancel button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    bool isPassword = false,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey200,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.grey300,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 14,
            color: AppColors.onBackground,
          ),
          decoration: InputDecoration(
            filled: false,
            fillColor: Colors.transparent,
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey400.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }

  void _handleDone() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty || phone.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    // Navigate to login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
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
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}