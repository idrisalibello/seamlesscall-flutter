import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/domain/job.dart';
import 'package:seamlesscall/features/operations/domain/dispatch_item.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart';

/// Unified, prioritized dispatch queue for Admin.
/// - Aggregates: escalated + pending + scheduled
/// - De-duplicates by job.id with precedence: escalated > pending > scheduled
/// - Scores deterministically and sorts by score (desc)
final dispatchQueueProvider = Provider<AsyncValue<List<DispatchItem>>>((ref) {
  final pendingJobsAsync = ref.watch(pendingJobsProvider);
  final scheduledJobsAsync = ref.watch(scheduledJobsProvider);
  final escalatedJobsAsync = ref.watch(escalatedJobsProvider);

  // If any provider is loading, dispatchQueueProvider is loading
  if (pendingJobsAsync is AsyncLoading ||
      scheduledJobsAsync is AsyncLoading ||
      escalatedJobsAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }

  // If any provider has an error, dispatchQueueProvider has an error
  if (pendingJobsAsync is AsyncError<List<Job>>) {
    return AsyncValue.error(
      pendingJobsAsync.error,
      pendingJobsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (scheduledJobsAsync is AsyncError<List<Job>>) {
    return AsyncValue.error(
      scheduledJobsAsync.error,
      scheduledJobsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (escalatedJobsAsync is AsyncError<List<Job>>) {
    return AsyncValue.error(
      escalatedJobsAsync.error,
      escalatedJobsAsync.stackTrace ?? StackTrace.current,
    );
  }

  // If all have data, combine and process
  if (pendingJobsAsync is AsyncData<List<Job>> &&
      scheduledJobsAsync is AsyncData<List<Job>> &&
      escalatedJobsAsync is AsyncData<List<Job>>) {
    final pendingJobs = pendingJobsAsync.value;
    final scheduledJobs = scheduledJobsAsync.value;
    final escalatedJobs = escalatedJobsAsync.value;

    // De-duplicate by job.id, prefer escalated > pending > scheduled
    final Map<int, Job> uniqueJobsMap = <int, Job>{};

    // Add escalated jobs first (highest priority)
    for (final job in escalatedJobs) {
      uniqueJobsMap[job.id] = job;
    }

    // Add pending jobs only if not already present (lower priority than escalated)
    for (final job in pendingJobs) {
      if (!uniqueJobsMap.containsKey(job.id)) {
        uniqueJobsMap[job.id] = job;
      }
    }

    // Add scheduled jobs only if not already present (lowest priority)
    for (final job in scheduledJobs) {
      if (!uniqueJobsMap.containsKey(job.id)) {
        uniqueJobsMap[job.id] = job;
      }
    }

    final List<DispatchItem> dispatchItems = <DispatchItem>[];

    for (final job in uniqueJobsMap.values) {
      var score = 0;
      var scoreReason = '';

      // Base scoring (keep as-is)
      if (job.status == 'escalated') {
        score += 1000;
        scoreReason += 'Escalated (+1000)';
      } else if (job.status == 'pending') {
        score += 500;
        if (scoreReason.isNotEmpty) scoreReason += ', ';
        scoreReason += 'Pending (+500)';
      } else if (job.status == 'scheduled') {
        score += 300;
        if (scoreReason.isNotEmpty) scoreReason += ', ';
        scoreReason += 'Scheduled (+300)';
      }

      // Bonus for unassigned jobs (keep as-is)
      if (job.providerId == null) {
        score += 200;
        if (scoreReason.isNotEmpty) scoreReason += ', ';
        scoreReason += 'Unassigned (+200)';
      }

      dispatchItems.add(
        DispatchItem(
          job: job,
          score: score,
          scoreReason: scoreReason.isEmpty ? 'Base Score' : scoreReason,
        ),
      );
    }

    // Sort by score descending
    dispatchItems.sort((a, b) => b.score.compareTo(a.score));

    return AsyncValue.data(dispatchItems);
  }

  // Fallback: if we reach here, return an empty stable value (not loading forever)
  return const AsyncValue.data(<DispatchItem>[]);
});
