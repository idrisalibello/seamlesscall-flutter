import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/customer/data/models/customer_orders_repository.dart';
import 'package:seamlesscall/features/customer/data/models/customer_repository.dart';
import 'package:seamlesscall/features/customer/data/models/order_model.dart';
import 'package:seamlesscall/features/customer/data/models/popular_service_model.dart';
import 'package:seamlesscall/features/customer/data/models/service_model.dart';
import 'package:seamlesscall/features/customer/presentation/apply_as_provider_screen.dart';
import 'package:seamlesscall/features/customer/presentation/customer_chat_screen.dart';
import 'package:seamlesscall/features/customer/presentation/customer_service_details.dart';
import 'package:seamlesscall/features/customer/presentation/customer_services_list.dart';
import 'package:seamlesscall/features/customer/presentation/job_tracking_screen.dart';
import 'package:seamlesscall/features/customer/presentation/widgets/customer_promotions_section.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

/// Fetches the latest non-terminal active order so the hero CTA can say "Track Job".
final _activeOrderProvider =
    FutureProvider.autoDispose<CustomerOrder?>((ref) async {
  final orders = await CustomerOrdersRepository().getOrders();
  try {
    return orders.firstWhere((o) => o.stage.isActive);
  } catch (_) {
    return null;
  }
});

/// Fetches services ranked by bookings, ratings, and views.
final _popularServicesProvider =
    FutureProvider.autoDispose<List<PopularService>>((ref) async {
  return CustomerRepository().getPopularServices(limit: 6);
});

// ─── Screen ───────────────────────────────────────────────────────────────────

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen>
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

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _refresh() async {
    ref.invalidate(_activeOrderProvider);
    ref.invalidate(_popularServicesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Real user name from auth state
    final user = ref.watch(authProvider).user;
    final firstName = (user?.name ?? '').split(' ').first;
    final greeting =
        firstName.isNotEmpty ? '$_greeting, $firstName 👋' : '$_greeting 👋';

    // Live active order
    final activeOrderAsync = ref.watch(_activeOrderProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Animated background blobs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bg,
              builder: (_, __) => CustomPaint(
                painter: _HomeBgPainter(
                  primary: cs.primary,
                  surface: cs.surface,
                  t: _bg.value,
                ),
              ),
            ),
          ),

          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [

                  // ── Top bar ─────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: _AnimatedIn(
                        delayMs: 40,
                        child: _HomeTopBar(greeting: greeting),
                      ),
                    ),
                  ),

                  // ── Hero card (live active job or default) ───────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      child: _AnimatedIn(
                        delayMs: 120,
                        child: activeOrderAsync.when(
                          loading: () => _HeroHeader(
                            hasActiveJob: false,
                            activeOrder: null,
                            onPrimaryTap: _goToServices,
                            onSecondaryTap: _goToServices,
                          ),
                          error: (_, __) => _HeroHeader(
                            hasActiveJob: false,
                            activeOrder: null,
                            onPrimaryTap: _goToServices,
                            onSecondaryTap: _goToServices,
                          ),
                          data: (order) => _HeroHeader(
                            hasActiveJob: order != null,
                            activeOrder: order,
                            onPrimaryTap: order != null
                                ? () => _goToTrack(order.jobId)
                                : _goToServices,
                            onSecondaryTap: _goToServices,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── "Other actions" heading ──────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: _AnimatedIn(
                        delayMs: 180,
                        child: Text(
                          'Other actions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Action tiles (directly under their heading) ──────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: _AnimatedIn(
                              delayMs: 220,
                              child: _Pressable(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ApplyAsProviderScreen(),
                                  ),
                                ),
                                child: const _ActionTile(
                                  icon: Icons.local_shipping_rounded,
                                  title: 'Become a Provider',
                                  subtitle: 'Render professional services',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AnimatedIn(
                              delayMs: 270,
                              child: _Pressable(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ChatShell(),
                                  ),
                                ),
                                child: const _ActionTile(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  title: 'Chat',
                                  subtitle: 'Support & technicians',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── "Special promotions" heading ─────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: _AnimatedIn(
                        delayMs: 300,
                        child: Text(
                          'Special promotions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Promotions carousel ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 340,
                        child: const CustomerPromotionsSection(),
                      ),
                    ),
                  ),

                  // ── "Popular services" heading ───────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                      child: _AnimatedIn(
                        delayMs: 380,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Popular services',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _goToServices,
                              child: Text(
                                'See all',
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
                  ),

                  // ── Popular services (live from API, tappable) ───────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                      child: _AnimatedIn(
                        delayMs: 420,
                        child: _PopularServicesSection(
                          onServiceTap: _goToServiceDetail,
                        ),
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

  // ── Navigation helpers ────────────────────────────────────────────────────

  void _goToServices() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ServicesListScreen()),
      );

  void _goToTrack(String jobId) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => JobTrackingScreen(jobId: jobId)),
      );

  void _goToServiceDetail(PopularService service) {
    // Record the view (fire-and-forget)
    CustomerRepository().recordServiceView(service.id);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailsScreen(
          serviceName: service.name,
          serviceDescription: service.description,
        ),
      ),
    );
  }
}

// ─── _PopularServicesSection ──────────────────────────────────────────────────

