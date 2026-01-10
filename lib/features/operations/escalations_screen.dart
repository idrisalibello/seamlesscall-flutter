import 'package:flutter/material.dart';
import 'package:seamlesscall/features/operations/escalations_details_screen.dart';

class EscalationsScreen extends StatelessWidget {
  const EscalationsScreen({super.key});

  static final List<Map<String, String>> _escalations = [
    {
      'title': 'Power Outage Complaint',
      'job': 'JOB-1023',
      'customer': 'John Doe',
      'reportedBy': 'Field Agent',
      'priority': 'High',
      'status': 'Open',
    },
    {
      'title': 'Delayed Installation',
      'job': 'JOB-1041',
      'customer': 'Jane Smith',
      'reportedBy': 'Customer Care',
      'priority': 'Medium',
      'status': 'Pending',
    },
    {
      'title': 'Technician No-Show',
      'job': 'JOB-1099',
      'customer': 'Michael Brown',
      'reportedBy': 'Customer',
      'priority': 'High',
      'status': 'Escalated',
    },
    {
      'title': 'Billing Dispute',
      'job': 'JOB-1102',
      'customer': 'Aisha Bello',
      'reportedBy': 'Finance',
      'priority': 'Low',
      'status': 'Open',
    },
    {
      'title': 'Equipment Damage',
      'job': 'JOB-1110',
      'customer': 'Samuel Okoro',
      'reportedBy': 'Technician',
      'priority': 'High',
      'status': 'Pending',
    },
    {
      'title': 'Service Downtime',
      'job': 'JOB-1118',
      'customer': 'Grace Williams',
      'reportedBy': 'Monitoring System',
      'priority': 'Critical',
      'status': 'Open',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Escalations', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: _escalations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final escalation = _escalations[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.report_problem),
                    title: Text(escalation['title']!),
                    subtitle: Text(
                      '${escalation['customer']} • ${escalation['status']}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EscalationDetailsScreen(escalation: escalation),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
