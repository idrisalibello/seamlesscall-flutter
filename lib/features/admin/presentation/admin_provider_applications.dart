import 'package:flutter/material.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'admin_provider_application_detail_screen.dart';

class AdminProviderApplicationsScreen extends StatefulWidget {
  const AdminProviderApplicationsScreen({super.key});

  @override
  State<AdminProviderApplicationsScreen> createState() =>
      _AdminProviderApplicationsScreenState();
}

class _AdminProviderApplicationsScreenState
    extends State<AdminProviderApplicationsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _applications = [];
  String? _error;
  late final AdminRepository _adminRepository;

  @override
  void initState() {
    super.initState();
    _adminRepository = AdminRepository();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apps = await _adminRepository.getProviderApplications();
      if (mounted) {
        setState(() {
          _applications = apps;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Provider Applications',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadApplications,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
             Expanded(
              child: Center(child: Text('Error: $_error')),
            )
          else if (_applications.isEmpty)
            const Expanded(
              child: Center(child: Text('No pending applications')),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _applications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final app = _applications[index];
                  final submittedAt = app['provider_applied_at'] ?? 'N/A';

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(
                        app['company_name'] ?? app['name'] ?? 'Unnamed',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${app['location'] ?? 'N/A'}\nApplied: $submittedAt',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminProviderApplicationDetailScreen(
                                  application: app,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
