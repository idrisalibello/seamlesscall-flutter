import 'package:flutter/material.dart';

class NewFeatureScreen extends StatelessWidget {
  const NewFeatureScreen({super.key});

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
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'New Feature',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Enter feature details and assign users.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Feature Settings
                  Expanded(
                    flex: 3,
                    child: Card(
                      elevation: 0,
                      color: theme.colorScheme.surface,
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
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Feature Name',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                            ),
                            const SizedBox(height: 16),
                            _toggleOption(context, 'Enabled', true),
                            _toggleOption(context, 'Visible to Users', true),
                            _toggleOption(context, 'Notify on Change', false),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Assign Users
                  Expanded(
                    flex: 2,
                    child: Card(
                      elevation: 0,
                      color: theme.colorScheme.surface,
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
                              'Assign Users',
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

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: () {
                    // TODO: create feature logic
                  },
                  child: const Text('Create'),
                ),
              ],
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
