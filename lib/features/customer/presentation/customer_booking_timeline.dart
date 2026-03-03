import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../common/widgets/main_layout.dart';
import 'booking_models.dart';

class BookingTimelineScreen extends StatefulWidget {
  final BookingDraft draft;

  const BookingTimelineScreen({super.key, required this.draft});

  @override
  State<BookingTimelineScreen> createState() => _BookingTimelineScreenState();
}

class _BookingTimelineScreenState extends State<BookingTimelineScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bg = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  // Phase 2: UI-only simulated stage
  int _stage =
      1; // 1=Request created, 2=Awaiting inspection payment, 3=Technician assigned

  @override
  void dispose() {
    _bg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final d = widget.draft;

    final address = d.address.isEmpty ? "Not provided yet" : d.address;
    final note = d.note.isEmpty ? "None" : d.note;

    return MainLayout(
      child: Scaffold(
        backgroundColor: cs.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bg,
                builder: (_, __) => CustomPaint(
                  painter: _SoftBgPainter(
                    primary: cs.primary,
                    surface: cs.surface,
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
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 40,
                        child: _TopBar(
                          title: "Booking status",
                          subtitle: d.serviceName,
                          onBack: () => Navigator.pop(context),
                          trailing: _StagePill(stage: _stage),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 120,
                        child: _RequestCard(
                          service: d.serviceName,
                          when: d.type == BookingType.asap
                              ? "ASAP"
                              : d.scheduleLabel,
                          address: address,
                          note: note,
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 190,
                        child: _TimelineCard(stage: _stage),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      child: _AnimatedIn(
                        delayMs: 260,
                        child: _ActionCard(
                          stage: _stage,
                          onAdvance: () => setState(() {
                            _stage = (_stage == 3) ? 1 : _stage + 1;
                          }),
                          onReset: () => setState(() => _stage = 1),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _BottomBar(
                  primaryText: "Go to Orders",
                  secondaryText: "Back to services",
                  onSecondary: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  onPrimary: () {
                    // Phase 2: we don’t have real Orders wired yet in this flow.
                    // Keep it non-destructive: go back for now.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Orders wiring comes next (Phase 3)."),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- UI components ---------------- */

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final Widget trailing;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onBack,
          child: Ink(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.90),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
            ),
            child: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onBackground,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onBackground.withOpacity(0.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _StagePill extends StatelessWidget {
  final int stage;
  const _StagePill({required this.stage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final text = switch (stage) {
      1 => "Created",
      2 => "Awaiting fee",
      _ => "Assigned",
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.70),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String service;
  final String when;
  final String address;
  final String note;

  const _RequestCard({
    required this.service,
    required this.when,
    required this.address,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Request",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _Row(
            icon: Icons.home_repair_service_rounded,
            label: "Service",
            value: service,
          ),
          const SizedBox(height: 10),
          _Row(icon: Icons.timer_rounded, label: "When", value: when),
          const SizedBox(height: 10),
          _Row(
            icon: Icons.location_on_rounded,
            label: "Address",
            value: address,
          ),
          const SizedBox(height: 10),
          _Row(icon: Icons.notes_rounded, label: "Notes", value: note),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface.withOpacity(0.65),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final int stage;
  const _TimelineCard({required this.stage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final steps = <_StepItem>[
      const _StepItem(
        title: "Request created",
        subtitle: "We received your request.",
        icon: Icons.check_circle_rounded,
      ),
      const _StepItem(
        title: "Pay inspection fee",
        subtitle: "Required before dispatch.",
        icon: Icons.payments_rounded,
      ),
      const _StepItem(
        title: "Technician assigned",
        subtitle: "A verified tech will be dispatched.",
        icon: Icons.engineering_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Timeline",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(steps.length, (i) {
            final idx = i + 1;
            final done = stage > idx;
            final active = stage == idx;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: done || active
                          ? cs.primaryContainer.withOpacity(0.75)
                          : cs.surfaceContainerHighest.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: done || active
                            ? cs.primary.withOpacity(0.25)
                            : cs.outlineVariant.withOpacity(0.6),
                      ),
                    ),
                    child: Icon(
                      steps[i].icon,
                      size: 18,
                      color: done || active
                          ? cs.primary
                          : cs.onSurface.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          steps[i].title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          steps[i].subtitle,
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
          }),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final int stage;
  final VoidCallback onAdvance;
  final VoidCallback onReset;

  const _ActionCard({
    required this.stage,
    required this.onAdvance,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final headline = switch (stage) {
      1 => "Request created",
      2 => "Inspection fee pending",
      _ => "Technician assigned",
    };

    final desc = switch (stage) {
      1 => "Next: proceed to pay the inspection/engagement fee.",
      2 => "Once payment is confirmed, we dispatch a technician.",
      _ => "Tracking, quote, and payments will be wired in later phases.",
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Status",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            headline,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            desc,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withOpacity(0.70),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _Pressable(
                  onTap: onAdvance,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "Simulate next",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _Pressable(
                onTap: onReset,
                child: Container(
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
                  child: Text(
                    "Reset",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface.withOpacity(0.80),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const _BottomBar({
    required this.primaryText,
    required this.secondaryText,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.94),
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withOpacity(0.7)),
        ),
      ),
      child: Row(
        children: [
          _Pressable(
            onTap: onSecondary,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.8)),
              ),
              child: Text(
                secondaryText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface.withOpacity(0.80),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _Pressable(
              onTap: onPrimary,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    primaryText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- motion + bg ---------------- */

class _AnimatedIn extends StatefulWidget {
  final Widget child;
  final int delayMs;
  const _AnimatedIn({required this.child, this.delayMs = 0});

  @override
  State<_AnimatedIn> createState() => _AnimatedInState();
}

class _AnimatedInState extends State<_AnimatedIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  late final Animation<double> _fade = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.035),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.985 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
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

/* ---------------- small types ---------------- */

class _StepItem {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
