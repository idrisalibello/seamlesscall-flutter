import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/operations/data/repositories/operations_repository.dart';
import 'package:seamlesscall/features/operations/domain/job.dart';

// 1. Provider for the OperationsRepository
final operationsRepositoryProvider = Provider<OperationsRepository>((ref) {
  return OperationsRepository();
});

// 2. StateNotifier for Active Jobs List
class ActiveJobsNotifier extends StateNotifier<AsyncValue<List<Job>>> {
  final OperationsRepository _repository;

  ActiveJobsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchJobs(String role) async {
    try {
      state = const AsyncValue.loading();
      final jobs = await _repository.getActiveJobs(role);
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final activeJobsProvider =
    StateNotifierProvider<ActiveJobsNotifier, AsyncValue<List<Job>>>((ref) {
      final repository = ref.watch(operationsRepositoryProvider);
      return ActiveJobsNotifier(repository);
    });

// 3. FutureProvider for individual Job Details
final jobDetailsProvider =
    FutureProvider.family<Job, ({String role, int jobId})>((ref, args) async {
      final repository = ref.watch(operationsRepositoryProvider);
      return repository.getJobDetails(args.role, args.jobId);
    });

// 4. StateNotifier for Pending Jobs List
class PendingJobsNotifier extends StateNotifier<AsyncValue<List<Job>>> {
  final OperationsRepository _repository;

  PendingJobsNotifier(this._repository) : super(const AsyncValue.loading());

  Future<void> fetchJobs() async {
    try {
      state = const AsyncValue.loading();
      final jobs = await _repository.getAdminPendingJobs();
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final pendingJobsProvider =
    StateNotifierProvider<PendingJobsNotifier, AsyncValue<List<Job>>>((ref) {
      final repository = ref.watch(operationsRepositoryProvider);
      return PendingJobsNotifier(repository);
    });

// 5. FutureProvider for Available Providers List
final availableProvidersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(operationsRepositoryProvider);
  return repository.getAvailableProviders();
});

