import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/customer_orders_repository.dart';
import '../data/models/order_model.dart';

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen>
    with SingleTickerProviderStateMixin {
  final CustomerOrdersRepository _repo = CustomerOrdersRepository();

  late final AnimationController _bg = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  bool _loading = true;
  String? _error;
  List<CustomerOrder> _orders = const [];
  String? _busyJobId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final orders = await _repo.getOrders();
      if (!mounted) return;

      setState(() {
        _orders = orders;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handlePrimaryAction(CustomerOrder order) async {
    if (_busyJobId != null) return;

    if (order.payment == PaymentState.inspectionDue ||
        order.payment == PaymentState.failed) {
      await _startInspectionPayment(order);
      return;
    }

    if (order.payment == PaymentState.executionPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Execution payment is the next phase. Inspection payment is live now.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(order.primaryActionText)),
    );
  }

  Future<void> _startInspectionPayment(CustomerOrder order) async {
    setState(() => _busyJobId = order.jobId);

    try {
      final init = await _repo.initializeInspectionPayment(order.jobId);

      final alreadyPaid = init['already_paid'] == true;
      if (alreadyPaid) {
        if (!mounted) return;
        await _load();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inspection fee is already paid.')),
        );
        return;
      }

      final authUrl = (init['authorization_url'] ?? '').toString();
      final reference = (init['reference'] ?? '').toString();

      if (authUrl.isEmpty || reference.isEmpty) {
        throw Exception('Payment initialization returned incomplete checkout data.');
      }

      final uri = Uri.tryParse(authUrl);
      if (uri == null) {
        throw Exception('Invalid Paystack checkout URL returned.');
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not open Paystack checkout.');
      }

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Complete payment'),
          content: const Text(
            'After completing the Paystack checkout, return here and tap Verify payment.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                await _verifyPayment(reference);
              },
              child: const Text('Verify payment'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _busyJobId = null);
      }
    }
  }

  Future<void> _verifyPayment(String reference) async {
    try {
      final result = await _repo.verifyPayment(reference);
      if (!mounted) return;

      await _load();

      final status = (result['status'] ?? 'pending').toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment verification result: $status')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  void dispose() {
    _bg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final pendingActions = _orders.where(_needsAttention).toList();
    final paidItems = _orders.where((o) => o.payment == PaymentState.paid).toList();
    final inspectionPaidItems = _orders
        .where((o) => o.payment == PaymentState.inspectionPaid)
        .toList();
    final failedItems =
        _orders.where((o) => o.payment == PaymentState.failed).toList();

    return Scaffold(
      backgroundColor: cs.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bg,
              builder: (_, __) => CustomPaint(
                painter: _SoftBgPainter(
                  primary: cs.primary,
                  surface: cs.background,
                  t: _bg.value,
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Text(
                        "Payments",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onBackground,
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _Card(
                        child: _PaymentSummary(
                          pendingCount: pendingActions.length,
                          inspectionPaidCount: inspectionPaidItems.length,
                          paidCount: paidItems.length,
                          failedCount: failedItems.length,
                        ),
                      ),
                    ),
                  ),

                  if (_loading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 32, 16, 0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Loading payments...'),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (_error != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _Card(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 40),
                              const SizedBox(height: 10),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          "Actions",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onBackground,
                          ),
                        ),
                      ),
                    ),
                    if (pendingActions.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                          child: _Card(
                            child: _EmptyStateBlock(
                              title: "No pending payment actions",
                              subtitle:
                                  "Inspection payment actions will appear here when needed.",
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                        sliver: SliverList.separated(
                          itemCount: pendingActions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _ActionTile(
                            action: _buildAction(pendingActions[i]),
                            busy: _busyJobId == pendingActions[i].jobId,
                            onTap: () => _handlePrimaryAction(pendingActions[i]),
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Text(
                          "Transaction history",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onBackground,
                          ),
                        ),
                      ),
                    ),
                    if (_orders.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: _Card(
                            child: _EmptyStateBlock(
                              title: "No payment history yet",
                              subtitle:
                                  "Your inspection payment history will appear here as you continue booking services.",
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList.separated(
                          itemCount: _orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => _TxTile(
                            tx: _buildTx(_orders[i]),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _needsAttention(CustomerOrder order) {
    return order.payment == PaymentState.inspectionDue ||
        order.payment == PaymentState.failed ||
        order.payment == PaymentState.executionPending;
  }

  _PayAction _buildAction(CustomerOrder order) {
    final kind = switch (order.payment) {
      PaymentState.failed => _ActionKind.danger,
      PaymentState.executionPending => _ActionKind.success,
      PaymentState.inspectionDue => _ActionKind.warning,
      PaymentState.inspectionPaid => _ActionKind.success,
      PaymentState.paid => _ActionKind.success,
    };

    final icon = switch (order.payment) {
      PaymentState.failed => Icons.refresh_rounded,
      PaymentState.executionPending => Icons.payments_rounded,
      PaymentState.inspectionDue => Icons.receipt_long_rounded,
      PaymentState.inspectionPaid => Icons.verified_rounded,
      PaymentState.paid => Icons.receipt_long_rounded,
    };

    return _PayAction(
      title: order.primaryActionText,
      subtitle: '${order.serviceName} • ${order.orderId}',
      icon: icon,
      kind: kind,
    );
  }

  _Tx _buildTx(CustomerOrder order) {
    final status = switch (order.payment) {
      PaymentState.paid => _TxStatus.paid,
      PaymentState.failed => _TxStatus.failed,
      PaymentState.executionPending ||
      PaymentState.inspectionDue ||
      PaymentState.inspectionPaid =>
        _TxStatus.pending,
    };

    return _Tx(
      title: order.serviceName,
      subtitle: '${order.payment.pill} • ${order.updatedAt}',
      status: status,
    );
  }
}

/* ---------- UI Components ---------- */

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PaymentSummary extends StatelessWidget {
  final int pendingCount;
  final int inspectionPaidCount;
  final int paidCount;
  final int failedCount;

  const _PaymentSummary({
    required this.pendingCount,
    required this.inspectionPaidCount,
    required this.paidCount,
    required this.failedCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.65),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.account_balance_wallet_rounded,
            color: cs.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Payment overview",
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Pending actions: $pendingCount",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.orange.shade700,
                ),
              ),
              Text(
                "Inspection paid: $inspectionPaidCount",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withOpacity(0.68),
                ),
              ),
              Text(
                "Fully paid/completed: $paidCount",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withOpacity(0.68),
                ),
              ),
              Text(
                "Failed items: $failedCount",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: failedCount > 0
                      ? Colors.red.shade700
                      : cs.onSurface.withOpacity(0.68),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyStateBlock extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyStateBlock({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        Icon(
          Icons.payments_outlined,
          size: 42,
          color: cs.onSurface.withOpacity(0.45),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: cs.onSurface.withOpacity(0.65),
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final _PayAction action;
  final VoidCallback onTap;
  final bool busy;

  const _ActionTile({
    required this.action,
    required this.onTap,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Color accent = action.kind == _ActionKind.success
        ? Colors.green
        : action.kind == _ActionKind.warning
            ? Colors.orange
            : Colors.red;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: busy ? null : onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: busy
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: accent,
                      ),
                    )
                  : Icon(action.icon, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface.withOpacity(0.66),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.45)),
          ],
        ),
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final _Tx tx;

  const _TxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Color accent = tx.status == _TxStatus.paid
        ? Colors.green
        : tx.status == _TxStatus.pending
            ? Colors.orange
            : Colors.red;

    final String statusText = tx.status == _TxStatus.paid
        ? "Paid"
        : tx.status == _TxStatus.pending
            ? "Pending"
            : "Failed";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.receipt_long_rounded, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withOpacity(0.66),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusText,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------- Local view models ---------- */

enum _ActionKind { success, warning, danger }

class _PayAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final _ActionKind kind;

  const _PayAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.kind,
  });
}

enum _TxStatus { paid, pending, failed }

class _Tx {
  final String title;
  final String subtitle;
  final _TxStatus status;

  const _Tx({
    required this.title,
    required this.subtitle,
    required this.status,
  });
}

/* ---------- Background painter ---------- */

class _SoftBgPainter extends CustomPainter {
  final Color primary;
  final Color surface;
  final double t;

  _SoftBgPainter({
    required this.primary,
    required this.surface,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [surface.withOpacity(1.0), primary.withOpacity(0.06)],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    final blob1 = Paint()..color = primary.withOpacity(0.08);
    final blob2 = Paint()..color = primary.withOpacity(0.06);

    final x1 = size.width * (0.18 + 0.06 * math.sin(t * 2 * math.pi));
    final y1 = size.height * (0.18 + 0.03 * math.cos(t * 2 * math.pi));
    canvas.drawCircle(Offset(x1, y1), size.width * 0.40, blob1);

    final x2 = size.width * (0.92 - 0.06 * math.cos(t * 2 * math.pi));
    final y2 = size.height * (0.52 + 0.04 * math.sin(t * 2 * math.pi));
    canvas.drawCircle(Offset(x2, y2), size.width * 0.34, blob2);
  }

  @override
  bool shouldRepaint(covariant _SoftBgPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primary != primary ||
        oldDelegate.surface != surface;
  }
}