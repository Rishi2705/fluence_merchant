import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/api_constants.dart';
import 'onboarding_page.dart';

/// Email authentication page for merchant login/signup
class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isLogin = true; // true for login, false for signup
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? userCredential;
      bool authSucceeded = false;
      
      if (_isLogin) {
        // Login with existing account
        try {
          userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          authSucceeded = true;
        } on FirebaseAuthException catch (e) {
          // Re-throw Firebase errors (not Pigeon errors)
          rethrow;
        } catch (e) {
          // Ignore Pigeon errors and try to proceed
          print('Sign in error (may be Pigeon): $e');
          authSucceeded = true; // Assume success, will verify with currentUser
        }
      } else {
        // Create new account
        try {
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          authSucceeded = true;
        } on FirebaseAuthException catch (e) {
          // Re-throw Firebase errors (not Pigeon errors)
          rethrow;
        } catch (e) {
          // Ignore Pigeon errors and try to proceed
          print('Create account error (may be Pigeon): $e');
          authSucceeded = true; // Assume success, will verify with currentUser
        }
      }

      // Wait a bit for Firebase to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check current user regardless of credential
      final currentUser = _auth.currentUser;
      print('Current user after auth: ${currentUser?.uid}');
      
      if (currentUser != null) {
        print('Firebase auth successful, getting ID token...');
        // Get Firebase ID token
        String? firebaseIdToken;
        try {
          firebaseIdToken = await currentUser.getIdToken();
          print('Got Firebase ID token: ${firebaseIdToken?.substring(0, 20)}...');
        } catch (e) {
          print('Failed to get ID token: $e');
        }

        if (firebaseIdToken == null) {
          setState(() {
            _isLoading = false;
          });
          _showError('Failed to get authentication token');
          return;
        }

        // Authenticate with backend Auth Service
        print('Authenticating with backend at ${ApiConstants.authBaseUrl}${ApiConstants.authFirebase}');
        try {
          final dio = Dio(BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
          ));
          final response = await dio.post(
            '${ApiConstants.authBaseUrl}${ApiConstants.authFirebase}',
            data: {
              'idToken': firebaseIdToken,
            },
            options: Options(
              headers: {
                'Content-Type': 'application/json',
              },
              validateStatus: (status) => status! < 500,
            ),
          );

          print('Backend response status: ${response.statusCode}');
          print('Backend response data: ${response.data}');

          if (response.statusCode == 200 || response.statusCode == 201) {
            final responseData = response.data;
            final backendToken = responseData['token'];
            final needsProfileCompletion = responseData['needsProfileCompletion'] ?? false;

            if (mounted) {
              setState(() {
                _isLoading = false;
              });

              // Navigate to onboarding page with backend JWT token
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => OnboardingPage(
                    phoneNumber: currentUser.email ?? email,
                    firebaseToken: backendToken, // Now using backend JWT token
                  ),
                ),
              );
            }
          } else {
            setState(() {
              _isLoading = false;
            });
            final errorMessage = response.data['error'] ?? 'Backend authentication failed';
            _showError(errorMessage);
          }
        } on DioException catch (e) {
          print('Backend auth DioException: ${e.type}, ${e.message}');
          setState(() {
            _isLoading = false;
          });

          String errorMessage = 'Failed to connect to authentication server';
          if (e.type == DioExceptionType.connectionTimeout) {
            errorMessage = 'Connection timeout. Please check your internet and ensure backend is running.';
          } else if (e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Server is taking too long to respond.';
          } else if (e.response != null) {
            print('Backend error response: ${e.response?.data}');
            errorMessage = e.response!.data['error'] ?? 'Authentication server error: ${e.response!.statusCode}';
          }
          
          _showError(errorMessage);
        } catch (e) {
          print('Backend auth general error: $e');
          setState(() {
            _isLoading = false;
          });
          _showError('Unexpected error during backend authentication');
        }
      } else {
        // No user signed in, still show error
        setState(() {
          _isLoading = false;
        });
        _showError('Authentication failed. Please try again.');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email. Please sign up.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email.';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address.';
          break;
        default:
          errorMessage = e.message ?? 'Authentication failed';
      }
      _showError(errorMessage);
    } catch (e) {
      // Unexpected error - this should rarely happen since we handle Pigeon errors above
      print('Unexpected error in _handleEmailAuth: $e');
      setState(() {
        _isLoading = false;
      });
      _showError('An unexpected error occurred. Please try again.');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo or icon
                const Icon(
                  Icons.storefront,
                  size: 80,
                  color: AppColors.fluenceGold,
                ),
                
                const SizedBox(height: 24),
                
                Text(
                  _isLogin ? 'Merchant Login' : 'Create Account',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  _isLogin 
                      ? 'Welcome back! Sign in to continue'
                      : 'Create your merchant account',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Email input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTextStyles.bodyLarge,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'merchant@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.fluenceGold, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error, width: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Password input
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: AppTextStyles.bodyLarge,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (!_isLogin && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.grey300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.fluenceGold, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error, width: 2),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Login/Signup button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.fluenceGold,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                          ),
                        )
                      : Text(
                          _isLogin ? 'Login' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Toggle between login and signup
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isLogin ? 'Don\'t have an account? ' : 'Already have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin ? 'Sign Up' : 'Login',
                        style: const TextStyle(
                          color: AppColors.fluenceGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your account will be verified after you complete the merchant application form.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
