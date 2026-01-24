import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import '../../common/widgets/main_layout.dart';

class PendingJobDetailsScreen extends ConsumerWidget {
  final int jobId;

  const PendingJobDetailsScreen({super.key, required this.jobId});

  // Deterministic loading wrapper: shows spinner, awaits, then closes spinner.
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
      if (context.mounted) Navigator.of(context).pop(); // close loading dialog
    }
  }

  Future<String?> _askEscalationReason(BuildContext context) {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Escalate Job'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Escalation reason',
            hintText: 'Why are you escalating this job?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }

  String _formatTime(DateTime dt) {
    final t = dt.toLocal();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _showAssignJobDialog(
    BuildContext context,
    WidgetRef ref,
    int jobId,
  ) async {
    try {
      // 1) Fetch providers reliably (await provider future)
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

      // 2) Ask user to select provider
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Assign Job to Provider'),
            content: StatefulBuilder(
              builder: (ctx, setState) {
                return DropdownButtonFormField<int>(
                  value: selectedProviderId,
                  hint: const Text('Select Provider'),
                  items: providers.map((provider) {
                    final id = provider['id'];
                    final name = provider['name'];
                    return DropdownMenuItem<int>(
                      value: id is int ? id : int.tryParse(id.toString()),
                      child: Text(name?.toString() ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => selectedProviderId = value),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Assign'),
              ),
            ],
          );
        },
      );

      if (confirmed != true || selectedProviderId == null) return;

      // 3) Assign (with loading)
      await _readWithLoading(
        context,
        () => ref
            .read(operationsRepositoryProvider)
            .assignJob(jobId, selectedProviderId!),
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job assigned successfully!')),
      );

      // 4) Refresh relevant state (single, consistent invalidation)
      ref.invalidate(pendingJobsProvider);
      ref.invalidate(jobDetailsProvider((role: 'Admin', jobId: jobId)));

      // 5) Return to list
      Navigator.of(context).pop();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to assign job: $e')));
    }
  }

  Future<void> _performJobAction(
    BuildContext context,
    WidgetRef ref,
    int jobId,
    String status,
  ) async {
    try {
      await _readWithLoading(
        context,
        () => ref
            .read(operationsRepositoryProvider)
            .updateJobStatus(jobId, status),
      );

      ref.invalidate(pendingJobsProvider);
      ref.invalidate(jobDetailsProvider((role: 'Admin', jobId: jobId)));

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Job $status successfully!')));

      Navigator.of(context).pop(); // back to list
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to $status job: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role;

    if (role == null) {
      return const Scaffold(
        body: Center(child: Text('User role not found. Please log in again.')),
      );
    }

    final jobDetailsAsync = ref.watch(
      jobDetailsProvider((role: role, jobId: jobId)),
    );

    return MainLayout(
      child: jobDetailsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (job) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Customer: ${job.customerName}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                if (job.customerPhone != null)
                  Text(
                    'Customer Phone: ${job.customerPhone}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                Text(
                  'Scheduled Time: ${_formatDate(job.scheduledTime)} ${_formatTime(job.scheduledTime)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                if (job.description != null && job.description!.isNotEmpty)
                  Text(
                    'Description: ${job.description}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                const SizedBox(height: 20),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _showAssignJobDialog(context, ref, job.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Assign'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final reason = await _askEscalationReason(context);
                        if (reason == null) return;

                        if (reason.isEmpty) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Escalation reason is required'),
                              ),
                            );
                          }
                          return;
                        }

                        try {
                          await ref
                              .read(operationsRepositoryProvider)
                              .escalateJob(job.id, reason);

                          ref.invalidate(pendingJobsProvider);
                          ref.invalidate(
                            jobDetailsProvider((
                              role: ref.read(authProvider).user!.role!,
                              jobId: job.id,
                            )),
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Job escalated successfully!'),
                              ),
                            );
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to escalate job: $e'),
                              ),
                            );
                          }
                        }
                      },

                      child: const Text('Escalate'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _performJobAction(context, ref, job.id, 'cancelled'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Customer Info'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${job.customerName}'),
                                if (job.customerPhone != null)
                                  Text('Phone: ${job.customerPhone}'),
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
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Customer'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ListView(
                        children: [
                          Text(
                            'Job Details',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.description ??
                                'No additional details provided.',
                          ),
                          const SizedBox(height: 8),
                          Text('Status: ${job.status.toUpperCase()}'),
                          Text('Created: ${_formatDate(job.createdAt)}'),
                          if (job.assignedAt != null)
                            Text('Assigned: ${_formatDate(job.assignedAt!)}'),
                          if (job.completedAt != null)
                            Text('Completed: ${_formatDate(job.completedAt!)}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
