import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/di/service_locator.dart';
import '../../services/api_service_new.dart';
import '../../blocs/merchant/merchant_bloc.dart';
import '../../blocs/merchant/merchant_event.dart';
import '../../blocs/merchant/merchant_state.dart';
import '../../models/merchant_model.dart';
import '../../utils/logger.dart';
import 'phone_auth_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _businessName = 'Merchant';
  String _email = '';
  String _phone = '';
  String _category = '';
  File? _profileImage;
  bool _hasDraft = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    AppLogger.step(1, 'ProfilePage: Initializing profile page');
    // Load merchant profile with analytics from backend
    context.read<MerchantBloc>().add(const FetchProfileWithAnalytics());
    // Also load draft data as fallback
    _loadDraftData();
  }

  Future<void> _handleSignOut() async {
    AppLogger.step(1, 'ProfilePage: User initiated sign out');
    try {
      AppLogger.step(2, 'ProfilePage: Clearing auth token');
      // Clear auth token
      final apiService = getIt<ApiService>();
      await apiService.clearToken();
      
      AppLogger.step(3, 'ProfilePage: Signing out from Firebase');
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      AppLogger.step(4, 'ProfilePage: Clearing SharedPreferences');
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      AppLogger.success('ProfilePage: Sign out successful, navigating to phone auth');
      // Navigate to phone auth page
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PhoneAuthPage()),
          (route) => false,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('ProfilePage: Sign out failed', error: e, stackTrace: stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Widget _buildNoProfileUI() {
    AppLogger.info('ProfilePage: Rendering no profile UI');
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 24),
            Text(
              'Complete Your Profile',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.onBackground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please complete your merchant application to access your profile',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                AppLogger.step(1, 'ProfilePage: User clicked Complete Application button');
                // Navigate to onboarding
                Navigator.of(context).pushNamed('/onboarding');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.fluenceGold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Complete Application'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadDraftData() async {
    AppLogger.step(1, 'ProfilePage: Loading draft data from SharedPreferences');
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final businessName = prefs.getString('draft_business_name');
      final email = prefs.getString('draft_email');
      final phone = prefs.getString('draft_phone');
      final category = prefs.getString('draft_category');
      final profileImagePath = prefs.getString('draft_profile_image');
      
      AppLogger.info('ProfilePage: Draft data retrieved', data: {
        'hasBusinessName': businessName != null && businessName.isNotEmpty,
        'hasEmail': email != null && email.isNotEmpty,
        'hasPhone': phone != null && phone.isNotEmpty,
        'hasCategory': category != null && category.isNotEmpty,
        'hasProfileImage': profileImagePath != null && profileImagePath.isNotEmpty,
      });
      
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
          final file = File(profileImagePath);
          // Only set if file actually exists
          if (file.existsSync()) {
            _profileImage = file;
            AppLogger.info('ProfilePage: Profile image loaded from draft');
          } else {
            AppLogger.warning('ProfilePage: Draft profile image path exists but file not found');
          }
        }
      });
      
      if (_hasDraft) {
        AppLogger.success('ProfilePage: Draft data loaded successfully');
      } else {
        AppLogger.info('ProfilePage: No draft data found');
      }
    } catch (e, stackTrace) {
      AppLogger.error('ProfilePage: Error loading draft data', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<MerchantBloc, MerchantState>(
        listener: (context, state) {
          AppLogger.info('ProfilePage: BLoC state changed', data: {
            'state': state.runtimeType.toString(),
          });
          
          if (state is MerchantError) {
            AppLogger.error('ProfilePage: Showing error to user', data: {
              'message': state.message,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is MerchantProfileNotFound) {
            AppLogger.warning('ProfilePage: Profile not found - user needs to complete onboarding');
          } else if (state is MerchantProfileLoaded) {
            AppLogger.success('ProfilePage: Profile loaded from backend', data: {
              'businessName': state.profile.businessName,
              'businessType': state.profile.businessType,
              'hasEmail': state.profile.contactEmail != null,
              'hasPhone': state.profile.contactPhone != null,
            });
          }
        },
        builder: (context, state) {
          // Update local state from BLoC
          MerchantProfile? profile;
          MerchantAnalytics? analytics;
          
          if (state is MerchantProfileWithAnalytics) {
            profile = state.profile;
            analytics = state.analytics;
            _businessName = profile.businessName;
            _email = profile.contactEmail ?? _email;
            _phone = profile.contactPhone ?? _phone;
            _category = profile.businessType;
            _isLoading = false;
          } else if (state is MerchantProfileLoaded) {
            profile = state.profile;
            _businessName = profile.businessName;
            _email = profile.contactEmail ?? _email;
            _phone = profile.contactPhone ?? _phone;
            _category = profile.businessType;
            _isLoading = false;
          } else if (state is MerchantProfileNotFound) {
            _isLoading = false;
          } else if (state is MerchantLoading) {
            _isLoading = true;
          } else if (state is MerchantError) {
            _isLoading = false;
          }

          return SafeArea(
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
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.fluenceGold,
                            ),
                          )
                        : state is MerchantProfileNotFound
                            ? _buildNoProfileUI()
                            : RefreshIndicator(
                            onRefresh: () async {
                              AppLogger.step(1, 'ProfilePage: User triggered pull-to-refresh');
                              context.read<MerchantBloc>().add(const FetchProfileWithAnalytics());
                            },
                            color: AppColors.fluenceGold,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(top: 24, bottom: 100),
                              child: Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildProfileCard(),
                                      const SizedBox(height: 24),
                                      if (analytics?.performanceMetrics != null)
                                        _buildPerformanceMetricsCard(analytics!.performanceMetrics!),
                                      if (analytics?.performanceMetrics != null)
                                        const SizedBox(height: 24),
                                      if (analytics?.socialPerformance != null)
                                        _buildSocialPerformanceCard(analytics!.socialPerformance!),
                                      if (analytics?.socialPerformance != null)
                                        const SizedBox(height: 24),
                                      _buildStatsRow(profile: profile, analytics: analytics),
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
                ),
              ],
            ),
          );
        },
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
                  child: _profileImage != null && _profileImage!.existsSync()
                      ? Image.file(
                          _profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.white,
                              child: const Icon(Icons.person, size: 40, color: AppColors.grey600),
                            );
                          },
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

  Widget _buildStatsRow({MerchantProfile? profile, MerchantAnalytics? analytics}) {
    final totalSales = profile?.totalSales?.toString() ?? 
                      analytics?.performanceMetrics?.totalTransactions.toString() ?? 
                      '156';
    final rating = profile?.rating?.toStringAsFixed(1) ?? '4.8';
    final score = '92'; // TODO: Calculate from analytics
    
    return Row(
      children: [
        Expanded(child: _buildStatCard(totalSales, 'Total Sales')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(rating, 'Rating ⭐')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(score, 'Score 💯')),
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
    return InkWell(
      onTap: () {
        AppLogger.step(1, 'ProfilePage: User tapped menu item', data: {
          'menuItem': title,
        });
        // TODO: Navigate to respective pages
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title - Coming soon!'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
        ),
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          AppLogger.step(1, 'ProfilePage: User clicked sign out button');
          // Show sign out confirmation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () {
                    AppLogger.info('ProfilePage: User cancelled sign out');
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    AppLogger.step(2, 'ProfilePage: User confirmed sign out');
                    Navigator.pop(context);
                    await _handleSignOut();
                  },
                  child: const Text('Sign Out', style: TextStyle(color: AppColors.error)),
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

  Widget _buildPerformanceMetricsCard(MerchantPerformanceMetrics metrics) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.fluenceGold, AppColors.fluenceGold.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.fluenceGold.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Metrics',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Total Revenue',
                  '${metrics.totalRevenue.toStringAsFixed(0)} AED',
                  Icons.attach_money,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'Monthly Revenue',
                  '${metrics.monthlyRevenue.toStringAsFixed(0)} AED',
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Total Transactions',
                  metrics.totalTransactions.toString(),
                  Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'Avg Transaction',
                  '${metrics.averageTransactionValue.toStringAsFixed(0)} AED',
                  Icons.analytics,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  'Total Customers',
                  metrics.totalCustomers.toString(),
                  Icons.people,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricItem(
                  'Retention Rate',
                  '${metrics.customerRetentionRate.toStringAsFixed(1)}%',
                  Icons.loyalty,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.white.withOpacity(0.8),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialPerformanceCard(SocialMediaPerformance social) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.share,
                color: AppColors.fluenceGold,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Social Media Performance',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSocialStatCard(
                  social.totalPosts.toString(),
                  'Posts',
                  Icons.article,
                  const Color(0xFFE8F4FA),
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSocialStatCard(
                  social.totalLikes.toString(),
                  'Likes',
                  Icons.favorite,
                  const Color(0xFFFFE8E8),
                  AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSocialStatCard(
                  social.followers.toString(),
                  'Followers',
                  Icons.people,
                  const Color(0xFFE8F9F0),
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fluenceGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSocialMetric(
                  'Engagement',
                  '${social.engagementRate.toStringAsFixed(1)}%',
                  Icons.trending_up,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.grey300,
                ),
                _buildSocialMetric(
                  'Reach Growth',
                  '${social.reachGrowth.toStringAsFixed(1)}%',
                  Icons.show_chart,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.grey300,
                ),
                _buildSocialMetric(
                  'Total Engagements',
                  social.totalEngagements.toString(),
                  Icons.touch_app,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialStatCard(String value, String label, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.grey600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMetric(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.fluenceGold,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.grey600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
