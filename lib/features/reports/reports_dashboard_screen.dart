import 'package:flutter/material.dart';
import 'package:seamlesscall/core/utils/exporter.dart';
import 'package:seamlesscall/features/reports/data/reports_repository.dart';

class ReportsDashboardScreen extends StatefulWidget {
  final String initialSection;
  final Set<String> permissions;

  const ReportsDashboardScreen({
    super.key,
    this.initialSection = 'overview',
    this.permissions = const <String>{},
  });

  @override
  State<ReportsDashboardScreen> createState() => _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends State<ReportsDashboardScreen>
    with SingleTickerProviderStateMixin {
  final ReportsRepository _repo = ReportsRepository();
  late final List<_ReportSection> _sections;
  late TabController _tabController;

  DateTimeRange? _selectedRange;
  bool _loading = false;
  String? _error;
  bool _exporting = false;

  final Map<String, dynamic> _dataBySection = <String, dynamic>{};
  final Map<String, int> _pageBySection = <String, int>{};
  final Map<String, int> _pageSizeBySection = <String, int>{};
  final Map<String, String> _searchBySection = <String, String>{};
  final Map<String, String> _statusBySection = <String, String>{};
  final Map<String, int?> _providerBySection = <String, int?>{};
  final Map<String, int?> _categoryBySection = <String, int?>{};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );

