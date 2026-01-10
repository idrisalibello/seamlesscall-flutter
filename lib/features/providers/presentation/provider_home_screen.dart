import 'package:flutter/material.dart';
import '../../../common/widgets/main_layout.dart';
import '../data/mock_provider_service.dart';
import 'provider_job_details_screen.dart';
import 'provider_earnings_history_screen.dart';

class ProviderHomeScreen extends StatelessWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobsToday = MockProviderService.jobsToday;
    final earningsToday = jobsToday.fold<int>(
      0,
      (sum, job) => sum + 2000,
    ); // Mock earnings per job

    return MainLayout(
      child: Scaffold(
        appBar: AppBar(title: const Text('Provider Home')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Earnings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: Text('Today\'s Earnings'),
                  subtitle: Text('₦$earningsToday'),
                  trailing: IconButton(
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProviderEarningsHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Jobs Today', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: jobsToday.length,
                  itemBuilder: (context, index) {
                    final job = jobsToday[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(job['title']),
                        subtitle: Text('${job['customer']} • ${job['time']}'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProviderJobDetailsScreen(jobId: job['id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
