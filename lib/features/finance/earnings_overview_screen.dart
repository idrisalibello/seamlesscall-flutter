import 'package:flutter/material.dart';
import 'package:seamlesscall/features/finance/earnings_details_screen.dart';

class EarningsOverviewScreen extends StatefulWidget {
  const EarningsOverviewScreen({super.key});

  @override
  State<EarningsOverviewScreen> createState() => _EarningsOverviewScreenState();
}

class _EarningsOverviewScreenState extends State<EarningsOverviewScreen> {
  final List<Map<String, dynamic>> _earnings = List.generate(12, (index) {
    return {
      'date': DateTime.now().subtract(Duration(days: index)),
      'provider': 'Provider ${index + 1}',
      'amount': 150.0 + (index * 35),
      'status': index % 3 == 0 ? 'Pending' : 'Completed',
      'reference': 'TXN-${1000 + index}',
    };
  });

  String _search = '';
  String _status = 'All';

  @override
  Widget build(BuildContext context) {
    final filtered = _earnings.where((e) {
      final matchSearch = e['provider'].toString().toLowerCase().contains(
        _search.toLowerCase(),
      );
      final matchStatus = _status == 'All' || e['status'] == _status;
      return matchSearch && matchStatus;
    }).toList();

    double total = _earnings.fold(0, (sum, e) => sum + (e['amount'] as double));
    double completed = _earnings
        .where((e) => e['status'] == 'Completed')
        .fold(0, (sum, e) => sum + (e['amount'] as double));
    double pending = _earnings
        .where((e) => e['status'] == 'Pending')
        .fold(0, (sum, e) => sum + (e['amount'] as double));

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings Overview')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow(total, completed, pending),
            const SizedBox(height: 20),
            _filters(),
            const SizedBox(height: 20),
            Expanded(child: _table(filtered)),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(double total, double completed, double pending) {
    return Row(
      children: [
        _summaryCard('Total Earnings', total),
        _summaryCard('Completed', completed),
        _summaryCard('Pending', pending),
      ],
    );
  }

  Widget _summaryCard(String title, double value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                '₦${value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search provider',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _status,
          items: [
            'All',
            'Completed',
            'Pending',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _status = v!),
        ),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('PDF'),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          icon: const Icon(Icons.grid_on),
          label: const Text('Excel'),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _table(List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 900),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Provider')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: data.map((e) {
              return DataRow(
                cells: [
                  DataCell(Text(e['date'].toString().split(' ').first)),
                  DataCell(Text(e['provider'])),
                  DataCell(Text('₦${e['amount']}')),
                  DataCell(Text(e['status'])),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () => _details(e),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // void _details(Map<String, dynamic> earning) {
  //   showDialog(
  //     context: context,
  //     builder: (_) => AlertDialog(
  //       title: const Text('Earning Details'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           _row('Reference', earning['reference']),
  //           _row('Provider', earning['provider']),
  //           _row('Amount', '₦${earning['amount']}'),
  //           _row('Status', earning['status']),
  //           _row('Date', earning['date'].toString()),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('Close'),
  //         ),
  //         if (earning['status'] == 'Pending')
  //           ElevatedButton(
  //             onPressed: () {},
  //             child: const Text('Raise Dispute'),
  //           ),
  //       ],
  //     ),
  //   );
  // }
  void _details(Map<String, dynamic> earning) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EarningsDetailsScreen(earning: earning),
      ),
    );
  }

  // Widget _row(String label, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: Text(
  //             label,
  //             style: const TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //         Expanded(child: Text(value)),
  //       ],
  //     ),
  //   );
  // }
}
