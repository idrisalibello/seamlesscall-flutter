import 'package:flutter/material.dart';

class RoleDetailsScreen extends StatelessWidget {
  const RoleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // 👇 This is the key change
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
                'Administrator',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit),
                label: const Text('Edit Role'),
              ),
              const SizedBox(width: 12),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                onPressed: () {},
                child: const Text('Delete'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Full system access. Use with caution.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Permissions matrix
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Permissions',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView(
                              children: [
                                _permissionGroup(
                                  context,
                                  title: 'Users',
                                  permissions: const [
                                    'View users',
                                    'Create users',
                                    'Edit users',
                                    'Delete users',
                                  ],
                                ),
                                _permissionGroup(
                                  context,
                                  title: 'System',
                                  permissions: const [
                                    'Toggle features',
                                    'Manage roles',
                                    'Maintenance mode',
                                  ],
                                ),
                                _permissionGroup(
                                  context,
                                  title: 'Finance',
                                  permissions: const [
                                    'View ledger',
                                    'Approve transactions',
                                  ],
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

                // Assigned users
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 0,
                    color: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
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
                                  onPressed: () {},
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () {},
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
    );
  }

  Widget _permissionGroup(
    BuildContext context, {
    required String title,
    required List<String> permissions,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
            (permission) => SwitchListTile(
              value: true,
              onChanged: (value) {},
              title: Text(permission),
              dense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
