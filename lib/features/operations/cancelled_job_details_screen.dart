import 'package:flutter/material.dart';

class CancelledJobDetailsScreen extends StatelessWidget {
  final Map<String, String> job;
  const CancelledJobDetailsScreen({super.key, required this.job});

  void _showMockDialog(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(action),
        content: Text('This is a mock for $action functionality.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: Text(job['title'] ?? 'Cancelled Job Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Job Info Card
            Card(
              color: Colors.blueGrey.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Job Info',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Title: ${job['title']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Customer: ${job['customer']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Scheduled Time: ${job['time']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Cancelled Reason: ${job['reason'] ?? 'Not specified'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions Card
            Card(
              color: Colors.blueGrey.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton(
                          onPressed: () =>
                              _showMockDialog(context, 'Reassign Job'),
                          child: const Text('Reassign Job'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              _showMockDialog(context, 'Reschedule'),
                          child: const Text('Reschedule'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              _showMockDialog(context, 'View History'),
                          child: const Text('View History'),
                        ),
                        ElevatedButton(
                          onPressed: () => _showMockDialog(context, 'Add Note'),
                          child: const Text('Add Note'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status / Timeline Card
            Card(
              color: Colors.blueGrey.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Timeline',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 3,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) => Text(
                        'Step ${index + 1}: Example status update',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
