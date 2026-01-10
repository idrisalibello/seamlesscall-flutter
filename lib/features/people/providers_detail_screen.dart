import 'package:flutter/material.dart';

class ProviderDetailScreen extends StatelessWidget {
  const ProviderDetailScreen({super.key});

  // Mock functions for modals
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
              subtitle: Text('₦${(index + 1) * 15000}'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Reference'),
              subtitle: const Text('PAY12345XYZ'),
            ),
            ListTile(
              leading: const Icon(Icons.description),
              title: const Text('Description'),
              subtitle: const Text('Payment for service completed'),
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

  void _showPayoutDetail(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Payout #${index + 1}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Payout Date'),
              subtitle: Text(
                '2025-12-${(index + 1).toString().padLeft(2, '0')}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Amount'),
              subtitle: Text('₦${(index + 1) * 50000}'),
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Status'),
              subtitle: Text(index % 2 == 0 ? 'Paid' : 'Pending'),
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
              subtitle: const Text('Service issue / Job dispute'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (index % 2 == 0)
            TextButton(onPressed: () {}, child: const Text('Approve')),
          if (index % 2 == 0)
            TextButton(onPressed: () {}, child: const Text('Reject')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Provider Details'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Earnings'),
              Tab(text: 'Ledger'),
              Tab(text: 'Payouts'),
              Tab(text: 'Performance'),
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
                          'Jane Smith',
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
                                color: Colors.purple[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Provider',
                                style: TextStyle(
                                  color: Colors.purple,
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
                  // Overview
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Card(
                          child: ListTile(
                            title: const Text('Phone'),
                            subtitle: const Text('+234 802 345 6789'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Email'),
                            subtitle: const Text('janesmith@example.com'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Service Type'),
                            subtitle: const Text('Cleaning / Delivery'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Joined Date'),
                            subtitle: const Text('2023-07-20'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Total Jobs Completed'),
                            subtitle: const Text('120'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Rating'),
                            subtitle: const Text('4.8 / 5.0'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Earnings Overview
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Card(
                          child: ListTile(
                            title: const Text('Total Earnings'),
                            subtitle: const Text('₦3,250,000'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Last Payout'),
                            subtitle: const Text('2025-12-10'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Job Breakdown'),
                            subtitle: const Text(
                              'Cleaning: 80 jobs\nDelivery: 40 jobs',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ledger
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
                          trailing: Text('₦${(index + 1) * 15000}'),
                          onTap: () => _showLedgerDetail(context, index),
                        ),
                      ),
                    ),
                  ),

                  // Payouts
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.payment),
                          title: Text('Payout #${index + 1}'),
                          subtitle: Text(
                            'Date: 2025-12-${(index + 1).toString().padLeft(2, '0')}',
                          ),
                          trailing: Text(index % 2 == 0 ? 'Paid' : 'Pending'),
                          onTap: () => _showPayoutDetail(context, index),
                        ),
                      ),
                    ),
                  ),

                  // Performance
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Card(
                          child: ListTile(
                            title: const Text('Jobs Completed'),
                            subtitle: const Text('120'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Cancellations'),
                            subtitle: const Text('5'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Disputes'),
                            subtitle: const Text('2'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Average Rating'),
                            subtitle: const Text('4.8 / 5.0'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Refunds & Disputes
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

                  // Activity
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
