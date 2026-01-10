import 'package:flutter/material.dart';
import '../data/mock_provider_service.dart';

class ProviderAvailabilityScreen extends StatefulWidget {
  const ProviderAvailabilityScreen({super.key});

  @override
  State<ProviderAvailabilityScreen> createState() =>
      _ProviderAvailabilityScreenState();
}

class _ProviderAvailabilityScreenState
    extends State<ProviderAvailabilityScreen> {
  Map<String, bool> availability = Map.from(
    MockProviderService.providerProfile['availability'],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Availability')),
      body: ListView(
        children: availability.keys.map((day) {
          return SwitchListTile(
            title: Text(day),
            value: availability[day]!,
            onChanged: (val) => setState(() => availability[day] = val),
          );
        }).toList(),
      ),
    );
  }
}
