import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApplyAsProviderScreen extends StatefulWidget {
  const ApplyAsProviderScreen({super.key});

  @override
  State<ApplyAsProviderScreen> createState() => _ApplyAsProviderScreenState();
}

class _ApplyAsProviderScreenState extends State<ApplyAsProviderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _serviceCategory;
  bool _isCompany = false;
  bool _submitting = false;

  final storage = const FlutterSecureStorage();
  final Dio dio = Dio();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      // Retrieve JWT token from secure storage
      final token = await storage.read(key: 'jwt_token');
      if (token == null) throw Exception('User not logged in');

      final payload = {
        'company_name': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'services': _serviceCategory,
        'is_company': _isCompany ? 1 : 0,
        'description': _descriptionController.text.trim(),
      };

      final response = await dio.post(
        'http://your-server.com/auth/provider/apply-as-customer',
        data: payload,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.data['message'] ?? 'Application submitted'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply as Provider')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SwitchListTile(
                title: const Text('Applying as a company'),
                value: _isCompany,
                onChanged: (v) => setState(() => _isCompany = v),
              ),

              if (_isCompany)
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Service Category',
                ),
                items: const [
                  DropdownMenuItem(value: 'Plumbing', child: Text('Plumbing')),
                  DropdownMenuItem(
                    value: 'Electrical',
                    child: Text('Electrical'),
                  ),
                  DropdownMenuItem(
                    value: 'Pest Control',
                    child: Text('Pest Control'),
                  ),
                  DropdownMenuItem(value: 'Cleaning', child: Text('Cleaning')),
                ],
                value: _serviceCategory,
                onChanged: (v) => setState(() => _serviceCategory = v),
                validator: (v) => v == null ? 'Select a service' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Brief Description (optional)',
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
