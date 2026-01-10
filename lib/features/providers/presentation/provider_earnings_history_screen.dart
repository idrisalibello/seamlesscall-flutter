import 'package:flutter/material.dart';
import '../data/mock_provider_service.dart';

class ProviderEarningsHistoryScreen extends StatelessWidget {
  const ProviderEarningsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final earnings = MockProviderService.earningsHistory;

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings History')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: earnings.length,
        itemBuilder: (context, index) {
          final record = earnings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('₦${record['amount']}'),
              subtitle: Text(record['date']),
            ),
          );
        },
      ),
    );
  }
}