    _sections = _buildAllowedSections();
    final initialIndex = _sections.indexWhere(
      (section) => section.key == widget.initialSection,
    );
    _tabController = TabController(
      length: _sections.length,
      vsync: this,
      initialIndex: initialIndex >= 0 ? initialIndex : 0,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _fetchCurrent();
    });
    for (final section in _sections) {
      _pageBySection[section.key] = 1;
      _pageSizeBySection[section.key] = 20;
      _searchBySection[section.key] = '';
      _statusBySection[section.key] = 'All';
      _providerBySection[section.key] = null;
      _categoryBySection[section.key] = null;
    }
    _fetchCurrent();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_ReportSection> _buildAllowedSections() {
    final all = <_ReportSection>[
      const _ReportSection('overview', 'Overview', 'view-reports-dashboard'),
      const _ReportSection('operations', 'Operations', 'view-operations-reports'),
      const _ReportSection('providers', 'Providers', 'view-provider-reports'),
      const _ReportSection('customers', 'Customers', 'view-customer-reports'),
      const _ReportSection('finance', 'Finance', 'view-finance-reports'),
      const _ReportSection('promotions', 'Promotions', 'view-promotion-reports'),
    ];

    final allowed = all
        .where((section) => widget.permissions.contains(section.permission))
        .toList();

    return allowed.isEmpty ? [all.first] : allowed;
  }

  _ReportSection get _currentSection => _sections[_tabController.index];

  Future<void> _fetchCurrent() async {
    if (_selectedRange == null || _sections.isEmpty) return;
    final sectionKey = _currentSection.key;

    setState(() {
      _loading = true;
      _error = null;
    });

    final from = _ymd(_selectedRange!.start);
    final to = _ymd(_selectedRange!.end);
    final page = _pageBySection[sectionKey] ?? 1;
    final pageSize = _pageSizeBySection[sectionKey] ?? 20;
    final status = _statusBySection[sectionKey] == 'All'
        ? null
        : _statusBySection[sectionKey];
    final search = _searchBySection[sectionKey];
    final providerId = _providerBySection[sectionKey];
    final categoryId = _categoryBySection[sectionKey];

    try {
      late final Map<String, dynamic> data;
      switch (sectionKey) {
        case 'overview':
          data = await _repo.getSummary(fromDate: from, toDate: to);
          break;
        case 'operations':
          data = await _repo.getOperationsReport(
            fromDate: from,
            toDate: to,
            page: page,
            pageSize: pageSize,
            status: status,
            categoryId: categoryId,
            providerId: providerId,
            search: search,
          );
          break;
        case 'providers':
          data = await _repo.getProvidersReport(
            fromDate: from,
            toDate: to,
            page: page,
            pageSize: pageSize,
            providerStatus: status,
            search: search,
          );
          break;
        case 'customers':
          data = await _repo.getCustomersReport(
            fromDate: from,
            toDate: to,
            page: page,
            pageSize: pageSize,
            search: search,
          );
          break;
        case 'finance':
          data = await _repo.getFinanceReport(
            fromDate: from,
            toDate: to,
            page: page,
            pageSize: pageSize,
            providerId: providerId,
            commissionStatus: status,
          );
          break;
        case 'promotions':
          data = await _repo.getPromotionsReport(
            fromDate: from,
            toDate: to,
            page: page,
            pageSize: pageSize,
            status: status,
          );
          break;
        default:
          data = <String, dynamic>{};
      }

      if (!mounted) return;
      setState(() {
        _dataBySection[sectionKey] = data;
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

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
      initialDateRange: _selectedRange,
    );

    if (picked != null) {
      setState(() {
        _selectedRange = picked;
        for (final section in _sections) {
          _pageBySection[section.key] = 1;
        }
      });
      await _fetchCurrent();
    }
  }

  Future<void> _exportCsv() async {
    if (!widget.permissions.contains('export-reports')) {
      _toast('You do not have export permission.');
      return;
    }
    final rows = _rowsForCurrent();
    if (rows.isEmpty) {
      _toast('No rows available for export.');
      return;
    }

    setState(() => _exporting = true);
    try {
      final csv = _buildCsv(rows);
      await downloadTextFile(
        filename: '${_currentSection.key}_${_ymd(_selectedRange!.start)}_to_${_ymd(_selectedRange!.end)}.csv',
        content: csv,
        mimeType: 'text/csv;charset=utf-8',
      );
      _toast('CSV export started.');
    } catch (e) {
      _toast('Export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _exportPdf() async {
    if (!widget.permissions.contains('export-reports')) {
      _toast('You do not have export permission.');
      return;
    }
    final rows = _rowsForCurrent();
    if (rows.isEmpty) {
      _toast('No rows available for export.');
      return;
    }

    setState(() => _exporting = true);
    try {
      await openPrintWindow(
        title: '${_currentSection.label} Report',
        htmlBody: _buildHtml(rows),
      );
      _toast('Print window opened.');
    } catch (e) {
      _toast('PDF/print export failed: $e');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  List<Map<String, dynamic>> _rowsForCurrent() {
    final payload = _dataBySection[_currentSection.key];
    final rows = payload is Map ? payload['rows'] as List? : null;
    if (rows == null) return const <Map<String, dynamic>>[];
    return rows
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_sections.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No report permissions available.')),
      );
    }

    final payload = _dataBySection[_currentSection.key] as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports Center'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _loading ? null : _fetchCurrent,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _sections.map((section) => Tab(text: section.label)).toList(),
        ),
      ),
      body: Column(
        children: [
          _topControls(context, payload),
          if (_error != null) _errorBanner(_error!),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _sections.map((section) {
                      final sectionPayload = _dataBySection[section.key]
                          as Map<String, dynamic>?;
                      return _sectionView(section, sectionPayload);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _topControls(BuildContext context, Map<String, dynamic>? payload) {
    final exportAllowed = widget.permissions.contains('export-reports');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(
                  _selectedRange == null
                      ? 'Select Date Range'
                      : '${_ymd(_selectedRange!.start)} → ${_ymd(_selectedRange!.end)}',
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (value) {
                    setState(() {
                      _searchBySection[_currentSection.key] = value.trim();
                      _pageBySection[_currentSection.key] = 1;
                    });
                    _fetchCurrent();
                  },
                ),
              ),
              if (_currentSection.key != 'overview')
                _statusDropdown(payload),
              if (_currentSection.key == 'operations' ||
                  _currentSection.key == 'finance')
                _providerDropdown(payload),
              if (_currentSection.key == 'operations')
                _categoryDropdown(payload),
              FilledButton.icon(
                onPressed: _loading ? null : _fetchCurrent,
                icon: const Icon(Icons.filter_alt),
                label: const Text('Apply'),
              ),
              OutlinedButton.icon(
                onPressed: (!exportAllowed || _exporting) ? null : _exportCsv,
                icon: const Icon(Icons.table_chart),
                label: const Text('CSV'),
              ),
              OutlinedButton.icon(
                onPressed: (!exportAllowed || _exporting) ? null : _exportPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Rich executive summaries and enterprise detail tables with live filters and export.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDropdown(Map<String, dynamic>? payload) {
    List<String> statuses = const <String>[];
    final meta = (payload?['meta'] as Map?)?.cast<String, dynamic>() ?? {};

    if (_currentSection.key == 'operations') {
      statuses = List<String>.from(meta['available_statuses'] ?? const []);
    } else if (_currentSection.key == 'providers') {
      statuses = List<String>.from(meta['available_provider_statuses'] ?? const []);
    } else if (_currentSection.key == 'finance') {
      statuses = List<String>.from(meta['commission_statuses'] ?? const []);
    } else if (_currentSection.key == 'promotions') {
      statuses = List<String>.from(meta['statuses'] ?? const []);
    }

    final value = _statusBySection[_currentSection.key] ?? 'All';

    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        value: statuses.contains(value) || value == 'All' ? value : 'All',
        decoration: const InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          const DropdownMenuItem(value: 'All', child: Text('All')),
          ...statuses.map(
            (status) => DropdownMenuItem(
              value: status,
              child: Text(status),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _statusBySection[_currentSection.key] = value ?? 'All';
            _pageBySection[_currentSection.key] = 1;
          });
        },
      ),
    );
  }

  Widget _providerDropdown(Map<String, dynamic>? payload) {
    final meta = (payload?['meta'] as Map?)?.cast<String, dynamic>() ?? {};
    final providers = (meta['providers'] as List? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final selected = _providerBySection[_currentSection.key];

    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<int?>(
        value: selected,
        decoration: const InputDecoration(
          labelText: 'Provider',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('All Providers')),
          ...providers.map(
            (provider) => DropdownMenuItem<int?>(
              value: provider['id'] as int?,
              child: Text('${provider['name']}'),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _providerBySection[_currentSection.key] = value;
            _pageBySection[_currentSection.key] = 1;
          });
        },
      ),
    );
  }

  Widget _categoryDropdown(Map<String, dynamic>? payload) {
    final meta = (payload?['meta'] as Map?)?.cast<String, dynamic>() ?? {};
    final categories = (meta['categories'] as List? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final selected = _categoryBySection[_currentSection.key];

    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<int?>(
        value: selected,
        decoration: const InputDecoration(
          labelText: 'Category',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          const DropdownMenuItem<int?>(value: null, child: Text('All Categories')),
          ...categories.map(
            (category) => DropdownMenuItem<int?>(
              value: category['id'] as int?,
              child: Text('${category['name']}'),
            ),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _categoryBySection[_currentSection.key] = value;
            _pageBySection[_currentSection.key] = 1;
          });
        },
      ),
    );
  }

  Widget _sectionView(_ReportSection section, Map<String, dynamic>? payload) {
    if (payload == null) {
      return const Center(child: Text('No data loaded yet.'));
    }

    final cards = (payload['cards'] as List? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final rows = (payload['rows'] as List? ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final notes = (payload['notes'] as List? ?? const [])
        .map((e) => e.toString())
        .toList();
    final pagination = (payload['pagination'] as Map?)?.cast<String, dynamic>() ?? {};
    final breakdowns = (payload['breakdowns'] as Map?)?.cast<String, dynamic>() ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cards.isNotEmpty) _cardsGrid(cards),
          if (payload['job_trend'] is List) ...[
            const SizedBox(height: 14),
            _miniTableCard('Job Trend', payload['job_trend'] as List),
          ],
          if (payload['revenue_trend'] is List) ...[
            const SizedBox(height: 14),
            _miniTableCard('Revenue Trend', payload['revenue_trend'] as List),
          ],
          if (breakdowns.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: breakdowns.entries.map((entry) {
                return SizedBox(
                  width: 420,
                  child: _miniTableCard(
                    _prettify(entry.key),
                    entry.value as List? ?? const [],
                  ),
                );
              }).toList(),
            ),
          ],
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    ...notes.map(
                      (note) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $note'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 14),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${section.label} Detail Rows',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    _rowsTable(rows),
                    const SizedBox(height: 12),
                    _paginationBar(pagination),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No rows found for the selected filters.'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cardsGrid(List<Map<String, dynamic>> cards) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards.map((card) {
        final value = card['value'];
        return SizedBox(
          width: 220,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${card['label']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value is num ? _formatValue(value) : '$value',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _miniTableCard(String title, List rawRows) {
    final rows = rawRows
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
    if (rows.isEmpty) return const SizedBox.shrink();

    final keys = rows.first.keys.toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: keys.map((key) => DataColumn(label: Text(_prettify(key)))).toList(),
                rows: rows.take(8).map((row) {
                  return DataRow(
                    cells: keys
                        .map((key) => DataCell(Text('${row[key] ?? ''}')))
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rowsTable(List<Map<String, dynamic>> rows) {
    final keys = rows.first.keys.toList(growable: false);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        columns: keys.map((key) => DataColumn(label: Text(_prettify(key)))).toList(),
        rows: rows.map((row) {
          return DataRow(
            cells: keys
                .map((key) => DataCell(Text('${row[key] ?? ''}')))
                .toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _paginationBar(Map<String, dynamic> pagination) {
    final totalPages = (pagination['total_pages'] as num?)?.toInt() ?? 1;
    final page = (pagination['page'] as num?)?.toInt() ?? 1;
    final currentKey = _currentSection.key;

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Page $page of $totalPages'),
        OutlinedButton(
          onPressed: page <= 1
              ? null
              : () {
                  setState(() => _pageBySection[currentKey] = page - 1);
                  _fetchCurrent();
                },
          child: const Text('Previous'),
        ),
        OutlinedButton(
          onPressed: page >= totalPages
              ? null
              : () {
                  setState(() => _pageBySection[currentKey] = page + 1);
                  _fetchCurrent();
                },
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget _errorBanner(String msg) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(msg),
    );
  }

  String _buildCsv(List<Map<String, dynamic>> rows) {
    final keys = rows.first.keys.toList(growable: false);
    final buffer = StringBuffer();
    buffer.writeln(keys.map(_csvCell).join(','));
    for (final row in rows) {
      buffer.writeln(keys.map((key) => _csvCell(row[key])).join(','));
    }
    return buffer.toString();
  }

  String _buildHtml(List<Map<String, dynamic>> rows) {
    final keys = rows.first.keys.toList(growable: false);
    final head = keys.map((key) => '<th>${_escapeHtml(_prettify(key))}</th>').join();
    final body = rows.map((row) {
      final tds = keys
          .map((key) => '<td>${_escapeHtml('${row[key] ?? ''}')}</td>')
          .join();
      return '<tr>$tds</tr>';
    }).join();

    return '''
<h2>${_escapeHtml(_currentSection.label)} Report</h2>
<div class="meta">Range: ${_ymd(_selectedRange!.start)} to ${_ymd(_selectedRange!.end)}</div>
<table>
  <thead><tr>$head</tr></thead>
  <tbody>$body</tbody>
</table>
''';
  }

  String _csvCell(Object? value) {
    final text = '${value ?? ''}'.replaceAll('"', '""');
    return '"$text"';
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _ymd(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _formatValue(num value) {
    final isWhole = value % 1 == 0;
    return isWhole ? value.toInt().toString() : value.toStringAsFixed(2);
  }

  String _prettify(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ReportSection {
  final String key;
  final String label;
  final String permission;

  const _ReportSection(this.key, this.label, this.permission);
}
