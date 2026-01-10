import 'package:flutter/material.dart';
import '../data/mock_provider_service.dart';
import 'provider_document_upload_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = MockProviderService.providerProfile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile['name'],
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('Email: ${profile['email']}'),
            const SizedBox(height: 4),
            Text('Phone: ${profile['phone']}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProviderDocumentUploadScreen(),
                  ),
                );
              },
              child: const Text('Upload / View Documents'),
            ),
          ],
        ),
      ),
    );
  }
}
