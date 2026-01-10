import 'package:flutter/material.dart';
import '../../../common/widgets/main_layout.dart';
import 'customer_booking_request.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String serviceName;
  const ServiceDetailsScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(title: Text(serviceName)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details for $serviceName',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Here you can describe the service, pricing, duration, provider ratings, etc.',
                style: TextStyle(fontSize: 16),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Book This Service'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingRequestScreen(),
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
