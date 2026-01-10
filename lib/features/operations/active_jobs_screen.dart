import 'package:flutter/material.dart';
import 'package:seamlesscall/features/operations/active_job_details_screen.dart';

class ActiveJobsScreen extends StatelessWidget {
  const ActiveJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example mock data
    final jobs = [
      {
        'title': 'Fix Air Conditioner',
        'customer': 'John Doe',
        'time': '10:00 AM',
      },
      {'title': 'Plumbing Leak', 'customer': 'Jane Smith', 'time': '12:30 PM'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Jobs', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: jobs.length, // Placeholder
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Card(
                  child: ListTile(
                    title: Text(job['title']!),
                    subtitle: Text('${job['customer']} • ${job['time']}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ActiveJobDetailsScreen(job: job),
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
