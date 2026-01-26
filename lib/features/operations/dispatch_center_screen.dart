import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:seamlesscall/features/operations/application/dispatch_providers.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart'; // <-- REQUIRED for pending/scheduled/escalated providers
import 'package:seamlesscall/features/operations/pending_job_details_screen.dart';
import 'package:seamlesscall/features/operations/scheduled_job_details_screen.dart';
import 'package:seamlesscall/features/operations/escalations_details_screen.dart';
import 'package:seamlesscall/features/operations/presentation/widgets/provider_picker.dart';

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
                  return const Center(
                    child: Text('No jobs in dispatch queue.'),
                  );
                }

                return ListView.separated(
                  itemCount: dispatchItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final dispatchItem = dispatchItems[index];
                    final job = dispatchItem.job;

                    final jobId =
                        job.id; // may be nullable depending on your model

                    final title = (job.title ?? '').trim();
                    final serviceName = (job.serviceName ?? '').trim();
                    final titleText = title.isNotEmpty
                        ? title
                        : (serviceName.isNotEmpty
                              ? serviceName
                              : 'Job #${jobId ?? "-"}');

                    final statusText = (job.status ?? '')
                        .toString()
                        .toUpperCase();

                    final assignedText = job.providerId != null
                        ? 'Assigned (${job.providerName ?? job.providerId})'
                        : 'Unassigned';

                    final subtitleText =
                        '$statusText • $assignedText (${dispatchItem.score} - ${dispatchItem.scoreReason})';

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping),
                        title: Text(titleText),
                        subtitle: Text(subtitleText),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.assignment_ind),
                              tooltip: 'Assign Job',
                              onPressed:
                                  (job.providerId != null || jobId == null)
                                  ? null
                                  : () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => ProviderPicker(
                                          jobId: jobId,
                                          onAssigned: () {
                                            // Dispatch queue recomputes automatically if base providers refresh,
                                            // but invalidating is fine as long as provider types allow it.
                                            ref.invalidate(pendingJobsProvider);
                                            ref.invalidate(
                                              scheduledJobsProvider,
                                            );
                                            ref.invalidate(
                                              escalatedJobsProvider,
                                            );
                                            ref.invalidate(
                                              dispatchQueueProvider,
                                            );
                                          },
                                        ),
                                      );
                                    },
                            ),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                        onTap: () {
                          if (jobId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Job ID is missing. Cannot open details.',
                                ),
                              ),
                            );
                            return;
                          }

                          Widget screen;
                          switch (job.status) {
                            case 'pending':
                              screen = PendingJobDetailsScreen(jobId: jobId);
                              break;
                            case 'scheduled':
                              screen = ScheduledJobDetailsScreen(jobId: jobId);
                              break;
                            case 'escalated':
                              // IMPORTANT: use the correct class name from escalations_details_screen.dart
                              // If your actual class is named differently, rename this line accordingly.
                              screen = EscalationDetailsScreen(jobId: jobId);
                              break;
                            default:
                              // Keep it non-destructive: show dialog instead of navigating to AlertDialog as a "screen"
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(
                                    'Unknown Job Status: ${job.status}',
                                  ),
                                  content: const Text(
                                    'No details screen is mapped for this status yet.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              return;
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
