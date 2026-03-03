import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../data/models/customer_repository.dart';
import 'customer_service_details.dart';

class ServicesListScreen extends StatefulWidget {
  const ServicesListScreen({super.key});

  @override
  State<ServicesListScreen> createState() => _ServicesListScreenState();
}

class _ServicesListScreenState extends State<ServicesListScreen>
    with SingleTickerProviderStateMixin {
  final CustomerRepository _repo = CustomerRepository();

  String _query = '';
  int _selectedCategory = 0;

  bool _loading = true;
  String? _error;

  late final AnimationController _bg = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  List<String> _categories = const ['All'];
  final Map<int, String> _categoryNameById = <int, String>{};

  List<_ServiceItem> _services = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _selectedCategory = 0;
      _query = '';
    });

    try {
      final cats = await _repo.getCategories();
      _categoryNameById
        ..clear()
        ..addEntries(cats.map((c) => MapEntry(c.id, c.name)));

      final categories = <String>['All', ...cats.map((c) => c.name)];

      final services = await _repo.getAllServices();
      final items = services.map((s) {
        final categoryName = _categoryNameById[s.categoryId] ?? 'Other';
        final title = s.name;
        final subtitle =
            (s.description == null || s.description!.trim().isEmpty)
            ? 'Professional service'
            : s.description!.trim();

        return _ServiceItem(
          title: title,
          subtitle: subtitle,
          category: categoryName,
          imageAsset: _pickImageAsset(title),
          badge: _pickBadge(title),
        );
      }).toList();

      setState(() {
        _categories = categories;
        _services = items;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  String _pickImageAsset(String title) {
    final t = title.toLowerCase();
    if (t.contains('ac')) {
      return 'assets/images/customer/premium_photo-1682126009570-3fe2399162f7.png';
    }
    if (t.contains('plumb') || t.contains('pipe') || t.contains('sink')) {
      return 'assets/images/customer/handyman-repairing-sink-pipe-young-african-worktool-56844343.png';
    }
    if (t.contains('clean')) {
      return 'assets/images/customer/im3rd-media-FJZtZldA-uE-unsplash.png';
    }
    if (t.contains('electric') ||
        t.contains('wiring') ||
        t.contains('socket')) {
      return 'assets/images/customer/emmanuel-ikwuegbu--0-kl1BjvFc-unsplash.png';
    }
    return 'assets/images/customer/premium_photo-1682126009570-3fe2399162f7.png';
  }

  String _pickBadge(String title) {
    final t = title.toLowerCase();
    if (t.contains('ac')) return 'Top-rated';
    if (t.contains('clean')) return 'Trusted';
    if (t.contains('electric')) return 'Verified';
    if (t.contains('plumb')) return 'Fast response';
    return 'Available';
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

    final selected =
        (_selectedCategory >= 0 && _selectedCategory < _categories.length)
        ? _categories[_selectedCategory]
        : 'All';

    final List<_ServiceItem> filtered;
    if (_loading || _error != null) {
      filtered = const [];
    } else {
      filtered = _services.where((s) {
        final q = _query.trim().toLowerCase();
        final matchesQuery =
            q.isEmpty ||
            s.title.toLowerCase().contains(q) ||
            s.subtitle.toLowerCase().contains(q);
        final matchesCategory = selected == 'All' || s.category == selected;
        return matchesQuery && matchesCategory;
      }).toList();
    }

    return Scaffold(
      body: Stack(
        children: [
          // ✅ Animated background (subtle)
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
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    child: _AnimatedIn(
                      delayMs: 40,
                      child: _TopBar(
                        title: 'Services',
                        subtitle: 'Find the right help, quickly.',
                        onBack: () => Navigator.pop(context),
                        trailing: _CountPill(count: filtered.length),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    child: _AnimatedIn(
                      delayMs: 110,
                      child: _SearchField(
                        onChanged: (v) => setState(() => _query = v),
                      ),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: _AnimatedIn(
                    delayMs: 160,
                    child: SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final isActive = index == _selectedCategory;
                          return _BouncyTap(
                            onTap: () =>
                                setState(() => _selectedCategory = index),
                            child: _CategoryChip(
                              label: _categories[index],
                              active: isActive,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // ✅ Loading / error / empty / list
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
                            Text('Loading services...'),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (_error != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                      child: _AnimatedIn(
                        delayMs: 0,
                        child: Column(
                          children: [
                            _EmptyState(
                              title: 'Failed to load services',
                              subtitle: _error!,
                            ),
                            const SizedBox(height: 12),
                            _BouncyTap(
                              onTap: _load,
                              child: Container(
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
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: filtered.isEmpty
                          ? Padding(
                              key: const ValueKey("empty"),
                              padding: const EdgeInsets.fromLTRB(16, 30, 16, 0),
                              child: _AnimatedIn(
                                delayMs: 0,
                                child: const _EmptyState(
                                  title: 'No services found',
                                  subtitle:
                                      'Try a different keyword or category.',
                                ),
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey("list")),
                    ),
                  ),

                if (filtered.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final item = filtered[i];

                        return _AnimatedIn(
                          // ✅ staggered entrance for cards
                          delayMs: 220 + (i * 70),
                          child: _ServiceCard(
                            item: item,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailsScreen(
                                    serviceName: item.title,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: cs.background,
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

class _CountPill extends StatelessWidget {
  final int count;
  const _CountPill({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.70),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        "$count found",
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search services...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: cs.onSurface.withOpacity(0.55),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool active;

  const _CategoryChip({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? cs.primaryContainer.withOpacity(0.85)
            : cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? cs.primary.withOpacity(0.25)
              : cs.outlineVariant.withOpacity(0.6),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: active ? cs.primary : cs.onSurface.withOpacity(0.72),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final _ServiceItem item;
  final VoidCallback onTap;

  const _ServiceCard({required this.item, required this.onTap});

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: _pressed ? 0.985 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
                child: SizedBox(
                  width: 110,
                  height: 92,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          widget.item.imageAsset,
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
                      // subtle overlay = “premium”
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.10),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.item.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                          _Badge(text: widget.item.badge),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.item.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.68),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Verified technicians",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface.withOpacity(0.70),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: cs.onSurface.withOpacity(0.45),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.primary,
          height: 1,
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
            child: Icon(Icons.search_off_rounded, color: cs.primary),
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

class _BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _BouncyTap({required this.child, required this.onTap});

  @override
  State<_BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<_BouncyTap> {
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
        scale: _down ? 0.97 : 1,
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

/* ---------------- Data model ---------------- */

class _ServiceItem {
  final String title;
  final String subtitle;
  final String category;
  final String imageAsset;
  final String badge;

  const _ServiceItem({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.imageAsset,
    required this.badge,
  });
}
