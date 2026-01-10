import 'package:flutter/material.dart';
import 'package:seamlesscall/features/people/verification_queue_detail_screen.dart';

class VerificationQueueScreen extends StatelessWidget {
  const VerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Queue',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.verified),
                  title: Text('Provider #${index + 1}'),
                  subtitle: const Text('Pending Verification'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VerificationQueueDetailScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
