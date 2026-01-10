import 'package:flutter/material.dart';
import 'package:seamlesscall/features/system/new_maintenance_screen.dart';
import 'maintenance_details_screen.dart'; // make sure this exists

class MaintenanceModeScreen extends StatelessWidget {
  const MaintenanceModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.build_circle_outlined,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Maintenance Mode',
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
                      builder: (_) => const NewMaintenanceScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Maintenance'),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Schedule and manage system maintenance periods.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          // Maintenance list
          Expanded(
            child: ListView.separated(
              itemCount: 3, // placeholder
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      child: Icon(
                        Icons.build_circle_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'Scheduled Maintenance #${index + 1}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text('Start & End Time'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MaintenanceDetailsScreen(
                            maintenanceTitle:
                                'Scheduled Maintenance #${index + 1}',
                          ),
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
    );
  }
}
