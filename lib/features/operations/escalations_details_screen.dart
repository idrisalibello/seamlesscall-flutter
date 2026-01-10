import 'package:flutter/material.dart';

class EscalationDetailsScreen extends StatelessWidget {
  final Map<String, String> escalation;
  const EscalationDetailsScreen({super.key, required this.escalation});

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
        title: Text(escalation['title'] ?? 'Escalation Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            // Escalation Info Card
            Card(
              color: Colors.blueGrey.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escalation Info',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Title: ${escalation['title']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Job: ${escalation['job']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Customer: ${escalation['customer']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Reported By: ${escalation['reportedBy'] ?? 'N/A'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Priority: ${escalation['priority'] ?? 'Normal'}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Status: ${escalation['status'] ?? 'Pending'}',
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
                              _showMockDialog(context, 'Assign Manager'),
                          child: const Text('Assign Manager'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              _showMockDialog(context, 'Resolve Escalation'),
                          child: const Text('Resolve Escalation'),
                        ),
                        ElevatedButton(
                          onPressed: () => _showMockDialog(context, 'Add Note'),
                          child: const Text('Add Note'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              _showMockDialog(context, 'Notify Customer'),
                          child: const Text('Notify Customer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Escalation Timeline Card
            Card(
              color: Colors.blueGrey.shade700,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Escalation Timeline',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 5,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (context, index) => Text(
                        'Step ${index + 1}: Escalation update example',
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
