import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_constants.dart';
import 'main_container_page.dart';

/// Merchant onboarding/application form page
class OnboardingPage extends StatefulWidget {
  final String? phoneNumber;
  final String? firebaseToken;

  const OnboardingPage({
    super.key,
    this.phoneNumber,
    this.firebaseToken,
  });

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _businessDescController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _hasProfileImage = false;
  File? _profileImage;
  File? _businessLicenseDoc;
  File? _tradeLicenseDoc;
  int _documentsCount = 0;
  double _progressPercentage = 33.0;
  String _selectedCategory = '🎨 Fashion & Beauty';

  // Available business categories
  final List<String> _businessCategories = [
    '🎨 Fashion & Beauty',
    '🍔 Food & Beverage',
    '🛒 Retail & Shopping',
    '💻 Electronics & Tech',
    '🏥 Health & Wellness',
    '🏠 Home & Lifestyle',
    '📚 Education & Books',
    '🎮 Entertainment & Gaming',
    '🚗 Automotive',
    '✈️ Travel & Tourism',
    '💪 Fitness & Sports',
    '🐾 Pets & Animals',
    '🔧 Services & Repair',
    '📱 Telecom & Mobile',
    '💎 Jewelry & Accessories',
    '🎭 Arts & Crafts',
    '🏗️ Construction & Hardware',
    '📦 Wholesale & Distribution',
    '🌱 Organic & Natural',
    '🎉 Events & Celebrations',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill phone number if provided from auth
    if (widget.phoneNumber != null) {
      _phoneController.text = widget.phoneNumber!;
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _businessDescController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fill all required fields');
      return;
    }

    if (_businessNameController.text.trim().isEmpty) {
      _showError('Business name is required');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      _showError('Email is required');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showError('Phone number is required');
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Prepare application data
      final applicationData = {
        'businessName': _businessNameController.text.trim(),
        'businessType': _selectedCategory,
        'contactEmail': _emailController.text.trim(),
        'contactPhone': _phoneController.text.trim().isEmpty 
            ? widget.phoneNumber ?? 'Not provided'
            : _phoneController.text.trim(),
        'businessAddress': {
          'street': _streetController.text.trim().isEmpty 
              ? 'Not provided' 
              : _streetController.text.trim(),
          'city': _cityController.text.trim().isEmpty 
              ? 'Not provided' 
              : _cityController.text.trim(),
          'state': _stateController.text.trim().isEmpty 
              ? 'Not provided' 
              : _stateController.text.trim(),
          'zipCode': _zipCodeController.text.trim().isEmpty 
              ? '000000' 
              : _zipCodeController.text.trim(),
          'country': 'India',
        },
        'businessDescription': _businessDescController.text.trim().isEmpty 
            ? 'Merchant application for ${_selectedCategory}' 
            : _businessDescController.text.trim(),
        'expectedMonthlyVolume': 0,
      };

      // Create Dio instance
      final dio = Dio();
      
      // Add authorization header if we have Firebase token
      if (widget.firebaseToken != null) {
        dio.options.headers['Authorization'] = 'Bearer ${widget.firebaseToken}';
      }

      // Submit to backend
      final response = await dio.post(
        '${ApiConstants.merchantBaseUrl}/api/applications',
        data: applicationData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          _showSuccess('Application submitted successfully!');
          
          // Navigate to home after short delay
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MainContainerPage(),
                ),
              );
            }
          });
        } else {
          final errorMessage = response.data['message'] ?? 'Failed to submit application';
          _showError(errorMessage);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        String errorMessage = 'Failed to connect to server';
        if (e.response != null) {
          errorMessage = e.response!.data['message'] ?? 
                        'Server error: ${e.response!.statusCode}';
        } else if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = 'Connection timeout. Please check your internet.';
        } else if (e.type == DioExceptionType.receiveTimeout) {
          errorMessage = 'Server is taking too long to respond.';
        }
        
        _showError(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showError('Error submitting application: $e');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
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
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final int fileSize = await imageFile.length();
        final double fileSizeInMB = fileSize / (1024 * 1024);

        // Check if file size exceeds 5MB
        if (fileSizeInMB > 5) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Image size too large! Maximum size is 5MB. Selected image is ${fileSizeInMB.toStringAsFixed(2)}MB',
                ),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        setState(() {
          _profileImage = imageFile;
          _hasProfileImage = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profile image uploaded successfully (${fileSizeInMB.toStringAsFixed(2)}MB)',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _pickDocument(String documentType) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final File documentFile = File(pickedFile.path);
        final int fileSize = await documentFile.length();
        final double fileSizeInMB = fileSize / (1024 * 1024);

        // Check if file size exceeds 10MB
        if (fileSizeInMB > 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Document size too large! Maximum size is 10MB. Selected document is ${fileSizeInMB.toStringAsFixed(2)}MB',
                ),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        setState(() {
          if (documentType == 'business_license') {
            _businessLicenseDoc = documentFile;
          } else if (documentType == 'trade_license') {
            _tradeLicenseDoc = documentFile;
          }
          
          // Update documents count
          _documentsCount = 0;
          if (_businessLicenseDoc != null) _documentsCount++;
          if (_tradeLicenseDoc != null) _documentsCount++;
          
          _updateProgress();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${documentType == 'business_license' ? 'Business License' : 'Trade License'} uploaded successfully (${fileSizeInMB.toStringAsFixed(2)}MB)',
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking document: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _saveAsDraft() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Save draft data to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      
      // Save text fields
      await prefs.setString('draft_business_name', _businessNameController.text);
      await prefs.setString('draft_email', _emailController.text);
      await prefs.setString('draft_phone', _phoneController.text);
      await prefs.setString('draft_category', _selectedCategory);
      
      // Save profile image path if exists
      if (_profileImage != null) {
        await prefs.setString('draft_profile_image', _profileImage!.path);
      }
      
      // Save document paths if exist
      if (_businessLicenseDoc != null) {
        await prefs.setString('draft_business_license', _businessLicenseDoc!.path);
      }
      if (_tradeLicenseDoc != null) {
        await prefs.setString('draft_trade_license', _tradeLicenseDoc!.path);
      }
      
      // Save flags
      await prefs.setBool('draft_has_profile_image', _hasProfileImage);
      await prefs.setInt('draft_documents_count', _documentsCount);
      await prefs.setDouble('draft_progress', _progressPercentage);
      
      // Save timestamp
      await prefs.setString('draft_saved_at', DateTime.now().toIso8601String());

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // Close loading dialog
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Draft Saved Successfully!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Business: ${_businessNameController.text.isEmpty ? "Not entered" : _businessNameController.text}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Show dialog with options
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.save, color: AppColors.fluenceGold),
                  SizedBox(width: 12),
                  Text('Draft Saved'),
                ],
              ),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your application has been saved as a draft.'),
                  SizedBox(height: 8),
                  Text(
                    'You can view the saved details in your profile.',
                    style: TextStyle(fontSize: 12, color: AppColors.grey600),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Continue Editing'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to home
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainContainerPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.fluenceGold,
                  ),
                  child: const Text('Go to Profile'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving draft: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC), // Very light bluish background
      body: Column(
        children: [
          // White header section
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get Started 😊',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set up your merchant account',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigate to home screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainContainerPage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'skip for now',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bluish background content
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.88,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProgressCard(),
                        const SizedBox(height: 20),
                        _buildUnderReviewNotice(),
                        const SizedBox(height: 20),
                        _buildProfilePictureSection(),
                        const SizedBox(height: 20),
                        _buildBusinessDetailsForm(),
                        const SizedBox(height: 20),
                        _buildContactInfoSection(),
                        const SizedBox(height: 20),
                        _buildRequiredDocumentsSection(),
                        const SizedBox(height: 20),
                        _buildSubmitButton(),
                        const SizedBox(height: 12),
                        _buildSaveDraftButton(),
                        const SizedBox(height: 20),
                        _buildHelpSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Progress',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              Text(
                '${(_progressPercentage ~/ 33.33).clamp(0, 3)}/3 Complete',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.fluenceGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: (_businessNameController.text.isNotEmpty) 
                        ? AppColors.fluenceGold 
                        : AppColors.grey200,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: (_emailController.text.isNotEmpty && _phoneController.text.isNotEmpty) 
                        ? AppColors.fluenceGold 
                        : AppColors.grey200,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: (_documentsCount > 0) 
                        ? AppColors.fluenceGold 
                        : AppColors.grey200,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildProgressStep('Business Info', Icons.business, 0)),
              Expanded(child: _buildProgressStep('Contact Details', Icons.mail, 1)),
              Expanded(child: _buildProgressStep('Documents', Icons.description, 2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, IconData icon, int step) {
    final isCompleted = (step == 0 && _businessNameController.text.isNotEmpty) ||
        (step == 1 && _emailController.text.isNotEmpty) ||
        (step == 2 && _documentsCount > 0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isCompleted ? AppColors.info.withOpacity(0.15) : AppColors.grey100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 24,
            color: isCompleted ? AppColors.info : AppColors.grey400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isCompleted ? AppColors.onBackground : AppColors.grey600,
            fontSize: 11,
            fontWeight: isCompleted ? FontWeight.w500 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildUnderReviewNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.fluenceGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: AppColors.fluenceGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.fluenceGold,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hourglass_empty,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Under Review ⏳',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hang tight! We\'re checking your application.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person,
                color: AppColors.fluenceGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Profile Picture 🖼️',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.fluenceGold,
                    width: 2,
                  ),
                ),
                child: _hasProfileImage && _profileImage != null
                    ? ClipOval(
                  child: Image.file(
                    _profileImage!,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.person,
                  size: 32,
                  color: AppColors.grey400,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: _pickProfileImage,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _hasProfileImage ? 'Change Photo' : 'Upload Photo',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.fluenceGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'JPG, PNG • Max 5MB',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDetailsForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.business,
                color: AppColors.fluenceGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Business Details',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Business Name 🏢',
            'Golden Merchant Co.',
            Icons.business,
            _businessNameController,
          ),
          const SizedBox(height: 12),
          _buildDropdownField(
            'Category',
            _selectedCategory,
            Icons.category,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      String placeholder,
      IconData icon,
      TextEditingController controller,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey400,
            ),
            prefixIcon: Icon(icon, color: AppColors.info, size: 20),
            filled: true,
            fillColor: AppColors.info.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.info.withOpacity(0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.info,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _updateProgress();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.grey600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.info.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Padding(
                padding: EdgeInsets.only(right: 12.0),
                child: Icon(Icons.keyboard_arrow_down, color: AppColors.grey600),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              dropdownColor: AppColors.surface,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onBackground,
              ),
              items: _businessCategories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(icon, color: AppColors.info, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          category,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.contact_mail,
                color: AppColors.fluenceGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '📧 Contact Info',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Email Address 📧',
            'merchant@goldco.com',
            Icons.email,
            _emailController,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            'Phone Number 📞',
            '+971 50 123 4567',
            Icons.phone,
            _phoneController,
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredDocumentsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description,
                color: AppColors.fluenceGold,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Required Documents',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // Show dialog to choose which document to upload
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Select Document Type'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.description, color: AppColors.fluenceGold),
                          title: const Text('Business License'),
                          trailing: _businessLicenseDoc != null 
                              ? const Icon(Icons.check_circle, color: AppColors.success)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            _pickDocument('business_license');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.description, color: AppColors.fluenceGold),
                          title: const Text('Trade License'),
                          trailing: _tradeLicenseDoc != null 
                              ? const Icon(Icons.check_circle, color: AppColors.success)
                              : null,
                          onTap: () {
                            Navigator.pop(context);
                            _pickDocument('trade_license');
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.fluenceGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.upload_file,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Drop your files here',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'or click to browse',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PDF, PNG, JPG • Max 10MB each',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _pickDocument('business_license'),
            child: _buildDocumentItem(
              '📄 Business License', 
              _businessLicenseDoc != null,
              () => _pickDocument('business_license'),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickDocument('trade_license'),
            child: _buildDocumentItem(
              '📋 Trade License', 
              _tradeLicenseDoc != null,
              () => _pickDocument('trade_license'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String name, bool isUploaded, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          border: Border.all(
            color: isUploaded ? AppColors.success.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isUploaded ? AppColors.success.withOpacity(0.1) : AppColors.grey200,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle : Icons.description,
                size: 16,
                color: isUploaded ? AppColors.success : AppColors.grey600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onBackground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    isUploaded ? 'Uploaded ✓' : 'Tap to upload',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isUploaded ? AppColors.success : AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded ? Icons.edit : Icons.upload_file,
              color: isUploaded ? AppColors.grey600 : AppColors.fluenceGold,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _submitApplication,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.fluenceGold,
          foregroundColor: AppColors.white,
          elevation: 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Submit Application',
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveDraftButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _saveAsDraft,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.fluenceGold,
          side: BorderSide(
            color: AppColors.fluenceGold,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(
          'Save as Draft',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.fluenceGold,
          ),
        ),
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need Help?',
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our support team is here 24/7 to help you get started!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  void _updateProgress() {
    int completed = 0;
    if (_businessNameController.text.isNotEmpty) completed++;
    if (_emailController.text.isNotEmpty) completed++;
    if (_documentsCount > 0) completed++;

    setState(() {
      _progressPercentage = (completed / 3) * 100;
    });
  }
}