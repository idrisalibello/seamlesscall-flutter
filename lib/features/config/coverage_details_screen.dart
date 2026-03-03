import 'package:flutter/material.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/models/coverage_model.dart';
import '../../common/widgets/main_layout.dart';

class CoverageDetailsScreen extends StatefulWidget {
  final int coverageId;

  const CoverageDetailsScreen({super.key, required this.coverageId});

  @override
  State<CoverageDetailsScreen> createState() => _CoverageDetailsScreenState();
}

class _CoverageDetailsScreenState extends State<CoverageDetailsScreen> {
  final AdminRepository _adminRepository = AdminRepository();
  late Future<Coverage> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _future = _adminRepository.getCoverageDetails(widget.coverageId);
  }

  Future<void> _openEditDialog(Coverage current) async {
    final nameCtrl = TextEditingController(text: current.name);
    final regionCtrl = TextEditingController(text: current.region);
    bool isActive = current.isActive;

    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Coverage'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: regionCtrl,
                      decoration: const InputDecoration(labelText: 'Region'),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: isActive,
                      onChanged: (v) => setDialogState(() => isActive = v),
                      title: const Text('Active'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final region = regionCtrl.text.trim();

                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name is required')),
                      );
                      return;
                    }

                    try {
                      await _adminRepository.updateCoverage(current.id, {
                        'name': name,
                        'region': region,
                        'is_active': isActive ? 1 : 0,
                      });
                      Navigator.pop(ctx, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update failed: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      setState(() => _reload());
      // tell previous screen something changed
      // (only when user navigates back)
    }
  }

  Future<void> _toggleActive(Coverage current) async {
    try {
      await _adminRepository.updateCoverage(current.id, {
        'is_active': current.isActive ? 0 : 1,
      });
      setState(() => _reload());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(current.isActive ? 'Disabled' : 'Enabled'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Toggle failed: $e')),
      );
    }
  }

  Future<void> _deleteCoverage(Coverage current) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Coverage'),
        content: Text('Delete "${current.name}"? This cannot be undone.'),
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
      await _adminRepository.deleteCoverage(current.id);
      if (!mounted) return;
      Navigator.pop(context, true); // tell list to refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<Coverage>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final coverage = snapshot.data!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Coverage Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: () => setState(() => _reload()),
                      icon: const Icon(Icons.refresh),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  coverage.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: const Text('Region'),
                    subtitle: Text(coverage.region.isEmpty ? '-' : coverage.region),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: Icon(coverage.isActive ? Icons.public : Icons.public_off),
                    title: const Text('Status'),
                    subtitle: Text(coverage.isActive ? 'Active' : 'Inactive'),
                  ),
                ),

                const SizedBox(height: 24),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openEditDialog(coverage),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _toggleActive(coverage),
                      icon: const Icon(Icons.toggle_on),
                      label: Text(coverage.isActive ? 'Disable' : 'Enable'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _deleteCoverage(coverage),
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