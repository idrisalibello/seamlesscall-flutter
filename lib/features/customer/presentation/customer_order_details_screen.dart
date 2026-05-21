import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/models/customer_orders_repository.dart';

class CustomerOrderDetailsScreen extends StatefulWidget {
  final String jobId;

  const CustomerOrderDetailsScreen({super.key, required this.jobId});

  @override
  State<CustomerOrderDetailsScreen> createState() =>
      _CustomerOrderDetailsScreenState();
}

class _CustomerOrderDetailsScreenState
    extends State<CustomerOrderDetailsScreen> {
  final CustomerOrdersRepository _repo = CustomerOrdersRepository();

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

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
      final data = await _repo.getOrderDetails(widget.jobId);
      if (!mounted) return;

      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(title: const Text('Order Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(title: const Text('Order Details')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 42),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                ElevatedButton(onPressed: _load, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final data = _data ?? const <String, dynamic>{};
    final job = _map(data['job']);
    final service = _map(data['service']);
    final provider = _map(data['provider']);
    final meta = _map(data['meta']);
    final payment = _map(data['payment_summary']);
    final inspection = data['inspection'] is Map<String, dynamic>
        ? _map(data['inspection'])
        : _map(data['inspection_summary']);
    final description = _decodeDescription(job['description']);
    final timeline = (data['timeline'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final jobId = 'SC-${job['id'] ?? widget.jobId}';
    final title =
        (job['title'] ?? service['name'] ?? 'Service Request').toString();
    final status = _label(job['status']);
    final address = _firstText([
      meta['address'],
      description['address'],
      job['address'],
    ]);
    final note = _firstText([meta['note'], description['note'], job['note']]);
    final scheduledTime = _firstText([
      job['scheduled_time'],
      job['scheduled_at'],
      description['scheduled_at'],
    ]);
    final createdAt = _firstText([job['created_at'], data['created_at']]);
    final updatedAt = _firstText([job['updated_at'], data['updated_at']]);
    final inspectionRequired = _inspectionRequired(inspection, payment);
    final inspectionAmount = _money(
      inspection['amount'] ?? inspection['inspection_fee'] ?? payment['amount'],
      (inspection['currency'] ?? payment['currency'] ?? 'NGN').toString(),
    );

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: _Header(
                    title: title,
                    subtitle: '$jobId - $status',
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: _Section(
                    title: 'Job information',
                    rows: [
                      _InfoRow('Order ID', jobId),
                      _InfoRow('Service', title),
                      _InfoRow('Status', status),
                      _InfoRow('Scheduled time', _emptyDash(scheduledTime)),
                      _InfoRow('Created', _formatDate(createdAt)),
                      _InfoRow('Last updated', _formatDate(updatedAt)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _Section(
                    title: 'Request details',
                    rows: [
                      _InfoRow('Address', _emptyDash(address)),
                      _InfoRow('Customer note', _emptyDash(note)),
                      _InfoRow(
                        'Pricing basis',
                        _label(service['pricing_basis'] ?? job['pricing_basis']),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _Section(
                    title: 'Inspection and payment',
                    rows: [
                      _InfoRow(
                        'Inspection fee',
                        inspectionRequired
                            ? inspectionAmount
                            : 'No inspection fee required',
                      ),
                      _InfoRow(
                        'Payment status',
                        _label(
                          inspection['status'] ?? payment['status'] ?? 'pending',
                        ),
                      ),
                      _InfoRow(
                        'Payment reference',
                        _emptyDash(payment['reference']?.toString()),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _Section(
                    title: 'Technician',
                    rows: [
                      _InfoRow(
                        'Name',
                        _emptyDash(provider['name']?.toString()),
                      ),
                      _InfoRow(
                        'Phone',
                        _emptyDash(provider['phone']?.toString()),
                      ),
                      _InfoRow(
                        'Assigned',
                        provider.isEmpty ? 'Not assigned yet' : 'Assigned',
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: _TimelineSection(items: timeline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _decodeDescription(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return <String, dynamic>{};
  }

  bool _inspectionRequired(
    Map<String, dynamic> inspection,
    Map<String, dynamic> payment,
  ) {
    final explicit = inspection['required'] ??
        inspection['inspection_required'] ??
        payment['inspection_required'];
    final explicitValue = _toBool(explicit);
    if (explicitValue != null) return explicitValue;

    final amount =
        _toDouble(inspection['amount'] ?? inspection['inspection_fee'] ?? payment['amount']);
    return amount > 0;
  }

  bool? _toBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value.toString().trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (['1', 'true', 'yes', 'required'].contains(normalized)) return true;
    if (['0', 'false', 'no', 'not_required', 'none', 'waived']
        .contains(normalized)) {
      return false;
    }
    return null;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = (value ?? '').toString().trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _emptyDash(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? '-' : text;
  }

  String _label(dynamic value) {
    final raw = (value ?? '').toString().trim();
    if (raw.isEmpty) return '-';
    return raw
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1).toLowerCase())
        .join(' ');
  }

  String _money(dynamic value, String currency) {
    final amount = _toDouble(value);
    final prefix = currency.toUpperCase() == 'NGN'
        ? 'NGN '
        : '${currency.toUpperCase()} ';
    if (amount == amount.roundToDouble()) return '$prefix${amount.toInt()}';
    return '$prefix${amount.toStringAsFixed(2)}';
  }

  String _formatDate(String value) {
    final text = value.trim();
    if (text.isEmpty) return '-';

    final parsed = DateTime.tryParse(text);
    if (parsed == null) return text;

    final two = (int v) => v.toString().padLeft(2, '0');
    return '${parsed.year}-${two(parsed.month)}-${two(parsed.day)} ${two(parsed.hour)}:${two(parsed.minute)}';
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onBackground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$title - $subtitle',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onBackground.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;

  const _Section({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map((row) => _DetailLine(row: row)),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final _InfoRow row;

  const _DetailLine({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              row.label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withOpacity(0.60),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              row.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _TimelineSection({required this.items});

  @override
  Widget build(BuildContext context) {
    final rows = items.isEmpty
        ? const [
            _InfoRow('Current update', 'No timeline updates yet.'),
          ]
        : items.map((item) {
            final title = (item['title'] ?? 'Update').toString();
            final subtitle = (item['subtitle'] ?? item['detail'] ?? '')
                .toString()
                .trim();
            final time = (item['time'] ?? item['created_at'] ?? '').toString();
            final value = [
              if (subtitle.isNotEmpty) subtitle,
              if (time.isNotEmpty) time,
            ].join(' - ');
            return _InfoRow(title, value.isEmpty ? '-' : value);
          }).toList();

    return _Section(title: 'Timeline', rows: rows);
  }
}

class _InfoRow {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);
}
