import 'package:flutter/material.dart';

class IntegrationDetailsScreen extends StatelessWidget {
  final String integrationName;

  const IntegrationDetailsScreen({super.key, required this.integrationName});

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
                  integrationName,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: edit integration
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                  ),
                  onPressed: () {
                    // TODO: delete integration (confirmation required)
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Integration details and configuration options.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Configuration / Status
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
                              'Status & Settings',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: ListView(
                                children: [
                                  _settingItem(
                                    context,
                                    title: 'Active',
                                    enabled: true,
                                  ),
                                  _settingItem(
                                    context,
                                    title: 'Auto Sync',
                                    enabled: false,
                                  ),
                                  _settingItem(
                                    context,
                                    title: 'Send Alerts',
                                    enabled: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Assigned Users / Linked Accounts
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
                              'Linked Users',
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
                                      // TODO: unlink user
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

  Widget _settingItem(
    BuildContext context, {
    required String title,
    required bool enabled,
  }) {
    return SwitchListTile(
      value: enabled,
      onChanged: (value) {
        // TODO: toggle setting
      },
      title: Text(title),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
