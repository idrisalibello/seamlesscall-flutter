import 'package:flutter/material.dart';
import 'package:seamlesscall/features/finance/provider_payout_details_screen.dart';
import '../../common/widgets/main_layout.dart';

class ProviderPayoutsScreen extends StatelessWidget {
  const ProviderPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Provider Payouts', style: theme.textTheme.headlineSmall),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Filter'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Summary strip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  _SummaryItem(label: 'Total Payouts', value: '₦12,450,000'),
                  SizedBox(width: 32),
                  _SummaryItem(label: 'Pending', value: '₦1,120,000'),
                  SizedBox(width: 32),
                  _SummaryItem(label: 'Completed', value: '₦11,330,000'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // List
            Expanded(
              child: ListView.separated(
                itemCount: 8,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        child: const Icon(Icons.account_balance_wallet),
                      ),
                      title: Text(
                        'Payout #${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Provider Name • ₦250,000 • 12 Sep 2025',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 14),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProviderPayoutDetailsScreen(
                              payout: {
                                'reference': 'PAYOUT-${index + 1}',
                                'provider': 'Provider ${index + 1}',
                                'amount': 250000,
                                'status': index % 3 == 0
                                    ? 'Pending'
                                    : 'Completed',
                                'date': '12 Sep 2025',
                                'paymentMethod': 'Bank Transfer',
                                'account': '1234567890',
                                'notes': 'Monthly payout',
                              },
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
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
