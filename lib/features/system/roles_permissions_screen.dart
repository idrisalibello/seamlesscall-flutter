import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/system/application/roles_providers.dart';
import 'package:seamlesscall/features/system/data/models/role.dart';
import 'package:seamlesscall/features/system/new_role_screen.dart';
import 'package:seamlesscall/features/system/role_details_screen.dart';


class RolesPermissionsScreen extends ConsumerStatefulWidget {
  const RolesPermissionsScreen({super.key});

  @override
  ConsumerState<RolesPermissionsScreen> createState() => _RolesPermissionsScreenState();
}

class _RolesPermissionsScreenState extends ConsumerState<RolesPermissionsScreen> {
  int? selectedRoleId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width >= 1000;
    final rolesAsync = ref.watch(rolesProvider);

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
                  // TODO: Use go_router for navigation
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewRoleScreen()),
                  ).then((success) {
                    if (success == true) {
                      ref.invalidate(rolesProvider);
                    }
                  });
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
                Expanded(
                  flex: 2,
                  child: rolesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                    data: (roles) {
                      if (roles.isEmpty) {
                        return const Center(child: Text('No roles found. Create one to begin.'));
                      }
                      return RefreshIndicator(
                        onRefresh: () => ref.refresh(rolesProvider.future),
                        child: ListView.separated(
                          itemCount: roles.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final role = roles[index];
                            final isSelected = selectedRoleId == role.id;
                            return _RoleListTile(
                              role: role,
                              isSelected: isSelected,
                              isWide: isWide,
                              onTap: () {
                                if (isWide) {
                                  setState(() {
                                    selectedRoleId = role.id;
                                  });
                                } else {
                                  // TODO: Use go_router for navigation
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RoleDetailsScreen(roleId: role.id, roleName: role.roleName),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                if (isWide) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: selectedRoleId == null
                        ? _EmptyDetailsState(theme)
                        : RoleDetailsScreen(
                            roleId: selectedRoleId!,
                            // Find role name from the list
                            roleName: rolesAsync.asData?.value.firstWhere((r) => r.id == selectedRoleId, orElse: () => const Role(id: 0, roleName: 'Unknown')).roleName ?? 'Unknown',
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

class _RoleListTile extends StatelessWidget {
  final Role role;
  final bool isSelected;
  final bool isWide;
  final VoidCallback onTap;

  const _RoleListTile({
    required this.role,
    required this.isSelected,
    required this.isWide,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: isSelected ? theme.colorScheme.primary.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(Icons.security, color: theme.colorScheme.primary),
        ),
        title: Text(
          role.roleName,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(role.description ?? 'No description'),
        trailing: isWide ? null : const Icon(Icons.chevron_right),
        onTap: onTap,
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