import 'package:flutter/material.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/models/category_model.dart';
import 'package:seamlesscall/features/config/data/models/service_model.dart';
import 'package:seamlesscall/features/config/data/models/pricing_profile_model.dart';

import '../../common/widgets/main_layout.dart';

class PricingEditScreen extends StatefulWidget {
  final int? profileId;
  const PricingEditScreen({super.key, this.profileId});

  @override
  State<PricingEditScreen> createState() => _PricingEditScreenState();
}

class _PricingEditScreenState extends State<PricingEditScreen> {
  final AdminRepository _repo = AdminRepository();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _saving = false;
  String? _error;

  List<Category> _categories = [];
  List<Service> _services = [];

  int? _categoryId;
  int? _serviceId;

  String _basis = 'quote_after_inspection';
  String _status = 'active';
  String _currency = 'NGN';

  final TextEditingController _inspectionCtrl = TextEditingController();
  final TextEditingController _minimumCtrl = TextEditingController();
  final TextEditingController _bandMinCtrl = TextEditingController();
  final TextEditingController _bandMaxCtrl = TextEditingController();
  final TextEditingController _notesClientCtrl = TextEditingController();
  final TextEditingController _notesProviderCtrl = TextEditingController();

  bool _allowOverride = false;
  final TextEditingController _maxOverrideCtrl = TextEditingController(
    text: '0',
  );
  bool _requireAdminReview = false;
  final TextEditingController _autoFlagCtrl = TextEditingController(text: '0');

  PricingProfile? _existing;

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

