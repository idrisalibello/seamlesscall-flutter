import 'package:flutter/material.dart';

class ProviderJobsScreen extends StatelessWidget {
  const ProviderJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Jobs",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Manage and track all jobs assigned to you",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  _JobCard(title: "AC Repair", status: "In Progress"),
                  _JobCard(title: "Plumbing Fix", status: "Pending"),
                  _JobCard(title: "House Cleaning", status: "Completed"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final String title;
  final String status;

  const _JobCard({required this.title, required this.status});

  Color _statusColor() {
    switch (status) {
      case "Completed":
        return Colors.greenAccent;
      case "In Progress":
        return Colors.orangeAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151F2E),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.work, color: _statusColor(), size: 36),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          status,
          style: TextStyle(color: _statusColor(), fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
