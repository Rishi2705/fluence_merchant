import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/api_constants.dart';
import '../../core/di/service_locator.dart';
import '../../services/api_service_new.dart';
import '../../utils/logger.dart';
import 'onboarding_page.dart';
import 'main_container_page.dart';

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
    AppLogger.step(1, 'Starting email authentication process');
    AppLogger.auth('Email auth initiated', data: {
      'isLogin': _isLogin,
      'email': _emailController.text.trim(),
      'hasPassword': _passwordController.text.trim().isNotEmpty,
    });

    if (!_formKey.currentState!.validate()) {
      AppLogger.warning('Form validation failed');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential? userCredential;
      
      AppLogger.step(2, _isLogin ? 'Attempting Firebase login' : 'Attempting Firebase signup');
      
      if (_isLogin) {
        // Login with existing account
        try {
          AppLogger.firebase('Signing in with email and password');
          userCredential = await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          AppLogger.firebase('Firebase sign in successful', data: {
            'uid': userCredential.user?.uid,
            'email': userCredential.user?.email,
          });
        } on FirebaseAuthException catch (e) {
          AppLogger.error('Firebase authentication exception during login', error: e);
          // Re-throw Firebase errors (not Pigeon errors)
          rethrow;
        } catch (e) {
          // Ignore Pigeon errors and try to proceed
          AppLogger.warning('Sign in error (may be Pigeon, continuing)', data: e);
        }
      } else {
        // Create new account
        try {
          AppLogger.firebase('Creating new account with email and password');
          userCredential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          AppLogger.firebase('Firebase account creation successful', data: {
            'uid': userCredential.user?.uid,
            'email': userCredential.user?.email,
          });
        } on FirebaseAuthException catch (e) {
          AppLogger.error('Firebase authentication exception during signup', error: e);
          // Re-throw Firebase errors (not Pigeon errors)
          rethrow;
        } catch (e) {
          // Ignore Pigeon errors and try to proceed
          AppLogger.warning('Create account error (may be Pigeon, continuing)', data: e);
        }
      }

      // Wait a bit for Firebase to complete
      AppLogger.step(3, 'Waiting for Firebase to complete authentication');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Check current user regardless of credential
      final currentUser = _auth.currentUser;
      AppLogger.step(4, 'Checking current Firebase user');
      AppLogger.firebase('Current user status', data: {
        'hasCurrentUser': currentUser != null,
        'uid': currentUser?.uid,
        'email': currentUser?.email,
        'isEmailVerified': currentUser?.emailVerified,
        'displayName': currentUser?.displayName,
      });
      
      if (currentUser != null) {
        AppLogger.step(5, 'Firebase auth successful, getting ID token');
        // Get Firebase ID token
        String? firebaseIdToken;
        try {
          AppLogger.firebase('Requesting Firebase ID token');
          firebaseIdToken = await currentUser.getIdToken();
          AppLogger.firebase('Firebase ID token obtained', data: {
            'hasToken': firebaseIdToken != null,
            'tokenLength': firebaseIdToken?.length,
            'tokenPreview': firebaseIdToken != null ? '${firebaseIdToken.substring(0, 20)}...' : null,
          });
        } catch (e, stackTrace) {
          AppLogger.error('Failed to get Firebase ID token', error: e, stackTrace: stackTrace);
        }

        if (firebaseIdToken == null) {
          AppLogger.error('Firebase ID token is null, cannot proceed');
          setState(() {
            _isLoading = false;
          });
          _showError('Failed to get authentication token');
          return;
        }

        // Authenticate with backend Auth Service
        AppLogger.step(6, 'Starting backend authentication');
        final backendUrl = '${ApiConstants.authBaseUrl}${ApiConstants.authFirebase}';
        AppLogger.api('Backend authentication URL', data: {
          'url': backendUrl,
          'authBaseUrl': ApiConstants.authBaseUrl,
          'authFirebaseEndpoint': ApiConstants.authFirebase,
          'currentHost': ApiConstants.currentHost,
          'isUsingEmulatorHost': ApiConstants.isUsingEmulatorHost,
          'isUsingPhysicalDeviceHost': ApiConstants.isUsingPhysicalDeviceHost,
        });
        
        // Retry mechanism for connection timeouts
        int retryCount = 0;
        const maxRetries = 3;
        Response? response;
        
        try {
          while (retryCount < maxRetries) {
            try {
              AppLogger.step(7, 'Backend auth attempt ${retryCount + 1} of $maxRetries');
              final dio = Dio(BaseOptions(
                connectTimeout: const Duration(seconds: 60),
                receiveTimeout: const Duration(seconds: 60),
              ));
              
              final requestData = {
                'idToken': firebaseIdToken,
              };
              
              AppLogger.networkRequest(
                method: 'POST',
                url: backendUrl,
                headers: {'Content-Type': 'application/json'},
                body: {
                  'idToken': '${firebaseIdToken.substring(0, 20)}...', // Truncated for security
                },
              );

              final stopwatch = Stopwatch()..start();
              response = await dio.post(
                backendUrl,
                data: requestData,
                options: Options(
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  validateStatus: (status) => status! < 500,
                ),
              );
              stopwatch.stop();

              AppLogger.networkResponse(
                statusCode: response.statusCode ?? 0,
                url: backendUrl,
                body: response.data,
                duration: stopwatch.elapsed,
              );

              AppLogger.success('Backend authentication request completed');
              break; // Success, exit retry loop
            } catch (e, stackTrace) {
              retryCount++;
              AppLogger.warning('Backend auth attempt $retryCount failed', data: e);
              
              // Check if it's a DioException and if it's a connection timeout
              if (e is DioException && e.type == DioExceptionType.connectionTimeout && retryCount < maxRetries) {
                final waitTime = retryCount * 2;
                AppLogger.warning('Connection timeout, retrying in $waitTime seconds...');
                await Future.delayed(Duration(seconds: waitTime));
                continue;
              } else {
                AppLogger.error('Non-retryable error or max retries reached', error: e, stackTrace: stackTrace);
                rethrow; // Re-throw if not a retryable timeout or max retries reached
              }
            }
          }

          AppLogger.step(8, 'Processing backend authentication response');

          if (response?.statusCode == 200 || response?.statusCode == 201) {
            AppLogger.success('Backend authentication successful');
            final responseData = response!.data;
            final backendToken = responseData['token'];
            final needsProfileCompletion = responseData['needsProfileCompletion'] ?? false;
            
            AppLogger.auth('Backend response parsed', data: {
              'hasToken': backendToken != null,
              'tokenLength': backendToken?.length,
              'tokenPreview': backendToken != null ? '${backendToken.toString().substring(0, 20)}...' : null,
              'needsProfileCompletion': needsProfileCompletion,
              'userData': responseData['user'],
            });

            // Save the backend JWT token to SharedPreferences and update API service
            if (backendToken != null) {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('auth_token', backendToken);
              
              // Update the API service with the new token
              final apiService = getIt<ApiService>();
              await apiService.setToken(backendToken);
              
              AppLogger.success('Backend token saved and API service updated');
            }

            if (mounted) {
              setState(() {
                _isLoading = false;
              });

              if (needsProfileCompletion) {
                AppLogger.step(9, 'User needs profile completion - navigating to onboarding page');
                // Navigate to onboarding page with backend JWT token
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => OnboardingPage(
                      phoneNumber: currentUser.email ?? email,
                      firebaseToken: backendToken, // Now using backend JWT token
                    ),
                  ),
                );
                AppLogger.success('Navigation to onboarding page completed');
              } else {
                AppLogger.step(9, 'User profile complete - navigating to main app');
                // Navigate directly to main app
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const MainContainerPage(),
                  ),
                );
                AppLogger.success('Navigation to main app completed');
              }
            }
          } else {
            AppLogger.error('Backend authentication failed', data: {
              'statusCode': response?.statusCode,
              'responseData': response?.data,
            });
            setState(() {
              _isLoading = false;
            });
            final errorMessage = response?.data['error'] ?? 'Backend authentication failed';
            _showError(errorMessage);
          }
        } catch (e, stackTrace) {
          AppLogger.error('Backend authentication failed with exception', error: e, stackTrace: stackTrace);
          setState(() {
            _isLoading = false;
          });

          String errorMessage = 'Failed to connect to authentication server';
          if (e is DioException) {
            AppLogger.error('DioException details', data: {
              'type': e.type.toString(),
              'message': e.message,
              'statusCode': e.response?.statusCode,
              'responseData': e.response?.data,
            });

            if (e.type == DioExceptionType.connectionTimeout) {
              errorMessage = 'Connection timeout after $maxRetries attempts. Please check your internet and ensure backend is running.';
            } else if (e.type == DioExceptionType.receiveTimeout) {
              errorMessage = 'Server is taking too long to respond.';
            } else if (e.response != null) {
              AppLogger.error('Backend error response details', data: e.response?.data);
              errorMessage = e.response!.data['error'] ?? 'Authentication server error: ${e.response!.statusCode}';
            }
          }
          
          AppLogger.error('Showing error to user', data: {'errorMessage': errorMessage});
          _showError(errorMessage);
        }
      } else {
        // No user signed in, still show error
        AppLogger.error('No current user found after Firebase authentication');
        setState(() {
          _isLoading = false;
        });
        _showError('Authentication failed. Please try again.');
      }
    } on FirebaseAuthException catch (e, stackTrace) {
      AppLogger.error('FirebaseAuthException caught', error: e, stackTrace: stackTrace);
      AppLogger.error('FirebaseAuthException details', data: {
        'code': e.code,
        'message': e.message,
        'email': e.email,
        'credential': e.credential?.toString(),
      });

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
      AppLogger.error('Firebase auth error message', data: {'errorMessage': errorMessage});
      _showError(errorMessage);
    } catch (e, stackTrace) {
      // Unexpected error - this should rarely happen since we handle Pigeon errors above
      AppLogger.error('Unexpected error in _handleEmailAuth', error: e, stackTrace: stackTrace);
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
