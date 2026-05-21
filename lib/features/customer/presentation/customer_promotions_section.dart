import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seamlesscall/features/customer/data/models/customer_repository.dart';
import 'package:seamlesscall/features/customer/data/models/promotion_model.dart';
import 'package:seamlesscall/features/customer/presentation/customer_services_list.dart';

/// Horizontal carousel of active promotions.
///
/// Each card is now actionable:
///   global  → opens ServicesListScreen (discount applies to all)
///   service → opens ServicesListScreen filtered to that service/category
///   coupon  → shows a bottom sheet to copy the code + explains how to use it
///   provider → opens ServicesListScreen (filter by provider — future)
///
/// The promo object is passed through navigation so BookingSummaryScreen
/// can pre-load it and call validatePromotion automatically.
class CustomerPromotionsSection extends StatefulWidget {
  const CustomerPromotionsSection({super.key});

  @override
  State<CustomerPromotionsSection> createState() =>
      _CustomerPromotionsSectionState();
}

class _CustomerPromotionsSectionState
    extends State<CustomerPromotionsSection> {
  final CustomerRepository _repo = CustomerRepository();

  bool _loading = true;
  String? _error;
  List<CustomerPromotion> _items = const [];

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
      final items = await _repo.getActivePromotions();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  void _onTap(CustomerPromotion item) {
    switch (item.promotionType) {
      case 'coupon':
        _showCouponSheet(item);
        break;
      case 'service':
      case 'provider':
      case 'global':
      default:
        // Navigate to Services list. Pass the promo so BookingSummaryScreen
        // can auto-apply it without the customer needing to retype anything.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServicesListScreen(autoPromo: item),
          ),
        );
        break;
    }
  }

  void _showCouponSheet(CustomerPromotion item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CouponSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return Container(
        height: 160,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
        ),
        child: const CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Promotions could not be loaded.',
                  style: theme.textTheme.bodyMedium),
            ),
            TextButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surface.withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_offer_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text('No active promotions right now.',
                  style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      final vw = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;

      final cardWidth = vw < 420
          ? vw - 24
          : vw < 700
              ? vw * 0.78
              : 320.0;

      return SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, i) {
            final item = _items[i];
            return SizedBox(
              width: cardWidth,
              child: _PromotionCard(
                item: item,
                onTap: () => _onTap(item),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─── Promotion card ───────────────────────────────────────────────────────────

class _PromotionCard extends StatefulWidget {
  final CustomerPromotion item;
  final VoidCallback onTap;
  const _PromotionCard({required this.item, required this.onTap});

  @override
  State<_PromotionCard> createState() => _PromotionCardState();
}

class _PromotionCardState extends State<_PromotionCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final item  = widget.item;

    IconData icon;
    String ctaLabel;
    switch (item.promotionType) {
      case 'coupon':
        icon     = Icons.confirmation_number_outlined;
        ctaLabel = 'Copy code';
        break;
      case 'provider':
        icon     = Icons.person_outline;
        ctaLabel = 'Browse services';
        break;
      case 'service':
        icon     = Icons.design_services_outlined;
        ctaLabel = 'Book now';
        break;
      default:
        icon     = Icons.local_offer_outlined;
        ctaLabel = 'Browse services';
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                cs.surface.withOpacity(0.95),
                cs.primaryContainer.withOpacity(0.38),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: cs.outlineVariant.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 38,
                    width: 38,
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: cs.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.discountLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.primary,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.resolvedTargetLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withOpacity(0.75),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  item.description?.trim().isEmpty ?? true
                      ? 'Limited-time offer'
                      : item.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.65),
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // CTA row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.validityLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      ctaLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Coupon bottom sheet ──────────────────────────────────────────────────────

class _CouponSheet extends StatelessWidget {
  final CustomerPromotion item;
  const _CouponSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.75),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.confirmation_number_rounded,
                color: cs.primary, size: 28),
          ),
          const SizedBox(height: 14),
          Text(
            item.discountLabel,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.validityLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.60),
            ),
          ),
          const SizedBox(height: 20),
          // Copyable code
          if (item.code != null && item.code!.isNotEmpty) ...[
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: item.code!));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Code "${item.code}" copied!'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: cs.primary.withOpacity(0.22),
                      style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.code!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.copy_rounded, color: cs.primary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface.withOpacity(0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: cs.outlineVariant.withOpacity(0.55)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: cs.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enter this code in the booking summary screen '
                    'to apply the discount to your inspection fee.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.75),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServicesListScreen(autoPromo: item),
                  ),
                );
              },
              child: const Text('Browse Services',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}
