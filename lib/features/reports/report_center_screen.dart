import 'package:flutter/material.dart';
import 'package:seamlesscall/core/utils/exporter.dart';
import 'package:seamlesscall/features/reports/data/reports_repository.dart';

enum ReportSection {
  overview,
  operations,
  providers,
  customers,
  finance,
  promotions,
}

class ReportCenterScreen extends StatefulWidget {
  final ReportSection section;

  const ReportCenterScreen({
    super.key,
    required this.section,
  });

  @override
  State<ReportCenterScreen> createState() => _ReportCenterScreenState();
}

class _ReportCenterScreenState extends State<ReportCenterScreen> {
  final ReportsRepository _repo = ReportsRepository();

  late DateTimeRange _range;
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _payload;

  String _status = 'All';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _range = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final from = _ymd(_range.start);
      final to = _ymd(_range.end);

      Map<String, dynamic> data;

      switch (widget.section) {
        case ReportSection.overview:
          data = await _repo.getOverview(from: from, to: to);
          break;
        case ReportSection.operations:
          data = await _repo.getOperations(from: from, to: to, status: _status);
          break;
        case ReportSection.providers:
          data = await _repo.getProviders(from: from, to: to);
          break;
        case ReportSection.customers:
          data = await _repo.getCustomers(from: from, to: to);
          break;
        case ReportSection.finance:
          data = await _repo.getFinance(from: from, to: to);
          break;
        case ReportSection.promotions:
          data = await _repo.getPromotions(from: from, to: to);
          break;
      }

      if (!mounted) return;
      setState(() {
        _payload = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String get _title {
    switch (widget.section) {
      case ReportSection.overview:
        return 'Reports Overview';
      case ReportSection.operations:
        return 'Operations Reports';
      case ReportSection.providers:
        return 'Provider Reports';
      case ReportSection.customers:
        return 'Customer Reports';
      case ReportSection.finance:
        return 'Finance Reports';
      case ReportSection.promotions:
        return 'Promotion Reports';
    }
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      initialDateRange: _range,
    );

    if (picked != null) {
      setState(() => _range = picked);
      await _load();
    }
  }

  Future<void> _exportCsv() async {
    final rows = _payload?['rows'];
    if (rows is! List || rows.isEmpty) return;

    final headers = (rows.first as Map).keys.map((e) => e.toString()).toList();
    final buffer = StringBuffer()
      ..writeln(headers.map(_csvCell).join(','));

    for (final row in rows) {
      final map = Map<String, dynamic>.from(row as Map);
      buffer.writeln(
        headers.map((key) => _csvCell('${map[key] ?? ''}')).join(','),
      );
    }

    await downloadTextFile(
      filename: '${_title.toLowerCase().replaceAll(' ', '_')}.csv',
      content: buffer.toString(),
      mimeType: 'text/csv;charset=utf-8',
    );
  }

  Future<void> _printReport() async {
    final summary = _payload?['summary'];
    final rows = _payload?['rows'];

    final buffer = StringBuffer()
      ..writeln('<h2>$_title</h2>')
      ..writeln(
        '<div class="meta">From ${_ymd(_range.start)} to ${_ymd(_range.end)}</div>',
      );

    if (summary is Map) {
      buffer.writeln('<h3>Summary</h3><table><tbody>');
      for (final entry in summary.entries) {
        buffer.writeln(
          '<tr><th>${_escape(entry.key)}</th><td>${_escape('${entry.value}')}</td></tr>',
        );
      }
      buffer.writeln('</tbody></table><br/>');
    }

    if (rows is List && rows.isNotEmpty) {
      final headers = Map<String, dynamic>.from(rows.first as Map).keys.toList();

      buffer.writeln('<h3>Rows</h3><table><thead><tr>');
      for (final header in headers) {
        buffer.writeln('<th>${_escape(header)}</th>');
      }
      buffer.writeln('</tr></thead><tbody>');

      for (final row in rows) {
        final map = Map<String, dynamic>.from(row as Map);
        buffer.writeln('<tr>');
        for (final header in headers) {
          buffer.writeln('<td>${_escape('${map[header] ?? ''}')}</td>');
        }
        buffer.writeln('</tr>');
      }

      buffer.writeln('</tbody></table>');
    }

    await openPrintWindow(
      title: _title,
      htmlBody: buffer.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payload = _payload ?? const <String, dynamic>{};
    final summary = payload['summary'] is Map
        ? Map<String, dynamic>.from(payload['summary'] as Map)
        : <String, dynamic>{};
    final rows = payload['rows'] is List
        ? (payload['rows'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList()
        : <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _toolbar(),
            const SizedBox(height: 16),
            if (_error != null) _errorBanner(_error!),
            if (_error != null) const SizedBox(height: 16),
            if (summary.isNotEmpty) _summaryGrid(summary),
            if (summary.isNotEmpty) const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _table(rows),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: _pickRange,
          icon: const Icon(Icons.date_range),
          label: Text('${_ymd(_range.start)} → ${_ymd(_range.end)}'),
        ),
        if (widget.section == ReportSection.operations)
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'scheduled', child: Text('Scheduled')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                DropdownMenuItem(value: 'escalated', child: Text('Escalated')),
              ],
              onChanged: (value) async {
                setState(() => _status = value ?? 'All');
                await _load();
              },
            ),
          ),
        ElevatedButton.icon(
          onPressed: _exportCsv,
          icon: const Icon(Icons.download),
          label: const Text('CSV'),
        ),
        OutlinedButton.icon(
          onPressed: _printReport,
          icon: const Icon(Icons.print),
          label: const Text('Print / PDF'),
        ),
      ],
    );
  }

  Widget _summaryGrid(Map<String, dynamic> summary) {
    final entries = summary.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      itemCount: entries.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisExtent: 100,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final entry = entries[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _labelize(entry.key),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const Spacer(),
                Text(
                  '${entry.value}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _table(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return const Center(
        child: Text('No records found for the selected report range.'),
      );
    }

    final columns = rows.first.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: columns
              .map((c) => DataColumn(label: Text(_labelize(c))))
              .toList(),
          rows: rows.map((row) {
            return DataRow(
              cells: columns
                  .map((c) => DataCell(Text('${row[c] ?? ''}')))
                  .toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        border: Border.all(color: Colors.red.withOpacity(0.30)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  String _ymd(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String _labelize(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((e) => e.isEmpty ? e : '${e[0].toUpperCase()}${e.substring(1)}')
        .join(' ');
  }

  String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _escape(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}