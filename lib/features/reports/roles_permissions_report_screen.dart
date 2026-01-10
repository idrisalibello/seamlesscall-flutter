import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class RolesPermissionsReportScreen extends StatelessWidget {
  const RolesPermissionsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Roles & Permissions Report',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Optional search/filter bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search roles...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.security, color: Colors.blue),
                      title: Text('Role #${index + 1}'),
                      subtitle: const Text(
                        'Permissions summary and access scope',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // Navigate to details & actions screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RoleDetailsScreen(roleId: index + 1),
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
      ),
    );
  }
}

// Details & Actions Screen
class RoleDetailsScreen extends StatelessWidget {
  final int roleId;
  const RoleDetailsScreen({super.key, required this.roleId});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Role #$roleId Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Text(
              'Permissions:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: List.generate(
                  5,
                  (index) => ListTile(
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    title: Text('Permission ${index + 1}'),
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                // Example action: edit role or modify permissions
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Role Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
