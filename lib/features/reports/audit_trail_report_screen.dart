import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class AuditTrailReportScreen extends StatelessWidget {
  const AuditTrailReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Trail Report',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search audit entries...',
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
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(
                        Icons.history,
                        color: Colors.blueGrey,
                      ),
                      title: Text('User${index + 1} performed an action'),
                      subtitle: Text(
                        'Module: Module${index + 1} • Status: Success • 12/12/2025 14:0$index',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AuditTrailDetailsScreen(auditId: index + 1),
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
class AuditTrailDetailsScreen extends StatelessWidget {
  final int auditId;
  const AuditTrailDetailsScreen({super.key, required this.auditId});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Audit Entry #$auditId Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'User: User$auditId',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Action: Edited record',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Module: Module$auditId',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Status: Success',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Timestamp: 12/12/2025 14:0$auditId',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Example action: mark as reviewed
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Reviewed'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    // Example action: export entry
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Export Entry'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Full Details:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: List.generate(
                  3,
                  (index) => ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text('Detail line ${index + 1}'),
                    subtitle: const Text('Additional info about the action'),
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
