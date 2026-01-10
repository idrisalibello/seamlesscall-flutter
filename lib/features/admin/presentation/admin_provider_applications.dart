import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _applications = [
        {
          'id': 1,
          'name': 'Mary Smith',
          'email': 'mary@example.com',
          'phone': '0816 555 8821',
          'company_name': null,
          'is_company': 0,
          'location': 'Abuja',
          'service_category': 'Electrical',
          'submitted_at': '2025-01-13',
        },
        {
          'id': 2,
          'name': 'Elite Electricians Ltd',
          'email': 'contact@elite.com',
          'phone': '0803 123 4567',
          'company_name': 'Elite Electricians Ltd',
          'is_company': 1,
          'location': 'Lagos',
          'service_category': 'Electrical',
          'submitted_at': '2025-01-14',
        },
      ];
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Provider Applications',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
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

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(
                        app['company_name'] ?? app['name'],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${app['service_category']} • ${app['location']}\nApplied: ${app['submitted_at']}',
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
