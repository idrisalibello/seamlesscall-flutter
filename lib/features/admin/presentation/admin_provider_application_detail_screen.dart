import 'package:flutter/material.dart';
import 'package:seamlesscall/core/network/dio_client.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';

class AdminProviderApplicationDetailScreen extends StatefulWidget {
  final Map<String, dynamic> application;

  const AdminProviderApplicationDetailScreen({
    super.key,
    required this.application,
  });

  @override
  State<AdminProviderApplicationDetailScreen> createState() =>
      _AdminProviderApplicationDetailScreenState();
}

class _AdminProviderApplicationDetailScreenState
    extends State<AdminProviderApplicationDetailScreen> {
  final AdminRepository _adminRepo = AdminRepository();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isCompany = widget.application['is_company'] == 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Application Review')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _sectionTitle(context, 'Applicant Information'),
            _infoRow('Full Name', widget.application['name']),
            _infoRow('Email', widget.application['email']),
            _infoRow('Phone', widget.application['phone']),
            _infoRow('Location', widget.application['location']),

            const SizedBox(height: 20),

            _sectionTitle(context, 'Service Details'),
            _infoRow(
              'Service Category',
              widget.application['service_category'],
            ),
            _infoRow('Applied On', widget.application['submitted_at']),

            const SizedBox(height: 20),

            _sectionTitle(context, 'Business Information'),
            _infoRow('Application Type', isCompany ? 'Company' : 'Individual'),
            _infoRow(
              'Company Name',
              isCompany ? widget.application['company_name'] : '—',
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
                    icon: _isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.check),
                    label: const Text('Approve Provider'),
                    onPressed: _isLoading
                        ? null
                        : () => _handleAction(context, 'approve'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.close),
                    label: const Text('Reject Application'),
                    onPressed: _isLoading
                        ? null
                        : () => _handleAction(context, 'reject'),
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

  Future<void> _handleAction(BuildContext context, String action) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId =
          widget.application['id'] as int; // Assuming 'id' is the user_id
      await _adminRepo.approveOrRejectProvider(userId, action);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Provider application ${action}d successfully!'),
        ),
      );
      Navigator.pop(
        context,
        true,
      ); // Pop with true to indicate a successful action
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${action} provider application: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
