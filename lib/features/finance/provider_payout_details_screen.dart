import 'package:flutter/material.dart';
import 'package:seamlesscall/features/finance/data/finance_repository.dart';

import '../../common/widgets/main_layout.dart';

class ProviderPayoutDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> payoutRow; // row returned by /finance/payouts

  const ProviderPayoutDetailsScreen({super.key, required this.payoutRow});

  @override
  State<ProviderPayoutDetailsScreen> createState() =>
      _ProviderPayoutDetailsScreenState();
}

class _ProviderPayoutDetailsScreenState
    extends State<ProviderPayoutDetailsScreen> {
  final FinanceRepository _repo = FinanceRepository();

  bool _saving = false;
  String? _error;

  Map<String, dynamic> get _p => widget.payoutRow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final status = (_p['status'] ?? '').toString();
    final canProcess = status == 'pending' || status == 'failed';
    final isRetry = status == 'failed';

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Payout Details', style: theme.textTheme.headlineSmall),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            Row(
              children: [
                _summaryCard('Amount', _money(_p['amount'] ?? 0)),
                const SizedBox(width: 16),
                _summaryCard('Status', _prettyStatus(status)),
                const SizedBox(width: 16),
                _summaryCard('Requested', '${_p['requested_at'] ?? ''}'),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                children: [
                  _detailRow('Payout ID', '${_p['id'] ?? ''}'),
                  _detailRow('Provider', '${_p['provider'] ?? ''}'),
                  _detailRow('Provider ID', '${_p['provider_id'] ?? ''}'),
                  _detailRow('Payment Method', '${_p['payment_method'] ?? ''}'),
                  _detailRow('Transaction ID', '${_p['transaction_id'] ?? ''}'),
                  _detailRow('Processed At', '${_p['processed_at'] ?? ''}'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (canProcess) ...[
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _saving ? null : _onMarkPaid,
                    icon: Icon(
                      isRetry ? Icons.restart_alt : Icons.check_circle,
                    ),
                    label: Text(isRetry ? 'Retry & Mark Paid' : 'Mark Paid'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    // Only show "Mark Failed" if not already failed
                    onPressed: (_saving || isRetry) ? null : _onMarkFailed,
                    icon: const Icon(Icons.error_outline),
                    label: const Text('Mark Failed'),
                  ),
                  if (_saving) ...[
                    const SizedBox(width: 16),
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              if (isRetry)
                Text(
                  'This payout previously failed. Retrying will mark it as paid and set processed_at.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
            ] else
              Text(
                'This payout is already paid; status changes are disabled.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value) {
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
                value,
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }

  Future<void> _onMarkPaid() async {
    final payoutId = int.tryParse('${_p['id']}');
    if (payoutId == null) return;

    final existingTxn = ('${_p['transaction_id'] ?? ''}').trim();

    final res = await _askMarkPaid(
      context,
      initialTransactionId: existingTxn,
      requireTransactionId: existingTxn.isEmpty,
    );

    if (res == null) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _repo.markPayoutPaid(
        payoutId: payoutId,
        paymentMethod: res.paymentMethod,
        transactionId: res.transactionId,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }

  Future<void> _onMarkFailed() async {
    final payoutId = int.tryParse('${_p['id']}');
    if (payoutId == null) return;

    final reason = await _askReason(context);
    if (reason == null || reason.trim().isEmpty) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await _repo.markPayoutFailed(payoutId: payoutId, reason: reason.trim());
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _saving = false;
      });
    }
  }
}

class _MarkPaidInput {
  final String paymentMethod;
  final String transactionId;
  const _MarkPaidInput(this.paymentMethod, this.transactionId);
}

Future<_MarkPaidInput?> _askMarkPaid(
  BuildContext context, {
  required String initialTransactionId,
  required bool requireTransactionId,
}) async {
  final methodCtrl = TextEditingController();
  final txnCtrl = TextEditingController(text: initialTransactionId);

  return showDialog<_MarkPaidInput>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Mark payout as paid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: methodCtrl,
              decoration: const InputDecoration(labelText: 'Payment method'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: txnCtrl,
              decoration: InputDecoration(
                labelText: 'Transaction ID',
                helperText: requireTransactionId
                    ? 'Required (no existing transaction id).'
                    : 'Optional (already exists; edit only if needed).',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final method = methodCtrl.text.trim();
              final txn = txnCtrl.text.trim();

              if (method.isEmpty) return;
              if (requireTransactionId && txn.isEmpty) return;

              Navigator.pop(ctx, _MarkPaidInput(method, txn));
            },
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

Future<String?> _askReason(BuildContext context) async {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Mark payout as failed'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
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
