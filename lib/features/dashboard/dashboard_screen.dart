import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/dashboard/data/dashboard_repository.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late DashboardRepository _dashboardRepository;
  int? _customerCount;
  int? _providerCount;

  @override
  void initState() {
    super.initState();
    _dashboardRepository = DashboardRepository();
    _fetchDashboardStats();
  }

  Future<void> _fetchDashboardStats() async {
    log('[DashboardScreen] Fetching dashboard stats...');
    try {
      final customerCount = await _dashboardRepository.getTotalCustomers();
      final providerCount = await _dashboardRepository.getTotalProviders();
      if (mounted) {
        setState(() {
          _customerCount = customerCount;
          _providerCount = providerCount;
        });
        log('[DashboardScreen] Customer count updated: $_customerCount');
        log('[DashboardScreen] Provider count updated: $_providerCount');
      }
    } catch (e) {
      log('[DashboardScreen] Error fetching dashboard stats: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not fetch dashboard stats: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'User';

    // Adjust grid for screen size
    final crossAxisCount = width > 1200
        ? 4
        : width > 850
        ? 3
        : width > 600
        ? 2
        : 1;

    // Dashboard metrics
    final metrics = [
      DashboardMetric(
        icon: Icons.people,
        title: "Customers",
        count: _customerCount ?? 0,
        trend: 12,
      ),
      DashboardMetric(
        icon: Icons.handyman,
        title: "Handymen",
        count: _providerCount ?? 0,
        trend: 3,
      ),
      DashboardMetric(
        icon: Icons.work,
        title: "Active Jobs",
        count: 24,
        trend: -2,
      ),
      DashboardMetric(
        icon: Icons.task_alt,
        title: "Completed Jobs",
        count: 210,
        trend: 8,
      ),
      DashboardMetric(
        icon: Icons.pending_actions,
        title: "Pending Jobs",
        count: 12,
        trend: 1,
      ),
      DashboardMetric(
        icon: Icons.attach_money,
        title: "Earnings (NGN)",
        count: 152000,
        trend: 15,
      ),
      DashboardMetric(
        icon: Icons.bar_chart,
        title: "Monthly Earnings",
        count: 62000,
        trend: 6,
      ),
      DashboardMetric(
        icon: Icons.star_rate,
        title: "Satisfaction (%)",
        count: 92,
        trend: 2,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome, $userName!",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Overview of your platform metrics",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Parent scroll handles scrolling
            children: metrics
                .map(
                  (metric) => _dashboardCard(
                    metric: metric,
                    theme: theme,
                    screenWidth: width,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard({
    required DashboardMetric metric,
    required ThemeData theme,
    required double screenWidth,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final chartHeight = screenWidth < 600
        ? 25.0
        : 35.0; // responsive chart height

    // Determine if the card is loading
    final bool isLoading =
        (metric.title == "Customers" && _customerCount == null) ||
        (metric.title == "Handymen" && _providerCount == null);

    return GestureDetector(
      onTap: () {
        // Navigate to detailed page if needed
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF101822), const Color(0xFF0B1118)]
                : [const Color(0xFFFDFDFE), const Color(0xFFF5F6F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.45)
                  : Colors.grey.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(-3, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 18,
          ), // Reduced padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                metric.icon,
                size: 42,
                color: isDark
                    ? Colors.white.withOpacity(0.88)
                    : Colors.black87.withOpacity(0.75),
              ),
              const SizedBox(height: 12),
              Text(
                metric.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withOpacity(0.92)
                      : Colors.black.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isLoading ? "..." : "${metric.count}",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 4),
              _trendIndicator(metric.trend),
              const SizedBox(height: 8),
              _miniChart(height: chartHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trendIndicator(int trend) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
          size: 16,
          color: trend >= 0 ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(
          "${trend.abs()}%",
          style: TextStyle(
            fontSize: 14,
            color: trend >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _miniChart({double height = 35}) {
    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 1),
                FlSpot(1, 1.5),
                FlSpot(2, 1.4),
                FlSpot(3, 2),
                FlSpot(4, 1.8),
              ],
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
              ),
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardMetric {
  final IconData icon;
  final String title;
  final int count;
  final int trend; // positive or negative trend percentage

  DashboardMetric({
    required this.icon,
    required this.title,
    required this.count,
    required this.trend,
  });
}
