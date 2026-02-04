import 'package:flutter/material.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/models/pricing_adjustment_model.dart';
import 'package:seamlesscall/features/config/data/models/pricing_profile_model.dart';

import '../../common/widgets/main_layout.dart';
import 'pricing_edit_screen.dart';

class PricingDetailsScreen extends StatefulWidget {
  final int profileId;
  const PricingDetailsScreen({super.key, required this.profileId});

  @override
  State<PricingDetailsScreen> createState() => _PricingDetailsScreenState();
}

class _PricingDetailsScreenState extends State<PricingDetailsScreen> {
  final AdminRepository _repo = AdminRepository();
  bool _loading = false;
  String? _error;

  PricingProfile? _profile;
  List<PricingAdjustment> _adjustments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _repo.getPricingProfile(widget.profileId);
      final a = await _repo.getPricingAdjustments(widget.profileId);
      setState(() {
        _profile = p;
        _adjustments = a;
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleProfileStatus() async {
    if (_profile == null) return;
    final next = _profile!.status == 'active' ? 'inactive' : 'active';
    try {
      final updated = await _repo.updatePricingProfileStatus(_profile!.id, next);
      setState(() => _profile = updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile marked $next')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<void> _deleteProfile() async {
    if (_profile == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete pricing profile?'),
        content: const Text('This will remove the pricing configuration for this service.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.deletePricingProfile(_profile!.id);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _openAdjustmentForm({PricingAdjustment? existing}) async {
    final res = await showModalBottomSheet<PricingAdjustment>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AdjustmentForm(profileId: widget.profileId, existing: existing),
    );
    if (res != null) {
      _load();
    }
  }

  Future<void> _toggleAdjustment(PricingAdjustment a) async {
    final next = a.status == 'active' ? 'inactive' : 'active';
    try {
      await _repo.updatePricingAdjustmentStatus(a.id, next);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _deleteAdjustment(PricingAdjustment a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete adjustment?'),
        content: Text(a.label),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _repo.deletePricingAdjustment(a.id);
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Pricing Details', style: Theme.of(context).textTheme.headlineSmall),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (_loading && _profile == null) const Expanded(child: Center(child: CircularProgressIndicator())),
              if (_error != null) Expanded(child: Center(child: Text(_error!))),
              if (!_loading && _profile != null) ...[
                _buildProfileCard(context, _profile!),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text('Adjustments', style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () => _openAdjustmentForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(child: _buildAdjustments(context)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, PricingProfile p) {
    final isActive = p.status == 'active';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.serviceName ?? 'Service #${p.serviceId}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('${p.categoryName ?? 'Category'} • ${p.pricingBasis}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.circle, size: 10, color: isActive ? Colors.green : Colors.grey),
              const SizedBox(width: 6),
              Text(isActive ? 'Active' : 'Inactive'),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _chip('${p.currency} Inspection: ${p.inspectionFee.toStringAsFixed(2)}'),
              _chip('${p.currency} Min job: ${p.minimumJobFee.toStringAsFixed(2)}'),
              _chip('${p.currency} Band: ${p.priceBandMin.toStringAsFixed(0)}–${p.priceBandMax.toStringAsFixed(0)}'),
              _chip('Override: ${p.allowBandOverride == 1 ? 'Yes' : 'No'}'),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final changed = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => PricingEditScreen(profileId: p.id)),
                  );
                  if (changed == true) _load();
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: _toggleProfileStatus,
                icon: const Icon(Icons.toggle_on),
                label: Text(isActive ? 'Deactivate' : 'Activate'),
              ),
              OutlinedButton.icon(
                onPressed: _deleteProfile,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdjustments(BuildContext context) {
    if (_adjustments.isEmpty) {
      return const Center(child: Text('No adjustments configured.'));
    }

    return ListView.separated(
      itemCount: _adjustments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final a = _adjustments[i];
        final isActive = a.status == 'active';
        final valueLabel = a.adjustmentType == 'percent'
            ? '${a.value.toStringAsFixed(0)}%'
            : '${_profile?.currency ?? 'NGN'} ${a.value.toStringAsFixed(2)}';
        final capLabel = a.adjustmentType == 'percent'
            ? 'cap ${a.maxAllowed.toStringAsFixed(0)}%'
            : 'cap ${_profile?.currency ?? 'NGN'} ${a.maxAllowed.toStringAsFixed(2)}';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      children: [
                        _chip('${a.appliesPhase}'),
                        _chip('${a.adjustmentType}: $valueLabel ($capLabel)'),
                        _chip('client approval: ${a.requiresClientApproval == 1 ? 'yes' : 'no'}'),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.circle, size: 10, color: isActive ? Colors.green : Colors.grey),
              const SizedBox(width: 6),
              Text(isActive ? 'Active' : 'Inactive'),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Edit',
                onPressed: () => _openAdjustmentForm(existing: a),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: isActive ? 'Deactivate' : 'Activate',
                onPressed: () => _toggleAdjustment(a),
                icon: const Icon(Icons.toggle_on),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => _deleteAdjustment(a),
                icon: const Icon(Icons.delete_outline),
              ),
            ],
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
}

class _AdjustmentForm extends StatefulWidget {
  final int profileId;
  final PricingAdjustment? existing;

  const _AdjustmentForm({required this.profileId, this.existing});

  @override
  State<_AdjustmentForm> createState() => _AdjustmentFormState();
}

class _AdjustmentFormState extends State<_AdjustmentForm> {
  final AdminRepository _repo = AdminRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _capCtrl;

  String _type = 'flat';
  String _phase = 'execution';
  bool _requiresApproval = true;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _labelCtrl = TextEditingController(text: e?.label ?? '');
    _valueCtrl = TextEditingController(text: e == null ? '' : e.value.toString());
    _capCtrl = TextEditingController(text: e == null ? '' : e.maxAllowed.toString());
    _type = e?.adjustmentType ?? 'flat';
    _phase = e?.appliesPhase ?? 'execution';
    _requiresApproval = (e?.requiresClientApproval ?? 1) == 1;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _valueCtrl.dispose();
    _capCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final value = double.tryParse(_valueCtrl.text.trim()) ?? 0;
      final cap = double.tryParse(_capCtrl.text.trim()) ?? 0;

      if (widget.existing == null) {
        final created = await _repo.createPricingAdjustment(
          widget.profileId,
          PricingAdjustment(
            id: 0,
            profileId: widget.profileId,
            label: _labelCtrl.text.trim(),
            adjustmentType: _type,
            value: value,
            maxAllowed: cap,
            appliesPhase: _phase,
            requiresClientApproval: _requiresApproval ? 1 : 0,
            status: 'active',
          ),
        );
        if (!mounted) return;
        Navigator.pop(context, created);
      } else {
        final payload = {
          'label': _labelCtrl.text.trim(),
          'adjustment_type': _type,
          'value': value,
          'max_allowed': cap,
          'applies_phase': _phase,
          'requires_client_approval': _requiresApproval ? 1 : 0,
        };
        final updated = await _repo.updatePricingAdjustment(widget.existing!.id, payload);
        if (!mounted) return;
        Navigator.pop(context, updated);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEdit ? 'Edit adjustment' : 'Add adjustment', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _labelCtrl,
              decoration: const InputDecoration(labelText: 'Label', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'flat', child: Text('Flat')),
                      DropdownMenuItem(value: 'percent', child: Text('Percent')),
                    ],
                    onChanged: (v) => setState(() => _type = v ?? 'flat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _phase,
                    decoration: const InputDecoration(labelText: 'Phase', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'inspection', child: Text('Inspection')),
                      DropdownMenuItem(value: 'execution', child: Text('Execution')),
                    ],
                    onChanged: (v) => setState(() => _phase = v ?? 'execution'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valueCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Value', border: OutlineInputBorder()),
                    validator: (v) => (double.tryParse((v ?? '').trim()) == null) ? 'Number required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _capCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cap (max)', border: OutlineInputBorder()),
                    validator: (v) => (double.tryParse((v ?? '').trim()) == null) ? 'Number required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _requiresApproval,
              title: const Text('Requires client approval'),
              onChanged: (v) => setState(() => _requiresApproval = v),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Spacer(),
                TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(_saving ? 'Saving...' : (isEdit ? 'Save' : 'Create')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
