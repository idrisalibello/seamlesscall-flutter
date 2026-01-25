import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';

class EscalationDetailsScreen extends ConsumerWidget {
  final int jobId;
  const EscalationDetailsScreen({super.key, required this.jobId});

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    final d = dt.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final jobAsync = ref.watch(jobDetailsProvider((role: 'Admin', jobId: jobId)));

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: jobAsync.when(
          data: (job) => Text(job.title),
          loading: () => const Text('Loading...'),
          error: (e, s) => const Text('Error'),
        ),
      ),
      body: jobAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (job) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: [
              Card(
                color: Colors.blueGrey.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Escalation Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Job Title: ${job.title}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Customer: ${job.customerName}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escalation Reason: ${job.escalationReason ?? 'Not specified'}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Escalated At: ${_formatDate(job.escalatedAt)}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Escalated By (User ID): ${job.escalatedBy?.toString() ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}