import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProviderPerformanceDetailScreen extends StatelessWidget {
  final int providerId;
  final String providerName; // Add providerName
  const ProviderPerformanceDetailScreen({super.key, required this.providerId, required this.providerName});

  // Mock function for dispute details
  void _showDisputeDetail(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Dispute #${index + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Submitted Date'),
              subtitle: Text(
                '2025-12-${(index + 1).toString().padLeft(2, '0')}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Status'),
              subtitle: Text(index % 2 == 0 ? 'Pending' : 'Resolved'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Reason'),
              subtitle: const Text('Issue with job completion'),
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

  // Job Trend Chart (Line)
  Widget _jobTrendChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  Text('Week ${value.toInt() + 1}'),
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 5),
              FlSpot(1, 8),
              FlSpot(2, 6),
              FlSpot(3, 10),
              FlSpot(4, 9),
              FlSpot(5, 12),
            ],
            isCurved: true,
            barWidth: 3,
            color: Colors.blue,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  // Ratings Chart (Bar)
  Widget _ratingsBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 50,
        barGroups: [
          BarChartGroupData(
            x: 5,
            barRods: [BarChartRodData(toY: 20, color: Colors.green)],
          ),
          BarChartGroupData(
            x: 4,
            barRods: [BarChartRodData(toY: 15, color: Colors.blue)],
          ),
          BarChartGroupData(
            x: 3,
            barRods: [BarChartRodData(toY: 10, color: Colors.orange)],
          ),
          BarChartGroupData(
            x: 2,
            barRods: [BarChartRodData(toY: 4, color: Colors.red)],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: 1, color: Colors.grey)],
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}★'),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Header / Identity
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jane Smith',
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
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.green,
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
                              onPressed: () {},
                              icon: const Icon(Icons.message),
                              label: const Text('Message'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.flag),
                              label: const Text('Escalate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs content
            Expanded(
              child: TabBarView(
                children: [
                  // Summary Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        _metricCard('Total Jobs', '120', Icons.work),
                        _metricCard('Completed', '115', Icons.check_circle),
                        _metricCard('Cancellations', '5', Icons.cancel),
                        _metricCard('Disputes', '2', Icons.report),
                        _metricCard('Avg Rating', '4.8 / 5', Icons.star),
                      ],
                    ),
                  ),

                  // Job Trend Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _jobTrendChart(),
                  ),

                  // Ratings Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _ratingsBarChart(),
                  ),

                  // Disputes Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.report),
                          title: Text('Dispute #${index + 1}'),
                          subtitle: Text(
                            'Status: ${index % 2 == 0 ? 'Pending' : 'Resolved'}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showDisputeDetail(context, index),
                        ),
                      ),
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
}
