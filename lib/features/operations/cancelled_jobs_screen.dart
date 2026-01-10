import 'package:flutter/material.dart';
import 'cancelled_job_details_screen.dart';

class CancelledJobsScreen extends StatelessWidget {
  const CancelledJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock cancelled jobs data
    final jobs = List.generate(
      5,
      (i) => {
        'title': 'Job #${i + 1}',
        'customer': 'Customer ${i + 1}',
        'reason': 'Reason for cancellation ${i + 1}',
      },
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancelled / Failed Jobs',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.cancel),
                    title: Text(job['title']!),
                    subtitle: Text('${job['customer']} • ${job['reason']}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CancelledJobDetailsScreen(job: job),
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
    );
  }
}
