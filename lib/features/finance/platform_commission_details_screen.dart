import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class PlatformCommissionDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> commission;

  const PlatformCommissionDetailsScreen({super.key, required this.commission});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Column(
        children: [
          // Back AppBar
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Commission Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  Row(
                    children: [
                      _summaryCard('Amount', commission['amount'].toDouble()),
                      const SizedBox(width: 16),
                      _summaryCard(
                        'Status',
                        commission['status'].toString(),
                        color: commission['status'].toString() == 'Completed'
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 16),
                      _summaryCard('Date', commission['date'].toString()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Detailed info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _row('Reference', commission['reference'].toString()),
                          _row('Job ID', commission['jobId'].toString()),
                          _row('Source', commission['source'].toString()),
                          _row('Notes', commission['notes'].toString()),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Action buttons if pending
                  if (commission['status'].toString() == 'Pending')
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Approve commission logic
                          },
                          child: const Text('Mark Completed'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            // Raise issue / dispute logic
                          },
                          child: const Text('Raise Issue'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, dynamic value, {Color? color}) {
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
                value.toString(),
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
