import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class ActiveJobDetailsScreen extends StatelessWidget {
  final Map<String, String> job;
  const ActiveJobDetailsScreen({super.key, required this.job});

  void _showMockDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(action),
        content: Text('This is a mock interface for "$action" action.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job['title'] ?? '',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Customer: ${job['customer']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Scheduled Time: ${job['time']}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => _showMockDialog(context, 'Complete Job'),
                  child: const Text('Complete'),
                ),
                ElevatedButton(
                  onPressed: () => _showMockDialog(context, 'Assign Job'),
                  child: const Text('Assign'),
                ),
                ElevatedButton(
                  onPressed: () => _showMockDialog(context, 'Escalate Job'),
                  child: const Text('Escalate'),
                ),
                ElevatedButton(
                  onPressed: () => _showMockDialog(context, 'Cancel Job'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _showMockDialog(context, 'Customer Info'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Customer'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Mock notes / details section
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: ListView(
                    children: [
                      Text(
                        'Job Notes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Ensure proper tools are available.\n'
                        '• Check previous service records.\n'
                        '• Contact customer before arrival.',
                      ),
                    ],
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
