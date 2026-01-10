import 'package:flutter/material.dart';
import 'package:seamlesscall/features/config/services_edit_screen.dart';
import 'package:seamlesscall/features/config/services_status_screen.dart';
import '../../common/widgets/main_layout.dart';

class ServicesDetailsScreen extends StatelessWidget {
  const ServicesDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final serviceId = args?['serviceId'] ?? 0;

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Service Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Service Category #$serviceId',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This service represents a category of operations available on the platform.',
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: const [
                        Icon(Icons.circle, size: 10, color: Colors.green),
                        SizedBox(width: 6),
                        Text('Active'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text('Actions', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionCard(
                  icon: Icons.edit,
                  label: 'Edit Service',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(
                          name: '/admin/config/services/edit',
                          arguments: {'serviceId': serviceId},
                        ),
                        builder: (_) => const ServicesEditScreen(),
                      ),
                    );
                  },
                ),
                _ActionCard(
                  icon: Icons.toggle_on,
                  label: 'Deactivate',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(
                          name: '/admin/config/services/status',
                          arguments: {'serviceId': serviceId},
                        ),
                        builder: (_) => const ServicesStatusScreen(),
                      ),
                    );
                  },
                ),

                _ActionCard(
                  icon: Icons.attach_money,
                  label: 'Pricing',
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/config/pricing');
                  },
                ),
                _ActionCard(
                  icon: Icons.public,
                  label: 'Coverage',
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/config/coverage');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
