import 'package:flutter/material.dart';

class ProviderEarningsScreen extends StatelessWidget {
  const ProviderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Earnings",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Overview of your payments",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: const [
                  _EarningsCard(label: "Today", amount: 8000),
                  _EarningsCard(label: "This Week", amount: 25000),
                  _EarningsCard(label: "This Month", amount: 102000),
                  _EarningsCard(label: "Total", amount: 320000),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String label;
  final int amount;

  const _EarningsCard({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C80FF), Color(0xFF2CE8E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 10),
            Text(
              "₦$amount",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
