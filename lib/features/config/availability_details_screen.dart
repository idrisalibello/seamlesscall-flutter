import 'package:flutter/material.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/availability_repository.dart';
import 'package:seamlesscall/features/config/data/models/availability_rule_model.dart';
import 'package:seamlesscall/features/config/data/models/category_model.dart';
import 'package:seamlesscall/features/config/widgets/availability_rule_dialog.dart';

import '../../common/widgets/main_layout.dart';

class AvailabilityDetailsScreen extends StatefulWidget {
  final int ruleId;

  const AvailabilityDetailsScreen({super.key, required this.ruleId});

  @override
  State<AvailabilityDetailsScreen> createState() =>
      _AvailabilityDetailsScreenState();
}

class _AvailabilityDetailsScreenState extends State<AvailabilityDetailsScreen> {
  final AvailabilityRepository _availabilityRepository =
      AvailabilityRepository();
  final AdminRepository _adminRepository = AdminRepository();
  late Future<AvailabilityRule> _future;
  bool _changed = false;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _reload();
    _loadCategories();
  }

  void _reload() {
    _future = _availabilityRepository.getAvailabilityRule(widget.ruleId);
  }

  Future<void> _loadCategories() async {
    try {
      final rows = await _adminRepository.getCategories();
      if (mounted) {
        setState(() => _categories = rows);
      }
    } catch (_) {}
  }

  Future<void> _toggleStatus(AvailabilityRule current) async {
    try {
      await _availabilityRepository.updateAvailabilityStatus(
        current.id,
        current.isActive ? 'inactive' : 'active',
      );
      _changed = true;
      if (mounted) {
        setState(() => _reload());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(current.isActive ? 'Rule disabled' : 'Rule enabled'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status update failed: $e')),
      );
    }
  }

  Future<void> _deleteRule(AvailabilityRule current) async {
    final title = current.categoryName.isEmpty
        ? 'Category #${current.categoryId}'
        : current.categoryName;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Availability Rule'),
        content: Text('Delete this rule for $title?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _availabilityRepository.deleteAvailabilityRule(current.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  Future<void> _openEditDialog(AvailabilityRule current) async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AvailabilityRuleDialog(
        categories: _categories,
        initialRule: current,
      ),
    );

    if (saved == true) {
      _changed = true;
      if (mounted) {
        setState(() => _reload());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false;
      },
      child: MainLayout(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<AvailabilityRule>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('Availability rule not found.'));
              }

              final rule = snapshot.data!;
              final title = rule.categoryName.isEmpty
                  ? 'Category #${rule.categoryId}'
                  : rule.categoryName;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Availability Details',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: () => setState(() => _reload()),
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.category_outlined),
                      title: const Text('Category'),
                      subtitle: Text(title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.place_outlined),
                      title: const Text('Location'),
                      subtitle: Text(rule.locationSummary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.date_range_outlined),
                      title: const Text('Days'),
                      subtitle: Text(rule.daysSummary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Time Window'),
                      subtitle: Text(rule.timeSummary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        rule.isActive ? Icons.check_circle : Icons.cancel,
                      ),
                      title: const Text('Status'),
                      subtitle: Text(rule.isActive ? 'Active' : 'Inactive'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _categories.isEmpty
                            ? null
                            : () => _openEditDialog(rule),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Rule'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _toggleStatus(rule),
                        icon: const Icon(Icons.toggle_on),
                        label: Text(rule.isActive ? 'Disable' : 'Enable'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _deleteRule(rule),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}