import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/operations/active_job_details_screen.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';

class ActiveJobsScreen extends ConsumerStatefulWidget {
  const ActiveJobsScreen({super.key});

  @override
  ConsumerState<ActiveJobsScreen> createState() => _ActiveJobsScreenState();
}

class _ActiveJobsScreenState extends ConsumerState<ActiveJobsScreen> {
  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to safely access providers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final role = ref.read(authProvider).user?.role;
      if (role != null) {
        ref.read(activeJobsProvider.notifier).fetchJobs(role);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeJobsAsync = ref.watch(activeJobsProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Jobs', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Expanded(
            child: activeJobsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (jobs) {
                if (jobs.isEmpty) {
                  return const Center(child: Text('No active jobs found.'));
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
                                  ActiveJobDetailsScreen(jobId: job.id),
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
