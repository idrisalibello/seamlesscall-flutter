import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seamlesscall/features/people/presentation/provider_performance_providers.dart';
import 'package:seamlesscall/features/people/domain/provider_performance_models.dart';

class ProviderPerformanceDetailScreen extends ConsumerWidget {
  final int providerId;
  final String providerName;

  const ProviderPerformanceDetailScreen({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  String _fmtDate(DateTime dt) {
    final s = dt.toIso8601String();
    return s.contains('T') ? s.split('T').first : s;
  }

  Color _badgeBg(String status) {
    final s = status.toLowerCase();
    if (s.contains('approved') ||
        s.contains('active') ||
        s.contains('verified')) {
      return const Color(0xFFE8F5E9);
    }
    if (s.contains('pending')) return const Color(0xFFFFF3E0);
    if (s.contains('rejected') || s.contains('suspended'))
      return const Color(0xFFFFEBEE);
    return const Color(0xFFECEFF1);
  }

  Color _badgeFg(String status) {
    final s = status.toLowerCase();
    if (s.contains('approved') ||
        s.contains('active') ||
        s.contains('verified')) {
      return const Color(0xFF2E7D32);
    }
    if (s.contains('pending')) return const Color(0xFFEF6C00);
    if (s.contains('rejected') || s.contains('suspended'))
      return const Color(0xFFC62828);
    return const Color(0xFF37474F);
  }

  void _showDisputeDetail(BuildContext context, ProviderDispute d) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Dispute #${d.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Submitted Date'),
              subtitle: Text(_fmtDate(d.createdAt)),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Status'),
              subtitle: Text(d.status),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Reason'),
              subtitle: Text(d.reason),
            ),
            if (d.resolvedAt != null)
              ListTile(
                leading: const Icon(Icons.check_circle),
                title: const Text('Resolved At'),
                subtitle: Text(_fmtDate(d.resolvedAt!)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _jobTrendChart(List<JobTrendBucket> series) {
    if (series.isEmpty) {
      return const Center(child: Text('No trend data'));
    }

    final spots = <FlSpot>[];
    double maxY = 0;

    for (var i = 0; i < series.length; i++) {
      final y = series[i].completed.toDouble();
      spots.add(FlSpot(i.toDouble(), y));
      if (y > maxY) maxY = y;
    }

    final effectiveMaxY = maxY <= 0 ? 5 : (maxY + 2);

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= series.length)
                  return const SizedBox.shrink();
                return Text('W${idx + 1}');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: (series.length - 1).toDouble(),
        minY: 0,
        maxY: effectiveMaxY.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: Colors.blue,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _ratingsChart(ProviderRatingsDistribution ratings) {
    final dist = ratings.distribution;
    final total = dist.values.fold<int>(0, (a, b) => a + b);

    if (total == 0) {
      return const Center(child: Text('No ratings yet'));
    }

    double maxY = 0;
    final groups = <BarChartGroupData>[];

    for (var star = 1; star <= 5; star++) {
      final key = star.toString();
      final count = (dist[key] ?? 0).toDouble();
      if (count > maxY) maxY = count;

      groups.add(
        BarChartGroupData(
          x: star,
          barRods: [BarChartRodData(toY: count, color: Colors.blue)],
        ),
      );
    }

    final effectiveMaxY = maxY <= 0 ? 5 : (maxY + 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avg Rating: ${ratings.avgRating <= 0 ? "N/A" : ratings.avgRating.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: effectiveMaxY.toDouble(),
              barGroups: groups,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text('${value.toInt()}★'),
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // NOTE: These calls assume your providers are family<Record>.
    // If your provider signatures differ, paste provider_performance_providers.dart and I’ll adjust instantly.
    final detailAsync = ref.watch(
      providerPerformanceDetailProvider((
        providerId: providerId,
        from: null,
        to: null,
        bucket: 'week',
      )),
    );

    final ratingsAsync = ref.watch(
      providerRatingsProvider((providerId: providerId, from: null, to: null)),
    );

    final disputesAsync = ref.watch(
      providerDisputesProvider((
        providerId: providerId,
        from: null,
        to: null,
        page: 1,
        limit: 50,
      )),
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Provider Performance'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Summary'),
              Tab(text: 'Job Trend'),
              Tab(text: 'Ratings'),
              Tab(text: 'Disputes'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header / identity
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    child: Icon(Icons.person, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: detailAsync.when(
                      loading: () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const LinearProgressIndicator(),
                        ],
                      ),
                      error: (err, stack) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            providerName,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('Error loading provider: $err'),
                        ],
                      ),
                      data: (detail) {
                        final identity = detail.providerIdentity;
                        final statusText = identity.providerStatus;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              identity.name.isNotEmpty
                                  ? identity.name
                                  : providerName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Provider',
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _badgeBg(statusText),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      color: _badgeFg(statusText),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Messaging not implemented here.',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.message),
                                  label: const Text('Message'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Escalation action not implemented here.',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.flag),
                                  label: const Text('Escalate'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                children: [
                  // Summary
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: detailAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (detail) {
                        final m = detail.summaryMetrics;

                        final avgRating = ratingsAsync.maybeWhen(
                          data: (r) => r.avgRating,
                          orElse: () => m.avgRating,
                        );

                        final disputesCount = disputesAsync.maybeWhen(
                          data: (list) => list.length,
                          orElse: () => m.disputesCount,
                        );

                        final avgRatingText = avgRating <= 0
                            ? 'N/A'
                            : '${avgRating.toStringAsFixed(2)} / 5';

                        return GridView.count(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: [
                            _metricCard(
                              'Total Jobs',
                              '${m.totalJobs}',
                              Icons.work,
                            ),
                            _metricCard(
                              'Completed',
                              '${m.completedJobs}',
                              Icons.check_circle,
                            ),
                            _metricCard(
                              'Cancellations',
                              '${m.cancelledJobs}',
                              Icons.cancel,
                            ),
                            _metricCard(
                              'Disputes',
                              '$disputesCount',
                              Icons.report,
                            ),
                            _metricCard(
                              'Avg Rating',
                              avgRatingText,
                              Icons.star,
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Job Trend
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: detailAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (detail) => _jobTrendChart(detail.jobTrendSeries),
                    ),
                  ),

                  // Ratings
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ratingsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (ratings) => _ratingsChart(ratings),
                    ),
                  ),

                  // Disputes
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: disputesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (disputes) {
                        if (disputes.isEmpty)
                          return const Center(child: Text('No disputes'));

                        return ListView.separated(
                          itemCount: disputes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final d = disputes[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.report),
                                title: Text('Dispute #${d.id}'),
                                subtitle: Text(
                                  'Status: ${d.status} • ${_fmtDate(d.createdAt)}',
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () => _showDisputeDetail(context, d),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
