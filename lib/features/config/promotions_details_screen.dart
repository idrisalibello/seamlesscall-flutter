import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class PromotionsDetailsScreen extends StatelessWidget {
  final int promotionId;

  const PromotionsDetailsScreen({super.key, required this.promotionId});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Promotion Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              'Promotion #$promotionId',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 24),

            Card(
              child: ListTile(
                leading: const Icon(Icons.campaign),
                title: const Text('Description'),
                subtitle: const Text('Full description of promotion'),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Validity'),
                subtitle: const Text('Start date - End date'),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Promotion'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.toggle_on),
                  label: const Text('Enable / Disable'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
