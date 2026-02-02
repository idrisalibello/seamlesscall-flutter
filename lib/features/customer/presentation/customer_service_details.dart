import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../common/widgets/main_layout.dart';
import 'customer_booking_request.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final String serviceName;
  const ServiceDetailsScreen({super.key, required this.serviceName});

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

    final meta = _ServiceMeta.fromName(widget.serviceName);

    return MainLayout(
      child: Scaffold(
        backgroundColor: cs.background,
        body: Stack(
          children: [
            // ✅ Animated background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bg,
                builder: (context, _) => CustomPaint(
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
                          title: widget.serviceName,
                          subtitle: meta.subtitle,
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),

                  // Hero image card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 120,
                        child: _HeroCard(
                          title: meta.heroTitle,
                          badge: meta.badge,
                          imageAsset: meta.imageAsset,
                        ),
                      ),
                    ),
                  ),

                  // Stats row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 180,
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatTile(
                                icon: Icons.schedule_rounded,
                                label: "ETA",
                                value: meta.etaText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.payments_rounded,
                                label: "From",
                                value: meta.fromPriceText,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatTile(
                                icon: Icons.star_rounded,
                                label: "Rating",
                                value: meta.ratingText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // About
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: _AnimatedIn(
                        delayMs: 240,
                        child: Text(
                          "About this service",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onBackground,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 280,
                        child: _SectionCard(
                          child: Text(
                            meta.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withOpacity(0.78),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // What you get
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                      child: _AnimatedIn(
                        delayMs: 320,
                        child: Text(
                          "What you get",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onBackground,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                    sliver: SliverList.separated(
                      itemCount: meta.includes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _AnimatedIn(
                        delayMs: 360 + (i * 70),
                        child: _IncludeTile(text: meta.includes[i]),
                      ),
                    ),
                  ),

                  // Safety & verification
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                      child: _AnimatedIn(
                        delayMs: 520,
                        child: _SectionCard(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.verified_user_rounded,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Verified technicians",
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: cs.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Providers are screened and rated. You can chat and track progress before arrival.",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: cs.onSurface.withOpacity(
                                              0.68,
                                            ),
                                            height: 1.2,
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
                  ),
                ],
              ),
            ),

            // ✅ Sticky bottom booking bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _BottomBar(
                  serviceName: widget.serviceName,
                  fromPriceText: meta.fromPriceText,
                  onBook: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BookingRequestScreen(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- UI blocks ---------------- */

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String badge;
  final String imageAsset;

  const _HeroCard({
    required this.title,
    required this.badge,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface.withOpacity(0.96),
              cs.primaryContainer.withOpacity(0.42),
            ],
          ),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 22,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.30,
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [cs.surface.withOpacity(0.84), Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _Badge(text: badge),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.70),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: cs.primary),
          ),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
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

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: child,
    );
  }
}

class _IncludeTile extends StatelessWidget {
  final String text;
  const _IncludeTile({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.70),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_rounded, size: 18, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withOpacity(0.78),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String serviceName;
  final String fromPriceText;
  final VoidCallback onBook;

  const _BottomBar({
    required this.serviceName,
    required this.fromPriceText,
    required this.onBook,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  serviceName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fromPriceText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _Pressable(
            onTap: onBook,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Book now",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

/* ---------------- Motion + background ---------------- */

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

/* ---------------- Data (mock) ---------------- */

class _ServiceMeta {
  final String subtitle;
  final String heroTitle;
  final String badge;
  final String imageAsset;
  final String etaText;
  final String fromPriceText;
  final String ratingText;
  final String description;
  final List<String> includes;

  const _ServiceMeta({
    required this.subtitle,
    required this.heroTitle,
    required this.badge,
    required this.imageAsset,
    required this.etaText,
    required this.fromPriceText,
    required this.ratingText,
    required this.description,
    required this.includes,
  });

  static _ServiceMeta fromName(String name) {
    final n = name.toLowerCase().trim();

    if (n.contains('ac')) {
      return const _ServiceMeta(
        subtitle: "Cooling issues • Maintenance • Gas refill",
        heroTitle: "Restore cooling fast, without stress.",
        badge: "Top-rated",
        imageAsset:
            "assets/images/customer/premium_photo-1682126009570-3fe2399162f7.png",
        etaText: "30–60 min",
        fromPriceText: "From ₦8,000",
        ratingText: "4.8",
        description:
            "Our technicians diagnose cooling faults, perform maintenance, and replace faulty parts. You’ll see updates and can chat before arrival.",
        includes: [
          "Technician diagnosis & inspection",
          "Minor fixes (tightening, cleaning, calibration)",
          "Clear quotation before major repairs",
          "Post-service tips for better efficiency",
        ],
      );
    }

    if (n.contains('plumb')) {
      return const _ServiceMeta(
        subtitle: "Leaks • fittings • installations",
        heroTitle: "Fix leaks quickly and protect your home.",
        badge: "Fast response",
        imageAsset:
            "assets/images/customer/handyman-repairing-sink-pipe-young-african-worktool-56844343.png",
        etaText: "20–50 min",
        fromPriceText: "From ₦6,000",
        ratingText: "4.7",
        description:
            "From leaking pipes to replacements and installations. Get verified plumbers with transparent pricing and real-time tracking.",
        includes: [
          "Leak detection & repair",
          "Pipe/fitting replacement (basic)",
          "Installation assistance & testing",
          "Clean-up after work",
        ],
      );
    }

    if (n.contains('clean')) {
      return const _ServiceMeta(
        subtitle: "Home • office • deep cleaning",
        heroTitle: "Make your space feel new again.",
        badge: "Trusted",
        imageAsset:
            "assets/images/customer/im3rd-media-FJZtZldA-uE-unsplash.png",
        etaText: "Same day",
        fromPriceText: "From ₦10,000",
        ratingText: "4.9",
        description:
            "Book trusted cleaners for routine or deep cleaning. Set scope, add notes, and track arrival. Perfect for home and office.",
        includes: [
          "Standard cleaning checklist",
          "Optional deep-clean add-ons",
          "Bring/confirm supplies",
          "Respectful, vetted cleaners",
        ],
      );
    }

    // default
    return const _ServiceMeta(
      subtitle: "Wiring • sockets • appliances",
      heroTitle: "Safe electrical fixes by verified pros.",
      badge: "Verified",
      imageAsset:
          "assets/images/customer/emmanuel-ikwuegbu--0-kl1BjvFc-unsplash.png",
      etaText: "30–70 min",
      fromPriceText: "From ₦7,000",
      ratingText: "4.6",
      description:
          "Electrical work should be safe and professional. Get verified technicians with clear pricing and status updates.",
      includes: [
        "Troubleshooting & inspection",
        "Sockets/switches replacement (basic)",
        "Appliance checks (basic)",
        "Safety advice after service",
      ],
    );
  }
}
