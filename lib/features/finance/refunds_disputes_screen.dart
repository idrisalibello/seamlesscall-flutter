import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:seamlesscall/core/utils/exporter.dart';
import 'package:seamlesscall/features/finance/data/finance_repository.dart';

import '../../common/widgets/main_layout.dart';
import 'refund_dispute_details_screen.dart';

class RefundsDisputesScreen extends StatefulWidget {
  const RefundsDisputesScreen({super.key});

  @override
  State<RefundsDisputesScreen> createState() => _RefundsDisputesScreenState();
}

class _RefundsDisputesScreenState extends State<RefundsDisputesScreen>
    with SingleTickerProviderStateMixin {
  final FinanceRepository _repo = FinanceRepository();

  late final TabController _tab;

  DateTimeRange? _selectedRange;

  // Refund filters
  String _refundStatus = 'All';
  int _refundPage = 1;
  int _refundPageSize = 20;

  // Dispute filters
  String _disputeStatus = 'All';
  int _disputePage = 1;
  int _disputePageSize = 20;

  bool _loading = false;
  String? _error;

  Map<String, dynamic>? _refundsList;
  Map<String, dynamic>? _refundsSummary;

  Map<String, dynamic>? _disputesList;
  Map<String, dynamic>? _disputesSummary;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);

    final now = DateTime.now();
    _selectedRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );

    _fetchActive();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  String _ymd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
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
      _refundPage = 1;
      _disputePage = 1;
    });
    await _fetchActive();
  }

  Future<void> _fetchActive() async {
    if (_selectedRange == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final from = _ymd(_selectedRange!.start);
      final to = _ymd(_selectedRange!.end);

      if (_tab.index == 0) {
        final s = _refundStatus == 'All' ? null : _refundStatus;
        final list = await _repo.getFinanceRefunds(
          fromDate: from,
          toDate: to,
          page: _refundPage,
          pageSize: _refundPageSize,
          status: s,
        );
        final summary = await _repo.getFinanceRefundsSummary(
          fromDate: from,
          toDate: to,
          status: s,
        );

        setState(() {
          _refundsList = list;
          _refundsSummary = summary;
          _loading = false;
        });
      } else {
        final s = _disputeStatus == 'All' ? null : _disputeStatus;
        final list = await _repo.getFinanceDisputes(
          fromDate: from,
          toDate: to,
          page: _disputePage,
          pageSize: _disputePageSize,
          status: s,
        );
        final summary = await _repo.getFinanceDisputesSummary(
          fromDate: from,
          toDate: to,
          status: s,
        );

        setState(() {
          _disputesList = list;
          _disputesSummary = summary;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _updateRefundStatus(int refundId, String status) async {
    try {
      await _repo.updateRefundStatus(refundId: refundId, status: status);
      _toast('Refund #$refundId marked $status');
      await _fetchActive();
    } catch (e) {
      _toast(e.toString());
    }
  }

  Future<void> _updateDisputeStatus(int disputeId, String status) async {
    try {
      await _repo.updateDisputeStatus(disputeId: disputeId, status: status);
      _toast('Dispute #$disputeId marked $status');
      await _fetchActive();
    } catch (e) {
      _toast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fromLabel = _selectedRange == null
        ? 'Select Range'
        : '${_ymd(_selectedRange!.start)} → ${_ymd(_selectedRange!.end)}';

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
                  'Refunds & Disputes',
                  style: theme.textTheme.headlineSmall,
                ),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(fromLabel),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _tab,
              onTap: (_) async {
                setState(() => _error = null);
                await _fetchActive();
              },
              tabs: const [
                Tab(text: 'Refunds'),
                Tab(text: 'Disputes'),
              ],
            ),
            const SizedBox(height: 12),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [_refundsTab(theme), _disputesTab(theme)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Refunds tab ----

  Widget _refundsTab(ThemeData theme) {
    final payload = _refundsList;
    final rows = ((payload?['rows'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final pagination = (payload?['pagination'] as Map?) ?? {};
    final totalPages = (pagination['total_pages'] is int)
        ? pagination['total_pages'] as int
        : int.tryParse('${pagination['total_pages']}') ?? 1;

    final safePage = _refundPage.clamp(1, math.max(1, totalPages)).toInt();
    if (safePage != _refundPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _refundPage = safePage);
      });
    }

    final byStatus = (_refundsSummary?['by_status'] as Map?) ?? {};
    final pending = (byStatus['pending'] as Map?) ?? const {};
    final approved = (byStatus['approved'] as Map?) ?? const {};
    final rejected = (byStatus['rejected'] as Map?) ?? const {};

    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _statusDropdown(
              label: 'Status',
              value: _refundStatus,
              options: const ['All', 'pending', 'approved', 'rejected'],
              onChanged: (v) async {
                if (v == null) return;
                setState(() {
                  _refundStatus = v;
                  _refundPage = 1;
                });
                await _fetchActive();
              },
            ),
            _miniStatCard('Pending', pending),
            _miniStatCard('Approved', approved),
            _miniStatCard('Rejected', rejected),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : rows.isEmpty
              ? const Center(child: Text('No refunds found.'))
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final r = rows[index];
                    final id = int.tryParse('${r['id']}') ?? 0;
                    final status = '${r['status'] ?? ''}';
                    final amount = '${r['amount'] ?? ''}';
                    final customer = '${r['customer'] ?? ''}';
                    final submittedAt = '${r['submitted_at'] ?? ''}';

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.currency_exchange),
                        title: Text('Refund #$id • ₦$amount'),
                        subtitle: Text('$customer • $submittedAt'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _statusPill(status),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RefundDisputeDetailsScreen(
                                mode: RefundDisputeMode.refund,
                                payload: r,
                                onApprove: status == 'pending'
                                    ? () => _updateRefundStatus(id, 'approved')
                                    : null,
                                onReject: status == 'pending'
                                    ? () => _updateRefundStatus(id, 'rejected')
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        _pager(
          page: _refundPage,
          totalPages: totalPages,
          pageSize: _refundPageSize,
          onPrev: _refundPage <= 1 || _loading
              ? null
              : () async {
                  setState(() => _refundPage--);
                  await _fetchActive();
                },
          onNext: _refundPage >= totalPages || _loading
              ? null
              : () async {
                  setState(() => _refundPage++);
                  await _fetchActive();
                },
          onPageSizeChanged: (v) async {
            setState(() {
              _refundPageSize = v;
              _refundPage = 1;
            });
            await _fetchActive();
          },
        ),
      ],
    );
  }

  // ---- Disputes tab ----

  Widget _disputesTab(ThemeData theme) {
    final payload = _disputesList;
    final rows = ((payload?['rows'] as List?) ?? const [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final pagination = (payload?['pagination'] as Map?) ?? {};
    final totalPages = (pagination['total_pages'] is int)
        ? pagination['total_pages'] as int
        : int.tryParse('${pagination['total_pages']}') ?? 1;

    final safePage = _disputePage.clamp(1, math.max(1, totalPages)).toInt();
    if (safePage != _disputePage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _disputePage = safePage);
      });
    }

    final byStatus = (_disputesSummary?['by_status'] as Map?) ?? {};
    final pending = (byStatus['pending'] as Map?) ?? const {};
    final resolved = (byStatus['resolved'] as Map?) ?? const {};
    final dismissed = (byStatus['dismissed'] as Map?) ?? const {};

    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _statusDropdown(
              label: 'Status',
              value: _disputeStatus,
              options: const ['All', 'pending', 'resolved', 'dismissed'],
              onChanged: (v) async {
                if (v == null) return;
                setState(() {
                  _disputeStatus = v;
                  _disputePage = 1;
                });
                await _fetchActive();
              },
            ),
            _miniStatCard('Pending', pending),
            _miniStatCard('Resolved', resolved),
            _miniStatCard('Dismissed', dismissed),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : rows.isEmpty
              ? const Center(child: Text('No disputes found.'))
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final d = rows[index];
                    final id = int.tryParse('${d['id']}') ?? 0;
                    final status = '${d['status'] ?? ''}';
                    final jobTitle = '${d['job_title'] ?? ''}';
                    final provider = '${d['provider'] ?? ''}';
                    final createdAt = '${d['created_at'] ?? ''}';

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.report_problem),
                        title: Text('Dispute #$id • $jobTitle'),
                        subtitle: Text('$provider • $createdAt'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _statusPill(status),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_ios, size: 14),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RefundDisputeDetailsScreen(
                                mode: RefundDisputeMode.dispute,
                                payload: d,
                                onResolve: status == 'pending'
                                    ? () => _updateDisputeStatus(id, 'resolved')
                                    : null,
                                onDismiss: status == 'pending'
                                    ? () =>
                                          _updateDisputeStatus(id, 'dismissed')
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        _pager(
          page: _disputePage,
          totalPages: totalPages,
          pageSize: _disputePageSize,
          onPrev: _disputePage <= 1 || _loading
              ? null
              : () async {
                  setState(() => _disputePage--);
                  await _fetchActive();
                },
          onNext: _disputePage >= totalPages || _loading
              ? null
              : () async {
                  setState(() => _disputePage++);
                  await _fetchActive();
                },
          onPageSizeChanged: (v) async {
            setState(() {
              _disputePageSize = v;
              _disputePage = 1;
            });
            await _fetchActive();
          },
        ),
      ],
    );
  }

  // ---- UI helpers ----

  Widget _statusDropdown({
    required String label,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: '),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: value,
          items: options
              .map((s) => DropdownMenuItem<String>(value: s, child: Text(s)))
              .toList(),
          onChanged: _loading ? null : onChanged,
        ),
      ],
    );
  }

  Widget _miniStatCard(String label, Map data) {
    final count = data['count'] ?? 0;
    final total = data['total'];
    final subtitle = total == null ? '$count' : '$count • ₦$total';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(String status) {
    Color c;
    switch (status) {
      case 'approved':
      case 'resolved':
        c = Colors.green;
        break;
      case 'rejected':
      case 'dismissed':
        c = Colors.red;
        break;
      case 'pending':
      default:
        c = Colors.orange;
        break;
    }
    return Text(
      status,
      style: TextStyle(color: c, fontWeight: FontWeight.w600),
    );
  }

  Widget _pager({
    required int page,
    required int totalPages,
    required int pageSize,
    required VoidCallback? onPrev,
    required VoidCallback? onNext,
    required ValueChanged<int> onPageSizeChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('Page $page / $totalPages'),
        const SizedBox(width: 12),
        IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        const SizedBox(width: 20),
        DropdownButton<int>(
          value: pageSize,
          items: const [20, 50, 100]
              .map((v) => DropdownMenuItem<int>(value: v, child: Text('$v')))
              .toList(),
          onChanged: _loading
              ? null
              : (v) {
                  if (v == null) return;
                  onPageSizeChanged(v);
                },
        ),
      ],
    );
  }
}
