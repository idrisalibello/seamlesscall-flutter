import 'package:flutter/material.dart';
import 'package:seamlesscall/features/system/new_integration_screen.dart';
import 'integration_details_screen.dart'; // make sure this exists

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});

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
                Icons.integration_instructions,
                size: 28,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Integrations',
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
                      builder: (_) =>
                          const NewIntegrationScreen(), // new screen for creation
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('New Integration'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Manage external system integrations and their statuses.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 20),

          // Integrations list
          Expanded(
            child: ListView.separated(
              itemCount: 8, // placeholder
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
                        Icons.integration_instructions,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      'Integration #${index + 1}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text('Status: Active/Inactive'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => IntegrationDetailsScreen(
                            integrationName: 'Integration #${index + 1}',
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
