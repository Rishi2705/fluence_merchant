import 'package:flutter/material.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _businessName = 'Meth Merchant';
  String _email = '';
  String _phone = '';
  String _category = '';
  File? _profileImage;
  bool _hasDraft = false;
  bool _hasBackendProfile = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    // First try to load from backend
    await _loadBackendProfile();
    
    // If no backend profile, load draft data
    if (!_hasBackendProfile) {
      await _loadDraftData();
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadBackendProfile() async {
    try {
      final dio = Dio();
      
      // Get Firebase token for authorization
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final token = await currentUser.getIdToken();
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Fetch profile from backend
      final response = await dio.get(
        '${ApiConstants.merchantBaseUrl}/api/profiles/me',
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final profileData = response.data['data'];
        
        setState(() {
          _businessName = profileData['businessName'] ?? 'Merchant';
          _email = profileData['contactEmail'] ?? '';
          _phone = profileData['contactPhone'] ?? '';
          _category = profileData['businessType'] ?? '';
          _hasBackendProfile = true;
        });
      }
    } catch (e) {
      print('Error loading backend profile: $e');
      // Continue to load draft data if backend fails
    }
  }

  Future<void> _loadDraftData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final businessName = prefs.getString('draft_business_name');
      final email = prefs.getString('draft_email');
      final phone = prefs.getString('draft_phone');
      final category = prefs.getString('draft_category');
      final profileImagePath = prefs.getString('draft_profile_image');
      
      setState(() {
        if (businessName != null && businessName.isNotEmpty) {
          _businessName = businessName;
          _hasDraft = true;
        }
        if (email != null && email.isNotEmpty) {
          _email = email;
        }
        if (phone != null && phone.isNotEmpty) {
          _phone = phone;
        }
        if (category != null && category.isNotEmpty) {
          _category = category;
        }
        if (profileImagePath != null && profileImagePath.isNotEmpty) {
          _profileImage = File(profileImagePath);
        }
      });
    } catch (e) {
      print('Error loading draft data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // White background header
            Container(
              width: double.infinity,
              color: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: _buildHeader(),
            ),
            // Blue background content
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F9FC),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 24, bottom: 100),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileCard(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildContactInformation(),
                const SizedBox(height: 24),
                _buildAccountSection(),
                const SizedBox(height: 24),
                _buildSettingsSection(),
                      const SizedBox(height: 24),
                      _buildSignOutButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Profile ',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
                ),
                const Text('👤', style: TextStyle(fontSize: 24)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your account',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.fluenceGold.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.fluenceGold,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5A620), Color(0xFFFDB913)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.fluenceGold.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                ),
                child: ClipOval(
                  child: _profileImage != null
                      ? Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/profile_placeholder.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                        color: AppColors.white,
                        child: const Icon(Icons.person, size: 40, color: AppColors.grey600),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 12, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _businessName,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                if (_category.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: AppColors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Verified ✓',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('156', 'Total Sales')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('4.8', 'Rating ⭐')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('92', 'Score 💯')),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.grey600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformation() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            Icons.email_outlined,
            'Email',
            _email.isNotEmpty ? _email : 'merchant@goldco.com',
            const Color(0xFFE8F4FA),
            AppColors.info,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.phone_outlined,
            'Phone',
            _phone.isNotEmpty ? _phone : '+971 50 123 4567',
            const Color(0xFFE8F9F0),
            AppColors.success,
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            Icons.business_outlined,
            'Business',
            _businessName,
            const Color(0xFFFFF8E1),
            AppColors.fluenceGold,
          ),
          if (_hasDraft) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Draft application data loaded',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value, Color bgColor, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.grey600,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuItem(
            Icons.person_outline,
            'Personal Info',
            const Color(0xFFE8F4FA),
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            Icons.business_outlined,
            'Business Details',
            const Color(0xFFE8F9F0),
            AppColors.success,
            subtitle: 'Golden Merchant Co.',
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            Icons.notifications_outlined,
            'Notifications',
            const Color(0xFFFFF8E1),
            AppColors.fluenceGold,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          _buildMenuItem(
            Icons.lock_outline,
            'Privacy & Security',
            const Color(0xFFE8F4FA),
            AppColors.info,
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            Icons.help_outline,
            'Help & Support',
            const Color(0xFFE8F9F0),
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            Icons.settings_outlined,
            'Preferences',
            const Color(0xFFFFF8E1),
            AppColors.fluenceGold,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color bgColor, Color iconColor, {String? subtitle}) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey600,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Icon(
          Icons.chevron_right,
          color: AppColors.grey400,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Show sign out confirmation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Implement sign out logic
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.fluenceGold,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
