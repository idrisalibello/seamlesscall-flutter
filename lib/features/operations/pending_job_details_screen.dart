import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import '../../common/widgets/main_layout.dart';

class PendingJobDetailsScreen extends ConsumerWidget {
  final int jobId;
  const PendingJobDetailsScreen({super.key, required this.jobId});

  void _showAssignJobDialog(
    BuildContext context,
    WidgetRef ref,
    int jobId,
  ) async {
    final availableProvidersAsync = ref.read(availableProvidersProvider);

    availableProvidersAsync.when(
      loading: () {
        // Show a loading indicator
        showDialog(
          context: context,
          builder: (ctx) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading providers...'),
              ],
            ),
          ),
        );
      },
      error: (err, stack) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load providers: $err')),
          );
        }
      },
      data: (providers) {
        Navigator.of(
          context,
        ).popUntil((route) => route.isCurrent); // Dismiss loading dialog
        int? selectedProviderId;

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Assign Job to Provider'),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (providers.isEmpty)
                      const Text('No available providers found.')
                    else
                      DropdownButtonFormField<int>(
                        value: selectedProviderId,
                        hint: const Text('Select Provider'),
                        items: providers.map((provider) {
                          return DropdownMenuItem<int>(
                            value: provider['id'] as int,
                            child: Text(provider['name'] as String),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProviderId = value;
                          });
                        },
                      ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedProviderId == null
                    ? null
                    : () async {
                        Navigator.of(ctx).pop(); // Dismiss dialog
                        try {
                          await ref
                              .read(operationsRepositoryProvider)
                              .assignJob(jobId, selectedProviderId!);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Job assigned successfully!'),
                              ),
                            );
                            ref.invalidate(pendingJobsProvider);
                            final role = ref.read(authProvider).user?.role;
                            if (role != null) {
                              ref.invalidate(
                                jobDetailsProvider((role: role, jobId: jobId)),
                              );
                            }

                            ref.invalidate(
                              jobDetailsProvider((
                                role: ref.read(authProvider).user!.role!,
                                jobId: jobId,
                              )),
                            );

                            Navigator.of(
                              context,
                            ).pop(); // Go back to pending jobs list
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to assign job: $e'),
                              ),
                            );
                          }
                        }
                      },
                child: const Text('Assign'),
              ),
            ],
          ),
        );
      },
    );
  }

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

      // Invalidate the providers to force a refresh.
      ref.invalidate(pendingJobsProvider);
      // Invalidate jobDetailsProvider for the current job to refresh its state.
      ref.invalidate(
        jobDetailsProvider((
          role: ref.read(authProvider).user!.role!,
          jobId: jobId,
        )),
      );

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
                          _showAssignJobDialog(context, ref, job.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Assign'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          _performJobAction(context, ref, job.id, 'escalated'),
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
