import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
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
                                'Stats ',
                                style: AppTextStyles.headlineSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onBackground,
                                ),
                              ),
                              const Text('📊', style: TextStyle(fontSize: 24)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track your performance',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.fluenceGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: AppColors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Monthly',
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
                          _buildScoreCard(),
                          const SizedBox(height: 24),
                          _buildMetricsRow(),
                          const SizedBox(height: 24),
                          _buildEngagementTrend(),
                          const SizedBox(height: 24),
                          _buildActivityBreakdown(),
                          const SizedBox(height: 24),
                          _buildTopPerformers(),
                          const SizedBox(height: 24),
                          _buildAchievements(),
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

  Widget _buildScoreCard() {
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
        children: [
          Text(
            'Performance Score',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '92',
            style: AppTextStyles.headlineLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.white,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Outstanding! Keep it up! 🎯',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.9),
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
                    'Details',
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
                    'Improve Score',
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

  Widget _buildMetricsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            '85%',
            'Completion Rate',
            Icons.check_circle_outline,
            const Color(0xFFE8F4FA),
            AppColors.info,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            '73%',
            'Success Rate',
            Icons.trending_up,
            const Color(0xFFE8F9F0),
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
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
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementTrend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
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
                'Engagement Trend',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE5E5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down, size: 14, color: Color(0xFFFF4444)),
                    const SizedBox(width: 4),
                    Text(
                      '12%',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: const Color(0xFFFF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontally scrollable line chart
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1.5, // 1.5x width for scrolling
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: CustomPaint(
                      painter: LineChartPainter(),
                      size: Size(MediaQuery.of(context).size.width * 1.5, 120),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jan', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Feb', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Mar', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Apr', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('May', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Jun', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Jul', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Aug', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Sep', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Oct', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Nov', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                      Text('Dec', style: AppTextStyles.labelSmall.copyWith(color: AppColors.grey600, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityBreakdown() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Breakdown',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 20),
          // Centered donut chart
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: DonutChartPainter(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Tags below the chart - horizontal layout with dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: _buildCompactLegendItem('Cashback', '45%', const Color(0xFF4285F4))),
              Expanded(child: _buildCompactLegendItem('Budget', '30%', const Color(0xFF34A853))),
              Expanded(child: _buildCompactLegendItem('Campaigns', '25%', const Color(0xFFFBBC04))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLegendItem(String label, String percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.grey600,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14.0, top: 2),
          child: Text(
            percentage,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey600,
          ),
        ),
        const Spacer(),
        Text(
          percentage,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildTopPerformers() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Top Performers',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
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
        _buildPerformerItem('🥇', 'Tokyo', '8.1K', 'Points'),
        const SizedBox(height: 12),
        _buildPerformerItem('🥈', 'Joan Samantha', '8.2K', 'Points'),
        const SizedBox(height: 12),
        _buildPerformerItem('🥉', 'Mahmud', '7.9K', 'Points'),
        const SizedBox(height: 12),
        _buildPerformerItem('4️⃣', 'Michael', '7.5K', 'Points'),
      ],
    );
  }

  Widget _buildPerformerItem(String emoji, String name, String points, String label) {
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
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.grey200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 24, color: AppColors.grey600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.fluenceGold,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.grey600,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements 🏆',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildAchievementCard('🎯', 'Goal Crusher', 'Unlocked'),
            _buildAchievementCard('🎨', 'Ad Customize', 'Unlocked'),
            _buildAchievementCard('👍', 'Good Start!', 'Unlocked'),
            _buildAchievementCard('🎸', 'Reach Master', 'Unlocked'),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementCard(String emoji, String title, String status) {
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.fluenceGold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.fluenceGold
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.fluenceGold.withOpacity(0.3),
          AppColors.fluenceGold.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final gradientPath = Path();

    // Sample data points for 12 months
    final points = [
      Offset(size.width * 0.04, size.height * 0.6),   // Jan
      Offset(size.width * 0.13, size.height * 0.4),   // Feb
      Offset(size.width * 0.21, size.height * 0.3),   // Mar
      Offset(size.width * 0.29, size.height * 0.5),   // Apr
      Offset(size.width * 0.38, size.height * 0.2),   // May
      Offset(size.width * 0.46, size.height * 0.3),   // Jun
      Offset(size.width * 0.54, size.height * 0.45),  // Jul
      Offset(size.width * 0.63, size.height * 0.35),  // Aug
      Offset(size.width * 0.71, size.height * 0.25),  // Sep
      Offset(size.width * 0.79, size.height * 0.4),   // Oct
      Offset(size.width * 0.88, size.height * 0.3),   // Nov
      Offset(size.width * 0.96, size.height * 0.5),   // Dec
    ];

    path.moveTo(points[0].dx, points[0].dy);
    gradientPath.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
      gradientPath.lineTo(points[i].dx, points[i].dy);
    }

    // Complete gradient path
    gradientPath.lineTo(size.width, size.height);
    gradientPath.lineTo(0, size.height);
    gradientPath.close();

    canvas.drawPath(gradientPath, gradientPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for donut chart
class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 20.0;

    // Customers - Blue (45%)
    final paint1 = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.57, // Start from top
      2 * 3.14159 * 0.45,
      false,
      paint1,
    );

    // Engage - Green (30%)
    final paint2 = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.57 + 2 * 3.14159 * 0.45,
      2 * 3.14159 * 0.30,
      false,
      paint2,
    );

    // Campaigns - Yellow (25%)
    final paint3 = Paint()
      ..color = const Color(0xFFFBBC04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -1.57 + 2 * 3.14159 * 0.75,
      2 * 3.14159 * 0.25,
      false,
      paint3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}