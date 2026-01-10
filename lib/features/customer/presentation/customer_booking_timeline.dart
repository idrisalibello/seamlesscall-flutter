import 'package:flutter/material.dart';
import '../../../common/widgets/main_layout.dart';

class BookingTimelineScreen extends StatelessWidget {
  const BookingTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(title: const Text('Booking Timeline')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(
              leading: Icon(Icons.pending_actions),
              title: Text('Booking Requested'),
              subtitle: Text('Pending provider confirmation'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.check_circle_outline),
              title: Text('Provider Assigned'),
              subtitle: Text('John Doe will serve you'),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.done_all),
              title: Text('Service Completed'),
              subtitle: Text('Rating & feedback available'),
            ),
          ],
        ),
      ),
    );
  }
}
