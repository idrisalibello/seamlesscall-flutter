import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart'; // Assuming DioClient is needed for some reason here for pattern matching, though repo already uses it.
import '../data/provider_performance_repository.dart';
import '../domain/provider_performance_models.dart';

// Provider to expose the repository
final providerPerformanceRepositoryProvider = Provider((ref) => ProviderPerformanceRepository());

// Provider for the list of provider performance summaries
final providerPerformanceListProvider = FutureProvider.autoDispose.family<List<ProviderPerformanceSummary>, ({String? from, String? to, int? page, int? limit})>((ref, args) {
  final repo = ref.watch(providerPerformanceRepositoryProvider);
  return repo.fetchProviderPerformanceList(
    from: args.from,
    to: args.to,
    page: args.page,
    limit: args.limit,
  );
});

// Provider for a single provider's performance detail
final providerPerformanceDetailProvider = FutureProvider.autoDispose.family<ProviderPerformanceDetail, ({int providerId, String? from, String? to, String? bucket})>((ref, args) {
  final repo = ref.watch(providerPerformanceRepositoryProvider);
  return repo.fetchProviderPerformanceDetail(
    args.providerId,
    from: args.from,
    to: args.to,
    bucket: args.bucket,
  );
});

// Provider for a single provider's ratings distribution
final providerRatingsProvider = FutureProvider.autoDispose.family<ProviderRatingsDistribution, ({int providerId, String? from, String? to})>((ref, args) {
  final repo = ref.watch(providerPerformanceRepositoryProvider);
  return repo.fetchProviderRatings(
    args.providerId,
    from: args.from,
    to: args.to,
  );
});

// Provider for a single provider's disputes list
final providerDisputesProvider = FutureProvider.autoDispose.family<List<ProviderDispute>, ({int providerId, String? from, String? to, int? page, int? limit})>((ref, args) {
  final repo = ref.watch(providerPerformanceRepositoryProvider);
  return repo.fetchProviderDisputes(
    args.providerId,
    from: args.from,
    to: args.to,
    page: args.page,
    limit: args.limit,
  );
});
