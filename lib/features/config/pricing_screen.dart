import 'package:flutter/material.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/models/category_model.dart';
import 'package:seamlesscall/features/config/data/models/service_model.dart';
import 'package:seamlesscall/features/config/data/models/pricing_profile_model.dart';

import '../../common/widgets/main_layout.dart';
import 'pricing_details_screen.dart';
import 'pricing_edit_screen.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final AdminRepository _repo = AdminRepository();

  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  List<Category> _categories = [];
  List<Service> _services = [];

  int? _categoryId;
  int? _serviceId;
  String _status = 'All';
  String _basis = 'All';

  int _page = 1;
  int _pageSize = 20;
  int _totalPages = 1;

  List<PricingProfile> _rows = [];

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
      _categories = await _repo.getCategories();
      await _loadRows(resetPage: true);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadServicesForCategory(int? categoryId) async {
    if (categoryId == null) {
      setState(() {
        _services = [];
        _serviceId = null;
      });
      return;
    }
    try {
      final list = await _repo.getServicesByCategory(categoryId);
      setState(() {
        _services = list;
        _serviceId = null;
      });
    } catch (_) {
      // non-fatal
    }
  }

  Future<void> _loadRows({bool resetPage = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (resetPage) _page = 1;
    });

    try {
      final res = await _repo.getPricingProfiles(
        page: _page,
        pageSize: _pageSize,
        categoryId: _categoryId,
        serviceId: _serviceId,
        status: _status == 'All' ? null : _status.toLowerCase(),
        pricingBasis: _basis == 'All' ? null : _basis,
        q: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );

      final rowsRaw = List<Map<String, dynamic>>.from(res['rows'] ?? []);
      final pagination = Map<String, dynamic>.from(res['pagination'] ?? {});

      setState(() {
        _rows = rowsRaw.map((m) => PricingProfile.fromMap(m)).toList();
        _totalPages = (pagination['total_pages'] ?? 1) is int
            ? pagination['total_pages'] as int
            : int.tryParse('${pagination['total_pages']}') ?? 1;
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _loading = false);
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
          icon: const Icon(Icons.add),
          label: const Text('Add Pricing'),
          onPressed: () async {
            final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const PricingEditScreen()),
            );
            if (changed == true) {
              _loadRows(resetPage: true);
            }
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pricing', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Text('Configure service pricing behavior, bands, and adjustments',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              _buildFilters(context),
              const SizedBox(height: 16),
              Expanded(child: _buildBody(context)),
              const SizedBox(height: 10),
              _buildPager(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
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
              labelText: 'Search service/category',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _loadRows(resetPage: true),
          ),
        ),
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<int?>(
            value: _categoryId,
            decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ..._categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
            ],
            onChanged: (v) async {
              setState(() => _categoryId = v);
              await _loadServicesForCategory(v);
              _loadRows(resetPage: true);
            },
          ),
        ),
        SizedBox(
          width: 240,
          child: DropdownButtonFormField<int?>(
            value: _serviceId,
            decoration: const InputDecoration(labelText: 'Service', border: OutlineInputBorder()),
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ..._services.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))),
            ],
            onChanged: (v) {
              setState(() => _serviceId = v);
              _loadRows(resetPage: true);
            },
          ),
        ),
        SizedBox(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Active', child: Text('Active')),
              DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
            ],
            onChanged: (v) {
              setState(() => _status = v ?? 'All');
              _loadRows(resetPage: true);
            },
          ),
        ),
        SizedBox(
          width: 260,
          child: DropdownButtonFormField<String>(
            value: _basis,
            decoration: const InputDecoration(labelText: 'Pricing basis', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
              DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
              DropdownMenuItem(value: 'unit', child: Text('Per unit')),
              DropdownMenuItem(value: 'quote_after_inspection', child: Text('Quote after inspection')),
            ],
            onChanged: (v) {
              setState(() => _basis = v ?? 'All');
              _loadRows(resetPage: true);
            },
          ),
        ),
        OutlinedButton.icon(
          onPressed: _loading ? null : () => _loadRows(resetPage: true),
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
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
      return const Center(child: Text('No pricing profiles found.'));
    }

    return ListView.separated(
      itemCount: _rows.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = _rows[i];
        final isActive = p.status == 'active';
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final changed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => PricingDetailsScreen(profileId: p.id)),
            );
            if (changed == true) {
              _loadRows();
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  child: const Icon(Icons.attach_money),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.serviceName ?? 'Service #${p.serviceId}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${p.categoryName ?? 'Category'} • ${p.pricingBasis}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        children: [
                          _chip('Inspection: ${p.currency} ${p.inspectionFee.toStringAsFixed(2)}'),
                          _chip('Band: ${p.currency} ${p.priceBandMin.toStringAsFixed(0)}–${p.priceBandMax.toStringAsFixed(0)}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: isActive ? Colors.green : Colors.grey),
                    const SizedBox(width: 6),
                    Text(isActive ? 'Active' : 'Inactive', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                const SizedBox(width: 10),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.withOpacity(0.35)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildPager(BuildContext context) {
    return Row(
      children: [
        Text('Page $_page / $_totalPages', style: Theme.of(context).textTheme.bodySmall),
        const Spacer(),
        IconButton(
          onPressed: (_page <= 1 || _loading) ? null : () {
            setState(() => _page -= 1);
            _loadRows();
          },
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          onPressed: (_page >= _totalPages || _loading) ? null : () {
            setState(() => _page += 1);
            _loadRows();
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
