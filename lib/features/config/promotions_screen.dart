import 'package:flutter/material.dart';
import 'package:seamlesscall/common/widgets/main_layout.dart';
import 'package:seamlesscall/features/config/data/models/promotion_model.dart';
import 'package:seamlesscall/features/config/data/promotion_repository.dart';
import 'package:seamlesscall/features/config/promotions_details_screen.dart';
import 'package:seamlesscall/features/config/promotions_edit_screen.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final PromotionRepository _repo = PromotionRepository();
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = false;
  String? _error;
  String _type = 'All';
  String _status = 'All';
  List<Promotion> _rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rows = await _repo.getPromotions(
        q: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
        promotionType: _type == 'All' ? null : _type.toLowerCase(),
        status: _status == 'All' ? null : _status.toLowerCase(),
      );

      setState(() => _rows = rows);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Color _statusColor(BuildContext context, String status) {
    return status == 'active' ? Colors.green : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => const PromotionsEditScreen(),
              ),
            );
            if (changed == true) {
              _load();
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Promotion'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Promotions', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text(
                'Manage global, service, provider, and coupon promotions',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: 280,
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Search title / code / target',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _load(),
                    ),
                  ),
                  SizedBox(
                    width: 220,
                    child: DropdownButtonFormField<String>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: 'Promotion type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'All', child: Text('All')),
                        DropdownMenuItem(value: 'Global', child: Text('Global')),
                        DropdownMenuItem(value: 'Service', child: Text('Service')),
                        DropdownMenuItem(value: 'Provider', child: Text('Provider')),
                        DropdownMenuItem(value: 'Coupon', child: Text('Coupon')),
                      ],
                      onChanged: (v) {
                        setState(() => _type = v ?? 'All');
                        _load();
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
                      onChanged: (v) {
                        setState(() => _status = v ?? 'All');
                        _load();
                      },
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _buildBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading && _rows.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_rows.isEmpty) {
      return const Center(child: Text('No promotions found.'));
    }

    return ListView.separated(
      itemCount: _rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final row = _rows[index];
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const Icon(Icons.campaign),
            title: Text(row.title),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(label: Text(row.promotionType)),
                      Chip(label: Text(row.discountLabel)),
                      Chip(
                        label: Text(row.status),
                        backgroundColor: _statusColor(context, row.status).withOpacity(.15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Target: ${row.targetLabel}'),
                  Text('Validity: ${row.validityLabel}'),
                  if ((row.code ?? '').isNotEmpty) Text('Code: ${row.code}'),
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final changed = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => PromotionsDetailsScreen(promotionId: row.id!),
                ),
              );
              if (changed == true) {
                _load();
              }
            },
          ),
        );
      },
    );
  }
}