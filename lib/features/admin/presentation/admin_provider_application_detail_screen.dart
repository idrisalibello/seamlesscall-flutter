import 'package:flutter/material.dart';

class AdminProviderApplicationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> application;

  const AdminProviderApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final isCompany = application['is_company'] == 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Application Review')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _sectionTitle(context, 'Applicant Information'),
            _infoRow('Full Name', application['name']),
            _infoRow('Email', application['email']),
            _infoRow('Phone', application['phone']),
            _infoRow('Location', application['location']),

            const SizedBox(height: 20),

            _sectionTitle(context, 'Service Details'),
            _infoRow('Service Category', application['service_category']),
            _infoRow('Applied On', application['submitted_at']),

            const SizedBox(height: 20),

            _sectionTitle(context, 'Business Information'),
            _infoRow('Application Type', isCompany ? 'Company' : 'Individual'),
            _infoRow(
              'Company Name',
              isCompany ? application['company_name'] : '—',
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve Provider'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Provider approved')),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject Application'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Provider rejected')),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value ?? '—')),
        ],
      ),
    );
  }
}
