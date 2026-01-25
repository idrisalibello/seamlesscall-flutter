import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import 'package:seamlesscall/features/operations/scheduled_job_details_screen.dart';

class ScheduledJobsScreen extends ConsumerWidget {
  const ScheduledJobsScreen({super.key});

  String _formatTime(DateTime dt) {
    final t = dt.toLocal();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authProvider).user?.role;
    final scheduledJobsAsync = ref.watch(scheduledJobsProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheduled Jobs',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          if (role != 'Admin')
            const Expanded(
              child: Center(child: Text('Only Admin can view scheduled jobs.')),
            )
          else
            Expanded(
              child: scheduledJobsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return const Center(child: Text('No scheduled jobs found.'));
                  }

                  return ListView.separated(
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.schedule),
                          title: Text(job.title),
                          subtitle: Text(
                            '${job.customerName} • ${_formatTime(job.scheduledTime)}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ScheduledJobDetailsScreen(jobId: job.id),
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