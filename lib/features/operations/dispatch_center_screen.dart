import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/application/dispatch_providers.dart'; // Import the new provider
import 'package:seamlesscall/features/operations/pending_job_details_screen.dart'; // For navigation
import 'package:seamlesscall/features/operations/scheduled_job_details_screen.dart'; // For navigation
import 'package:seamlesscall/features/operations/escalations_details_screen.dart'; // For navigation
import 'package:seamlesscall/features/operations/presentation/widgets/provider_picker.dart'; // NEW import for ProviderPicker

class DispatchCenterScreen extends ConsumerWidget {
  const DispatchCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dispatchQueueAsync = ref.watch(dispatchQueueProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dispatch Center',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: dispatchQueueAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (dispatchItems) {
                if (dispatchItems.isEmpty) {
                  return const Center(child: Text('No jobs in dispatch queue.'));
                }

                return ListView.separated(
                  itemCount: dispatchItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final dispatchItem = dispatchItems[index];
                    final job = dispatchItem.job;

                    final titleText = job.title.isNotEmpty ? job.title : job.serviceName;
                    final subtitleText =
                        '${job.status.toUpperCase()} • ${job.providerId != null ? 'Assigned (${job.providerName ?? job.providerId})' : 'Unassigned'}';

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping),
                        title: Text(titleText),
                        subtitle: Text('$subtitleText (${dispatchItem.score} - ${dispatchItem.scoreReason})'),
                        trailing: Row( // Changed trailing to a Row to include the assign button
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.assignment_ind),
                              tooltip: 'Assign Job',
                              onPressed: job.providerId != null
                                  ? null // Disable if already assigned
                                  : () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => ProviderPicker(
                                          jobId: job.id,
                                          onAssigned: () {
                                            ref.invalidate(dispatchQueueProvider); // Refresh the main dispatch list
                                            // Invalidate individual job list providers to ensure consistency
                                            ref.invalidate(pendingJobsProvider);
                                            ref.invalidate(scheduledJobsProvider);
                                            ref.invalidate(escalatedJobsProvider);
                                          },
                                        ),
                                      );
                                    },
                            ),
                            const Icon(Icons.arrow_forward_ios), // Keep existing forward arrow
                          ],
                        ),
                        onTap: () {
                          Widget screen;
                          switch (job.status) {
                            case 'pending':
                              screen = PendingJobDetailsScreen(jobId: job.id);
                              break;
                            case 'scheduled':
                              screen = ScheduledJobDetailsScreen(jobId: job.id);
                              break;
                            case 'escalated':
                              screen = EscalationDetailsScreen(jobId: job.id);
                              break;
                            default:
                              screen = AlertDialog(title: Text('Unknown Job Status: ${job.status}'));
                              break;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => screen),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
