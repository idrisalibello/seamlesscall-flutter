import 'package:flutter/material.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/models/coverage_model.dart';
import '../../common/widgets/main_layout.dart';
import 'coverage_details_screen.dart';

class CoverageScreen extends StatefulWidget {
  const CoverageScreen({super.key});

  @override
  State<CoverageScreen> createState() => _CoverageScreenState();
}

class _CoverageScreenState extends State<CoverageScreen> {
  final AdminRepository _adminRepository = AdminRepository();
  late Future<List<Coverage>> _coverageFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _coverageFuture = _adminRepository.getCoverages();
  }

  Future<void> _openCreateDialog() async {
    final nameCtrl = TextEditingController();
    final regionCtrl = TextEditingController();
    bool isActive = true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Add Coverage'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        hintText: 'e.g. Kaduna North',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: regionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Region',
                        hintText: 'e.g. Kaduna State',
                      ),
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
                      await _adminRepository.createCoverage({
                        'name': name,
                        'region': region,
                        'is_active': isActive ? 1 : 0,
                      });
                      Navigator.pop(ctx, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Create failed: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true) {
      setState(() => _reload());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Coverage Areas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _openCreateDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Coverage'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Coverage>>(
                future: _coverageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final coverages = snapshot.data ?? [];
                  if (coverages.isEmpty) {
                    return const Center(child: Text('No coverage areas found.'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() => _reload());
                      await _coverageFuture;
                    },
                    child: ListView.builder(
                      itemCount: coverages.length,
                      itemBuilder: (context, index) {
                        final coverage = coverages[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: ListTile(
                              leading: Icon(
                                coverage.isActive
                                    ? Icons.public
                                    : Icons.public_off,
                              ),
                              title: Text(coverage.name),
                              subtitle: Text(
                                coverage.region.isEmpty ? '-' : coverage.region,
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () async {
                                final changed = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CoverageDetailsScreen(
                                      coverageId: coverage.id,
                                    ),
                                  ),
                                );

                                if (changed == true) {
                                  setState(() => _reload());
                                }
                              },
                            ),
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
      ),
    );
  }
}