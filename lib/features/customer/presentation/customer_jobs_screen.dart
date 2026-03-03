import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:seamlesscall/features/customer/presentation/job_tracking_screen.dart';

import '../data/models/customer_orders_repository.dart';
import '../data/models/order_model.dart';

class CustomerJobsScreen extends StatefulWidget {
  const CustomerJobsScreen({super.key});

  @override
  State<CustomerJobsScreen> createState() => _CustomerJobsScreenState();
}

class _CustomerJobsScreenState extends State<CustomerJobsScreen>
    with SingleTickerProviderStateMixin {
  final CustomerOrdersRepository _repo = CustomerOrdersRepository();

  int _tab = 0; // 0 Active, 1 Completed, 2 Cancelled

  bool _loading = true;
  String? _error;
  List<CustomerOrder> _all = const [];

  late final AnimationController _bg = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

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
      setState(() {
        _all = orders;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
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

    final active = _all.where((o) => o.stage.isActive).toList();
    final completed = _all
        .where((o) => o.stage == OrderStage.completed)
        .toList();
    final cancelled = _all
        .where((o) => o.stage == OrderStage.cancelled)
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
            child: RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                  if (_loading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 32, 16, 0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 8),
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Loading orders...'),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (_error != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                        child: Column(
                          children: [
                            _EmptyState(
                              title: "Failed to load orders",
                              subtitle: _error!,
                            ),
                            const SizedBox(height: 12),
                            InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: _load,
                              child: Ink(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surface.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: cs.outlineVariant.withOpacity(0.6),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.refresh_rounded,
                                      color: cs.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Retry',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: cs.onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (list.isEmpty)
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(list[i].primaryActionText),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
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
  final CustomerOrder item;
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
    final statusColor = item.stage.color(cs);
    final payPill = item.payment.pill;
    final payColor = item.payment.color(cs);

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
              _MiniProgress(stage: item.stage),

              const SizedBox(height: 12),

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
  final OrderStage stage;
  const _MiniProgress({required this.stage});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final double v = stage == OrderStage.requested
        ? 0.18
        : stage == OrderStage.inspectionDue
        ? 0.26
        : stage == OrderStage.enRoute
        ? 0.48
        : stage == OrderStage.quoteReady
        ? 0.66
        : stage == OrderStage.inProgress
        ? 0.82
        : stage == OrderStage.completed
        ? 1.0
        : 0.20;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 10,
        color: cs.onSurface.withOpacity(0.08),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: v,
            child: Container(
              height: 10,
              color: stage == OrderStage.cancelled
                  ? Colors.red.withOpacity(0.75)
                  : cs.primary.withOpacity(0.85),
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
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.onSurface.withOpacity(0.80),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.65),
              borderRadius: BorderRadius.circular(16),
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
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withOpacity(0.68),
                    height: 1.2,
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
