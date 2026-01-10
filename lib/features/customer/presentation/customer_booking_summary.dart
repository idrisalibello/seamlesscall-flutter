import 'package:flutter/material.dart';
import '../../../common/widgets/main_layout.dart';
import 'customer_booking_timeline.dart';

class BookingSummaryScreen extends StatelessWidget {
  const BookingSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(title: const Text('Booking Summary')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking Summary',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Service: Plumbing'),
              const Text('Booking Type: ASAP'),
              const Text('Date: Today'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Confirm Booking'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingTimelineScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
