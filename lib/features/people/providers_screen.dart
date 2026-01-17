import 'package:flutter/material.dart';
import 'package:seamlesscall/features/people/data/people_repository.dart';
import 'package:seamlesscall/features/people/data/models/provider_model.dart';
import 'package:seamlesscall/features/people/provider_detail_screen.dart'; // Will create this next

class ProvidersScreen extends StatefulWidget {
  const ProvidersScreen({super.key});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen> {
  late Future<List<Provider>> _providersFuture;
  final PeopleRepository _peopleRepository = PeopleRepository();

  @override
  void initState() {
    super.initState();
    _providersFuture = _peopleRepository.getProviders();
  }

  Future<void> _refreshProviders() async {
    setState(() {
      _providersFuture = _peopleRepository.getProviders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Providers', style: Theme.of(context).textTheme.headlineSmall),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshProviders,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Provider>>(
              future: _providersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No providers found.'));
                } else {
                  final providers = snapshot.data!;
                  return ListView.separated(
                    itemCount: providers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final provider = providers[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person_outline),
                          title: Text(provider.name),
                          subtitle: Text(
                            '${provider.phone ?? 'N/A'} • ${provider.services ?? 'N/A'} • Status: ${provider.providerStatus ?? 'N/A'}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProviderDetailScreen(providerId: provider.id),
                              ),
                            ).then((value) {
                              // Refresh providers when returning from detail screen
                              if (value == true) {
                                _refreshProviders();
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}