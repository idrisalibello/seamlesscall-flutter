import 'package:flutter/material.dart';
import 'package:seamlesscall/features/finance/data/finance_repository.dart';
import '../../common/widgets/main_layout.dart';

class PlatformCommissionDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> commission;

  const PlatformCommissionDetailsScreen({super.key, required this.commission});

  @override
  State<PlatformCommissionDetailsScreen> createState() =>
      _PlatformCommissionDetailsScreenState();
}

class _PlatformCommissionDetailsScreenState
    extends State<PlatformCommissionDetailsScreen> {
  final FinanceRepository _repo = FinanceRepository();

  late Map<String, dynamic> _commission;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _commission = Map<String, dynamic>.from(widget.commission);
  }

  @override
  Widget build(BuildContext context) {
    final gross = _num(_commission['gross_amount']);
    final rate = _num(_commission['commission_rate']);
    final comm = _num(_commission['commission_amount']);
    final net = _num(_commission['provider_net']);

    final isConfirmed =
        (_commission['commission_status']?.toString() ?? '') == 'confirmed';

    return MainLayout(
      child: Column(
        children: [
          // Back AppBar
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, false),
                ),
                const SizedBox(width: 8),
                Text(
                  'Commission Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                if (!isConfirmed)
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _confirmLock,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock),
                    label: const Text('Confirm (Lock)'),
                  ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _summaryCard('Commission', '₦${comm.toStringAsFixed(2)}'),
                      const SizedBox(width: 16),
                      _summaryCard(
                        'Rate',
                        '${(rate * 100).toStringAsFixed(2)}%',
                      ),
                      const SizedBox(width: 16),
                      _summaryCard(
                        'Status',
                        isConfirmed ? 'Confirmed' : 'Unconfirmed',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _row(
                            'Reference',
                            _commission['reference'].toString(),
                          ),
                          _row(
                            'Earning ID',
                            '${_commission['earning_id'] ?? _commission['id'] ?? ''}',
                          ),
                          _row(
                            'Job ID',
                            _commission['job_id'] == null
                                ? '—'
                                : 'JOB-${_commission['job_id']}',
                          ),
                          _row('Provider', _commission['provider'].toString()),
                          _row('Date', (_commission['date'] ?? '—').toString()),
                          const Divider(),
                          _row('Gross Amount', '₦${gross.toStringAsFixed(2)}'),
                          _row(
                            'Commission Amount',
                            '₦${comm.toStringAsFixed(2)}',
                          ),
                          _row('Provider Net', '₦${net.toStringAsFixed(2)}'),
                          const Divider(),
                          _row(
                            'Description',
                            (_commission['description'] ?? '—').toString(),
                          ),
                          if (isConfirmed) ...[
                            const Divider(),
                            _row(
                              'Confirmed At',
                              (_commission['commission_confirmed_at'] ?? '—')
                                  .toString(),
                            ),
                            _row(
                              'Confirmed By (ID)',
                              _commission['commission_confirmed_by'] == null
                                  ? '—'
                                  : _commission['commission_confirmed_by']
                                        .toString(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  if (!isConfirmed)
                    Text(
                      'Unconfirmed items are projected using the current global rate. Confirming will lock the split for reporting.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLock() async {
    final earningId = (_commission['earning_id'] ?? _commission['id']);
    final id = (earningId is int) ? earningId : int.tryParse('$earningId');

    if (id == null || id <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid earning id.')));
      return;
    }

    setState(() => _saving = true);
    try {
      final updated = await _repo.confirmCommission(earningId: id);

      // Merge locked fields into local map
      setState(() {
        _commission['commission_status'] =
            updated['commission_status'] ?? 'confirmed';
        _commission['commission_rate'] = updated['commission_rate'];
        _commission['commission_amount'] = updated['commission_amount'];
        _commission['provider_net'] = updated['provider_net'];
        _commission['commission_confirmed_at'] =
            updated['commission_confirmed_at'];
        _commission['commission_confirmed_by'] =
            updated['commission_confirmed_by'];
        _saving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Commission confirmed and locked.')),
        );
      }

      // Return true so list refreshes
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to confirm: $e')));
      }
    }
  }

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  Widget _summaryCard(String label, dynamic value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 6),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
