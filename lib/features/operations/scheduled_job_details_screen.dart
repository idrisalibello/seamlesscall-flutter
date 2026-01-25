import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';

class ScheduledJobDetailsScreen extends ConsumerWidget {
  final int jobId;
  const ScheduledJobDetailsScreen({super.key, required this.jobId});

  // Loading wrapper for async actions, consistent with pending screen
  Future<T> _readWithLoading<T>(
    BuildContext context,
    Future<T> Function() action,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      return await action();
    } finally {
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  // Handle simple status updates
  Future<void> _performJobAction(
    BuildContext context,
    WidgetRef ref,
    String status,
  ) async {
    try {
      await _readWithLoading(
        context,
        () => ref.read(operationsRepositoryProvider).updateJobStatus(jobId, status),
      );

      ref.invalidate(scheduledJobsProvider);
      ref.invalidate(jobDetailsProvider((role: 'Admin', jobId: jobId)));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job has been marked as $status.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update job status: $e')),
      );
    }
  }

  // Handle the 'Assign Technician' flow
  Future<void> _showAssignJobDialog(BuildContext context, WidgetRef ref) async {
    try {
      final providers = await _readWithLoading(
        context,
        () => ref.read(availableProvidersProvider.future),
      );

      if (!context.mounted) return;

      if (providers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No available providers found.')),
        );
        return;
      }

      int? selectedProviderId;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Assign Job to Provider'),
          content: StatefulBuilder(
            builder: (ctx, setState) => DropdownButtonFormField<int>(
              value: selectedProviderId,
              hint: const Text('Select Provider'),
              items: providers.map((p) => DropdownMenuItem<int>(
                value: p['id'] as int,
                child: Text(p['name'].toString()),
              )).toList(),
              onChanged: (value) => setState(() => selectedProviderId = value),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Assign')),
          ],
        ),
      );

      if (confirmed != true || selectedProviderId == null) return;

      await _readWithLoading(
        context,
        () => ref.read(operationsRepositoryProvider).assignJob(jobId, selectedProviderId!),
      );

      ref.invalidate(scheduledJobsProvider);
      ref.invalidate(jobDetailsProvider((role: 'Admin', jobId: jobId)));

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job assigned successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign job: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final role = ref.watch(authProvider).user?.role ?? 'Admin';
    final jobAsync = ref.watch(jobDetailsProvider((role: role, jobId: jobId)));

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade800,
        title: const Text('Scheduled Job Details'),
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
                      Text('Job Info', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                      const SizedBox(height: 8),
                      Text('Title: ${job.title}', style: const TextStyle(color: Colors.white)),
                      Text('Customer: ${job.customerName}', style: const TextStyle(color: Colors.white)),
                      Text('Scheduled: ${job.scheduledTime.toLocal()}', style: const TextStyle(color: Colors.white)),
                      Text('Status: ${job.status}', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.blueGrey.shade700,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Actions', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton(
                            onPressed: () => _performJobAction(context, ref, 'completed'),
                            child: const Text('Mark Completed'),
                          ),
                          ElevatedButton(
                            onPressed: () => _showAssignJobDialog(context, ref),
                            child: const Text('Assign Technician'),
                          ),
                          ElevatedButton(
                            onPressed: () => _performJobAction(context, ref, 'cancelled'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Cancel Job'),
                          ),
                        ],
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
