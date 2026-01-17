import 'package:flutter/material.dart';
import 'package:seamlesscall/features/people/data/people_repository.dart';
import 'package:seamlesscall/features/people/data/models/customer_model.dart';
import 'package:seamlesscall/features/people/customers_detail_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late Future<List<Customer>> _customersFuture;
  final PeopleRepository _peopleRepository = PeopleRepository();

  @override
  void initState() {
    super.initState();
    _customersFuture = _peopleRepository.getCustomers();
  }

  Future<void> _refreshCustomers() async {
    setState(() {
      _customersFuture = _peopleRepository.getCustomers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Customers', style: Theme.of(context).textTheme.headlineSmall),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshCustomers,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Customer>>(
              future: _customersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No customers found.'));
                } else {
                  final customers = snapshot.data!;
                  return ListView.separated(
                    itemCount: customers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(customer.name),
                          subtitle: Text('${customer.phone ?? 'N/A'} • ${customer.email}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerDetailScreen(customerId: customer.id),
                              ),
                            ).then((value) {
                              // Refresh customers when returning from detail screen
                              if (value == true) {
                                _refreshCustomers();
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
