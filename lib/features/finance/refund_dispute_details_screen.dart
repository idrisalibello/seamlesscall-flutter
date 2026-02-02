import 'package:flutter/material.dart';

import '../../common/widgets/main_layout.dart';

enum RefundDisputeMode { refund, dispute }

class RefundDisputeDetailsScreen extends StatelessWidget {
  final RefundDisputeMode mode;
  final Map<String, dynamic> payload;

  // Refund actions
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  // Dispute actions
  final VoidCallback? onResolve;
  final VoidCallback? onDismiss;

  const RefundDisputeDetailsScreen({
    super.key,
    required this.mode,
    required this.payload,
    this.onApprove,
    this.onReject,
    this.onResolve,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRefund = mode == RefundDisputeMode.refund;
    final title = isRefund ? 'Refund Details' : 'Dispute Details';
    final status = '${payload['status'] ?? ''}';

    return MainLayout(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[200],
                  ),
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
                  if (isRefund) ..._refundFields(payload, status),
                  if (!isRefund) ..._disputeFields(payload, status),
                  const SizedBox(height: 20),
                  _actions(context, isRefund, status),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _refundFields(Map<String, dynamic> r, String status) {
    final id = '${r['id'] ?? ''}';
    final customer = '${r['customer'] ?? ''}';
    final email = '${r['email'] ?? ''}';
    final phone = '${r['phone'] ?? ''}';
    final txn = '${r['transaction_id'] ?? ''}';
    final amount = '${r['amount'] ?? ''}';
    final reason = '${r['reason'] ?? ''}';
    final submittedAt = '${r['submitted_at'] ?? ''}';
    final processedBy = '${r['processed_by'] ?? ''}';
    final processedAt = '${r['processed_at'] ?? ''}';

    return [
      _summaryCard('Refund ID', id),
      const SizedBox(height: 12),
      _summaryCard('Customer', customer),
      const SizedBox(height: 12),
      _summaryCard('Email', email),
      const SizedBox(height: 12),
      _summaryCard('Phone', phone),
      const SizedBox(height: 12),
      _summaryCard('Transaction ID', txn.isEmpty ? '-' : txn),
      const SizedBox(height: 12),
      _summaryCard('Amount', '₦$amount'),
      const SizedBox(height: 12),
      _summaryCard('Reason', reason),
      const SizedBox(height: 12),
      _summaryCard('Status', status, color: _statusColor(status)),
      const SizedBox(height: 12),
      _summaryCard('Submitted At', submittedAt),
      const SizedBox(height: 12),
      _summaryCard('Processed By', processedBy.isEmpty ? '-' : processedBy),
      const SizedBox(height: 12),
      _summaryCard('Processed At', processedAt.isEmpty ? '-' : processedAt),
    ];
  }

  List<Widget> _disputeFields(Map<String, dynamic> d, String status) {
    final id = '${d['id'] ?? ''}';
    final jobId = '${d['job_id'] ?? ''}';
    final jobTitle = '${d['job_title'] ?? ''}';
    final provider = '${d['provider'] ?? ''}';
    final customer = '${d['customer'] ?? ''}';
    final raisedBy = '${d['raised_by_name'] ?? ''}';
    final reason = '${d['reason'] ?? ''}';
    final createdAt = '${d['created_at'] ?? ''}';
    final resolvedAt = '${d['resolved_at'] ?? ''}';

    return [
      _summaryCard('Dispute ID', id),
      const SizedBox(height: 12),
      _summaryCard('Job', '#$jobId • $jobTitle'),
      const SizedBox(height: 12),
      _summaryCard('Provider', provider),
      const SizedBox(height: 12),
      _summaryCard('Customer', customer),
      const SizedBox(height: 12),
      _summaryCard('Raised By', raisedBy.isEmpty ? '-' : raisedBy),
      const SizedBox(height: 12),
      _summaryCard('Reason', reason),
      const SizedBox(height: 12),
      _summaryCard('Status', status, color: _statusColor(status)),
      const SizedBox(height: 12),
      _summaryCard('Created At', createdAt),
      const SizedBox(height: 12),
      _summaryCard('Resolved At', resolvedAt.isEmpty ? '-' : resolvedAt),
    ];
  }

  Widget _actions(BuildContext context, bool isRefund, String status) {
    final isPending = status == 'pending';

    if (!isPending) {
      return const SizedBox.shrink();
    }

    if (isRefund) {
      return Row(
        children: [
          ElevatedButton(onPressed: onApprove, child: const Text('Approve')),
          const SizedBox(width: 12),
          OutlinedButton(onPressed: onReject, child: const Text('Reject')),
        ],
      );
    }

    return Row(
      children: [
        ElevatedButton(onPressed: onResolve, child: const Text('Resolve')),
        const SizedBox(width: 12),
        OutlinedButton(onPressed: onDismiss, child: const Text('Dismiss')),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
      case 'resolved':
        return Colors.greenAccent;
      case 'rejected':
      case 'dismissed':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  Widget _summaryCard(String label, String value, {Color? color}) {
    return Card(
      color: Colors.grey[850],
      elevation: 2,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.grey[200],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
