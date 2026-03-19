import 'package:flutter/material.dart';
import 'data/executive_repository.dart';

class ExecutiveSummaryScreen extends StatefulWidget {
  const ExecutiveSummaryScreen({super.key});

  @override
  State<ExecutiveSummaryScreen> createState() => _ExecutiveSummaryScreenState();
}

class _ExecutiveSummaryScreenState extends State<ExecutiveSummaryScreen> {

  final repo = ExecutiveRepository();
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    data = await repo.getExecutive();
    setState(() {});
  }

  Widget card(String title, dynamic value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 10),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final k = data!['kpis'];

    return GridView.count(
      crossAxisCount: 4,
      children: [
        card("Jobs", k['jobs_total']),
        card("Completed", k['completed']),
        card("Cancelled", k['cancelled']),
        card("Escalated", k['escalated']),
        card("Completion %", k['completion_rate']),
        card("Cancel %", k['cancel_rate']),
        card("Earnings", k['earnings']),
        card("Refunds", k['refunds']),
      ],
    );
  }
}