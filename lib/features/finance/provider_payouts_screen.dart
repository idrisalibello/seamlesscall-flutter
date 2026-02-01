import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:seamlesscall/core/utils/exporter.dart';
import 'package:seamlesscall/features/finance/data/finance_repository.dart';
import 'package:seamlesscall/features/finance/provider_payout_details_screen.dart';
import 'package:seamlesscall/features/people/data/models/provider_model.dart';

import '../../common/widgets/main_layout.dart';

class ProviderPayoutsScreen extends StatefulWidget {
  const ProviderPayoutsScreen({super.key});

  @override
  State<ProviderPayoutsScreen> createState() => _ProviderPayoutsScreenState();
}

class _ProviderPayoutsScreenState extends State<ProviderPayoutsScreen> {
  final FinanceRepository _repo = FinanceRepository();

  DateTimeRange? _selectedRange;

  int? _providerId; // null => all
  String _status = 'All';

  int _pageSize = 20;
  int _page = 1;

  bool _loading = false;
  String? _error;

  bool _loadingProviders = false;
  List<Provider> _providers = const [];

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
      // non-blocking
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
      final from = _ymd(_selectedRange!.start);
      final to = _ymd(_selectedRange!.end);
      final apiStatus = _status == 'All' ? null : _status;

      final list = await _repo.getFinancePayouts(
        fromDate: from,
        toDate: to,
        page: _page,
        pageSize: _pageSize,
        providerId: _providerId,
        status: apiStatus,
      );

