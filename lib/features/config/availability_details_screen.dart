import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class AvailabilityDetailsScreen extends StatelessWidget {
  final int ruleId;

  const AvailabilityDetailsScreen({super.key, required this.ruleId});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Availability Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Rule #$ruleId',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Schedule'),
                subtitle: const Text('Start time / End time / Conditions'),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Status'),
                subtitle: const Text('Active'),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Rule'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.toggle_on),
                  label: const Text('Enable / Disable'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
