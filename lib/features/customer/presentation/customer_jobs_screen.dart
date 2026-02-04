import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:seamlesscall/features/customer/presentation/job_tracking_screen.dart';

class CustomerJobsScreen extends StatefulWidget {
  const CustomerJobsScreen({super.key});

  @override
  State<CustomerJobsScreen> createState() => _CustomerJobsScreenState();
}

class _CustomerJobsScreenState extends State<CustomerJobsScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0; // 0 Active, 1 Completed, 2 Cancelled

  late final AnimationController _bg = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bg.dispose();
    super.dispose();
  }

  // UI-only mock list (replace later with API list)
  final List<_OrderItem> _all = const [
    _OrderItem(
      orderId: "SC-1042",
      jobId: "1042",
      serviceName: "AC Repair",
      subtitle: "Ikeja, Lagos",
      stage: _OrderStage.enRoute,
      payment: _PaymentState.inspectionPaid,
      amountText: "₦2,000 paid • Quote pending",
      updatedAt: "Today • 09:20",
    ),
    _OrderItem(
      orderId: "SC-1039",
      jobId: "1039",
      serviceName: "Plumbing",
      subtitle: "Surulere, Lagos",
      stage: _OrderStage.quoteReady,
      payment: _PaymentState.executionPending,
      amountText: "₦2,000 paid • ₦11,000 pending",
      updatedAt: "Today • 08:05",
    ),
    _OrderItem(
      orderId: "SC-1031",
      jobId: "1031",
      serviceName: "House Cleaning",
      subtitle: "Wuse, Abuja",
      stage: _OrderStage.completed,
      payment: _PaymentState.paid,
      amountText: "₦9,500 paid",
      updatedAt: "Jan 28 • 16:12",
    ),
    _OrderItem(
      orderId: "SC-1028",
      jobId: "1028",
      serviceName: "Electrical",
      subtitle: "Garki, Abuja",
      stage: _OrderStage.cancelled,
      payment: _PaymentState.failed,
      amountText: "Payment failed",
      updatedAt: "Jan 26 • 10:45",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final active = _all.where((o) => o.stage.isActive).toList();
    final completed = _all
        .where((o) => o.stage == _OrderStage.completed)
        .toList();
    final cancelled = _all
        .where((o) => o.stage == _OrderStage.cancelled)
        .toList();

    final list = _tab == 0
        ? active
        : _tab == 1
        ? completed
        : cancelled;

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
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Orders",
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onBackground,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: cs.primary.withOpacity(0.18),
                            ),
                          ),
                          child: Text(
                            "${active.length} active",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _SegmentedTabs(
                      index: _tab,
                      labels: const ["Active", "Completed", "Cancelled"],
                      onChanged: (i) => setState(() => _tab = i),
                    ),
                  ),
                ),

                if (list.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: _EmptyState(
                        title: _tab == 0
                            ? "No active orders"
                            : _tab == 1
                            ? "No completed orders"
                            : "No cancelled orders",
                        subtitle: _tab == 0
                            ? "Book a service and track it here."
                            : "Your history will appear here.",
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                    sliver: SliverList.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _OrderCard(
                        item: list[i],
                        onOpen: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  JobTrackingScreen(jobId: list[i].jobId),
                            ),
                          );
                        },
                        onPrimary: () {
                          // UI-only now; later you’ll route to Paystack/Flutterwave or quote approval.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(list[i].primaryActionText)),
                          );
                        },
                      ),
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

/* ---------------- UI ---------------- */

