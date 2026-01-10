import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class EarningsDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> earning;

  const EarningsDetailsScreen({super.key, required this.earning});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 20),
            _section(
              title: 'Transaction Information',
              child: Column(
                children: [
                  _row('Reference', earning['reference']),
                  _row('Date', earning['date'].toString()),
                  _row('Status', earning['status']),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(
              title: 'Financial Breakdown',
              child: Column(
                children: [
                  _row('Gross Amount', '₦${earning['amount']}'),
                  _row('Platform Commission', '₦${_commission()}'),
                  _row('Provider Payout', '₦${_providerPayout()}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _section(
              title: 'Provider',
              child: Column(
                children: [
                  _row('Provider Name', earning['provider']),
                  _row(
                    'Payout Status',
                    earning['status'] == 'Completed' ? 'Paid' : 'Pending',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _actions(context),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Earning #${earning['reference']}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        TextButton.icon(
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            child,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final bool isPending = earning['status'] == 'Pending';

    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.receipt_long),
          label: const Text('View Ledger'),
          onPressed: () {
            // navigate to ledger filtered by reference
          },
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Export Receipt'),
          onPressed: () {},
        ),
        const SizedBox(width: 12),
        if (isPending)
          ElevatedButton.icon(
            icon: const Icon(Icons.report_problem),
            label: const Text('Raise Dispute'),
            onPressed: () {},
          ),
        if (isPending) const SizedBox(width: 12),
        if (isPending)
          ElevatedButton.icon(
            icon: const Icon(Icons.money),
            label: const Text('Release Payout'),
            onPressed: () {},
          ),
      ],
    );
  }

  double _commission() {
    return (earning['amount'] as double) * 0.15;
  }

  double _providerPayout() {
    return (earning['amount'] as double) * 0.85;
  }
}
