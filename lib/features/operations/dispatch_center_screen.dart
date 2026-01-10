import 'package:flutter/material.dart';
import 'dispatch_center_details_screen.dart';

class DispatchCenterScreen extends StatelessWidget {
  const DispatchCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final jobs = [
      {
        'title': 'Emergency Electrical Repair',
        'customer': 'John Doe',
        'time': '09:30 AM',
        'technician': 'Mike Adams',
        'priority': 'High',
      },
      {
        'title': 'Water Heater Installation',
        'customer': 'Jane Smith',
        'time': '12:00 PM',
        'technician': 'Unassigned',
        'priority': 'Normal',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dispatch Center',
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
                    leading: const Icon(Icons.local_shipping),
                    title: Text(job['title']!),
                    subtitle: Text('${job['customer']} • ${job['time']}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DispatchCenterDetailsScreen(job: job),
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
