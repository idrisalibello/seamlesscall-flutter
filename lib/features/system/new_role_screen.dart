import 'package:flutter/material.dart';

class NewRoleScreen extends StatelessWidget {
  const NewRoleScreen({super.key});

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
                  'New Role',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              'Define role details and assign permissions/users.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Role details & permissions
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
                              'Role Details',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Role Name',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                            ),
                            const SizedBox(height: 16),
                            _permissionGroup(context, 'Users', [
                              'View users',
                              'Create users',
                              'Edit users',
                              'Delete users',
                            ]),
                            _permissionGroup(context, 'System', [
                              'Manage roles',
                              'Toggle features',
                              'Maintenance mode',
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Assign users
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
                    // TODO: create role logic
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

  Widget _permissionGroup(
    BuildContext context,
    String title,
    List<String> permissions,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...permissions.map(
            (perm) => SwitchListTile(
              value: true,
              onChanged: (v) {
                // TODO: toggle permission
              },
              title: Text(perm),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
