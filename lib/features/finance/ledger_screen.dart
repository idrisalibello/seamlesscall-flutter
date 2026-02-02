import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:seamlesscall/features/finance/data/finance_repository.dart';

import '../../common/widgets/main_layout.dart';

class LedgerScreen extends StatefulWidget {
  final String? initialReference;

  const LedgerScreen({super.key, this.initialReference});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final FinanceRepository _repo = FinanceRepository();

  DateTimeRange? _selectedRange;

  String _transactionType = 'All';
  late final TextEditingController _referenceCtrl;

  int _page = 1;
  int _pageSize = 20;

  bool _loading = false;
  String? _error;

  Map<String, dynamic>? _list;
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );

    _referenceCtrl = TextEditingController(text: widget.initialReference ?? '');

    _fetch();
  }

  @override
  void dispose() {
    _referenceCtrl.dispose();
    super.dispose();
  }

  String _ymd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedRange,
    );
    if (picked == null) return;
    setState(() {
      _selectedRange = picked;
      _page = 1;
    });
    await _fetch();
  }

  Future<void> _fetch() async {
    if (_selectedRange == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final from = _ymd(_selectedRange!.start);
      final to = _ymd(_selectedRange!.end);

      final type = _transactionType == 'All' ? null : _transactionType;
      final ref = _referenceCtrl.text.trim().isEmpty
          ? null
          : _referenceCtrl.text.trim();

      final list = await _repo.getFinanceLedger(
        fromDate: from,
        toDate: to,
        page: _page,
        pageSize: _pageSize,
        transactionType: type,
        reference: ref,
      );

      final summary = await _repo.getFinanceLedgerSummary(
        fromDate: from,
        toDate: to,
        transactionType: type,
        reference: ref,
      );

      setState(() {
        _list = list;
        _summary = summary;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _showDetails(Map<String, dynamic> row) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Ledger #${row['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _kv(
              'User',
              '${row['user_name'] ?? '-'} (${row['user_role'] ?? '-'})',
            ),
            _kv('Type', '${row['transaction_type'] ?? '-'}'),
            _kv('Amount', '₦${row['amount'] ?? '-'}'),
            _kv('Reference', '${row['reference'] ?? '-'}'),
            _kv('Date', '${row['created_at'] ?? '-'}'),
            _kv('Description', '${row['description'] ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final payload = _list;
    final rows = ((payload?['rows'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final pagination = (payload?['pagination'] as Map?) ?? {};
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

    final rangeLabel = _selectedRange == null
        ? 'Select Range'
        : '${_ymd(_selectedRange!.start)} → ${_ymd(_selectedRange!.end)}';

    // ✅ derive type options from summary
    final byType = (_summary?['by_type'] as Map?) ?? {};
    final typeOptions = <String>[
      'All',
      ...byType.keys.map((e) => e.toString()).toList()..sort(),
    ];

    // ✅ keep selection valid
    final currentType = typeOptions.contains(_transactionType)
        ? _transactionType
        : 'All';

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ledger', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(rangeLabel),
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Type: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: currentType,
                      items: typeOptions
                          .map(
                            (v) => DropdownMenuItem(value: v, child: Text(v)),
                          )
                          .toList(),
                      onChanged: _loading
                          ? null
                          : (v) async {
                              if (v == null) return;
                              setState(() {
                                _transactionType = v;
                                _page = 1;
                              });
                              await _fetch();
                            },
                    ),
                  ],
                ),

                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _referenceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Reference',
                      hintText: 'Search by reference',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) async {
                      setState(() => _page = 1);
                      await _fetch();
                    },
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _page = 1);
                          await _fetch();
                        },
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (byType.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    'Summary: ${_summary?['count'] ?? 0} entries • Total ₦${_summary?['total'] ?? 0}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : rows.isEmpty
                  ? const Center(child: Text('No ledger entries found.'))
                  : ListView.separated(
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final r = rows[index];
                        final id = r['id'];
                        final type = r['transaction_type'] ?? '';
                        final amount = r['amount'] ?? '';
                        final ref = r['reference'] ?? '';
                        final createdAt = r['created_at'] ?? '';

                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.book),
                            title: Text('Ledger #$id • ₦$amount'),
                            subtitle: Text('$type • $ref • $createdAt'),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                            ),
                            onTap: () => _showDetails(r),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Page $_page / $totalPages'),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: (_page <= 1 || _loading)
                      ? null
                      : () async {
                          setState(() => _page--);
                          await _fetch();
                        },
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  onPressed: (_page >= totalPages || _loading)
                      ? null
                      : () async {
                          setState(() => _page++);
                          await _fetch();
                        },
                  icon: const Icon(Icons.chevron_right),
                ),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: _pageSize,
                  items: const [20, 50, 100]
                      .map(
                        (v) =>
                            DropdownMenuItem<int>(value: v, child: Text('$v')),
                      )
                      .toList(),
                  onChanged: _loading
                      ? null
                      : (v) async {
                          if (v == null) return;
                          setState(() {
                            _pageSize = v;
                            _page = 1;
                          });
                          await _fetch();
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
