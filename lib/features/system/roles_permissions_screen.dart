import 'package:flutter/material.dart';
import 'package:seamlesscall/features/system/new_role_screen.dart';
import 'role_details_screen.dart';

class RolesPermissionsScreen extends StatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  State<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends State<RolesPermissionsScreen> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 1000;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Roles & Permissions',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewRoleScreen()),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Role'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Manage access levels and system capabilities assigned to users.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: Row(
              children: [
                // Roles list (master)
                Expanded(
                  flex: 2,
                  child: ListView.separated(
                    itemCount: 10,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final isSelected = selectedIndex == index;

                      return Card(
                        elevation: 0,
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.05)
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.1),
                            child: Icon(
                              Icons.security,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            'Role #${index + 1}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text('12 permissions • 3 users'),
                          trailing: isWide
                              ? null
                              : const Icon(Icons.chevron_right),
                          onTap: () {
                            if (isWide) {
                              setState(() {
                                selectedIndex = index;
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => RoleDetailsScreen(
                                    // roleName: 'Role #${index + 1}',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                if (isWide) ...[
                  const SizedBox(width: 16),

                  // Details panel (detail)
                  Expanded(
                    flex: 3,
                    child: selectedIndex == null
                        ? _EmptyDetailsState(theme)
                        : RoleDetailsScreen(
                            //roleName: 'Role #${selectedIndex! + 1}',
                          ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDetailsState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyDetailsState(this.theme);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Center(
        child: Text(
          'Select a role to view details',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
