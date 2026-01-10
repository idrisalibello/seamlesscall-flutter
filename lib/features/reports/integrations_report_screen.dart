import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class IntegrationsReportScreen extends StatelessWidget {
  const IntegrationsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Integrations Report',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search integrations...',
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
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(
                        Icons.extension,
                        color: Colors.orange,
                      ),
                      title: Text('Integration ${index + 1}'),
                      subtitle: Row(
                        children: const [
                          Text(
                            'Status: Active • Last Sync: 12/12/2025 • Errors: 0',
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IntegrationDetailsScreen(
                              integrationId: index + 1,
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
class IntegrationDetailsScreen extends StatelessWidget {
  final int integrationId;
  const IntegrationDetailsScreen({super.key, required this.integrationId});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Integration #$integrationId Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Connection Status: Active',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Last Sync: 12/12/2025 14:00',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text('Error Logs:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: List.generate(
                  3,
                  (index) => ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: Text('Error log ${index + 1}'),
                    subtitle: const Text('Details of the error'),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Sync Now action
                  },
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    // Edit integration action
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Integration'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
