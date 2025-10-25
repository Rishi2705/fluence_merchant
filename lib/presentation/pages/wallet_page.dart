import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100), // Space for bottom nav
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBalanceCard(),
                          const SizedBox(height: 24),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          _buildCashbackBanner(),
                          const SizedBox(height: 24),
                          _buildRecentTransactions(),
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

  Widget _buildBalanceCard() {
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
                '10,000',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'AED',
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
                      '6,000 AED',
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
                        '4,000 AED',
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
              value: 0.6,
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
        _buildActionButton(Icons.receipt_outlined, 'Request', const Color(0xFFE8F4FA)),
        _buildActionButton(Icons.send_outlined, 'Send', const Color(0xFFE8F4FA)),
        _buildActionButton(Icons.more_horiz, 'More', const Color(0xFFFFF8E1)),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bgColor) {
    return Column(
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
            color: icon == Icons.more_horiz ? AppColors.fluenceGold : AppColors.info,
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
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.white,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
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
        _buildTransactionItem(
          'Mdmando',
          'Cashback',
          '1hr ago',
          '+450\nAED',
          true,
          const Color(0xFFE8F4FA),
          Icons.arrow_downward,
        ),
        const SizedBox(height: 12),
        _buildTransactionItem(
          'Mike',
          '6hr ago',
          '',
          '-320\nAED',
          false,
          const Color(0xFFE8F4FA),
          Icons.arrow_upward,
        ),
        const SizedBox(height: 12),
        _buildTransactionItem(
          'Ana',
          'Cashback',
          '1d 1hr',
          '+275\nAED',
          true,
          const Color(0xFFE8F4FA),
          Icons.arrow_downward,
        ),
        const SizedBox(height: 12),
        _buildTransactionItem(
          'Budget Top-up',
          '3d 1hr',
          '',
          '-105\nAED',
          false,
          const Color(0xFFE8F4FA),
          Icons.arrow_upward,
        ),
        const SizedBox(height: 12),
        _buildTransactionItem(
          'Alex Kin',
          'Cashback',
          '1w 1hr',
          '+620\nAED',
          true,
          const Color(0xFFE8F4FA),
          Icons.arrow_downward,
        ),
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
            child: Icon(
              icon,
              color: AppColors.info,
              size: 20,
            ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
}