      if (widget.profileId != null) {
        _existing = await _repo.getPricingProfile(widget.profileId!);

        _serviceId = _existing!.serviceId;
        _basis = _existing!.pricingBasis;
        _status = _existing!.status;
        _currency = _existing!.currency;

        _inspectionCtrl.text = _existing!.inspectionFee.toString();
        _minimumCtrl.text = _existing!.minimumJobFee.toString();
        _bandMinCtrl.text = _existing!.priceBandMin.toString();
        _bandMaxCtrl.text = _existing!.priceBandMax.toString();
        _notesClientCtrl.text = _existing!.notesForClient ?? '';
        _notesProviderCtrl.text = _existing!.notesForProvider ?? '';
        _allowOverride = _existing!.allowBandOverride == 1;
        _maxOverrideCtrl.text = _existing!.maxOverridePercent.toString();
        _requireAdminReview = _existing!.requireAdminReview == 1;
        _autoFlagCtrl.text = _existing!.autoFlagDisputeThreshold.toString();

        // Best-effort derive category from joined info; otherwise find via services list later.
        _categoryId = _existing!.categoryId;
        if (_categoryId != null) {
          _services = await _repo.getServicesByCategory(_categoryId!);
        }

        if (_categoryId == null) {
          // fallback: scan categories until we find service
          for (final c in _categories) {
            final s = await _repo.getServicesByCategory(c.id);
            final hit = s.where((x) => x.id == _serviceId).toList();
            if (hit.isNotEmpty) {
              _categoryId = c.id;
              _services = s;
              break;
            }
          }
        }
      }
    } catch (e) {
      _error = '$e';
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _inspectionCtrl.dispose();
    _minimumCtrl.dispose();
    _bandMinCtrl.dispose();
    _bandMaxCtrl.dispose();
    _notesClientCtrl.dispose();
    _notesProviderCtrl.dispose();
    _maxOverrideCtrl.dispose();
    _autoFlagCtrl.dispose();
    super.dispose();
  }

  Future<void> _onCategoryChanged(int? v) async {
    setState(() {
      _categoryId = v;
      _serviceId = null;
      _services = [];
    });
    if (v == null) return;
    try {
      final s = await _repo.getServicesByCategory(v);
      setState(() => _services = s);
    } catch (_) {
      // ignore
    }
  }

  String? _numValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (double.tryParse(v.trim()) == null) return 'Number required';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_serviceId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Select a service')));
      return;
    }

    final inspection = double.parse(_inspectionCtrl.text.trim());
    final minimum = double.parse(_minimumCtrl.text.trim());
    final bandMin = double.parse(_bandMinCtrl.text.trim());
    final bandMax = double.parse(_bandMaxCtrl.text.trim());
    if (bandMax < bandMin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Band max must be >= band min')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final profile = PricingProfile(
        id: widget.profileId ?? 0,
        serviceId: _serviceId!,
        pricingBasis: _basis,
        inspectionFee: inspection,
        minimumJobFee: minimum,
        priceBandMin: bandMin,
        priceBandMax: bandMax,
        currency: _currency,
        status: _status,
        notesForClient: _notesClientCtrl.text.trim().isEmpty
            ? null
            : _notesClientCtrl.text.trim(),
        notesForProvider: _notesProviderCtrl.text.trim().isEmpty
            ? null
            : _notesProviderCtrl.text.trim(),
        allowBandOverride: _allowOverride ? 1 : 0,
        maxOverridePercent: int.tryParse(_maxOverrideCtrl.text.trim()) ?? 0,
        requireAdminReview: _requireAdminReview ? 1 : 0,
        autoFlagDisputeThreshold: int.tryParse(_autoFlagCtrl.text.trim()) ?? 0,
        serviceName: null,
        categoryId: null,
        categoryName: null,
      );

      if (widget.profileId == null) {
        await _repo.createPricingProfile(profile);
      } else {
        // ✅ FIX: repo expects Map<String, dynamic>
        await _repo.updatePricingProfile(
          widget.profileId!,
          profile.toPayload(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.profileId != null;

    return MainLayout(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Edit Pricing' : 'Add Pricing',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: (_saving || _loading) ? null : _save,
                    child: Text(_saving ? 'Saving...' : 'Save'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (!_loading && _error != null)
                Expanded(child: Center(child: Text(_error!))),
              if (!_loading && _error == null)
                Expanded(child: _buildForm(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          Text('Target', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Select')),
                    ..._categories.map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ),
                  ],
                  onChanged: (v) => _onCategoryChanged(v),
                  validator: (v) => (v == null) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  value: _serviceId,
                  decoration: const InputDecoration(
                    labelText: 'Service',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Select')),
                    ..._services.map(
                      (s) => DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _serviceId = v),
                  validator: (v) => (v == null) ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Pricing basis', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _basis,
            decoration: const InputDecoration(
              labelText: 'Basis',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
              DropdownMenuItem(value: 'hourly', child: Text('Hourly')),
              DropdownMenuItem(value: 'unit', child: Text('Per unit')),
              DropdownMenuItem(
                value: 'quote_after_inspection',
                child: Text('Quote after inspection'),
              ),
            ],
            onChanged: (v) =>
                setState(() => _basis = v ?? 'quote_after_inspection'),
          ),
          const SizedBox(height: 18),
          Text(
            'Discovery phase (inspection)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _inspectionCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Inspection fee',
              border: OutlineInputBorder(),
            ),
            validator: _numValidator,
          ),
          const SizedBox(height: 18),
          Text(
            'Execution guardrails',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _minimumCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minimum job fee',
              border: OutlineInputBorder(),
            ),
            validator: _numValidator,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bandMinCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Band min',
                    border: OutlineInputBorder(),
                  ),
                  validator: _numValidator,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _bandMaxCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Band max',
                    border: OutlineInputBorder(),
                  ),
                  validator: _numValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Governance', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _allowOverride,
            title: const Text('Allow band override'),
            onChanged: (v) => setState(() => _allowOverride = v),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _maxOverrideCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Max override percent',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _requireAdminReview,
            title: const Text('Require admin review (extreme variance)'),
            onChanged: (v) => setState(() => _requireAdminReview = v),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _autoFlagCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Auto-flag dispute threshold (%)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          Text('Notes', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          TextFormField(
            controller: _notesClientCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Client note',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesProviderCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Provider note',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'active'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
