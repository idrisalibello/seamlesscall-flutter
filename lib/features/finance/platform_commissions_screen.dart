import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:seamlesscall/features/finance/data/finance_repository.dart';
import 'package:seamlesscall/features/finance/platform_commission_details_screen.dart';
import 'package:seamlesscall/features/people/data/models/provider_model.dart';

import '../../common/widgets/main_layout.dart';

class PlatformCommissionsScreen extends StatefulWidget {
  const PlatformCommissionsScreen({super.key});

  @override
  State<PlatformCommissionsScreen> createState() =>
      _PlatformCommissionsScreenState();
}

class _PlatformCommissionsScreenState extends State<PlatformCommissionsScreen> {
  final FinanceRepository _repo = FinanceRepository();

  DateTimeRange? _selectedRange;
  int? _providerId; // null => all
  String? _status; // null => all, confirmed|unconfirmed

  int _pageSize = 20;
  int _page = 1;

  bool _loading = false;
  String? _error;

  bool _loadingProviders = false;
  List<Provider> _providers = const [];

  bool _loadingConfig = false;
  double _commissionRate = 0.15;

  Map<String, dynamic>? _listPayload;
  Map<String, dynamic>? _summaryPayload;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );

    _loadProviders();
    _fetchAll();
  }

  Future<void> _loadProviders() async {
    setState(() => _loadingProviders = true);
    try {
      final p = await _repo.getProviders();
      setState(() {
        _providers = p;
        _loadingProviders = false;
      });
    } catch (_) {
      setState(() => _loadingProviders = false);
    }
  }

  Future<void> _fetchAll() async {
    if (_selectedRange == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // config
      setState(() => _loadingConfig = true);
      try {
        final cfg = await _repo.getCommissionConfig();
        final r = cfg['rate'];
        final parsed = (r is num) ? r.toDouble() : double.tryParse('$r');
        if (parsed != null) {
          _commissionRate = parsed;
        }
      } catch (_) {
        // non-blocking
      } finally {
        if (mounted) setState(() => _loadingConfig = false);
      }

      final from = _ymd(_selectedRange!.start);
      final to = _ymd(_selectedRange!.end);

      final list = await _repo.getPlatformCommissions(
        fromDate: from,
        toDate: to,
        page: _page,
        pageSize: _pageSize,
        providerId: _providerId,
        status: _status,
      );

      final summary = await _repo.getPlatformCommissionsSummary(
        fromDate: from,
        toDate: to,
        providerId: _providerId,
        status: _status,
      );

      setState(() {
        _listPayload = list;
        _summaryPayload = summary;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickRange() async {
    final current = _selectedRange;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: current,
    );
    if (picked == null) return;
    setState(() {
      _selectedRange = picked;
      _page = 1;
    });
    await _fetchAll();
  }

  Future<void> _editRate() async {
    final controller = TextEditingController(
      text: (_commissionRate * 100).toStringAsFixed(2),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Set Commission Rate (%)'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'e.g. 15',
              suffixText: '%',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final raw = controller.text.trim();
                final p = double.tryParse(raw);
                if (p == null) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Enter a valid number.')),
                  );
                  return;
                }
                if (p < 0 || p > 100) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Rate must be between 0 and 100.'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx, p / 100);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    setState(() => _loading = true);
    try {
      final updated = await _repo.updateCommissionConfig(rate: result);
      final r = updated['rate'];
      final parsed = (r is num) ? r.toDouble() : double.tryParse('$r');
      if (parsed != null) {
        setState(() => _commissionRate = parsed);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Commission rate updated to ${(result * 100).toStringAsFixed(2)}%',
            ),
          ),
        );
      }
      await _fetchAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update rate: $e')));
      }
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final rows = ((_listPayload?['rows'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final pagination = (_listPayload?['pagination'] as Map?) ?? {};

    final totalPages = (pagination['total_pages'] is int)
        ? pagination['total_pages'] as int
        : int.tryParse('${pagination['total_pages']}') ?? 1;
    final safePage = _page.clamp(1, math.max(1, totalPages)).toInt();
    if (safePage != _page) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _page = safePage);
      });
    }

    final rate = (_summaryPayload?['rate'] is num)
        ? (_summaryPayload?['rate'] as num).toDouble()
        : double.tryParse('${_summaryPayload?['rate']}') ?? _commissionRate;

    final grossTotal = (_summaryPayload?['gross_total'] is num)
        ? (_summaryPayload?['gross_total'] as num).toDouble()
        : double.tryParse('${_summaryPayload?['gross_total']}') ?? 0;

    final confirmed = (_summaryPayload?['confirmed'] as Map?) ?? {};
    final unconfirmed = (_summaryPayload?['unconfirmed'] as Map?) ?? {};

    final confirmedCommission = (confirmed['commission_total'] is num)
        ? (confirmed['commission_total'] as num).toDouble()
        : double.tryParse('${confirmed['commission_total']}') ?? 0;

    final projectedCommission = (unconfirmed['commission_total'] is num)
        ? (unconfirmed['commission_total'] as num).toDouble()
        : double.tryParse('${unconfirmed['commission_total']}') ?? 0;

    final projectedGross = (unconfirmed['gross_total'] is num)
        ? (unconfirmed['gross_total'] as num).toDouble()
        : double.tryParse('${unconfirmed['gross_total']}') ?? 0;

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Platform Commissions',
                  style: theme.textTheme.headlineSmall,
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _loading ? null : _pickRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _selectedRange == null
                            ? 'Pick range'
                            : '${_ymd(_selectedRange!.start)} → ${_ymd(_selectedRange!.end)}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: (_loading || _loadingConfig)
                          ? null
                          : _editRate,
                      icon: const Icon(Icons.percent),
                      label: Text('Rate: ${(rate * 100).toStringAsFixed(2)}%'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filters row
            Row(
              children: [
                // provider filter
                SizedBox(
                  width: 280,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Provider',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        isExpanded: true,
                        value: _providerId,
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('All providers'),
                          ),
                          ..._providers.map(
                            (p) => DropdownMenuItem<int?>(
                              value: p.id,
                              child: Text(p.name),
                            ),
                          ),
                        ],
                        onChanged: _loading || _loadingProviders
                            ? null
                            : (v) async {
                                setState(() {
                                  _providerId = v;
                                  _page = 1;
                                });
                                await _fetchAll();
                              },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // status filter
                SizedBox(
                  width: 240,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        isExpanded: true,
                        value: _status,
                        items: const [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'unconfirmed',
                            child: Text('Unconfirmed'),
                          ),
                          DropdownMenuItem<String?>(
                            value: 'confirmed',
                            child: Text('Confirmed'),
                          ),
                        ],
                        onChanged: _loading
                            ? null
                            : (v) async {
                                setState(() {
                                  _status = v;
                                  _page = 1;
                                });
                                await _fetchAll();
                              },
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Gross: ₦${grossTotal.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Summary cards (clarity)
            Row(
              children: [
                _summaryCard(
                  'Confirmed Commission',
                  '₦${confirmedCommission.toStringAsFixed(2)}',
                ),
                const SizedBox(width: 12),
                _summaryCard(
                  'Projected Commission',
                  '₦${projectedCommission.toStringAsFixed(2)}',
                  subtitle:
                      'Unconfirmed gross ₦${projectedGross.toStringAsFixed(2)}',
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (_loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else
              Expanded(
                child: Card(
                  child: Column(
                    children: [
                      _tableHeader(),
                      const Divider(height: 1),
                      Expanded(
                        child: rows.isEmpty
                            ? const Center(child: Text('No records'))
                            : ListView.separated(
                                itemCount: rows.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (ctx, i) {
                                  final r = rows[i];
                                  final isConfirmed =
                                      (r['commission_status']?.toString() ??
                                          '') ==
                                      'confirmed';

                                  return ListTile(
                                    title: Text(
                                      '${r['reference']} • ₦${_toMoney(r['commission_amount'])}',
                                    ),
                                    subtitle: Text(
                                      'Provider: ${r['provider']} • Job: ${r['job_id'] == null ? '—' : 'JOB-${r['job_id']}'} • ${r['date']}',
                                    ),
                                    trailing: _statusChip(isConfirmed),
                                    onTap: () async {
                                      final res = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              PlatformCommissionDetailsScreen(
                                                commission: r,
                                              ),
                                        ),
                                      );

                                      // If details confirmed something, refresh
                                      if (res == true) {
                                        await _fetchAll();
                                      }
                                    },
                                  );
                                },
                              ),
                      ),
                      const Divider(height: 1),
                      _paginationRow(totalPages: totalPages),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, {String? subtitle}) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Reference',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Provider',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              'Commission',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paginationRow({required int totalPages}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Text('Page $_page of $totalPages'),
          const Spacer(),
          DropdownButton<int>(
            value: _pageSize,
            items: const [
              DropdownMenuItem(value: 20, child: Text('20')),
              DropdownMenuItem(value: 50, child: Text('50')),
              DropdownMenuItem(value: 100, child: Text('100')),
            ],
            onChanged: _loading
                ? null
                : (v) async {
                    if (v == null) return;
                    setState(() {
                      _pageSize = v;
                      _page = 1;
                    });
                    await _fetchAll();
                  },
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: _loading || _page <= 1
                ? null
                : () async {
                    setState(() => _page -= 1);
                    await _fetchAll();
                  },
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            onPressed: _loading || _page >= totalPages
                ? null
                : () async {
                    setState(() => _page += 1);
                    await _fetchAll();
                  },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool isConfirmed) {
    final label = isConfirmed ? 'Confirmed' : 'Unconfirmed';
    final color = isConfirmed ? Colors.green : Colors.orange;
    return Container(
      width: 120,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  static String _ymd(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String _toMoney(dynamic v) {
    final n = (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;
    return n.toStringAsFixed(2);
  }
}
