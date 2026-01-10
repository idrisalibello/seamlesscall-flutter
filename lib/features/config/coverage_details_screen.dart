import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class CoverageDetailsScreen extends StatelessWidget {
  final int coverageId;

  const CoverageDetailsScreen({super.key, required this.coverageId});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Coverage Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Coverage Area #$coverageId',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Region / City'),
                subtitle: const Text('Coverage description and boundaries'),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.public),
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
                  label: const Text('Edit'),
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
