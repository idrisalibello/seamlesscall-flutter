import 'package:flutter/material.dart';
import 'scheduled_job_details_screen.dart';

class ScheduledJobsScreen extends StatelessWidget {
  const ScheduledJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock scheduled jobs data
    final jobs = List.generate(
      8,
      (i) => {
        'title': 'Scheduled Job #${i + 1}',
        'customer': 'Customer ${i + 1}',
        'time': '${9 + i}:00 AM',
      },
    );

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled Jobs',
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
                    leading: const Icon(Icons.schedule),
                    title: Text(job['title']!),
                    subtitle: Text('${job['customer']} • ${job['time']}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Navigate to details screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScheduledJobDetailsScreen(job: job),
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
