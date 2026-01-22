import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/system/application/roles_providers.dart';

class RoleDetailsScreen extends ConsumerWidget {
  final int roleId;
  final String roleName;

  const RoleDetailsScreen({
    super.key,
    required this.roleId,
    required this.roleName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(roleDetailsNotifierProvider(roleId));
    final notifier = ref.read(roleDetailsNotifierProvider(roleId).notifier);
    final isWide = MediaQuery.of(context).size.width >= 1000;

    Widget body;

    if (state.isLoading && state.allPermissions.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.errorMessage != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error: ${state.errorMessage}'),
        ),
      );
    } else {
      final grouped = state.groupedPermissions;
      body = Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: grouped.keys.length,
            itemBuilder: (context, index) {
              final groupName = grouped.keys.elementAt(index);
              final permissions = grouped[groupName]!;
              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Divider(height: 24),
                      ...permissions.map((p) {
                        // Capitalize first letter of each word for display
                        final displayPermissionName = p.permissionName
                            .replaceAll('-', ' ')
                            .split(' ')
                            .map((l) => l.isNotEmpty ? l[0].toUpperCase() + l.substring(1) : '')
                            .join(' ');
                            
                        return CheckboxListTile(
                          title: Text(displayPermissionName),
                          subtitle: Text(p.description ?? 'No description available.'),
                          value: state.selectedPermissionIds.contains(p.id),
                          onChanged: (_) => notifier.togglePermission(p.id),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          ),
          if (state.isLoading && state.allPermissions.isNotEmpty)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      );
    }

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text('Edit Role: $roleName'),
        backgroundColor: isWide ? theme.colorScheme.surface : null,
        elevation: isWide ? 0 : null,
        centerTitle: isWide ? false : null,
        automaticallyImplyLeading: !isWide,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final success = await notifier.saveChanges();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Permissions updated successfully!'
                                : 'Failed to update permissions.'),
                            backgroundColor: success ? Colors.green : theme.colorScheme.error,
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.save_alt_outlined),
              label: const Text('Save Changes'),
            ),
          ),
        ],
      ),
      body: body,
    );

    // For wide screens, the details view is embedded directly.
    // Return just the body, styled to look like an embedded card.
    if (isWide) {
      return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            scaffold.appBar!, // We reuse the AppBar as a header row
            Expanded(child: body),
          ],
        ),
      );
    }

    // For narrow screens, return the full scaffold for a standalone page.
    return scaffold;
  }
}