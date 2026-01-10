import 'package:flutter/material.dart';

class MaintenanceDetailsScreen extends StatelessWidget {
  final String maintenanceTitle;

  const MaintenanceDetailsScreen({super.key, required this.maintenanceTitle});

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
                  maintenanceTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: edit maintenance
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
                    // TODO: delete maintenance
                  },
                  child: const Text('Delete'),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Scheduled system maintenance. Configure times and assign affected modules.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Schedule info & settings
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
                              'Maintenance Settings',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Start Time',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'End Time',
                              ),
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              value: true,
                              onChanged: (v) {
                                // TODO: toggle active status
                              },
                              title: const Text('Active'),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Affected modules / assigned users
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
                              'Affected Modules',
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
                                    child: Icon(Icons.settings),
                                  ),
                                  title: Text('Module ${index + 1}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      // TODO: unassign module
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () {
                                // TODO: assign module
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Assign Module'),
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
}
