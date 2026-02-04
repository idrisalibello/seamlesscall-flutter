import 'dart:math' as math;
import 'package:flutter/material.dart';

class CustomerPaymentsScreen extends StatefulWidget {
  const CustomerPaymentsScreen({super.key});

  @override
  State<CustomerPaymentsScreen> createState() => _CustomerPaymentsScreenState();
}

class _CustomerPaymentsScreenState extends State<CustomerPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bg = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // UI-only mock data (safe; no backend dependency)
    const walletCredit = 1500;
    const pendingCharges = 11000;

    final actions = const [
      _PayAction(
        title: "Pay inspection fee",
        subtitle: "AC Repair • ₦2,000",
        icon: Icons.receipt_long_rounded,
        kind: _ActionKind.warning,
      ),
      _PayAction(
        title: "Complete job payment",
        subtitle: "Plumbing • ₦11,000",
        icon: Icons.payments_rounded,
        kind: _ActionKind.success,
      ),
      _PayAction(
        title: "Retry failed payment",
        subtitle: "Electrical • ₦6,000",
        icon: Icons.refresh_rounded,
        kind: _ActionKind.danger,
      ),
    ];

    final txs = const [
      _Tx(
        title: "AC Repair (Inspection)",
        subtitle: "₦2,000 • Paystack",
        status: _TxStatus.paid,
      ),
      _Tx(
        title: "House Cleaning",
        subtitle: "₦9,500 • Flutterwave",
        status: _TxStatus.paid,
      ),
      _Tx(
        title: "Electrical Repair",
        subtitle: "₦6,000 • Paystack",
        status: _TxStatus.failed,
      ),
    ];

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
            child: CustomScrollView(
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

                // Wallet summary
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _Card(
                      child: Row(
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
                                  "Wallet",
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Available credit: ₦$walletCredit",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface.withOpacity(0.68),
                                  ),
                                ),
                                Text(
                                  "Pending charges: ₦$pendingCharges",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Actions
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  sliver: SliverList.separated(
                    itemCount: actions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _ActionTile(
                      action: actions[i],
                      onTap: () {
                        // TODO: later hook to Paystack/Flutterwave flow
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(actions[i].title)),
                        );
                      },
                    ),
                  ),
                ),

                // History
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: txs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _TxTile(tx: txs[i]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

class _ActionTile extends StatelessWidget {
  final _PayAction action;
  final VoidCallback onTap;

  const _ActionTile({required this.action, required this.onTap});

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
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
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
              child: Icon(action.icon, color: accent),
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
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.68),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurface.withOpacity(0.55),
            ),
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

    final bool paid = tx.status == _TxStatus.paid;
    final Color accent = paid ? Colors.green : Colors.red;

    return _Card(
      child: Row(
        children: [
          Icon(
            paid ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            color: accent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tx.subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withOpacity(0.68),
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
              paid ? "Paid" : "Failed",
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

/* ---------- Data (UI-only) ---------- */

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

enum _TxStatus { paid, failed }

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

/* ---------- Soft background painter ---------- */

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

    final blob1 = Paint()..color = primary.withOpacity(0.07);
    final blob2 = Paint()..color = primary.withOpacity(0.05);

    final x1 = size.width * (0.18 + 0.06 * math.sin(t * 2 * math.pi));
    final y1 = size.height * (0.20 + 0.04 * math.cos(t * 2 * math.pi));
    canvas.drawCircle(Offset(x1, y1), size.width * 0.42, blob1);

    final x2 = size.width * (0.95 - 0.06 * math.cos(t * 2 * math.pi));
    final y2 = size.height * (0.55 + 0.04 * math.sin(t * 2 * math.pi));
    canvas.drawCircle(Offset(x2, y2), size.width * 0.36, blob2);
  }

  @override
  bool shouldRepaint(covariant _SoftBgPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primary != primary ||
        oldDelegate.surface != surface;
  }
}
