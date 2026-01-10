import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';
import 'refund_dispute_details_screen.dart';

class RefundsDisputesScreen extends StatelessWidget {
  const RefundsDisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final disputes = List.generate(5, (index) {
      return {
        'reference': 'REF-${1000 + index}',
        'customer': 'Customer ${index + 1}',
        'issue': 'Issue details for dispute ${index + 1}',
        'amount': 500.0 + index * 150,
        'status': index % 2 == 0 ? 'Pending' : 'Resolved',
        'date': DateTime.now().subtract(Duration(days: index)),
      };
    });

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Refunds & Disputes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: disputes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final dispute = disputes[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.report_problem),
                      title: Text('Dispute #${index + 1}'),
                      subtitle: Text(
                        '${dispute['customer']} • ${dispute['issue']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dispute['status'].toString(),
                            style: TextStyle(
                              color: dispute['status'] == 'Resolved'
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
                            builder: (_) =>
                                RefundDisputeDetailsScreen(dispute: dispute),
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
