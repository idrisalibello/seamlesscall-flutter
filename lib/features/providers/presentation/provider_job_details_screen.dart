import 'package:flutter/material.dart';
import '../data/mock_provider_service.dart';
import 'provider_job_progress_screen.dart';

class ProviderJobDetailsScreen extends StatelessWidget {
  final int jobId;
  const ProviderJobDetailsScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final job = MockProviderService.jobsToday.firstWhere(
      (j) => j['id'] == jobId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job['title'],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Customer: ${job['customer']}'),
            const SizedBox(height: 4),
            Text('Time: ${job['time']}'),
            const SizedBox(height: 4),
            Text('Status: ${job['status']}'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProviderJobProgressScreen(jobId: jobId),
                  ),
                );
              },
              child: const Text('Start / Track Job'),
            ),
          ],
        ),
      ),
    );
  }
}
