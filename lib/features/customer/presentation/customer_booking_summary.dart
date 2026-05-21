import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../common/widgets/main_layout.dart';
import '../data/models/customer_repository.dart';
import '../data/models/promotion_model.dart';
import 'booking_models.dart';
import 'customer_booking_timeline.dart';

class BookingSummaryScreen extends StatefulWidget {
  final BookingDraft draft;

  /// Pre-loaded promotion from promo card tap / ServicesListScreen.
  /// When provided the screen auto-validates it on first build.
  final CustomerPromotion? autoPromo;

  const BookingSummaryScreen({
    super.key,
    required this.draft,
    this.autoPromo,
  });

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen>
    with SingleTickerProviderStateMixin {
  final CustomerRepository _repo = CustomerRepository();

  // ── State ──────────────────────────────────────────────────────────────────
  bool _submitting = false;

  // Promotion
  final _codeCtrl = TextEditingController();
  bool _promoLoading    = false;
  String? _promoError;
  String? _promoSuccess;
  int?    _appliedPromoId;
  double  _originalAmount    = 0;   // set after the promo validates (inspection fee)
  double  _discountApplied   = 0;
  double  _finalAmount       = 0;
  bool    _promoSectionOpen  = false;

  late final AnimationController _bg = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    // If a promo was passed in via navigation, auto-validate it
    if (widget.autoPromo != null) {
      _promoSectionOpen = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _autoApplyPromo(widget.autoPromo!);
      });
    }
  }

  @override
  void dispose() {
    _bg.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  // ── Promotion helpers ──────────────────────────────────────────────────────

  void _autoApplyPromo(CustomerPromotion promo) {
    if (promo.promotionType == 'coupon' && (promo.code?.isNotEmpty ?? false)) {
      _codeCtrl.text = promo.code!;
    }
    _validatePromo(promotionId: promo.id);
  }

  Future<void> _validatePromo({int? promotionId}) async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (promotionId == null && code.isEmpty) {
      setState(() => _promoError = 'Enter a promo code first.');
      return;
    }

    setState(() {
      _promoLoading = true;
      _promoError   = null;
      _promoSuccess = null;
    });

    try {
      // We don't know the inspection fee until Paystack initialises, but the
      // validate endpoint accepts amount=0 for eligibility-only checks.
      // The actual discount is re-calculated server-side at payment time using
      // the real inspection_fee from service_pricing_profiles.
      // We pass 0 here so we can show the user the promo is valid;
      // the backend recalculates the exact amounts at initializeInspectionPayment.
      final result = await _repo.validatePromotion(
        promotionId: promotionId,
        code: promotionId == null ? code : null,
        serviceId: widget.draft.serviceId ?? 0,
        amount: 0,
      );

      if (result['valid'] == true) {
        setState(() {
          _appliedPromoId  = result['promotion_id'] as int?;
          _discountApplied = (result['discount_applied'] as num?)?.toDouble() ?? 0;
          _finalAmount     = (result['final_amount']     as num?)?.toDouble() ?? 0;
          _originalAmount  = (result['original_amount']  as num?)?.toDouble() ?? 0;
          _promoSuccess    = result['message']?.toString() ?? 'Promotion applied!';
          _promoError      = null;
          _promoLoading    = false;
        });
      } else {
        setState(() {
          _appliedPromoId  = null;
          _discountApplied = 0;
          _promoError      = result['message']?.toString() ?? 'Invalid promotion.';
          _promoSuccess    = null;
          _promoLoading    = false;
        });
      }
    } catch (e) {
      setState(() {
        _promoLoading = false;
        _promoError   = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _removePromo() {
    setState(() {
      _appliedPromoId  = null;
      _discountApplied = 0;
      _finalAmount     = 0;
      _originalAmount  = 0;
      _promoSuccess    = null;
      _promoError      = null;
      _codeCtrl.clear();
    });
  }

  // ── Booking submission ─────────────────────────────────────────────────────

  Future<void> _submitBooking(BookingDraft draft) async {
    if (_submitting) return;
    setState(() => _submitting = true);

    try {
      int? serviceId = draft.serviceId;

      if (serviceId == null) {
        final services = await _repo.getAllServices();
        for (final s in services) {
          if (s.name.trim().toLowerCase() == draft.serviceName.trim().toLowerCase()) {
            serviceId = s.id;
            break;
          }
        }
      }

      if (serviceId == null) {
        throw Exception(
          'Unable to resolve the selected service. Please go back and reselect.',
        );
      }

      await _repo.createBooking(
        serviceId:   serviceId,
        serviceName: draft.serviceName,
        bookingType: draft.type == BookingType.asap ? 'asap' : 'scheduled',
        scheduledAt: draft.scheduledAt,
        address:     draft.address.trim(),
        note:        draft.note.trim(),
      );

      if (!mounted) return;

      // Pass promotionId into the draft so BookingTimelineScreen
      // (and eventually initializeInspectionPayment) can use it
      final finalDraft = draft.copyWith(
        promotionId:     _appliedPromoId,
        discountApplied: _discountApplied,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingTimelineScreen(draft: finalDraft),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final d     = widget.draft;

    final address = d.address.isEmpty ? 'Not provided yet' : d.address;
    final note    = d.note.isEmpty    ? 'None' : d.note;

    return MainLayout(
      child: Scaffold(
        backgroundColor: cs.surface,
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

                  // ── Top bar ────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 40,
                        child: _TopBar(
                          title: 'Booking summary',
                          subtitle: d.serviceName,
                          stepText: 'Step 2 of 2',
                          onBack: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ),

                  // ── Hero ──────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 120,
                        child: _HeroCard(
                          title: 'Review your request',
                          subtitle:
                              'Confirm the details below. You can refine them later via chat.',
                          icon: Icons.fact_check_rounded,
                        ),
                      ),
                    ),
                  ),

                  // ── Request details ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 190,
                        child: _SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Request details',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _SummaryRow(
                                icon: Icons.home_repair_service_rounded,
                                label: 'Service',
                                value: d.serviceName,
                              ),
                              const SizedBox(height: 10),
                              _SummaryRow(
                                icon: Icons.timer_rounded,
                                label: 'When',
                                value: d.type == BookingType.asap
                                    ? 'ASAP'
                                    : d.scheduleLabel,
                              ),
                              const SizedBox(height: 10),
                              _SummaryRow(
                                icon: Icons.location_on_rounded,
                                label: 'Address',
                                value: address,
                              ),
                              const SizedBox(height: 10),
                              _SummaryRow(
                                icon: Icons.notes_rounded,
                                label: 'Notes',
                                value: note,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Promotion section ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _AnimatedIn(
                        delayMs: 240,
                        child: _PromoSection(
                          codeCtrl:         _codeCtrl,
                          loading:          _promoLoading,
                          error:            _promoError,
                          success:          _promoSuccess,
                          appliedPromoId:   _appliedPromoId,
                          discountApplied:  _discountApplied,
                          isOpen:           _promoSectionOpen,
                          onToggle: () => setState(
                              () => _promoSectionOpen = !_promoSectionOpen),
                          onApply:  () => _validatePromo(),
                          onRemove: _removePromo,
                        ),
                      ),
                    ),
                  ),

                  // ── Next steps ─────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                      child: _AnimatedIn(
                        delayMs: 300,
                        child: _SectionCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next steps',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const _Bullet(
                                text:
                                    "You'll pay the inspection/engagement fee to dispatch a technician.",
                              ),
                              const SizedBox(height: 10),
                              const _Bullet(
                                text:
                                    'After inspection, you receive a structured quote.',
                              ),
                              const SizedBox(height: 10),
                              const _Bullet(
                                text:
                                    'You approve and pay before execution starts.',
                              ),
                              if (_appliedPromoId != null) ...[
                                const SizedBox(height: 10),
                                _Bullet(
                                  text:
                                      'Your promotion discount (₦${_discountApplied.toStringAsFixed(0)}) will be applied when you pay the inspection fee.',
                                  highlight: true,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom bar ───────────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: _BottomBar(
                  primaryText:
                      _submitting ? 'Submitting…' : 'Confirm request',
                  secondaryText: 'Back',
                  onSecondary:
                      _submitting ? () {} : () => Navigator.pop(context),
                  onPrimary:
                      _submitting ? () {} : () => _submitBooking(d),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Promotion section widget ─────────────────────────────────────────────────

class _PromoSection extends StatelessWidget {
  final TextEditingController codeCtrl;
  final bool loading;
  final String? error;
  final String? success;
  final int? appliedPromoId;
  final double discountApplied;
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _PromoSection({
    required this.codeCtrl,
    required this.loading,
    required this.error,
    required this.success,
    required this.appliedPromoId,
    required this.discountApplied,
    required this.isOpen,
    required this.onToggle,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    // Collapsed state: just a tappable row
    if (!isOpen && appliedPromoId == null) {
      return _Pressable(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: cs.outlineVariant.withOpacity(0.6),
                style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              Icon(Icons.local_offer_outlined,
                  color: cs.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Have a promo code or promotion?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withOpacity(0.80),
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurface.withOpacity(0.45)),
            ],
          ),
        ),
      );
    }

    // Applied state: show discount summary with remove option
    if (appliedPromoId != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withOpacity(0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.check_circle_rounded,
                  color: cs.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promotion applied!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                    ),
                  ),
                  if (discountApplied > 0)
                    Text(
                      'Discount will be applied at payment',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.68),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRemove,
              child: Text(
                'Remove',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Expanded input state
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_rounded,
                  color: cs.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Apply a promotion',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              _Pressable(
                onTap: onToggle,
                child: Icon(Icons.close_rounded,
                    color: cs.onSurface.withOpacity(0.45), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Code input + apply button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeCtrl,
                  textCapitalization: TextCapitalization.characters,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    hintText: 'PROMO CODE',
                    hintStyle: TextStyle(
                      color: cs.onSurface.withOpacity(0.38),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                    filled: true,
                    fillColor:
                        cs.surfaceContainerHighest.withOpacity(0.45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: cs.outlineVariant.withOpacity(0.6)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                          color: cs.outlineVariant.withOpacity(0.6)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _Pressable(
                onTap: loading ? () {} : onApply,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: loading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : Text(
                          'Apply',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onPrimary,
                          ),
                        ),
                ),
              ),
            ],
          ),

          // Feedback messages
          if (error != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.error_outline_rounded,
                    color: cs.error, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (success != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: cs.primary, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    success!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Shared UI components ─────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final String stepText;
  final VoidCallback onBack;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.stepText,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

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
              border:
                  Border.all(color: cs.outlineVariant.withOpacity(0.6)),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.68),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.65),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.primary.withOpacity(0.18)),
          ),
          child: Text(
            stepText,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withOpacity(0.15),
            cs.surface.withOpacity(0.96),
          ],
        ),
        border: Border.all(color: cs.primary.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              height: 54,
              width: 54,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: cs.primary, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
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
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.72),
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

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

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

class _Bullet extends StatelessWidget {
  final String text;
  final bool highlight;
  const _Bullet({required this.text, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          highlight
              ? Icons.local_offer_rounded
              : Icons.check_circle_rounded,
          size: 18,
          color: highlight ? cs.primary : cs.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
              color: highlight
                  ? cs.primary
                  : cs.onSurface.withOpacity(0.75),
              height: 1.25,
            ),
          ),
        ),
      ],
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
    final cs    = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.94),
        border: Border(
            top: BorderSide(color: cs.outlineVariant.withOpacity(0.7))),
      ),
      child: Row(
        children: [
          _Pressable(
            onTap: onSecondary,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: cs.outlineVariant.withOpacity(0.8)),
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

class _SoftBgPainter extends CustomPainter {
  final Color primary;
  final Color surface;
  final double t;

  const _SoftBgPainter({
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
    final x1 = size.width * (0.18 + 0.06 * math.sin(t * 2 * math.pi));
    final y1 = size.height * (0.18 + 0.03 * math.cos(t * 2 * math.pi));
    canvas.drawCircle(Offset(x1, y1), size.width * 0.40,
        Paint()..color = primary.withOpacity(0.08));
    final x2 = size.width * (0.92 - 0.06 * math.cos(t * 2 * math.pi));
    final y2 = size.height * (0.52 + 0.04 * math.sin(t * 2 * math.pi));
    canvas.drawCircle(Offset(x2, y2), size.width * 0.34,
        Paint()..color = primary.withOpacity(0.06));
  }

  @override
  bool shouldRepaint(covariant _SoftBgPainter old) =>
      old.t != t || old.primary != primary || old.surface != surface;
}