class _SegmentedTabs extends StatelessWidget {
  final int index;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _SegmentedTabs({
    required this.index,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == index;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active
                      ? cs.primaryContainer.withOpacity(0.75)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    labels[i],
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: active
                          ? cs.primary
                          : cs.onSurface.withOpacity(0.70),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _OrderCard extends StatefulWidget {
  final _OrderItem item;
  final VoidCallback onOpen;
  final VoidCallback onPrimary;

  const _OrderCard({
    required this.item,
    required this.onOpen,
    required this.onPrimary,
  });

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final item = widget.item;

    final status = item.stage.label;
    final statusColor = item.stage.color;
    final payPill = item.payment.pill;
    final payColor = item.payment.color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onOpen();
      },
      child: AnimatedScale(
        scale: _down ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.94),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top row
              Row(
                children: [
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withOpacity(0.60),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(item.stage.icon, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.serviceName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${item.orderId} • ${item.subtitle}",
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Pill(text: status, color: statusColor),
                ],
              ),

              const SizedBox(height: 12),

              // payment line
              Row(
                children: [
                  _Pill(text: payPill, color: payColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.amountText,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface.withOpacity(0.70),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // progress hint
              _MiniProgress(stage: item.stage),

              const SizedBox(height: 12),

              // actions
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: widget.onPrimary,
                      child: Ink(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: item.primaryIsDanger ? Colors.red : cs.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            item.primaryActionText,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: widget.onOpen,
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: cs.outlineVariant.withOpacity(0.8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.track_changes_rounded,
                            size: 18,
                            color: cs.onSurface.withOpacity(0.75),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Track",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface.withOpacity(0.78),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                "Updated: ${item.updatedAt}",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  final _OrderStage stage;
  const _MiniProgress({required this.stage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // simple stage-based progress (UI-only)
    final double v = stage == _OrderStage.requested
        ? 0.18
        : stage == _OrderStage.inspectionDue
        ? 0.26
        : stage == _OrderStage.enRoute
        ? 0.48
        : stage == _OrderStage.quoteReady
        ? 0.66
        : stage == _OrderStage.inProgress
        ? 0.82
        : stage == _OrderStage.completed
        ? 1.0
        : 0.20;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 10,
        color: cs.onSurface.withOpacity(0.08),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            height: 10,
            width: double.infinity,
            transform: Matrix4.identity()..scale(v, 1.0),
            transformAlignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: stage == _OrderStage.cancelled
                  ? Colors.red.withOpacity(0.75)
                  : cs.primary.withOpacity(0.75),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.65),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.receipt_long_rounded, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.65),
                    fontWeight: FontWeight.w600,
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

/* ---------------- Data ---------------- */

enum _OrderStage {
  requested,
  inspectionDue,
  enRoute,
  quoteReady,
  inProgress,
  completed,
  cancelled;

  bool get isActive => this != completed && this != cancelled;

  String get label {
    switch (this) {
      case requested:
        return "Requested";
      case inspectionDue:
        return "Inspection due";
      case enRoute:
        return "En route";
      case quoteReady:
        return "Quote ready";
      case inProgress:
        return "In progress";
      case completed:
        return "Completed";
      case cancelled:
        return "Cancelled";
    }
  }

  IconData get icon {
    switch (this) {
      case requested:
        return Icons.send_rounded;
      case inspectionDue:
        return Icons.receipt_rounded;
      case enRoute:
        return Icons.directions_walk_rounded;
      case quoteReady:
        return Icons.request_quote_rounded;
      case inProgress:
        return Icons.build_rounded;
      case completed:
        return Icons.check_circle_rounded;
      case cancelled:
        return Icons.cancel_rounded;
    }
  }

  Color get color {
    switch (this) {
      case completed:
        return Colors.green;
      case cancelled:
        return Colors.red;
      case quoteReady:
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }
}

enum _PaymentState {
  inspectionPending,
  inspectionPaid,
  executionPending,
  paid,
  failed;

  String get pill {
    switch (this) {
      case inspectionPending:
        return "Inspection unpaid";
      case inspectionPaid:
        return "Inspection paid";
      case executionPending:
        return "Payment pending";
      case paid:
        return "Paid";
      case failed:
        return "Failed";
    }
  }

  Color get color {
    switch (this) {
      case paid:
        return Colors.green;
      case executionPending:
      case inspectionPending:
        return Colors.orange;
      case failed:
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}

class _OrderItem {
  final String orderId;
  final String jobId;
  final String serviceName;
  final String subtitle;
  final _OrderStage stage;
  final _PaymentState payment;
  final String amountText;
  final String updatedAt;

  const _OrderItem({
    required this.orderId,
    required this.jobId,
    required this.serviceName,
    required this.subtitle,
    required this.stage,
    required this.payment,
    required this.amountText,
    required this.updatedAt,
  });

  String get primaryActionText {
    // customer-centric money-first actions
    if (payment == _PaymentState.inspectionPending) return "Pay inspection";
    if (payment == _PaymentState.executionPending) return "Approve & Pay";
    if (payment == _PaymentState.failed) return "Retry payment";
    if (stage == _OrderStage.completed) return "View receipt";
    return "Share location";
  }

  bool get primaryIsDanger => payment == _PaymentState.failed;
}

/* ---------------- Soft background painter ---------------- */

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