class _PopularServicesSection extends ConsumerWidget {
  final void Function(PopularService) onServiceTap;
  const _PopularServicesSection({required this.onServiceTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final async = ref.watch(_popularServicesProvider);

    return async.when(
      loading: () => Container(
        height: 110,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.90),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.90),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Could not load services.',
                  style: theme.textTheme.bodySmall),
            ),
            TextButton(
              onPressed: () => ref.invalidate(_popularServicesProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (services) {
        if (services.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.90),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.design_services_outlined,
                    color: cs.primary, size: 20),
                const SizedBox(width: 10),
                Text('No services yet. Check back soon.',
                    style: theme.textTheme.bodySmall),
              ],
            ),
          );
        }
        return _PopularServicesRow(services: services, onTap: onServiceTap);
      },
    );
  }
}

// ─── Components ───────────────────────────────────────────────────────────────

class _HomeTopBar extends StatelessWidget {
  final String greeting;
  const _HomeTopBar({required this.greeting});

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
                greeting,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'What do you need fixed today?',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(0.62),
                ),
              ),
            ],
          ),
        ),
        // Tappable bell — wire to notifications screen when ready
        _Pressable(
          onTap: () {
            // TODO: Navigator.push to NotificationsScreen
          },
          child: Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.85),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final bool hasActiveJob;
  final CustomerOrder? activeOrder;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const _HeroHeader({
    required this.hasActiveJob,
    required this.activeOrder,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final heroTitle =
        hasActiveJob ? 'Job in progress' : 'Fast. Verified. Nearby.';
    final heroSubtitle = hasActiveJob
        ? '${activeOrder!.serviceName} • ${activeOrder!.stage.label}'
        : 'Track jobs like deliveries and chat with technicians.';
    final primaryCtaText = hasActiveJob ? 'Track Job' : 'Book a Service';

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
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
                  'assets/images/customer/photo-1621905252507-b35492cc74b4.png',
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
                  if (hasActiveJob) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: cs.primary.withOpacity(0.22)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Active job',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    heroTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    heroSubtitle,
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
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
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
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: cs.surface.withOpacity(0.90),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: cs.outlineVariant.withOpacity(0.8)),
                          ),
                          child: Text(
                            'View Services',
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
        color: cs.surface.withOpacity(0.92),
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
  final List<PopularService> services;
  final void Function(PopularService) onTap;

  const _PopularServicesRow({required this.services, required this.onTap});

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
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        alignment: WrapAlignment.spaceAround,
        children: services
            .map((s) => _PopularServiceChip(service: s, onTap: () => onTap(s)))
            .toList(),
      ),
    );
  }
}

class _PopularServiceChip extends StatelessWidget {
  final PopularService service;
  final VoidCallback onTap;

  const _PopularServiceChip({required this.service, required this.onTap});

  static const _iconMap = <String, IconData>{
    'plumbing':  Icons.plumbing_rounded,
    'bore':      Icons.water_rounded,
    'overhead':  Icons.water_rounded,
    'electric':  Icons.electrical_services_rounded,
    'renewable': Icons.solar_power_rounded,
    'solar':     Icons.solar_power_rounded,
    'carpent':   Icons.carpenter_rounded,
    'furniture': Icons.chair_rounded,
    'cleaning':  Icons.cleaning_services_rounded,
    'painting':  Icons.format_paint_rounded,
    'ac':        Icons.ac_unit_rounded,
    'air':       Icons.ac_unit_rounded,
  };

  IconData get _icon {
    final lower = service.name.toLowerCase();
    for (final e in _iconMap.entries) {
      if (lower.contains(e.key)) return e.value;
    }
    return Icons.design_services_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return _Pressable(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.70),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_icon, color: cs.primary),
            ),
            const SizedBox(height: 6),
            Text(
              service.name,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withOpacity(0.80),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            // Booking count badge
            if (service.bookingCount > 0)
              Text(
                service.bookingLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cs.primary.withOpacity(0.80),
                ),
              ),
            // Rating badge
            if (service.ratingCount > 0)
              Text(
                service.ratingLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.amber.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Motion helpers ───────────────────────────────────────────────────────────

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
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
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
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
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
  Widget build(BuildContext context) => GestureDetector(
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

// ─── Background painter ───────────────────────────────────────────────────────

class _HomeBgPainter extends CustomPainter {
  final Color primary;
  final Color surface;
  final double t;

  const _HomeBgPainter({
    required this.primary,
    required this.surface,
    required this.t,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [surface, primary.withOpacity(0.06)],
        ).createShader(rect),
    );

    final x1 = size.width * (0.15 + 0.05 * math.sin(t * 2 * math.pi));
    final y1 = size.height * (0.18 + 0.03 * math.cos(t * 2 * math.pi));
    canvas.drawCircle(Offset(x1, y1), size.width * 0.38,
        Paint()..color = primary.withOpacity(0.08));

    final x2 = size.width * (0.92 - 0.06 * math.cos(t * 2 * math.pi));
    final y2 = size.height * (0.45 + 0.04 * math.sin(t * 2 * math.pi));
    canvas.drawCircle(Offset(x2, y2), size.width * 0.32,
        Paint()..color = primary.withOpacity(0.06));
  }

  @override
  bool shouldRepaint(covariant _HomeBgPainter old) =>
      old.t != t || old.primary != primary || old.surface != surface;
}