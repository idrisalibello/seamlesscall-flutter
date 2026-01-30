import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import for Riverpod
import 'package:seamlesscall/features/people/presentation/provider_performance_providers.dart'; // Import providers
import 'package:seamlesscall/features/people/provider_performance_detail_screen.dart';
import 'package:seamlesscall/features/people/domain/provider_performance_models.dart'; // Import models

class ProviderPerformanceScreen extends ConsumerWidget {
  // Converted to ConsumerWidget
  const ProviderPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Added WidgetRef ref
    final providerListAsync = ref.watch(
      providerPerformanceListProvider(
        (
          from: null,
          to: null,
          page: null,
          limit: null,
        ), // Pass default/null args for now
      ),
    ); // Watch the provider

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provider Performance',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: providerListAsync.when(
              // Handle AsyncValue states
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (providers) {
                if (providers.isEmpty) {
                  return const Center(
                    child: Text('No provider performance data found.'),
                  );
                }
                return ListView.separated(
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    final String avgRatingText = provider.avgRating == 0.0
                        ? 'N/A'
                        : provider.avgRating.toStringAsFixed(
                            1,
                          ); // Format to 1 decimal

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.star),
                        title: Text(
                          provider.providerName,
                        ), // Use actual provider name
                        subtitle: Text(
                          'Completed: ${provider.completedJobs} • Cancelled: ${provider.cancelledJobs} • Escalations: ${provider.escalationsCount} • Rating: $avgRatingText',
                        ), // Formatted subtitle
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProviderPerformanceDetailScreen(
                                // Pass providerId and providerName
                                providerId: provider.providerId,
                                providerName: provider.providerName,
                              ),
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
