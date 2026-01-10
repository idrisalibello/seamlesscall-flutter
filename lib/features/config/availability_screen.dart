import 'package:flutter/material.dart';
import '../../common/widgets/main_layout.dart';
import 'availability_details_screen.dart';

class AvailabilityScreen extends StatelessWidget {
  const AvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Availability Rules',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text('Availability Rule #${index + 1}'),
                      subtitle: const Text('Start & End time / conditions'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AvailabilityDetailsScreen(ruleId: index + 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
