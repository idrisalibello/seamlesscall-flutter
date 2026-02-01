import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:seamlesscall/features/customer/presentation/apply_as_provider_screen.dart';
import 'package:seamlesscall/features/customer/presentation/customer_chat_screen.dart';
import 'package:seamlesscall/features/customer/presentation/customer_services_list.dart';
import 'package:seamlesscall/features/customer/presentation/job_tracking_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen>
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

    // Fake: replace with your real state later
    final bool hasOngoingJob = true;
    final String ongoingJobId = "SC-1042";

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Background: gradient + subtle animated blobs (adds “depth” + breaks homogeneity)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bg,
              builder: (context, _) {
                final t = _bg.value; // 0..1
                return CustomPaint(
                  painter: _HomeBgPainter(
                    primary: cs.primary,
                    surface: cs.surface,
                    t: t,
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _AnimatedIn(
                      delayMs: 40,
                      child: _HomeTopBar(
                        title: "Hello 👋",
                        subtitle: "What do you need fixed today?",
                      ),
                    ),
                  ),
                ),

                // ✅ Hero: more white + image + glow + motion
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                    child: _AnimatedIn(
                      delayMs: 120,
                      child: _HeroHeader(
                        title: "Fast. Verified. Nearby.",
                        subtitle:
                            "Track jobs like deliveries and chat with technicians.",
                        // Use local asset (avoid web 404 issues)
                        imageAsset:
                            "assets/images/customer/photo-1621905252507-b35492cc74b4.jpg",
                        primaryCtaText: hasOngoingJob
                            ? "Track Job"
                            : "Book a Service",
                        secondaryCtaText: "View Services",
                        onPrimaryTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const JobTrackingScreen(jobId: '13'),
                            ),
                          );
                        },
                        onSecondaryTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ServicesListScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ✅ Quick actions (more white separation + micro motion)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: _AnimatedIn(
                      delayMs: 180,
                      child: Text(
                        "Other actions",
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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _AnimatedIn(
                            delayMs: 240,
                            child: _Pressable(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ApplyAsProviderScreen(),
                                ),
                              ),
                              child: _ActionTile(
                                icon: Icons.local_shipping_rounded,
                                title: "Become a Provider",
                                subtitle: "Render Professional Services",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _AnimatedIn(
                            delayMs: 300,
                            child: _Pressable(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ChatShell(),
                                  ),
                                );
                              },
                              child: _ActionTile(
                                icon: Icons.chat_bubble_outline_rounded,
                                title: "Chat",
                                subtitle: "Support & technicians",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✅ Popular services
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: _AnimatedIn(
                      delayMs: 340,
                      child: Text(
                        "Popular services",
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
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
                    child: _AnimatedIn(
                      delayMs: 420,
                      child: _PopularServicesRow(
                        items: const [
                          _MiniService(
                            icon: Icons.ac_unit_rounded,
                            label: "AC Repair",
                          ),
                          _MiniService(
                            icon: Icons.plumbing_rounded,
                            label: "Plumbing",
                          ),
                          _MiniService(
                            icon: Icons.electrical_services_rounded,
                            label: "Electrical",
                          ),
                          _MiniService(
                            icon: Icons.cleaning_services_rounded,
                            label: "Cleaning",
                          ),
                        ],
                      ),
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

/* ---------------- Components ---------------- */

class _HomeTopBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HomeTopBar({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
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
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onBackground.withOpacity(0.65),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.85), // ✅ touch of white
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
          ),
          child: Icon(Icons.notifications_none_rounded, color: cs.onSurface),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageAsset;
  final String primaryCtaText;
  final String secondaryCtaText;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const _HeroHeader({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    required this.primaryCtaText,
    required this.secondaryCtaText,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          // ✅ gradient uses more “white/surface” to break the blue wall
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.surface.withOpacity(0.95),
              cs.primaryContainer.withOpacity(0.45),
            ],
          ),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.28,
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
                    colors: [cs.surface.withOpacity(0.82), Colors.transparent],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.68),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _Pressable(
                          onTap: onPrimaryTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Text(
                                primaryCtaText,
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
                      _Pressable(
                        onTap: onSecondaryTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surface.withOpacity(0.90),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.outlineVariant.withOpacity(0.8),
                            ),
                          ),
                          child: Text(
                            secondaryCtaText,
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92), // ✅ white touch
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
              color: cs.primaryContainer.withOpacity(0.70),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: cs.primary),
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
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withOpacity(0.65),
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

class _PopularServicesRow extends StatelessWidget {
  final List<_MiniService> items;

  const _PopularServicesRow({required this.items});

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((s) => _MiniServiceChip(service: s)).toList(),
      ),
    );
  }
}

class _MiniService {
  final IconData icon;
  final String label;
  const _MiniService({required this.icon, required this.label});
}

class _MiniServiceChip extends StatelessWidget {
  final _MiniService service;
  const _MiniServiceChip({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.70),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(service.icon, color: cs.primary),
        ),
        const SizedBox(height: 8),
        Text(
          service.label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface.withOpacity(0.75),
          ),
        ),
      ],
    );
  }
}

/* ---------------- Motion helpers ---------------- */

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

/* ---------------- Background painter ---------------- */

class _HomeBgPainter extends CustomPainter {
  final Color primary;
  final Color surface;
  final double t;

  _HomeBgPainter({
    required this.primary,
    required this.surface,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base background
    final rect = Offset.zero & size;
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [surface.withOpacity(1.0), primary.withOpacity(0.06)],
      ).createShader(rect);
    canvas.drawRect(rect, bg);

    // Soft blobs (animated positions)
    final blob1 = Paint()..color = primary.withOpacity(0.08);
    final blob2 = Paint()..color = primary.withOpacity(0.06);

    final x1 = size.width * (0.15 + 0.05 * math.sin(t * 2 * math.pi));
    final y1 = size.height * (0.18 + 0.03 * math.cos(t * 2 * math.pi));
    canvas.drawCircle(Offset(x1, y1), size.width * 0.38, blob1);

    final x2 = size.width * (0.92 - 0.06 * math.cos(t * 2 * math.pi));
    final y2 = size.height * (0.45 + 0.04 * math.sin(t * 2 * math.pi));
    canvas.drawCircle(Offset(x2, y2), size.width * 0.32, blob2);
  }

  @override
  bool shouldRepaint(covariant _HomeBgPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primary != primary ||
        oldDelegate.surface != surface;
  }
}
