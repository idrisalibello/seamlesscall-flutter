import 'package:flutter/material.dart';
import '../data/mock_provider_service.dart';

class ProviderJobProgressScreen extends StatefulWidget {
  final int jobId;
  const ProviderJobProgressScreen({super.key, required this.jobId});

  @override
  State<ProviderJobProgressScreen> createState() =>
      _ProviderJobProgressScreenState();
}

class _ProviderJobProgressScreenState extends State<ProviderJobProgressScreen> {
  bool taskCompleted = false;

  @override
  Widget build(BuildContext context) {
    final job = MockProviderService.jobsToday.firstWhere(
      (j) => j['id'] == widget.jobId,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Job Progress')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              job['title'],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: taskCompleted,
              onChanged: (val) => setState(() => taskCompleted = val!),
              title: const Text('Task Completed'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: taskCompleted ? () => Navigator.pop(context) : null,
              child: const Text('Finish Job'),
            ),
          ],
        ),
      ),
    );
  }
}
