import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import 'package:seamlesscall/features/operations/cancelled_job_details_screen.dart';

class CancelledJobsScreen extends ConsumerWidget {
  const CancelledJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelledJobsAsync = ref.watch(cancelledJobsProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancelled / Failed Jobs',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: cancelledJobsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return const Center(child: Text('No cancelled jobs found.'));
                }

                return ListView.separated(
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.cancel, color: Colors.red),
                        title: Text(job.title),
                        subtitle: Text(
                          '${job.customerName} • Cancelled',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  CancelledJobDetailsScreen(jobId: job.id),
                            ),
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