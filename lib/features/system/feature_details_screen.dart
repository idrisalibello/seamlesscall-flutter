import 'package:flutter/material.dart';
import 'package:seamlesscall/features/system/new_feature_screen.dart';

class FeatureDetailsScreen extends StatelessWidget {
  final String featureName;

  const FeatureDetailsScreen({super.key, required this.featureName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        color: theme.colorScheme.surfaceContainerLowest,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.toggle_on,
                  size: 28,
                  color: theme.colorScheme.primary,
                ),
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
              'Manage feature toggles and user assignments for "$featureName".',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature toggles
                  Expanded(
                    flex: 3,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _toggleOption(context, 'Enabled', true),
                            _toggleOption(context, 'Visible to Users', true),
                            _toggleOption(context, 'Notify on Change', false),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Assigned users
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assigned Users',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView.separated(
                                itemCount: 5,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) => ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text('User ${index + 1}'),
                                  subtitle: const Text('Active'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      // TODO: unassign user
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () {
                                // TODO: assign new user
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Assign User'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleOption(BuildContext context, String title, bool value) {
    return SwitchListTile(
      value: value,
      onChanged: (v) {
        // TODO: handle toggle
      },
      title: Text(title),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
