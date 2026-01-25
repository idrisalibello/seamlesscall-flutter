import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import 'package:seamlesscall/features/operations/escalations_details_screen.dart';

class EscalationsScreen extends ConsumerWidget {
  const EscalationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final escalatedJobsAsync = ref.watch(escalatedJobsProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Escalations', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: escalatedJobsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return const Center(child: Text('No escalated jobs found.'));
                }

                return ListView.separated(
                  itemCount: jobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.report_problem, color: Colors.orange),
                        title: Text(job.title),
                        subtitle: Text(
                          '${job.customerName} • Escalated',
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EscalationDetailsScreen(jobId: job.id),
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