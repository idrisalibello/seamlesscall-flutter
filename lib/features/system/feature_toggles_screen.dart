import 'package:flutter/material.dart';
import 'package:seamlesscall/features/system/new_feature_screen.dart';
import 'feature_details_screen.dart'; // Make sure this exists

class FeatureTogglesScreen extends StatelessWidget {
  const FeatureTogglesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.toggle_on, size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Feature Toggles',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const NewFeatureScreen(), // new screen for creation
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Feature'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Manage which system features are enabled or disabled for users.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          // Feature list
          Expanded(
            child: ListView.separated(
              itemCount: 6, // placeholder
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      child: Icon(
                        Icons.toggle_on,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'Feature #${index + 1}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text('Enabled/Disabled'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FeatureDetailsScreen(
                            featureName: 'Feature #${index + 1}',
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
    );
  }
}
