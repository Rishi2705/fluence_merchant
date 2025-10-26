import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../cubits/dashboard/dashboard_cubit.dart';
import '../../cubits/dashboard/dashboard_state.dart';
import '../../models/analytics_model.dart';
import '../../utils/logger.dart';

// Content-only widget for use in MainContainerPage
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  @override
  void initState() {
    super.initState();
    AppLogger.step(1, 'HomePage: Initializing home page');
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    AppLogger.step(2, 'HomePage: Loading dashboard data');
    try {
      await context.read<DashboardCubit>().loadDashboardData();
      AppLogger.success('HomePage: Dashboard data load initiated');
    } catch (e, stackTrace) {
      AppLogger.error('HomePage: Error loading dashboard data', error: e, stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // White header section
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hey Heisenberg! 👋',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Let\'s check what\'s poppin\'',
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
                        color: AppColors.fluenceGold,
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(
                              Icons.notifications,
                              color: AppColors.white,
                              size: 24,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Light blue background content
          Expanded(
            child: Container(
              color: const Color(0xFFF5F9FC),
              child: BlocConsumer<DashboardCubit, DashboardState>(
                listener: (context, state) {
                  AppLogger.info('HomePage: State changed', data: {
                    'state': state.runtimeType.toString(),
                  });

                  if (state is DashboardError) {
                    AppLogger.error('HomePage: Dashboard error state', data: {
                      'message': state.message,
                    });
                    
                    if (!state.message.contains('401') && !state.message.contains('Unauthorized')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  } else if (state is DashboardLoaded) {
                    AppLogger.success('HomePage: Dashboard data loaded', data: {
                      'todayTransactions': state.data.stats.todayTransactions,
                      'totalRevenue': state.data.stats.totalRevenue,
                      'recentActivitiesCount': state.data.recentActivities.length,
                    });
                  }
                },
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.fluenceGold,
                      ),
                    );
                  }

                  DashboardData? dashboardData;
                  if (state is DashboardLoaded) {
                    dashboardData = state.data;
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      AppLogger.step(1, 'HomePage: User triggered pull-to-refresh');
                      await context.read<DashboardCubit>().refresh();
                    },
                    color: AppColors.fluenceGold,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width - 32,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTopPerformersSection(dashboardData?.topCustomers),
                              const SizedBox(height: 24),
                              _buildStatsRow(dashboardData?.stats),
                              const SizedBox(height: 24),
                              _buildActiveCampaignCard(dashboardData?.balanceSummary, dashboardData?.activeCampaign),
                              const SizedBox(height: 24),
                              _buildLiveActivitySection(dashboardData?.recentActivities ?? []),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformersSection(List<TopCustomer>? topCustomers) {
    final customers = topCustomers ?? [];
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('⭐', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Top Performers',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
            Text(
              'View all',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.fluenceGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: customers.take(4).map((customer) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildPerformerAvatar(
                  customer.name,
                  customer.initial,
                  _getPerformerColor(customer.name),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getPerformerColor(String name) {
    // Assign colors based on name hash for consistency
    final hash = name.hashCode;
    final colors = [Colors.orange, Colors.grey.shade800, Colors.blue, Colors.green];
    return colors[hash.abs() % colors.length];
  }

  Widget _buildPerformerAvatar(String name, String initial, Color? color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color ?? AppColors.grey300,
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.grey600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(DashboardStats? stats) {
    final activeUsers = stats?.activeUsers.toString() ?? '0';
    final todayTransactions = stats?.todayTransactions.toString() ?? '0';
    final trending = stats != null && stats.trendingPercentage != 0
        ? '${stats.trendingPercentage > 0 ? '+' : ''}${stats.trendingPercentage.toStringAsFixed(1)}%'
        : '0%';

    return Row(
      children: [
        Expanded(child: _buildStatCard(activeUsers, 'Active Now')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(todayTransactions, 'Today')),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(trending, 'Trending')),
      ],
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCampaignCard(BalanceSummary? balance, ActiveCampaign? campaign) {
    final campaignName = campaign?.name ?? 'Winter Sale\n2024 ❄️';
    final daysLeft = campaign?.daysLeft ?? 9;
    final usedPercentage = campaign?.budgetPercentage ?? 0.6;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE5A620), Color(0xFFFDB913)],
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Campaign',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$daysLeft Days\nLeft',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            campaignName,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Available Balance',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: usedPercentage.clamp(0.0, 1.0),
                    backgroundColor: AppColors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(usedPercentage * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.fluenceGold,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Details',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.fluenceGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveActivitySection(List<RecentActivity> activities) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('⚡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  'Live Activity',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.onBackground,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.fluenceGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Live',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (activities.isEmpty)
          _buildEmptyActivityState()
        else
          ...activities.take(5).map((activity) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildActivityItem(
                activity.userName,
                activity.action,
                activity.timeAgo,
                '+${activity.amount.toStringAsFixed(0)} AED',
                activity.userInitial,
                _getAvatarColor(activity.type),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 12),
            Text(
              'No recent activity',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String type) {
    switch (type.toLowerCase()) {
      case 'earn':
      case 'earned':
        return Colors.green;
      case 'redeem':
      case 'redeemed':
        return Colors.orange;
      case 'purchase':
        return Colors.blue;
      default:
        return Colors.grey.shade800;
    }
  }

  Widget _buildActivityItem(String name, String action, String time, String amount, String initial, Color avatarColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.fluenceGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(Icons.shopping_bag, size: 10, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.onBackground,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• $time',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}