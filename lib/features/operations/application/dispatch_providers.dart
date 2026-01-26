import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/domain/job.dart';
import 'package:seamlesscall/features/operations/domain/dispatch_item.dart';
import 'package:seamlesscall/features/operations/application/operations_providers.dart'; // To read existing job providers

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
  if (pendingJobsAsync is AsyncError) {
    return AsyncValue.error(pendingJobsAsync.error!, pendingJobsAsync.stackTrace);
  }
  if (scheduledJobsAsync is AsyncError) {
    return AsyncValue.error(scheduledJobsAsync.error!, scheduledJobsAsync.stackTrace);
  }
  if (escalatedJobsAsync is AsyncError) {
    return AsyncValue.error(escalatedJobsAsync.error!, escalatedJobsAsync.stackTrace);
  }

  // If all have data, combine and process
  if (pendingJobsAsync is AsyncData &&
      scheduledJobsAsync is AsyncData &&
      escalatedJobsAsync is AsyncData) {
    final pendingJobs = pendingJobsAsync.value;
    final scheduledJobs = scheduledJobsAsync.value;
    final escalatedJobs = escalatedJobsAsync.value;

    final Map<int, Job> uniqueJobsMap = {};

    // Combine rule: de-duplicate by job.id, prefer escalated > pending > scheduled
    // Add escalated jobs first
    for (var job in escalatedJobs) {
      uniqueJobsMap[job.id] = job;
    }
    // Add pending jobs, will overwrite if job.id already exists (lower priority than escalated)
    for (var job in pendingJobs) {
      if (!uniqueJobsMap.containsKey(job.id)) { // Only add if not already present (from escalated)
        uniqueJobsMap[job.id] = job;
      }
    }
    // Add scheduled jobs, will overwrite if job.id already exists (lowest priority)
    for (var job in scheduledJobs) {
      if (!uniqueJobsMap.containsKey(job.id)) { // Only add if not already present (from escalated or pending)
        uniqueJobsMap[job.id] = job;
      }
    }

    final List<DispatchItem> dispatchItems = [];
    for (var job in uniqueJobsMap.values) {
      int score = 0;
      String scoreReason = '';

      // Base scoring
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

      // Bonus for unassigned jobs
      if (job.providerId == null) {
        score += 200;
        if (scoreReason.isNotEmpty) scoreReason += ', ';
        scoreReason += 'Unassigned (+200)';
      }

      dispatchItems.add(DispatchItem(
        job: job,
        score: score,
        scoreReason: scoreReason.isEmpty ? 'Base Score' : scoreReason,
      ));
    }

    // Sort by score descending
    dispatchItems.sort((a, b) => b.score.compareTo(a.score));

    return AsyncValue.data(dispatchItems);
  }

  // Fallback in case of unexpected AsyncValue states (should not happen with comprehensive checks)
  // Or if no data is available from any of the providers
  return const AsyncValue.loading();
});
