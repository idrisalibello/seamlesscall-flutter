import 'package:flutter/material.dart';

class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key});

  // Mock functions to show modal dialogs
  void _showLedgerDetail(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Transaction #${index + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(
                '2025-12-${(index + 1).toString().padLeft(2, '0')}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Amount'),
              subtitle: Text('₦${(index + 1) * 5000}'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Reference'),
              subtitle: const Text('REF12345XYZ'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Description'),
              subtitle: const Text('Payment for services rendered'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRefundDetail(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Refund #${index + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Submitted'),
              subtitle: Text(
                '2025-12-${(index + 1).toString().padLeft(2, '0')}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Status'),
              subtitle: Text(index % 2 == 0 ? 'Pending' : 'Approved'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Reason'),
              subtitle: const Text('Product not delivered / Service issue'),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Supporting Documents'),
              subtitle: const Text('Invoice.pdf, Screenshot.png'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (index % 2 == 0)
            TextButton(
              onPressed: () {
                // Approve action placeholder
                Navigator.pop(context);
              },
              child: const Text('Approve'),
            ),
          if (index % 2 == 0)
            TextButton(
              onPressed: () {
                // Reject action placeholder
                Navigator.pop(context);
              },
              child: const Text('Reject'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Customer Details'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Ledger'),
              Tab(text: 'Refunds'),
              Tab(text: 'Activity'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Header / Identity
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[100],
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    child: Icon(Icons.person, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Customer',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.message),
                              label: const Text('Message'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.flag),
                              label: const Text('Escalate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs content
            Expanded(
              child: TabBarView(
                children: [
                  // Overview Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Card(
                          child: ListTile(
                            title: const Text('Phone'),
                            subtitle: const Text('+234 801 234 5678'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Email'),
                            subtitle: const Text('johndoe@example.com'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Address'),
                            subtitle: const Text(
                              '12 Market Street, Lagos, Nigeria',
                            ),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Joined Date'),
                            subtitle: const Text('2024-01-15'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Total Orders'),
                            subtitle: const Text('42'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Total Spent'),
                            subtitle: const Text('₦1,250,000'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Refunds / Disputes'),
                            subtitle: const Text('3'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ledger Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: 10,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.receipt),
                          title: Text('Transaction #${index + 1}'),
                          subtitle: Text(
                            'Date: 2025-12-${(index + 1).toString().padLeft(2, '0')}',
                          ),
                          trailing: Text('₦${(index + 1) * 5000}'),
                          onTap: () => _showLedgerDetail(context, index),
                        ),
                      ),
                    ),
                  ),

                  // Refunds & Disputes Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.report),
                          title: Text('Refund #${index + 1}'),
                          subtitle: Text(
                            'Status: ${index % 2 == 0 ? 'Pending' : 'Approved'}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showRefundDetail(context, index),
                        ),
                      ),
                    ),
                  ),

                  // Activity Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: 8,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.history),
                          title: Text('Activity #${index + 1}'),
                          subtitle: Text(
                            '2025-12-${(index + 1).toString().padLeft(2, '0')} - Example activity log.',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          tooltip: 'Add Action',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
