import 'package:flutter/material.dart';
import 'package:seamlesscall/features/config/services_details_screen.dart';
import '../../common/widgets/main_layout.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Services & Categories',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Manage the core services offered on the platform',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: 6, // placeholder
                itemBuilder: (context, index) {
                  final isActive = index.isEven;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? Colors.green.withOpacity(0.15)
                              : Colors.grey.withOpacity(0.15),
                          child: Icon(
                            Icons.miscellaneous_services,
                            color: isActive ? Colors.green : Colors.grey,
                          ),
                        ),
                        title: Text(
                          'Service Category #${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            const Text('Description of service'),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: isActive ? Colors.green : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(
                                name: '/admin/config/services/details',
                                arguments: {'serviceId': index + 1},
                              ),
                              builder: (_) => const ServicesDetailsScreen(),
                            ),
                          );
                        },
                      ),
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
