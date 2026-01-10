import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';

class ProviderPayoutDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> payout;

  const ProviderPayoutDetailsScreen({super.key, required this.payout});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payout Details',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            // Summary Cards
            Row(
              children: [
                _summaryCard('Amount', '₦${payout['amount']}'),
                const SizedBox(width: 16),
                _summaryCard('Status', payout['status']),
                const SizedBox(width: 16),
                _summaryCard('Date', payout['date']),
              ],
            ),

            const SizedBox(height: 24),

            // Details section
            Expanded(
              child: ListView(
                children: [
                  _detailRow('Payout Reference', payout['reference']),
                  _detailRow('Provider Name', payout['provider']),
                  _detailRow('Payment Method', payout['paymentMethod']),
                  _detailRow('Bank Account', payout['account']),
                  _detailRow('Notes', payout['notes'] ?? 'N/A'),
                  const SizedBox(height: 20),

                  // Collapsible Ledger
                  _LedgerSection(ledger: payout['ledger'] ?? []),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            if (payout['status'] == 'Pending') ...[
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Trigger release payout logic
                    },
                    icon: const Icon(Icons.send),
                    label: const Text('Release Payout'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // Trigger dispute / hold
                    },
                    icon: const Icon(Icons.block),
                    label: const Text('Hold / Dispute'),
                  ),
                ],
              ),
            ] else
              Text(
                'This payout has been completed.',
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value) {
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
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ---------------- Ledger Section ----------------

class _LedgerSection extends StatefulWidget {
  final List<Map<String, dynamic>> ledger;

  const _LedgerSection({required this.ledger});

  @override
  State<_LedgerSection> createState() => _LedgerSectionState();
}

class _LedgerSectionState extends State<_LedgerSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: _expanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        title: const Text('Ledger / Transaction History'),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Reference')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Type')),
                DataColumn(label: Text('Status')),
              ],
              rows: widget.ledger.map((entry) {
                return DataRow(
                  cells: [
                    DataCell(Text(entry['date'])),
                    DataCell(Text(entry['reference'])),
                    DataCell(Text('₦${entry['amount']}')),
                    DataCell(Text(entry['type'])),
                    DataCell(Text(entry['status'])),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
