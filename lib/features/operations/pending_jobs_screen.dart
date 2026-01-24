import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';
import 'package:seamlesscall/features/operations/pending_job_details_screen.dart'; // New details screen for pending jobs

class PendingJobsScreen extends ConsumerStatefulWidget {
  const PendingJobsScreen({super.key});

  @override
  ConsumerState<PendingJobsScreen> createState() => _PendingJobsScreenState();
}

class _PendingJobsScreenState extends ConsumerState<PendingJobsScreen> {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely access providers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(authProvider).user?.role;
      if (role == 'Admin') {
        ref.read(pendingJobsProvider.notifier).fetchJobs();
      } else {
        // Handle unauthorized access or show a message
        // For now, we'll just show an empty list
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingJobsAsync = ref.watch(pendingJobsProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pending Jobs', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
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
                          '${job.customerName} • ${job.scheduledTime.toLocal().toString().split(' ')[1]}',
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
