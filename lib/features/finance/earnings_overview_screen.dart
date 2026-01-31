import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:seamlesscall/core/utils/exporter.dart';
import 'package:seamlesscall/features/finance/data/finance_repository.dart';
import 'package:seamlesscall/features/finance/earnings_details_screen.dart';

class EarningsOverviewScreen extends StatefulWidget {
  const EarningsOverviewScreen({super.key});

  @override
  State<EarningsOverviewScreen> createState() => _EarningsOverviewScreenState();
}

class _EarningsOverviewScreenState extends State<EarningsOverviewScreen> {
  final FinanceRepository _repo = FinanceRepository();

  DateTimeRange? _selectedRange;

  String _search = '';
  String _status = 'All';

  int _pageSize = 20;
  int _page = 1;

  bool _loading = false;
  String? _error;

  Map<String, dynamic>? _payload;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );

    _fetch();
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

      final data = await _repo.getEarningsOverview(
        fromDate: from,
        toDate: to,
        page: _page,
        pageSize: _pageSize,
      );

      setState(() {
        _payload = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lifetimeTotals = (_payload?['lifetimeTotals'] as Map?) ?? {};
    final rangeTotals = (_payload?['rangeTotals'] as Map?) ?? {};
    final trend = (_payload?['trend'] as List?) ?? const [];
    final serverRows = (_payload?['rows'] as List?) ?? const [];
    final pagination = (_payload?['pagination'] as Map?) ?? {};

    final filtered = serverRows
        .where((raw) {
          final e = raw as Map;
          final provider = (e['provider'] ?? '').toString().toLowerCase();
          final status = (e['status'] ?? '').toString();

          final matchSearch = provider.contains(_search.toLowerCase());
          final matchStatus = _status == 'All' || status == _status;

          return matchSearch && matchStatus;
        })
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final totalPages = (pagination['total_pages'] is int)
        ? pagination['total_pages'] as int
        : int.tryParse('${pagination['total_pages']}') ?? 1;

    final int safePage = _page.clamp(1, math.max(1, totalPages)).toInt();
    if (safePage != _page) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _page = safePage);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings Overview'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _fetch,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final tableHeight = math.max(260.0, constraints.maxHeight * 0.55);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) ...[
                    _errorBanner(_error!),
                    const SizedBox(height: 12),
                  ],

                  const Text(
                    'Summary (All time)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _summaryRow(
                    _asDouble(lifetimeTotals['total']),
                    _asDouble(lifetimeTotals['completed']),
                    _asDouble(lifetimeTotals['pending']),
                  ),
                  const SizedBox(height: 14),

                  const Text(
                    'Summary (Selected range)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _summaryRow(
                    _asDouble(rangeTotals['total']),
                    _asDouble(rangeTotals['completed']),
                    _asDouble(rangeTotals['pending']),
                  ),
                  const SizedBox(height: 12),

                  _rangePicker(context),
                  const SizedBox(height: 12),

                  _miniTrendFromTrendList(trend),
                  const SizedBox(height: 12),

                  _filtersBar(filtered),
                  const SizedBox(height: 10),

                  _paginationBar(
                    totalPages: math.max(1, totalPages),
                    currentPage: safePage,
                    loading: _loading,
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: tableHeight,
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _table(filtered),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorBanner(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.red.withOpacity(0.08),
        border: Border.all(color: Colors.red.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ],
      ),
    );
  }

  Widget _summaryRow(double total, double completed, double pending) {
    return Row(
      children: [
        _summaryCard('Total Earnings', total),
        _summaryCard('Completed', completed),
        _summaryCard('Pending', pending),
      ],
    );
  }

  Widget _summaryCard(String title, double value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              Text(
                '₦${value.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filtersBar(List<Map<String, dynamic>> currentRows) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search provider',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SizedBox(
          width: 160,
          child: DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              labelText: 'Status',
            ),
            items: const [
              'All',
              'Completed',
              'Pending',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _status = v ?? 'All'),
          ),
        ),
        SizedBox(
          width: 140,
          child: DropdownButtonFormField<int>(
            value: _pageSize,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              labelText: 'Page size',
            ),
            items: const [20, 50, 100]
                .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                .toList(),
            onChanged: _loading
                ? null
                : (v) {
                    setState(() {
                      _pageSize = v ?? 20;
                      _page = 1;
                    });
                    _fetch();
                  },
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('PDF'),
          onPressed: _loading ? null : () => _exportPdfCurrentView(currentRows),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.grid_on),
          label: const Text('Excel'),
          onPressed: _loading ? null : () => _exportCsvCurrentView(currentRows),
        ),
      ],
    );
  }

  Widget _paginationBar({
    required int totalPages,
    required int currentPage,
    required bool loading,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Previous',
              onPressed: (loading || currentPage <= 1)
                  ? null
                  : () {
                      setState(() => _page = currentPage - 1);
                      _fetch();
                    },
              icon: const Icon(Icons.chevron_left),
            ),
            Text('Page $currentPage / $totalPages'),
            IconButton(
              tooltip: 'Next',
              onPressed: (loading || currentPage >= totalPages)
                  ? null
                  : () {
                      setState(() => _page = currentPage + 1);
                      _fetch();
                    },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  Widget _table(List<Map<String, dynamic>> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 900),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Date')),
              DataColumn(label: Text('Provider')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: data.map((e) {
              final date = (e['date'] ?? '').toString();
              final provider = (e['provider'] ?? '').toString();
              final amount = e['amount'];
              final status = (e['status'] ?? '').toString();
              return DataRow(
                cells: [
                  DataCell(Text(date.split(' ').first)),
                  DataCell(Text(provider)),
                  DataCell(Text('₦$amount')),
                  DataCell(Text(status)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () => _details(e),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _rangePicker(BuildContext context) {
    final label = _selectedRange == null
        ? 'Select date range'
        : '${_fmt(_selectedRange!.start)} - ${_fmt(_selectedRange!.end)}';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.date_range),
        title: Text(label),
        subtitle: const Text('Max range: 12 months'),
        trailing: const Icon(Icons.chevron_right),
        onTap: _loading
            ? null
            : () async {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: now.subtract(const Duration(days: 365)),
                  lastDate: now,
                  initialDateRange: _selectedRange,
                );
                if (picked == null) return;

                final days =
                    picked.end.difference(picked.start).inDays.abs() + 1;
                final range = (days > 365)
                    ? DateTimeRange(
                        start: picked.end.subtract(const Duration(days: 364)),
                        end: picked.end,
                      )
                    : picked;

                setState(() {
                  _selectedRange = range;
                  _page = 1;
                });
                _fetch();
              },
      ),
    );
  }

  Widget _miniTrendFromTrendList(List trend) {
    final points = trend
        .map((e) => _asDouble((e as Map)['total']))
        .toList()
        .cast<double>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Earnings Trend (Selected Range)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              width: double.infinity,
              child: CustomPaint(painter: _SparklinePainter(points)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsvCurrentView(List<Map<String, dynamic>> rows) async {
    try {
      final csv = _buildCsv(rows);
      final from = _selectedRange == null ? 'na' : _ymd(_selectedRange!.start);
      final to = _selectedRange == null ? 'na' : _ymd(_selectedRange!.end);

      await downloadTextFile(
        filename: 'earnings_${from}_to_${to}_page_${_page}.csv',
        content: csv,
        mimeType: 'text/csv;charset=utf-8',
      );
    } catch (_) {
      _toast('Export supported on Web for now.');
    }
  }

  Future<void> _exportPdfCurrentView(List<Map<String, dynamic>> rows) async {
    try {
      final title = 'Earnings Overview';
      final htmlBody = _buildPrintableHtml(rows);

      await openPrintWindow(title: title, htmlBody: htmlBody);
    } catch (_) {
      _toast('PDF export supported on Web for now.');
    }
  }

  String _buildCsv(List<Map<String, dynamic>> rows) {
    String esc(String? v) {
      final s = (v ?? '').replaceAll('"', '""');
      return '"$s"';
    }

    final buf = StringBuffer();
    buf.writeln('Date,Provider,Amount,Status,Reference');

    for (final r in rows) {
      final date = (r['date'] ?? '').toString().split(' ').first;
      final provider = (r['provider'] ?? '').toString();
      final amount = (r['amount'] ?? '').toString();
      final status = (r['status'] ?? '').toString();
      final reference = (r['reference'] ?? '').toString();

      buf.writeln(
        [
          esc(date),
          esc(provider),
          esc(amount),
          esc(status),
          esc(reference),
        ].join(','),
      );
    }

    return buf.toString();
  }

  String _buildPrintableHtml(List<Map<String, dynamic>> rows) {
    final rangeLabel = _selectedRange == null
        ? 'N/A'
        : '${_fmt(_selectedRange!.start)} - ${_fmt(_selectedRange!.end)}';

    final sb = StringBuffer();
    sb.writeln('<h2>Earnings Overview</h2>');
    sb.writeln('<div class="meta">Range: $rangeLabel | Page: $_page</div>');
    sb.writeln('<table>');
    sb.writeln(
      '<thead><tr>'
      '<th>Date</th><th>Provider</th><th>Amount</th><th>Status</th><th>Reference</th>'
      '</tr></thead>',
    );
    sb.writeln('<tbody>');

    for (final r in rows) {
      final date = (r['date'] ?? '').toString().split(' ').first;
      final provider = _html((r['provider'] ?? '').toString());
      final amount = _html((r['amount'] ?? '').toString());
      final status = _html((r['status'] ?? '').toString());
      final ref = _html((r['reference'] ?? '').toString());

      sb.writeln(
        '<tr>'
        '<td>${_html(date)}</td>'
        '<td>$provider</td>'
        '<td>₦$amount</td>'
        '<td>$status</td>'
        '<td>$ref</td>'
        '</tr>',
      );
    }

    sb.writeln('</tbody></table>');
    return sb.toString();
  }

  String _html(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _details(Map<String, dynamic> earning) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EarningsDetailsScreen(earning: earning),
      ),
    );
  }

  String _fmt(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _ymd(DateTime d) {
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mm-$dd';
  }

  double _asDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  _SparklinePainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final axis = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      axis,
    );

    if (values.isEmpty) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final span = (maxV - minV).abs() < 0.00001 ? 1.0 : (maxV - minV);

    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final norm = (values[i] - minV) / span;
      final x = dx * i;
      final y = size.height - (norm * (size.height - 6)) - 3;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
