import 'package:flutter/material.dart';
import 'package:seamlesscall/features/people/provider_performance_detail_screen.dart';

class ProviderPerformanceScreen extends StatelessWidget {
  const ProviderPerformanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: ListView.separated(
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.star),
                  title: Text('Provider #${index + 1}'),
                  subtitle: const Text('Rating • Jobs Completed'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProviderPerformanceDetailScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
