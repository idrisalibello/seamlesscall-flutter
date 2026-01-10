import 'package:flutter/material.dart';
import '../../../common/widgets/main_layout.dart';
import 'customer_service_details.dart';

class ServicesListScreen extends StatelessWidget {
  const ServicesListScreen({super.key});

  final List<String> dummyServices = const [
    'Plumbing',
    'Electrical',
    'Cleaning',
    'Gardening',
    'Painting',
  ];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(title: const Text('Services')),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dummyServices.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(dummyServices[index]),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ServiceDetailsScreen(serviceName: dummyServices[index]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
