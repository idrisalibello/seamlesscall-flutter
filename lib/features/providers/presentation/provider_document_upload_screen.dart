import 'package:flutter/material.dart';
import '../data/mock_provider_service.dart';
// Conditional import
import 'pick_document_stub.dart'
    if (dart.library.html) 'pick_document_web.dart'
    if (dart.library.io) 'pick_document_mobile.dart';

class ProviderDocumentUploadScreen extends StatefulWidget {
  const ProviderDocumentUploadScreen({super.key});

  @override
  State<ProviderDocumentUploadScreen> createState() =>
      _ProviderDocumentUploadScreenState();
}

class _ProviderDocumentUploadScreenState
    extends State<ProviderDocumentUploadScreen> {
  bool uploaded = MockProviderService.providerProfile['documentsUploaded'];

  Future<void> pickFile() async {
    final success = await pickDocument();
    if (success) {
      setState(() {
        uploaded = true;
        MockProviderService.providerProfile['documentsUploaded'] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Upload')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(uploaded ? Icons.check_circle : Icons.upload_file, size: 80),
            const SizedBox(height: 16),
            Text(uploaded ? 'Document Uploaded' : 'No Document Uploaded'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Upload Document'),
            ),
          ],
        ),
      ),
    );
  }
}
