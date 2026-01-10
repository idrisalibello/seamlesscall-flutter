import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';
import 'platform_commission_details_screen.dart';

class PlatformCommissionsScreen extends StatelessWidget {
  const PlatformCommissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final commissions = List.generate(10, (index) {
      return {
        'reference': 'COM-${1000 + index}',
        'jobId': 'JOB-${2000 + index}',
        'amount': 5000 + index * 250,
        'date': '12 Sep 2025',
        'status': index % 2 == 0 ? 'Pending' : 'Completed',
        'source': 'Provider ${index + 1}',
        'notes': 'Commission from completed job',
      };
    });

    double total = commissions.fold(
      0,
      (sum, c) => sum + (c['amount'] as int),
    ); // total amount
    double completed = commissions
        .where((c) => c['status'] == 'Completed')
        .fold(0, (sum, c) => sum + (c['amount'] as int));
    double pending = commissions
        .where((c) => c['status'] == 'Pending')
        .fold(0, (sum, c) => sum + (c['amount'] as int));

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Platform Commissions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            // Summary cards
            Row(
              children: [
                _summaryCard('Total', total),
                const SizedBox(width: 16),
                _summaryCard('Completed', completed),
                const SizedBox(width: 16),
                _summaryCard('Pending', pending),
              ],
            ),

            const SizedBox(height: 20),

            // Commission list
            Expanded(
              child: ListView.separated(
                itemCount: commissions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final commission = commissions[index];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        child: const Icon(Icons.percent),
                      ),
                      title: Text(
                        'Commission Entry #${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${commission['jobId']} • ₦${commission['amount']} • ${commission['source']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            commission['status'].toString(),
                            style: TextStyle(
                              color: commission['status'] == 'Completed'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios, size: 14),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlatformCommissionDetailsScreen(
                              commission: commission,
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

  Widget _summaryCard(String label, double value, {Color? color}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                '₦${value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