      final summary = await _repo.getFinancePayoutsSummary(
        fromDate: from,
        toDate: to,
        providerId: _providerId,
        status: apiStatus,
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

  Future<void> _exportCsvCurrentView(List<Map<String, dynamic>> rows) async {
    try {
      final csv = _buildCsv(rows);
      final from = _selectedRange == null ? 'na' : _ymd(_selectedRange!.start);
      final to = _selectedRange == null ? 'na' : _ymd(_selectedRange!.end);

      await downloadTextFile(
        filename: 'provider_payouts_${from}_to_${to}_page_${_page}.csv',
        content: csv,
        mimeType: 'text/csv;charset=utf-8',
      );
    } catch (_) {
      _toast('Export supported on Web for now.');
    }
  }

  String _buildCsv(List<Map<String, dynamic>> rows) {
    String esc(String? v) {
      final s = (v ?? '').replaceAll('"', '""');
      return '"$s"';
    }

    final buf = StringBuffer();
    buf.writeln(
      'ID,Provider ID,Provider,Amount,Status,Payment Method,Transaction ID,Requested At,Processed At',
    );

    for (final r in rows) {
      buf.writeln(
        [
          esc('${r['id'] ?? ''}'),
          esc('${r['provider_id'] ?? ''}'),
          esc('${r['provider'] ?? ''}'),
          esc('${r['amount'] ?? ''}'),
          esc('${r['status'] ?? ''}'),
          esc('${r['payment_method'] ?? ''}'),
          esc('${r['transaction_id'] ?? ''}'),
          esc('${r['requested_at'] ?? ''}'),
          esc('${r['processed_at'] ?? ''}'),
        ].join(','),
      );
    }

    return buf.toString();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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

    final byStatus = (_summaryPayload?['by_status'] as Map?) ?? {};
    final pending = (byStatus['pending'] as Map?) ?? const {};
    final processed = (byStatus['processed'] as Map?) ?? const {};
    final failed = (byStatus['failed'] as Map?) ?? const {};
    final grandTotal = (_summaryPayload?['total'] ?? 0).toString();

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Provider Payouts', style: theme.textTheme.headlineSmall),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: (_loading || _selectedRange == null)
                          ? null
                          : () => _exportCsvCurrentView(rows),
                      icon: const Icon(Icons.download),
                      label: const Text('Export CSV'),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      tooltip: 'Refresh',
                      onPressed: _loading ? null : _fetchAll,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            _buildFilters(theme),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.4,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _SummaryItem(
                    label: 'Total (range)',
                    value: _money(grandTotal),
                  ),
                  const SizedBox(width: 32),
                  _SummaryItem(
                    label: 'Pending',
                    value: _money(pending['total'] ?? 0),
                  ),
                  const SizedBox(width: 32),
                  _SummaryItem(
                    label: 'Paid',
                    value: _money(processed['total'] ?? 0),
                  ),
                  const SizedBox(width: 32),
                  _SummaryItem(
                    label: 'Failed',
                    value: _money(failed['total'] ?? 0),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTable(theme, rows),
            ),

            const SizedBox(height: 8),
            _buildPagination(theme, totalPages),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(ThemeData theme) {
    final rangeText = _selectedRange == null
        ? 'Select date range'
        : '${_ymd(_selectedRange!.start)} → ${_ymd(_selectedRange!.end)}';

    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: _loading ? null : _pickRange,
          icon: const Icon(Icons.date_range),
          label: Text(rangeText),
        ),
        SizedBox(
          width: 260,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Provider',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        SizedBox(
          width: 220,
          child: DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'processed', child: Text('Paid')),
              DropdownMenuItem(value: 'failed', child: Text('Failed')),
            ],
            onChanged: _loading
                ? null
                : (v) async {
                    if (v == null) return;
                    setState(() {
                      _status = v;
                      _page = 1;
                    });
                    await _fetchAll();
                  },
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<int>(
            value: _pageSize,
            decoration: const InputDecoration(
              labelText: 'Page size',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
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
        ),
      ],
    );
  }

  Widget _buildTable(ThemeData theme, List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return const Center(
        child: Text('No payouts found for the selected range.'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Provider')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Requested')),
          DataColumn(label: Text('Processed')),
          DataColumn(label: Text('Txn ID')),
          DataColumn(label: Text('')),
        ],
        rows: rows.map((r) {
          final status = (r['status'] ?? '').toString();
          return DataRow(
            cells: [
              DataCell(Text('${r['id'] ?? ''}')),
              DataCell(Text('${r['provider'] ?? ''}')),
              DataCell(Text(_money(r['amount'] ?? 0))),
              DataCell(Text(_prettyStatus(status))),
              DataCell(Text('${r['requested_at'] ?? ''}')),
              DataCell(Text('${r['processed_at'] ?? ''}')),
              DataCell(Text('${r['transaction_id'] ?? ''}')),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProviderPayoutDetailsScreen(payoutRow: r),
                          ),
                        );
                        if (changed == true) {
                          await _fetchAll();
                        }
                      },
                      child: const Text('View'),
                    ),
                    if (status == 'failed') ...[
                      const SizedBox(width: 6),
                      Tooltip(
                        message: 'Retry & Mark Paid',
                        child: IconButton(
                          icon: const Icon(Icons.restart_alt),
                          onPressed: () async {
                            // Same flow: open details where Retry UX exists
                            final changed = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProviderPayoutDetailsScreen(payoutRow: r),
                              ),
                            );
                            if (changed == true) {
                              await _fetchAll();
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagination(ThemeData theme, int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Page $_page of $totalPages'),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Previous',
          onPressed: (_loading || _page <= 1)
              ? null
              : () async {
                  setState(() => _page--);
                  await _fetchAll();
                },
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton(
          tooltip: 'Next',
          onPressed: (_loading || _page >= totalPages)
              ? null
              : () async {
                  setState(() => _page++);
                  await _fetchAll();
                },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

String _ymd(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _prettyStatus(String status) {
  switch (status) {
    case 'pending':
      return 'Pending';
    case 'processed':
      return 'Paid';
    case 'failed':
      return 'Failed';
    default:
      return status;
  }
}

String _money(dynamic raw) {
  final v = double.tryParse(raw.toString()) ?? 0;
  return '₦${v.toStringAsFixed(2)}';
}
