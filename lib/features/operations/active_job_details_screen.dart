import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import '../../common/widgets/main_layout.dart';

class ActiveJobDetailsScreen extends ConsumerWidget {
  final int jobId;
  const ActiveJobDetailsScreen({super.key, required this.jobId});

  void _performJobAction(
    BuildContext context,
    WidgetRef ref,
    int jobId,
    String status,
  ) async {
    try {
      await ref
          .read(operationsRepositoryProvider)
          .updateJobStatus(jobId, status);

      final role = ref.read(authProvider).user?.role ?? 'Provider';

      await ref.read(activeJobsProvider.notifier).fetchJobs(role);

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Job $status successfully!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to $status job: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role;
    if (role == null) {
      // Handle the case where the role is not available
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
                  'Scheduled Time: ${job.scheduledTime.toLocal().toIso8601String().split('T')[0]} ${job.scheduledTime.toLocal().toString().split(' ')[1].substring(0, 5)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (job.description != null && job.description!.isNotEmpty)
                  Text(
                    'Description: ${job.description}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                const SizedBox(height: 20),

                // Action Buttons
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          _performJobAction(context, ref, job.id, 'completed'),
                      child: const Text('Complete'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Implement assign job dialog/screen later if needed
                        // For now, it's just a placeholder
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Assign Job not yet implemented.'),
                          ),
                        );
                      },
                      child: const Text('Re-assign'),
                    ),
                    // ElevatedButton(
                    //   onPressed: () =>
                    //       _performJobAction(context, ref, job.id, 'escalated'),
                    //   child: const Text('Escalate'),
                    // ),
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
                        // Show customer contact info
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
                                // Add more customer info if available in Job model
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
                // Job Notes / Details section
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
                          // Add more detailed job info here if available
                          Text('Status: ${job.status.toUpperCase()}'),
                          Text(
                            'Created: ${job.createdAt.toLocal().toIso8601String().split('T')[0]}',
                          ),
                          if (job.assignedAt != null)
                            Text(
                              'Assigned: ${job.assignedAt!.toLocal().toIso8601String().split('T')[0]}',
                            ),
                          if (job.completedAt != null)
                            Text(
                              'Completed: ${job.completedAt!.toLocal().toIso8601String().split('T')[0]}',
                            ),
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
