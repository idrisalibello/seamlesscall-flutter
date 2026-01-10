import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class RefundDisputeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> dispute;

  const RefundDisputeDetailsScreen({super.key, required this.dispute});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Column(
        children: [
          // Back navigation row
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Dispute Details',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.grey[200]),
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
                  _summaryCard('Reference', dispute['reference'].toString()),
                  const SizedBox(height: 12),
                  _summaryCard('Customer', dispute['customer'].toString()),
                  const SizedBox(height: 12),
                  _summaryCard('Issue', dispute['issue'].toString()),
                  const SizedBox(height: 12),
                  _summaryCard('Amount', '₦${dispute['amount']}'),
                  const SizedBox(height: 12),
                  _summaryCard(
                    'Status',
                    dispute['status'].toString(),
                    color: dispute['status'] == 'Resolved'
                        ? Colors.greenAccent[400]
                        : Colors.orangeAccent[400],
                  ),
                  const SizedBox(height: 12),
                  _summaryCard(
                    'Date',
                    dispute['date'].toString(),
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),

                  if (dispute['status'].toString() == 'Pending')
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Resolve dispute logic
                          },
                          child: const Text('Mark Resolved'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () {
                            // Contact customer logic
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.amber[200],
                          ),
                          child: const Text('Contact Customer'),
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

  Widget _summaryCard(String label, String value, {Color? color}) {
    return Card(
      color: Colors.grey[850], // softer dark card, distinct from background
      elevation: 2,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400], // muted label
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.grey[200], // light value text
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
