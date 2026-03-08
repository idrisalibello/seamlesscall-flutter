import 'package:flutter/material.dart';
import 'package:seamlesscall/common/widgets/main_layout.dart';
import 'package:seamlesscall/features/admin/data/admin_repository.dart';
import 'package:seamlesscall/features/config/data/models/category_model.dart';
import 'package:seamlesscall/features/config/data/models/promotion_model.dart';
import 'package:seamlesscall/features/config/data/models/service_model.dart';
import 'package:seamlesscall/features/config/data/promotion_repository.dart';

class PromotionsEditScreen extends StatefulWidget {
  final Promotion? existing;

  const PromotionsEditScreen({super.key, this.existing});

  @override
  State<PromotionsEditScreen> createState() => _PromotionsEditScreenState();
}

class _PromotionsEditScreenState extends State<PromotionsEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final PromotionRepository _repo = PromotionRepository();
  final AdminRepository _adminRepo = AdminRepository();

  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _discountValueCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _usageLimitCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();

  bool _saving = false;
  bool _loadingDeps = false;

  String _promotionType = 'global';
  String _discountType = 'percent';
  String _status = 'active';

  List<Category> _categories = [];
  List<Service> _services = [];
  List<Map<String, dynamic>> _providers = [];

  int? _categoryId;
  int? _serviceId;
  int? _providerId;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _seed();
  }

  void _seed() async {
    final p = widget.existing;
    if (p != null) {
      _titleCtrl.text = p.title;
      _descriptionCtrl.text = p.description ?? '';
      _discountValueCtrl.text = p.discountValue.toString();
      _codeCtrl.text = p.code ?? '';
      _usageLimitCtrl.text = p.usageLimit?.toString() ?? '';
      _startDateCtrl.text = p.startDate?.split(' ').first ?? '';
      _endDateCtrl.text = p.endDate?.split(' ').first ?? '';
      _promotionType = p.promotionType;
      _discountType = p.discountType;
      _status = p.status;
      _serviceId = p.serviceId;
      _providerId = p.providerId;
    }

    await _loadDependencies();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    _discountValueCtrl.dispose();
    _codeCtrl.dispose();
    _usageLimitCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDependencies() async {
    setState(() => _loadingDeps = true);
    try {
      _categories = await _adminRepo.getCategories();
      _providers = await _repo.getProviders();

      if (_serviceId != null) {
        for (final c in _categories) {
          final list = await _adminRepo.getServicesByCategory(c.id);
          final hit = list.where((s) => s.id == _serviceId).toList();
          if (hit.isNotEmpty) {
            _categoryId = c.id;
            _services = list;
            break;
          }
        }
      }

      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() {});
    } finally {
      if (mounted) setState(() => _loadingDeps = false);
    }
  }

  Future<void> _loadServices(int? categoryId) async {
    if (categoryId == null) {
      setState(() {
        _categoryId = null;
        _services = [];
        _serviceId = null;
      });
      return;
    }

    final list = await _adminRepo.getServicesByCategory(categoryId);
    setState(() {
      _categoryId = categoryId;
      _services = list;
      if (!_services.any((s) => s.id == _serviceId)) {
        _serviceId = null;
      }
    });
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime initial = DateTime.now();
    if (controller.text.trim().isNotEmpty) {
      initial = DateTime.tryParse(controller.text.trim()) ?? DateTime.now();
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
      setState(() {});
    }
  }

  Promotion _buildPayload() {
  return Promotion(
    id: widget.existing?.id,
    title: _titleCtrl.text.trim(),
    description: _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim(),
    promotionType: _promotionType,
    discountType: _discountType,
    discountValue: double.tryParse(_discountValueCtrl.text.trim()) ?? 0,
    code: _promotionType == 'coupon' && _codeCtrl.text.trim().isNotEmpty
        ? _codeCtrl.text.trim().toUpperCase()
        : null,
    categoryId: _promotionType == 'service' ? _categoryId : null,
    serviceId: _promotionType == 'service' ? _serviceId : null,
    providerId: _promotionType == 'provider' ? _providerId : null,
    startDate: _startDateCtrl.text.trim().isEmpty ? null : _startDateCtrl.text.trim(),
    endDate: _endDateCtrl.text.trim().isEmpty ? null : _endDateCtrl.text.trim(),
    usageLimit: _usageLimitCtrl.text.trim().isEmpty
        ? null
        : int.tryParse(_usageLimitCtrl.text.trim()),
    status: _status,
  );
}
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final payload = _buildPayload();

      if (_isEdit) {
        await _repo.updatePromotion(widget.existing!.id!, payload);
      } else {
        await _repo.createPromotion(payload);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit Promotion' : 'New Promotion'),
        ),
        body: _loadingDeps
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 420,
                            child: TextFormField(
                              controller: _titleCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                if ((v ?? '').trim().length < 3) {
                                  return 'Enter a valid title';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: DropdownButtonFormField<String>(
                              value: _promotionType,
                              decoration: const InputDecoration(
                                labelText: 'Promotion type',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'global',
                                  child: Text('Global'),
                                ),
                                DropdownMenuItem(
                                  value: 'service',
                                  child: Text('Service'),
                                ),
                                DropdownMenuItem(
                                  value: 'provider',
                                  child: Text('Provider'),
                                ),
                                DropdownMenuItem(
                                  value: 'coupon',
                                  child: Text('Coupon'),
                                ),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  _promotionType = v ?? 'global';
                                  if (_promotionType != 'service') {
                                    _categoryId = null;
                                    _serviceId = null;
                                    _services = [];
                                  }
                                  if (_promotionType != 'provider') {
                                    _providerId = null;
                                  }
                                  if (_promotionType != 'coupon') {
                                    _codeCtrl.clear();
                                  }
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text('Active'),
                                ),
                                DropdownMenuItem(
                                  value: 'inactive',
                                  child: Text('Inactive'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _status = v ?? 'active'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 220,
                            child: DropdownButtonFormField<String>(
                              value: _discountType,
                              decoration: const InputDecoration(
                                labelText: 'Discount type',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'percent',
                                  child: Text('Percent'),
                                ),
                                DropdownMenuItem(
                                  value: 'fixed',
                                  child: Text('Fixed amount'),
                                ),
                              ],
                              onChanged: (v) => setState(
                                () => _discountType = v ?? 'percent',
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: _discountValueCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: const InputDecoration(
                                labelText: 'Discount value',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) {
                                final value = double.tryParse((v ?? '').trim());
                                if (value == null || value <= 0) {
                                  return 'Enter a valid discount';
                                }
                                if (_discountType == 'percent' && value > 100) {
                                  return 'Percent cannot exceed 100';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: _usageLimitCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Usage limit (optional)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_promotionType == 'coupon')
                        SizedBox(
                          width: 320,
                          child: TextFormField(
                            controller: _codeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Coupon code',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (_promotionType == 'coupon' &&
                                  (v ?? '').trim().isEmpty) {
                                return 'Coupon code is required';
                              }
                              return null;
                            },
                          ),
                        ),

                      if (_promotionType == 'service') ...[
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Service Target',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Select a category. Selecting a service is optional. If no service is selected, the promotion will apply to all services in that category.',
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    SizedBox(
                                      width: 260,
                                      child: DropdownButtonFormField<int?>(
                                        value: _categoryId,
                                        decoration: const InputDecoration(
                                          labelText: 'Category',
                                          border: OutlineInputBorder(),
                                        ),
                                        items: [
                                          const DropdownMenuItem<int?>(
                                            value: null,
                                            child: Text('Select category'),
                                          ),
                                          ..._categories.map(
                                            (c) => DropdownMenuItem<int?>(
                                              value: c.id,
                                              child: Text(c.name),
                                            ),
                                          ),
                                        ],
                                        onChanged: (v) => _loadServices(v),
                                        validator: (v) {
                                          if (_promotionType == 'service' &&
                                              v == null &&
                                              _serviceId == null) {
                                            return 'Select a category or a service';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: 320,
                                      child: DropdownButtonFormField<int?>(
                                        value: _serviceId,
                                        decoration: const InputDecoration(
                                          labelText:
                                              'Specific service (optional)',
                                          border: OutlineInputBorder(),
                                          helperText:
                                              'Leave empty to apply to all services in the category',
                                        ),
                                        items: [
                                          const DropdownMenuItem<int?>(
                                            value: null,
                                            child: Text(
                                              'All services in category',
                                            ),
                                          ),
                                          ..._services.map(
                                            (s) => DropdownMenuItem<int?>(
                                              value: s.id,
                                              child: Text(s.name),
                                            ),
                                          ),
                                        ],
                                        onChanged: (v) =>
                                            setState(() => _serviceId = v),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      if (_promotionType == 'provider') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 360,
                          child: DropdownButtonFormField<int?>(
                            value: _providerId,
                            decoration: const InputDecoration(
                              labelText: 'Provider',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('Select'),
                              ),
                              ..._providers.map(
                                (p) => DropdownMenuItem<int?>(
                                  value: int.tryParse('${p['id']}'),
                                  child: Text(
                                    '${p['name'] ?? 'Provider'} (#${p['id']})',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => _providerId = v),
                            validator: (v) {
                              if (_promotionType == 'provider' && v == null) {
                                return 'Select a provider';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: _startDateCtrl,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Start date',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _pickDate(_startDateCtrl),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 220,
                            child: TextFormField(
                              controller: _endDateCtrl,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'End date',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () => _pickDate(_endDateCtrl),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: const Icon(Icons.save),
                            label: Text(
                              _saving ? 'Saving...' : 'Save Promotion',
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
