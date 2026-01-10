import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class SystemHealthReportScreen extends StatelessWidget {
  const SystemHealthReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Health Report',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search system components...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  String status = index % 2 == 0 ? "Healthy" : "Warning";
                  Color statusColor = status == "Healthy"
                      ? Colors.green
                      : Colors.orange;

                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(Icons.computer, color: statusColor),
                      title: Text('Service ${index + 1}'),
                      subtitle: Text(
                        'Status: $status • CPU: ${20 + index * 10}% • RAM: ${30 + index * 5}%',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SystemHealthDetailsScreen(
                              serviceId: index + 1,
                              status: status,
                            ),
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
    );
  }
}

// Details & Actions Screen
class SystemHealthDetailsScreen extends StatelessWidget {
  final int serviceId;
  final String status;

  const SystemHealthDetailsScreen({
    super.key,
    required this.serviceId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    //bool isWarning = status != "Healthy";

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service #$serviceId Health Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Status: $status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'CPU Usage: 50%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'RAM Usage: 60%',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Uptime: 72 hours',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Restart service
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Restart Service'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    // Run diagnostics
                  },
                  icon: const Icon(Icons.analytics),
                  label: const Text('Run Diagnostics'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Recent Logs:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: List.generate(
                  4,
                  (index) => ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text('Log entry ${index + 1}'),
                    subtitle: const Text('Details about system event'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
