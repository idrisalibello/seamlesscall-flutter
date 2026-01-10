import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';
import 'pricing_details_screen.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing & Fees',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'Manage pricing rules and service fees',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: 5, // placeholder
                itemBuilder: (context, index) {
                  final isActive = index != 3;

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
                          backgroundColor: Colors.blue.withOpacity(0.12),
                          child: const Icon(Icons.attach_money),
                        ),
                        title: Text(
                          'Pricing Rule #${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            const Text('Applies to: Service Category'),
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
                                name: '/admin/config/pricing/details',
                                arguments: {'pricingId': index + 1},
                              ),
                              builder: (_) => const PricingDetailsScreen(),
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
