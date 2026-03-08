import 'package:flutter/material.dart';
import 'package:seamlesscall/features/customer/data/models/customer_repository.dart';
import 'package:seamlesscall/features/customer/data/models/promotion_model.dart';

class CustomerPromotionsSection extends StatefulWidget {
  const CustomerPromotionsSection({super.key});

  @override
  State<CustomerPromotionsSection> createState() =>
      _CustomerPromotionsSectionState();
}

class _CustomerPromotionsSectionState extends State<CustomerPromotionsSection> {
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
              child: Text(
                'Promotions could not be loaded.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
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
              child: Text(
                'No active promotions right now.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        final cardWidth = viewportWidth < 420
            ? viewportWidth - 24
            : viewportWidth < 700
                ? viewportWidth * 0.78
                : 320.0;

        return SizedBox(
          height: 205,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _items[index];
              return SizedBox(
                width: cardWidth,
                child: _PromotionCard(item: item),
              );
            },
          ),
        );
      },
    );
  }
}

class _PromotionCard extends StatelessWidget {
  final CustomerPromotion item;

  const _PromotionCard({required this.item});

  IconData _iconForType() {
    switch (item.promotionType) {
      case 'coupon':
        return Icons.confirmation_number_outlined;
      case 'provider':
        return Icons.person_outline;
      case 'service':
        return Icons.design_services_outlined;
      default:
        return Icons.local_offer_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
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
                child: Icon(_iconForType(), color: cs.primary),
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
          const SizedBox(height: 12),
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.resolvedTargetLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withOpacity(0.80),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              (item.description == null || item.description!.trim().isEmpty)
                  ? 'Limited-time offer'
                  : item.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.68),
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  item.validityLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withOpacity(0.62),
                  ),
                ),
              ),
              if (item.promotionType == 'coupon' &&
                  item.code != null &&
                  item.code!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.code!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}