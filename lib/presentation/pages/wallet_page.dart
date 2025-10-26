import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/wallet/wallet_cubit.dart';
import '../../cubits/wallet/wallet_state.dart';
import '../../models/wallet_model.dart';
import '../../utils/logger.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  @override
  void initState() {
    super.initState();
    AppLogger.step(1, 'WalletPage: Initializing wallet page');
    // Load wallet data when page initializes (only if authenticated)
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    AppLogger.step(2, 'WalletPage: Loading wallet data');
    try {
      await context.read<WalletCubit>().loadWalletData();
      AppLogger.success('WalletPage: Wallet data load initiated');
    } catch (e, stackTrace) {
      AppLogger.error('WalletPage: Error loading wallet data', error: e, stackTrace: stackTrace);
      // Handle authentication errors silently - user needs to log in first
      if (mounted && e.toString().contains('401')) {
        AppLogger.warning('WalletPage: User not authenticated');
        // User not authenticated, show login prompt
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                          Row(
                            children: [
                              Text(
                                'Wallet ',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                ),
                              ),
                              const Text('💰', style: TextStyle(fontSize: 24)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Manage your funds',
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
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.grey600,
                          size: 24,
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
                child: RefreshIndicator(
                  onRefresh: () async {
                    AppLogger.step(1, 'WalletPage: User triggered pull-to-refresh');
                    context.read<WalletCubit>().refresh();
                  },
                  color: AppColors.fluenceGold,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      bottom: 100,
                    ), // Space for bottom nav
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: BlocConsumer<WalletCubit, WalletState>(
                          listener: (context, state) {
                            AppLogger.info('WalletPage: State changed', data: {
                              'state': state.runtimeType.toString(),
                            });
                            
                            if (state is WalletError) {
                              AppLogger.error('WalletPage: Wallet error state', data: {
                                'message': state.message,
                                'isAuthError': state.message.contains('401') || state.message.contains('Authorization'),
                              });
                              
                              // Don't show error for authentication issues
                              if (!state.message.contains('401') && 
                                  !state.message.contains('Authorization')) {
                                AppLogger.error('WalletPage: Showing error to user', data: {
                                  'message': state.message,
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              } else {
                                AppLogger.warning('WalletPage: Auth error - showing login prompt');
                              }
                            } else if (state is WalletDataLoaded) {
                              AppLogger.success('WalletPage: Wallet data loaded', data: {
                                'availableBalance': state.balance.availableBalance,
                                'pendingBalance': state.balance.pendingBalance,
                                'transactionCount': state.recentTransactions.length,
                              });
                            } else if (state is WalletBalanceLoaded) {
                              AppLogger.success('WalletPage: Balance loaded', data: {
                                'availableBalance': state.balance.availableBalance,
                                'pendingBalance': state.balance.pendingBalance,
                              });
                            }
                          },
                          builder: (context, state) {
                            if (state is WalletLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.fluenceGold,
                                ),
                              );
                            }

                            // Show login prompt if authentication error
                            if (state is WalletError && 
                                (state.message.contains('401') || 
                                 state.message.contains('Authorization'))) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.lock_outline,
                                        size: 80,
                                        color: AppColors.grey400,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Login Required',
                                        style: AppTextStyles.headlineSmall.copyWith(
                                          color: AppColors.onBackground,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Please log in to view your wallet',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.grey600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 32),
                                      ElevatedButton(
                                        onPressed: () {
                                          // Navigate to login page
                                          Navigator.of(context).pushReplacementNamed('/login');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.fluenceGold,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 48,
                                            vertical: 16,
                                          ),
                                        ),
                                        child: const Text('Login'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            WalletBalance? balance;
                            List<WalletTransaction> transactions = [];
                            List<BalanceHistoryPoint>? balanceHistory;
                            LifetimeWalletStats? lifetimeStats;
                            DailyTransactionSummary? dailySummary;

                            if (state is WalletDataLoaded) {
                              balance = state.balance;
                              transactions = state.recentTransactions;
                              balanceHistory = state.balanceHistory;
                              lifetimeStats = state.lifetimeStats;
                              dailySummary = state.dailySummary;
                            } else if (state is WalletBalanceLoaded) {
                              balance = state.balance;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildBalanceCard(balance),
                                const SizedBox(height: 24),
                                if (lifetimeStats != null) ...[
                                  _buildLifetimeStatsCard(lifetimeStats),
                                  const SizedBox(height: 24),
                                ],
                                if (balanceHistory != null && balanceHistory.isNotEmpty) ...[
                                  _buildBalanceHistoryCard(balanceHistory),
                                  const SizedBox(height: 24),
                                ],
                                if (dailySummary != null) ...[
                                  _buildDailySummaryCard(dailySummary),
                                  const SizedBox(height: 24),
                                ],
                                _buildQuickActions(),
                                const SizedBox(height: 24),
                                _buildCashbackBanner(),
                                const SizedBox(height: 24),
                                _buildRecentTransactions(transactions),
                              ],
                            );
                          },
                        ),
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

  Widget _buildBalanceCard(WalletBalance? balance) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💳 Total Balance',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                balance != null ? balance.totalBalance.toStringAsFixed(0) : '0',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Points',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '↓ Income',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      balance != null
                          ? '${balance.totalEarned.toStringAsFixed(0)} Points'
                          : '0 Points',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: AppColors.white.withOpacity(0.3),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '↑ Expenses',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        balance != null
                            ? '${balance.totalRedeemed.toStringAsFixed(0)} Points'
                            : '0 Points',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: balance != null && balance.totalEarned > 0
                  ? (balance.totalRedeemed / balance.totalEarned).clamp(
                      0.0,
                      1.0,
                    )
                  : 0.0,
              backgroundColor: AppColors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
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
                  child: Text(
                    '💸 Add Funds',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.fluenceGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: BorderSide(
                      color: AppColors.white.withOpacity(0.8),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    '💰 Transfer',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildActionButton(
          Icons.receipt_outlined,
          'Earn',
          const Color(0xFFE8F4FA),
          () => _showEarnPointsDialog(),
        ),
        _buildActionButton(
          Icons.send_outlined,
          'Redeem',
          const Color(0xFFE8F4FA),
          () => _showRedeemPointsDialog(),
        ),
        _buildActionButton(
          Icons.more_horiz,
          'More',
          const Color(0xFFFFF8E1),
          () => _showMoreOptions(),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: icon == Icons.more_horiz
                  ? AppColors.fluenceGold
                  : AppColors.info,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashbackBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFDB913), Color(0xFFE5A620)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎉 Cashback Active!',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Transfer for cashback from 5 AM tomorrow',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: AppColors.white, size: 16),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(List<WalletTransaction> transactions) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            Text(
              'See all',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.fluenceGold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 64,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your transaction history will appear here',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...transactions
              .map(
                (transaction) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTransactionItem(
                    transaction.description ?? 'Transaction',
                    transaction.type,
                    _formatTransactionDate(transaction.createdAt),
                    '${transaction.amount >= 0 ? '+' : ''}${transaction.amount.toStringAsFixed(0)}\nPoints',
                    transaction.amount >= 0,
                    const Color(0xFFE8F4FA),
                    transaction.amount >= 0
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                  ),
                ),
              )
              .toList(),
      ],
    );
  }

  Widget _buildTransactionItem(
    String name,
    String subtitle,
    String time,
    String amount,
    bool isPositive,
    Color iconBgColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.info, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onBackground,
                      ),
                    ),
                    if (subtitle == 'Cashback') ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.fluenceGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Cashback',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.fluenceGold,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  time.isNotEmpty ? time : subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            textAlign: TextAlign.right,
            style: AppTextStyles.titleSmall.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
              fontSize: 13,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTransactionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  void _showEarnPointsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Earn Points'),
        content: const Text(
          'Points are earned automatically when you make purchases or complete activities.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRedeemPointsDialog() {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Points to redeem',
                hintText: 'Enter amount',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What are you redeeming for?',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                context.read<WalletCubit>().redeemPoints(
                  amount: amount,
                  description: descriptionController.text.isEmpty
                      ? 'Points redemption'
                      : descriptionController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Transaction History'),
              onTap: () {
                Navigator.pop(context);
                context.read<WalletCubit>().loadTransactions();
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('Points Statistics'),
              onTap: () {
                Navigator.pop(context);
                context.read<WalletCubit>().loadPointsStatistics();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh'),
              onTap: () {
                Navigator.pop(context);
                context.read<WalletCubit>().refresh();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifetimeStatsCard(LifetimeWalletStats stats) {
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
              const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text('Lifetime Stats', style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatItem('Total Earned', '${stats.totalEarned.toStringAsFixed(0)} AED', Icons.trending_up)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatItem('Total Redeemed', '${stats.totalRedeemed.toStringAsFixed(0)} AED', Icons.trending_down)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildStatItem('Net Earnings', '${stats.netEarnings.toStringAsFixed(0)} AED', Icons.account_balance_wallet)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatItem('Savings Rate', '${stats.savingsRate.toStringAsFixed(1)}%', Icons.savings)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
            const SizedBox(width: 4),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.white.withOpacity(0.9))),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBalanceHistoryCard(List<BalanceHistoryPoint> history) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.show_chart, color: AppColors.fluenceGold, size: 24),
              const SizedBox(width: 8),
              Text('Balance History (30 Days)', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(height: 120, child: _buildSimpleChart(history)),
        ],
      ),
    );
  }

  Widget _buildSimpleChart(List<BalanceHistoryPoint> history) {
    if (history.isEmpty) {
      return Center(child: Text('No history data', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500)));
    }
    final maxBalance = history.map((p) => p.balance).reduce((a, b) => a > b ? a : b);
    final minBalance = history.map((p) => p.balance).reduce((a, b) => a < b ? a : b);
    final range = maxBalance - minBalance;
    return Container(
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        painter: _BalanceChartPainter(history, minBalance, range),
        child: Container(),
      ),
    );
  }

  Widget _buildDailySummaryCard(DailyTransactionSummary summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.today, color: AppColors.fluenceGold, size: 24),
              const SizedBox(width: 8),
              Text('Today\'s Summary', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Earned', '${summary.totalEarned.toStringAsFixed(0)} AED', Icons.add_circle, Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem('Redeemed', '${summary.totalRedeemed.toStringAsFixed(0)} AED', Icons.remove_circle, Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Transactions', '${summary.transactionCount}', Icons.receipt, AppColors.fluenceGold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem('Net Change', '${summary.netChange.toStringAsFixed(0)} AED', Icons.trending_up, summary.netChange >= 0 ? Colors.green : Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600)),
        ],
      ),
    );
  }
}

class _BalanceChartPainter extends CustomPainter {
  final List<BalanceHistoryPoint> history;
  final double minBalance;
  final double range;

  _BalanceChartPainter(this.history, this.minBalance, this.range);

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;
    final paint = Paint()..color = AppColors.fluenceGold..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path();
    for (int i = 0; i < history.length; i++) {
      final x = (i / (history.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (history[i].balance - minBalance) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
    final pointPaint = Paint()..color = AppColors.fluenceGold..style = PaintingStyle.fill;
    for (int i = 0; i < history.length; i++) {
      final x = (i / (history.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (history[i].balance - minBalance) / range : 0.5;
      final y = size.height - (normalizedValue * size.height);
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
