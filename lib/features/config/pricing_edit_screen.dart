import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class PricingEditScreen extends StatelessWidget {
  const PricingEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    final pricingId = args?['pricingId'] ?? 0;

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                  'Edit Pricing Rule',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: 'Pricing Rule #$pricingId',
                      decoration: const InputDecoration(labelText: 'Rule Name'),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: '2500',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount (₦)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: 'Flat Fee',
                      items: const [
                        DropdownMenuItem(
                          value: 'Flat Fee',
                          child: Text('Flat Fee'),
                        ),
                        DropdownMenuItem(
                          value: 'Percentage',
                          child: Text('Percentage'),
                        ),
                      ],
                      onChanged: (_) {},
                      decoration: const InputDecoration(
                        labelText: 'Charge Type',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
