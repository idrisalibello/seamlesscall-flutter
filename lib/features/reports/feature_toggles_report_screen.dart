import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class FeatureTogglesReportScreen extends StatelessWidget {
  const FeatureTogglesReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feature Toggles Report',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search features...',
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
                  bool isActive = index % 2 == 0; // Example toggle status
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: Icon(
                        isActive ? Icons.check_circle : Icons.cancel,
                        color: isActive ? Colors.green : Colors.red,
                      ),
                      title: Text('Feature ${index + 1}'),
                      subtitle: Text(
                        'Status: ${isActive ? "ON" : "OFF"} • Last Updated: 12/12/2025',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FeatureDetailsScreen(
                              featureId: index + 1,
                              isActive: isActive,
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
class FeatureDetailsScreen extends StatelessWidget {
  final int featureId;
  final bool isActive;
  const FeatureDetailsScreen({
    super.key,
    required this.featureId,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feature #$featureId Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Feature Status: ${isActive ? "ON" : "OFF"}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Text(
              'Last Updated: 12/12/2025',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Toggle feature
                  },
                  icon: Icon(isActive ? Icons.toggle_off : Icons.toggle_on),
                  label: Text(isActive ? 'Disable Feature' : 'Enable Feature'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    // Edit feature action
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Feature'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Change Logs:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: List.generate(
                  3,
                  (index) => ListTile(
                    leading: const Icon(Icons.history),
                    title: Text('Change log ${index + 1}'),
                    subtitle: const Text('Details of change'),
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
