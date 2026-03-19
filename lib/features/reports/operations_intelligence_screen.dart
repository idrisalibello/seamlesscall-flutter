import 'package:flutter/material.dart';
import 'data/executive_repository.dart';

class OperationsIntelligenceScreen extends StatefulWidget {
  const OperationsIntelligenceScreen({super.key});

  @override
  State<OperationsIntelligenceScreen> createState() => _OperationsIntelligenceScreenState();
}

class _OperationsIntelligenceScreenState extends State<OperationsIntelligenceScreen> {

  final repo = ExecutiveRepository();
  Map<String, dynamic>? data;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    data = await repo.getOperationsSummary();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    if (data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      children: data!.entries.map((e) {
        return ListTile(
          title: Text(e.key),
          trailing: Text(e.value.toString()),
        );
      }).toList(),
    );
  }
}