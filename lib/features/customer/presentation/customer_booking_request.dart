import 'package:flutter/material.dart';
import '../../../common/widgets/main_layout.dart';
import 'customer_booking_summary.dart';

class BookingRequestScreen extends StatefulWidget {
  const BookingRequestScreen({super.key});

  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  bool asapSelected = true;
  DateTime? scheduledDate;

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(title: const Text('Booking Request')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose Booking Type', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('ASAP'),
                    selected: asapSelected,
                    onSelected: (val) => setState(() {
                      asapSelected = true;
                      scheduledDate = null;
                    }),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('Schedule'),
                    selected: !asapSelected,
                    onSelected: (val) => setState(() {
                      asapSelected = false;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!asapSelected)
                Row(
                  children: [
                    const Text('Select Date: '),
                    TextButton(
                      child: Text(
                        scheduledDate == null
                            ? 'Pick a Date'
                            : scheduledDate!.toLocal().toString().split(' ')[0],
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) {
                          setState(() => scheduledDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  child: const Text('Proceed to Summary'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingSummaryScreen(),
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
