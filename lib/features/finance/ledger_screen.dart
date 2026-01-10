import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ledger', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: 12,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.book),
                    title: Text('Ledger Entry #${index + 1}'),
                    subtitle: const Text('Transaction Details • Amount'),
                    trailing: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      onPressed: () => _showDetails(context, index),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, int index) {
    final amount = 1000 + (index * 250);
    final date = DateTime.now().subtract(Duration(days: index));
    final status = index % 2 == 0 ? 'Completed' : 'Pending';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ledger Entry #${index + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Reference', 'LED-${1000 + index}'),
            _row('Details', 'Transaction Details for entry #${index + 1}'),
            _row('Amount', '₦${amount.toStringAsFixed(2)}'),
            _row('Date', date.toString().split(' ').first),
            _row('Status', status),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (status == 'Pending')
            ElevatedButton(
              onPressed: () {
                // Add logic to mark completed
              },
              child: const Text('Mark Completed'),
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
