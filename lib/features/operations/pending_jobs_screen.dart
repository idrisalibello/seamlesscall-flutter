import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import 'package:seamlesscall/features/operations/pending_job_details_screen.dart';

class PendingJobsScreen extends ConsumerStatefulWidget {
  const PendingJobsScreen({super.key});

  @override
  ConsumerState<PendingJobsScreen> createState() => _PendingJobsScreenState();
}

class _PendingJobsScreenState extends ConsumerState<PendingJobsScreen> {
  @override
  void initState() {
    super.initState();

    // Post-frame so ref is safe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(authProvider).user?.role;
      if (role == 'Admin') {
        ref.read(pendingJobsProvider.notifier).fetchJobs();
      }
    });
  }

  String _formatTime(DateTime dt) {
    final t = dt.toLocal();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(authProvider).user?.role;
    final pendingJobsAsync = ref.watch(pendingJobsProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pending Jobs', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          // Optional: show quick “not authorized” message
          if (role != 'Admin')
            const Expanded(
              child: Center(child: Text('Only Admin can view pending jobs.')),
            )
          else
            Expanded(
              child: pendingJobsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return const Center(child: Text('No pending jobs found.'));
                  }

                  return ListView.separated(
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = jobs[index];

                      return Card(
                        child: ListTile(
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
                                    PendingJobDetailsScreen(jobId: job.id),
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
