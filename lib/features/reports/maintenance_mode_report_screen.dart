import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class MaintenanceModeReportScreen extends StatelessWidget {
  const MaintenanceModeReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Maintenance Mode Report',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search services...',
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
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  String status = index % 3 == 0
                      ? "Active"
                      : index % 3 == 1
                      ? "Maintenance"
                      : "Scheduled";
                  Color statusColor = status == "Active"
                      ? Colors.green
                      : status == "Maintenance"
                      ? Colors.red
                      : Colors.orange;

                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(Icons.build, color: statusColor),
                      title: Text('Service ${index + 1}'),
                      subtitle: Text(
                        'Status: $status • Last Downtime: 12/12/2025 • Next Schedule: 20/12/2025',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MaintenanceDetailsScreen(
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
class MaintenanceDetailsScreen extends StatelessWidget {
  final int serviceId;
  final String status;

  const MaintenanceDetailsScreen({
    super.key,
    required this.serviceId,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    bool inMaintenance = status == "Maintenance";

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service #$serviceId Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Current Status: $status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Last Downtime: 12/12/2025',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Next Scheduled Maintenance: 20/12/2025',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Toggle maintenance mode
                  },
                  icon: Icon(inMaintenance ? Icons.play_arrow : Icons.build),
                  label: Text(
                    inMaintenance ? 'End Maintenance' : 'Start Maintenance',
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    // Edit schedule
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Schedule'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Maintenance Logs:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: List.generate(
                  3,
                  (index) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('Maintenance log ${index + 1}'),
                    subtitle: const Text('Details of maintenance event'),
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
