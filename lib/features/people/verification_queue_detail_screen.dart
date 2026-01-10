import 'package:flutter/material.dart';

class VerificationQueueDetailScreen extends StatelessWidget {
  const VerificationQueueDetailScreen({super.key});

  // Mock functions for modals
  void _showDocumentPreview(BuildContext context, String docName) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(docName),
        content: Container(
          height: 300,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.picture_as_pdf, size: 100, color: Colors.grey),
          ),
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

  void _showActionConfirmation(BuildContext context, String actionType) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$actionType Confirmation'),
        content: Text('Are you sure you want to $actionType this provider?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Action placeholder
              Navigator.pop(context);
            },
            child: Text(actionType),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verification Detail'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Documents'),
              Tab(text: 'Profile Info'),
              Tab(text: 'History / Notes'),
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
                          'Michael Ade',
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
                                color: Colors.orange[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Provider',
                                style: TextStyle(
                                  color: Colors.orange,
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
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Pending',
                                style: TextStyle(
                                  color: Colors.red,
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
                              onPressed: () =>
                                  _showActionConfirmation(context, 'Escalate'),
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
                  // Documents Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text('Document #${index + 1}'),
                          subtitle: const Text('Uploaded on 2025-12-10'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => _showDocumentPreview(
                            context,
                            'Document #${index + 1}',
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Profile Info Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Card(
                          child: ListTile(
                            title: const Text('Phone'),
                            subtitle: const Text('+234 803 456 7890'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Email'),
                            subtitle: const Text('michael.ade@example.com'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Service Type'),
                            subtitle: const Text('Delivery / Cleaning'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Joined Date'),
                            subtitle: const Text('2024-03-12'),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            title: const Text('Jobs Completed'),
                            subtitle: const Text('35'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // History / Notes Tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView.separated(
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.history),
                          title: Text('Action #${index + 1}'),
                          subtitle: Text(
                            '2025-12-${(index + 1).toString().padLeft(2, '0')} - Example verification note.',
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
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'approve',
              onPressed: () => _showActionConfirmation(context, 'Approve'),
              tooltip: 'Approve',
              backgroundColor: Colors.green,
              child: const Icon(Icons.check),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: 'reject',
              onPressed: () => _showActionConfirmation(context, 'Reject'),
              tooltip: 'Reject',
              backgroundColor: Colors.red,
              child: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
