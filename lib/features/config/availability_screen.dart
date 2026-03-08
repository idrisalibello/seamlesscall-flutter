import 'package:flutter/material.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/availability_repository.dart';
import 'package:seamlesscall/features/config/data/models/availability_rule_model.dart';
import 'package:seamlesscall/features/config/data/models/category_model.dart';
import 'package:seamlesscall/features/config/widgets/availability_rule_dialog.dart';

import '../../common/widgets/main_layout.dart';
import 'availability_details_screen.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final AvailabilityRepository _availabilityRepository =
      AvailabilityRepository();
  final AdminRepository _adminRepository = AdminRepository();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  List<AvailabilityRule> _rules = [];
  List<Category> _categories = [];
  int? _categoryId;
  String _status = 'All';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      _categories = await _adminRepository.getCategories();
      await _loadRules();
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadRules() async {
    try {
      final rows = await _availabilityRepository.getAvailabilityRules(
        categoryId: _categoryId,
        status: _status == 'All' ? null : _status.toLowerCase(),
        q: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );

      if (mounted) {
        setState(() {
          _rules = rows;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = '$e');
      }
    }
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _loadRules();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _openCreateDialog() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AvailabilityRuleDialog(categories: _categories),
    );

    if (saved == true) {
      await _reload();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _categories.isEmpty ? null : _openCreateDialog,
          icon: const Icon(Icons.add),
          label: const Text('Add Rule'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Availability Rules',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Manage category coverage windows by location, days, and time.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              _buildFilters(),
              const SizedBox(height: 16),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 280,
          child: TextField(
            controller: _searchCtrl,
            decoration: const InputDecoration(
              labelText: 'Search location/category',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _reload(),
          ),
        ),
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<int?>(
            value: _categoryId,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('All')),
              ..._categories.map(
                (c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name)),
              ),
            ],
            onChanged: (value) {
              setState(() => _categoryId = value);
              _reload();
            },
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
            ],
            onChanged: (value) {
              setState(() => _status = value ?? 'All');
              _reload();
            },
          ),
        ),
        OutlinedButton.icon(
          onPressed: _loading ? null : _reload,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading && _rules.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_rules.isEmpty) {
      return const Center(child: Text('No availability rules found.'));
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.builder(
        itemCount: _rules.length,
        itemBuilder: (context, index) {
          final rule = _rules[index];
          final title = rule.categoryName.isEmpty
              ? 'Category #${rule.categoryId}'
              : rule.categoryName;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                leading: Icon(
                  rule.isActive ? Icons.access_time_filled : Icons.access_time,
                ),
                title: Text(title),
                subtitle: Text(
                  '${rule.locationSummary}\n${rule.daysSummary} • ${rule.timeSummary}',
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      rule.isActive ? Icons.check_circle : Icons.cancel,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(rule.isActive ? 'Active' : 'Inactive'),
                  ],
                ),
                onTap: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AvailabilityDetailsScreen(ruleId: rule.id),
                    ),
                  );
                  if (changed == true) {
                    await _reload();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}