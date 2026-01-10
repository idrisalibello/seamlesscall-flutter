import 'package:flutter/material.dart';
import 'package:seamlesscall/features/people/customers_detail_screen.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Customers', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: 10,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('Customer #${index + 1}'),
                  subtitle: const Text('Phone • Email'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CustomerDetailScreen()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
