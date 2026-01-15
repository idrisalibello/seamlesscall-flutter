import 'package:flutter/material.dart';
import 'package:seamlesscall/features/auth/data/auth_repository.dart';

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

  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepository();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _serviceCategory == null) return;

    setState(() => _submitting = true);

    try {
      final response = await _authRepository.applyAsProvider(
        companyName: _companyController.text.trim(),
        location: _locationController.text.trim(),
        services: _serviceCategory!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Application submitted successfully. Await admin approval.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
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
