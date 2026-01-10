import 'package:flutter/material.dart';

class DispatchCenterDetailsScreen extends StatelessWidget {
  final Map<String, String> job;
  const DispatchCenterDetailsScreen({super.key, required this.job});

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
        title: Text(job['title'] ?? 'Dispatch Center Details'),
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
                      'Time: ${job['time']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Assigned Technician: ${job['technician'] ?? 'Not assigned'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Priority: ${job['priority'] ?? 'Normal'}',
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
                              _showMockDialog(context, 'Assign Technician'),
                          child: const Text('Assign Technician'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              _showMockDialog(context, 'Mark as Completed'),
                          child: const Text('Mark as Completed'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              _showMockDialog(context, 'Send Message'),
                          child: const Text('Send Message'),
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

            // Dispatch Timeline Card
            Card(
              color: Colors.blueGrey.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dispatch Timeline',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 4,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) => Text(
                        'Step ${index + 1}: Dispatch update example',
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
