import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../common/widgets/main_layout.dart';
import 'customer_booking_request.dart';

class ServiceDetailsScreen extends StatefulWidget {
  /// Backward-compatible: existing calls pass only serviceName.
  final String serviceName;

  /// Optional enhancements (if caller provides later).
  final String? serviceDescription;
  final String? categoryName;
  final String? imageAsset;
  final String? badge;

  const ServiceDetailsScreen({
    super.key,
    required this.serviceName,
    this.serviceDescription,
    this.categoryName,
    this.imageAsset,
    this.badge,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen>
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

    final title = widget.serviceName;
    final subtitle =
        (widget.serviceDescription == null ||
            widget.serviceDescription!.trim().isEmpty)
        ? _fallbackSubtitle(title)
        : widget.serviceDescription!.trim();

    final imageAsset = widget.imageAsset ?? _pickImageAsset(title);
    final badge = widget.badge ?? _pickBadge(title);
    final category = widget.categoryName;

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
                          title: "Service details",
                          subtitle: category == null || category.trim().isEmpty
                              ? "Choose and book confidently"
                              : category,
                          onBack: () => Navigator.pop(context),
                          trailing: _BadgePill(text: badge),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 120,
                        child: _HeroImageCard(
                          imageAsset: imageAsset,
                          title: title,
                          subtitle: subtitle,
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 200,
                        child: _InfoCard(
                          title: "What you get",
                          items: _benefitsFor(title),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      child: _AnimatedIn(
                        delayMs: 280,
                        child: _InfoCard(
                          title: "How it works",
                          items: const [
                            "Pay inspection/engagement fee to dispatch a technician",
                            "Technician inspects and generates a structured quote",
                            "You approve and pay before work proceeds",
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sticky bottom CTA
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _BottomBar(
                  primaryText: "Book now",
                  secondaryText: "Back",
                  onSecondary: () => Navigator.pop(context),
                  onPrimary: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingRequestScreen(
                          serviceName: widget.serviceName,
                        ),
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

  String _fallbackSubtitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('ac'))
      return "Reliable diagnosis and repairs by vetted techs.";
    if (t.contains('plumb') || t.contains('pipe') || t.contains('sink')) {
      return "Fast plumbing fixes with clear, structured pricing.";
    }
    if (t.contains('clean'))
      return "Premium cleaning with consistent quality checks.";
    if (t.contains('electric') ||
        t.contains('wiring') ||
        t.contains('socket')) {
      return "Safe electrical work handled by verified professionals.";
    }
    return "Professional service delivered with transparent pricing.";
  }

  String _pickImageAsset(String title) {
    final t = title.toLowerCase();
    if (t.contains('ac')) {
      return 'images/customer/premium_photo-1682126009570-3fe2399162f7.png';
    }
    if (t.contains('plumb') || t.contains('pipe') || t.contains('sink')) {
      return 'images/customer/handyman-repairing-sink-pipe-young-african-worktool-56844343.png';
    }
    if (t.contains('clean')) {
      return 'images/customer/im3rd-media-FJZtZldA-uE-unsplash.png';
    }
    if (t.contains('electric') ||
        t.contains('wiring') ||
        t.contains('socket')) {
      return 'images/customer/emmanuel-ikwuegbu--0-kl1BjvFc-unsplash.png';
    }
    return 'images/customer/premium_photo-1682126009570-3fe2399162f7.png';
  }

  String _pickBadge(String title) {
    final t = title.toLowerCase();
    if (t.contains('ac')) return 'Top-rated';
    if (t.contains('clean')) return 'Trusted';
    if (t.contains('electric')) return 'Verified';
    if (t.contains('plumb')) return 'Fast response';
    return 'Available';
  }

  List<String> _benefitsFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('ac')) {
      return const [
        "Diagnosis + clear quote before work starts",
        "Verified technicians with service history",
        "Structured pricing with visible adjustments",
      ];
    }
    if (t.contains('plumb') || t.contains('pipe') || t.contains('sink')) {
      return const [
        "Quick troubleshooting and fix plan",
        "Transparent quote and itemized adjustments",
        "Work proceeds only after approval",
      ];
    }
    if (t.contains('clean')) {
      return const [
        "Consistent premium cleaning checklist",
        "Clear scope and price confirmation",
        "Option to request changes before approval",
      ];
    }
    if (t.contains('electric') ||
        t.contains('wiring') ||
        t.contains('socket')) {
      return const [
        "Safety-first assessment",
        "Clear quote and approval before execution",
        "Verified professionals, documented service",
      ];
    }
    return const [
      "Clear quote after inspection",
      "Approval required before work begins",
      "Payments tracked with receipts",
    ];
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

class _BadgePill extends StatelessWidget {
  final String text;
  const _BadgePill({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

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

class _HeroImageCard extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String subtitle;

  const _HeroImageCard({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
            child: SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: cs.primaryContainer.withOpacity(0.25),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported,
                          color: cs.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.05),
                            Colors.black.withOpacity(0.25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.70),
                    fontWeight: FontWeight.w600,
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

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _InfoCard({required this.title, required this.items});

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
          const SizedBox(height: 12),
          ...items.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      t,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface.withOpacity(0.75),
                        height: 1.25,
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

/* ---------------- Motion + bg ---------------- */

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
