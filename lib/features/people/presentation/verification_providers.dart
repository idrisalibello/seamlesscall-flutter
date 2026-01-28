import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/verification_repository.dart';

// Provider to expose the repository
final verificationRepositoryProvider = Provider((ref) => VerificationRepository());

// Provider to get the list of pending verification cases
final verificationQueueProvider = FutureProvider.autoDispose<List<VerificationCase>>((ref) {
  final repo = ref.watch(verificationRepositoryProvider);
  return repo.getVerificationQueue();
});

// Provider to get the details of a single verification case
final verificationCaseDetailProvider = FutureProvider.autoDispose.family<VerificationCase, int>((ref, caseId) {
  final repo = ref.watch(verificationRepositoryProvider);
  return repo.getVerificationCaseDetail(caseId);
});
