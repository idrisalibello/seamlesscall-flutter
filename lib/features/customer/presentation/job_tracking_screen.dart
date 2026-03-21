import 'package:flutter/material.dart';

import '../data/models/customer_orders_repository.dart';

class JobTrackingScreen extends StatefulWidget {
  final String jobId;

  const JobTrackingScreen({super.key, required this.jobId});

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  final CustomerOrdersRepository _repo = CustomerOrdersRepository();

  bool _loading = true;
  String? _error;
  _TrackingModel? _model;

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
      final data = await _repo.getOrderDetails(widget.jobId);
      final model = _TrackingModel.fromApi(widget.jobId, data);

      if (!mounted) return;

      setState(() {
        _model = model;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(title: const Text('Track Service')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: cs.background,
        appBar: AppBar(title: const Text('Track Service')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, size: 42),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final model = _model!;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: _TopBar(
                    title: "Track Service",
                    subtitle: "Job ${model.jobId} • ${model.serviceName}",
                    onBack: () => Navigator.pop(context),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: _StatusHero(
                    statusTitle: model.statusTitle,
                    statusHint: model.statusHint,
                    etaText: model.etaText,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                  child: _QuoteProformaCard(
                    quote: model.quote,
                    onApproveAndPay: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Approve & Pay will be wired to the payment flow next.",
                          ),
                        ),
                      );
                    },
                    onRequestChange: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Request change will be wired to chat/support next.",
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                  child: _MiniMapPreview(
                    pickupLabel: model.pickupLabel,
                    destinationLabel: model.destinationLabel,
                    distanceText: model.distanceText,
                    etaText: model.etaText,
                    onOpenMap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Live map hookup comes next."),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
                  child: _TechnicianCard(
                    techName: model.techName,
                    techRating: model.techRating,
                    techJobs: model.techJobs,
                    onChat: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Technician chat comes next."),
                        ),
                      );
                    },
                    onCall: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Technician calling comes next."),
                        ),
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  child: Text(
                    "Progress",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onBackground,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.separated(
                  itemCount: model.steps.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final step = model.steps[i];
                    return _TrackingStepTile(step: step);
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  child: Text(
                    "Latest updates",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onBackground,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList.separated(
                  itemCount: model.updates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) =>
                      _UpdateLogTile(update: model.updates[i]),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: _ActionPanel(
                    primaryText: model.primaryActionText,
                    secondaryText: "Report an issue",
                    onPrimary: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(model.primaryActionText),
                        ),
                      );
                    },
                    onSecondary: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Support/dispute flow will be wired next.",
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
      ),
    );
  }
}

/* ---------------- Widgets ---------------- */

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
              color: cs.surface,
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
      ],
    );
  }
}

class _QuoteProformaCard extends StatelessWidget {
  final _QuoteProforma quote;
  final VoidCallback onApproveAndPay;
  final VoidCallback onRequestChange;

  const _QuoteProformaCard({
    required this.quote,
    required this.onApproveAndPay,
    required this.onRequestChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Color statusColor;
    String statusText;
    switch (quote.state) {
      case _QuoteState.pending:
        statusColor = Colors.orange;
        statusText = "Pending";
        break;
      case _QuoteState.ready:
        statusColor = Colors.blue;
        statusText = "Ready";
        break;
      case _QuoteState.approved:
        statusColor = Colors.green;
        statusText = "Approved";
        break;
      case _QuoteState.rejected:
        statusColor = Colors.red;
        statusText = "Rejected";
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.receipt_long_rounded, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quote / Proforma",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Expected range: ${quote.bandText}",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _QuoteLine(
            label: "Inspection fee",
            value: quote.inspectionFeeText,
            strong: true,
          ),
          const SizedBox(height: 8),
          ...quote.lines.map(
            (l) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _QuoteLine(label: l.label, value: l.value),
            ),
          ),
          const Divider(height: 20),
          _QuoteLine(label: "Total", value: quote.totalText, strong: true),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.primary.withOpacity(0.12)),
            ),
            child: Text(
              "No price changes outside the app. If adjustments are needed, you’ll approve them here before payment.",
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withOpacity(0.75),
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: quote.state == _QuoteState.ready
                      ? onApproveAndPay
                      : null,
                  child: Ink(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: quote.state == _QuoteState.ready
                          ? cs.primary
                          : cs.onSurface.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "Approve & Pay",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: quote.state == _QuoteState.ready
                              ? cs.onPrimary
                              : cs.onSurface.withOpacity(0.45),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onRequestChange,
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
                  child: Text(
                    "Request change",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface.withOpacity(0.78),
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

class _QuoteLine extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _QuoteLine({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
              color: cs.onSurface.withOpacity(strong ? 0.85 : 0.70),
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
            color: cs.onSurface.withOpacity(0.82),
          ),
        ),
      ],
    );
  }
}

class _StatusHero extends StatelessWidget {
  final String statusTitle;
  final String statusHint;
  final String etaText;

  const _StatusHero({
    required this.statusTitle,
    required this.statusHint,
    required this.etaText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
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
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.75),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.track_changes_rounded, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.68),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.65),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              etaText,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMapPreview extends StatelessWidget {
  final String pickupLabel;
  final String destinationLabel;
  final String distanceText;
  final String etaText;
  final VoidCallback onOpenMap;

  const _MiniMapPreview({
    required this.pickupLabel,
    required this.destinationLabel,
    required this.distanceText,
    required this.etaText,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
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
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primaryContainer.withOpacity(0.65),
                    cs.surfaceContainerHighest.withOpacity(0.75),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.25,
                      child: CustomPaint(
                        painter: _RoadPainter(color: cs.primary),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    top: 22,
                    child: _MapPin(label: "You", icon: Icons.home_rounded),
                  ),
                  Positioned(
                    right: 18,
                    bottom: 24,
                    child: _MapPin(
                      label: "Tech",
                      icon: Icons.engineering_rounded,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 12,
                    child: Row(
                      children: [
                        _Pill(text: distanceText),
                        const SizedBox(width: 10),
                        _Pill(text: etaText),
                        const Spacer(),
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: onOpenMap,
                          child: Ink(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.map_rounded,
                                  size: 18,
                                  color: cs.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Open map",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                _RouteRow(
                  icon: Icons.radio_button_checked_rounded,
                  iconColor: cs.primary,
                  title: "Pickup",
                  value: pickupLabel,
                ),
                const SizedBox(height: 10),
                _RouteRow(
                  icon: Icons.location_on_rounded,
                  iconColor: cs.onSurface.withOpacity(0.55),
                  title: "Destination",
                  value: destinationLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _RouteRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(
          "$title:",
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: cs.onSurface.withOpacity(0.75),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withOpacity(0.70),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MapPin({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface.withOpacity(0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: cs.onSurface.withOpacity(0.75),
        ),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  final Color color;
  const _RoadPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final dash = Paint()
      ..color = color.withOpacity(0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.25)
      ..quadraticBezierTo(
        size.width * 0.50,
        size.height * 0.10,
        size.width * 0.76,
        size.height * 0.50,
      )
      ..quadraticBezierTo(
        size.width * 0.92,
        size.height * 0.78,
        size.width * 0.62,
        size.height * 0.86,
      );

    canvas.drawPath(path, p);

    final metrics = path.computeMetrics().toList();
    for (final m in metrics) {
      double dist = 0;
      const dashLen = 10.0;
      const gapLen = 8.0;
      while (dist < m.length) {
        final seg = m.extractPath(dist, dist + dashLen);
        canvas.drawPath(seg, dash);
        dist += dashLen + gapLen;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TechnicianCard extends StatelessWidget {
  final String techName;
  final double techRating;
  final int techJobs;
  final VoidCallback onChat;
  final VoidCallback onCall;

  const _TechnicianCard({
    required this.techName,
    required this.techRating,
    required this.techJobs,
    required this.onChat,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.primaryContainer.withOpacity(0.75),
            child: Icon(Icons.person_rounded, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  techName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: cs.primary),
                    const SizedBox(width: 4),
                    Text(
                      techRating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "$techJobs jobs",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface.withOpacity(0.60),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onChat,
            child: Ink(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.chat_bubble_outline_rounded, color: cs.primary),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onCall,
            child: Ink(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withOpacity(0.65),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.call_rounded, color: cs.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStepTile extends StatelessWidget {
  final _TrackingStep step;

  const _TrackingStepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Color dotColor = step.state == _StepState.done
        ? cs.primary
        : step.state == _StepState.active
            ? cs.primary
            : cs.onSurface.withOpacity(0.25);

    final Color lineColor = step.state == _StepState.upcoming
        ? cs.onSurface.withOpacity(0.12)
        : cs.primary.withOpacity(0.35);

    final IconData icon = step.state == _StepState.done
        ? Icons.check_rounded
        : step.state == _StepState.active
            ? Icons.circle
            : Icons.circle_outlined;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  height: 26,
                  width: 26,
                  decoration: BoxDecoration(
                    color: step.state == _StepState.upcoming
                        ? cs.surfaceContainerHighest.withOpacity(0.7)
                        : cs.primaryContainer.withOpacity(0.65),
                    shape: BoxShape.circle,
                    border: Border.all(color: lineColor),
                  ),
                  child: Icon(icon, size: 16, color: dotColor),
                ),
                const SizedBox(height: 6),
                Container(height: 42, width: 2, color: lineColor),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      step.timeText ?? "",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.55),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (step.subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    step.subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.68),
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionPanel extends StatelessWidget {
  final String primaryText;
  final String secondaryText;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const _ActionPanel({
    required this.primaryText,
    required this.secondaryText,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onPrimary,
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  primaryText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onSecondary,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.8)),
            ),
            child: Text(
              secondaryText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.78),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------------- Model ---------------- */

enum _StepState { done, active, upcoming }

class _TrackingStep {
  final String title;
  final String? subtitle;
  final String? timeText;
  final _StepState state;

  const _TrackingStep({
    required this.title,
    required this.state,
    this.subtitle,
    this.timeText,
  });
}

enum _UpdateType { info, success, warning }

class _TrackingUpdate {
  final String timeText;
  final String title;
  final String detail;
  final _UpdateType type;

  const _TrackingUpdate({
    required this.timeText,
    required this.title,
    required this.detail,
    required this.type,
  });
}

class _UpdateLogTile extends StatelessWidget {
  final _TrackingUpdate update;

  const _UpdateLogTile({required this.update});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final icon = update.type == _UpdateType.info
        ? Icons.info_outline_rounded
        : update.type == _UpdateType.success
            ? Icons.check_circle_outline_rounded
            : Icons.warning_amber_rounded;

    final iconColor = update.type == _UpdateType.info
        ? cs.primary
        : update.type == _UpdateType.success
            ? Colors.green
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.65),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        update.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Text(
                      update.timeText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  update.detail,
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

class _TrackingModel {
  final String jobId;
  final String serviceName;

  final String statusTitle;
  final String statusHint;
  final String etaText;

  final String techName;
  final double techRating;
  final int techJobs;

  final _QuoteProforma quote;
  final String pickupLabel;
  final String destinationLabel;
  final String distanceText;
  final List<_TrackingUpdate> updates;

  final String primaryActionText;
  final List<_TrackingStep> steps;

  const _TrackingModel({
    required this.jobId,
    required this.serviceName,
    required this.statusTitle,
    required this.statusHint,
    required this.etaText,
    required this.techName,
    required this.techRating,
    required this.techJobs,
    required this.quote,
    required this.pickupLabel,
    required this.destinationLabel,
    required this.distanceText,
    required this.updates,
    required this.primaryActionText,
    required this.steps,
  });

  factory _TrackingModel.fromApi(String jobId, Map<String, dynamic> data) {
    final job = Map<String, dynamic>.from(data['job'] ?? const {});
    final service = Map<String, dynamic>.from(data['service'] ?? const {});
    final provider = data['provider'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['provider'])
        : <String, dynamic>{};
    final meta = Map<String, dynamic>.from(data['meta'] ?? const {});
    final summary = Map<String, dynamic>.from(data['status_summary'] ?? const {});
    final timeline = (data['timeline'] as List<dynamic>? ?? const [])
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final status = (job['status'] ?? 'pending').toString().toLowerCase();
    final address = (meta['address'] ?? 'Customer address').toString();
    final scheduledTime = (job['scheduled_time'] ?? '').toString();

    final steps = timeline.map(_stepFromApi).toList();
    final updates = _updatesFromApi(job, provider, timeline);

    return _TrackingModel(
      jobId: 'SC-${job['id'] ?? jobId}',
      serviceName: (job['title'] ?? service['name'] ?? 'Service Request')
          .toString(),
      statusTitle: (summary['title'] ?? 'Tracking').toString(),
      statusHint: (summary['hint'] ?? 'Status information is available.')
          .toString(),
      etaText: _etaFromStatus(status, scheduledTime),
      techName: (provider['name'] ?? 'Technician not assigned').toString(),
      techRating: provider.isEmpty ? 0.0 : 4.8,
      techJobs: provider.isEmpty ? 0 : 0,
      quote: _quoteFromApi(status),
      pickupLabel: address,
      destinationLabel: provider.isEmpty
          ? 'Technician will appear here after assignment'
          : 'Technician route to your location',
      distanceText: provider.isEmpty ? '-- km' : 'En route',
      updates: updates,
      primaryActionText:
          (data['primary_action_text'] ?? _primaryActionFromStatus(status))
              .toString(),
      steps: steps.isEmpty ? _fallbackSteps(status) : steps,
    );
  }

  static _TrackingStep _stepFromApi(Map<String, dynamic> step) {
    final completed = step['completed'] == true;
    final active = step['active'] == true;

    return _TrackingStep(
      title: (step['title'] ?? '').toString(),
      subtitle: (step['subtitle'] ?? '').toString(),
      timeText: _formatTime(step['time']),
      state: completed
          ? _StepState.done
          : active
              ? _StepState.active
              : _StepState.upcoming,
    );
  }

  static List<_TrackingUpdate> _updatesFromApi(
    Map<String, dynamic> job,
    Map<String, dynamic> provider,
    List<Map<String, dynamic>> timeline,
  ) {
    final updates = <_TrackingUpdate>[];

    for (final step in timeline) {
      final completed = step['completed'] == true;
      final active = step['active'] == true;

      if (!completed && !active) continue;

      updates.add(
        _TrackingUpdate(
          timeText: _formatTime(step['time']),
          title: (step['title'] ?? '').toString(),
          detail: (step['subtitle'] ?? '').toString(),
          type: completed ? _UpdateType.success : _UpdateType.info,
        ),
      );
    }

    if (provider.isNotEmpty) {
      updates.insert(
        0,
        _TrackingUpdate(
          timeText: '',
          title: 'Technician assigned',
          detail:
              '${provider['name'] ?? 'A technician'} has been assigned to your request.',
          type: _UpdateType.success,
        ),
      );
    }

    if (updates.isEmpty) {
      updates.add(
        _TrackingUpdate(
          timeText: _formatTime(job['created_at']),
          title: 'Request received',
          detail: 'We received your request and it is awaiting the next action.',
          type: _UpdateType.info,
        ),
      );
    }

    return updates;
  }

  static _QuoteProforma _quoteFromApi(String status) {
    switch (status) {
      case 'completed':
        return const _QuoteProforma(
          state: _QuoteState.approved,
          bandText: 'Confirmed',
          inspectionFeeText: 'Paid / processed',
          lines: [
            _QuoteLineItem(label: 'Job status', value: 'Completed'),
          ],
          totalText: 'Finalized',
        );
      case 'active':
        return const _QuoteProforma(
          state: _QuoteState.ready,
          bandText: 'Awaiting quote approval',
          inspectionFeeText: 'Inspection underway',
          lines: [
            _QuoteLineItem(label: 'Status', value: 'Technician assigned'),
          ],
          totalText: 'Quote pending',
        );
      case 'scheduled':
        return const _QuoteProforma(
          state: _QuoteState.pending,
          bandText: 'To be assessed',
          inspectionFeeText: 'Pending',
          lines: [
            _QuoteLineItem(label: 'Status', value: 'Scheduled'),
          ],
          totalText: 'Pending',
        );
      case 'cancelled':
        return const _QuoteProforma(
          state: _QuoteState.rejected,
          bandText: 'Cancelled',
          inspectionFeeText: 'Not applicable',
          lines: [
            _QuoteLineItem(label: 'Status', value: 'Cancelled'),
          ],
          totalText: 'Cancelled',
        );
      case 'pending':
      default:
        return const _QuoteProforma(
          state: _QuoteState.pending,
          bandText: 'To be assessed after inspection',
          inspectionFeeText: 'Pending',
          lines: [
            _QuoteLineItem(label: 'Status', value: 'Awaiting review'),
          ],
          totalText: 'Pending',
        );
    }
  }

  static String _etaFromStatus(String status, String scheduledTime) {
    switch (status) {
      case 'completed':
        return 'Done';
      case 'cancelled':
        return 'Stopped';
      case 'active':
        return 'Live';
      case 'scheduled':
        return scheduledTime.isEmpty ? 'Scheduled' : 'Scheduled';
      default:
        return 'Pending';
    }
  }

  static String _primaryActionFromStatus(String status) {
    switch (status) {
      case 'completed':
        return 'View completion';
      case 'cancelled':
        return 'View details';
      case 'active':
        return 'View technician status';
      case 'scheduled':
        return 'View schedule';
      default:
        return 'Awaiting inspection';
    }
  }

  static List<_TrackingStep> _fallbackSteps(String status) {
    if (status == 'completed') {
      return const [
        _TrackingStep(title: 'Request sent', state: _StepState.done),
        _TrackingStep(title: 'Technician matched', state: _StepState.done),
        _TrackingStep(title: 'Work in progress', state: _StepState.done),
        _TrackingStep(title: 'Completed', state: _StepState.done),
      ];
    }

    if (status == 'active') {
      return const [
        _TrackingStep(title: 'Request sent', state: _StepState.done),
        _TrackingStep(title: 'Technician matched', state: _StepState.done),
        _TrackingStep(title: 'Technician en route', state: _StepState.active),
        _TrackingStep(title: 'Completed', state: _StepState.upcoming),
      ];
    }

    return const [
      _TrackingStep(title: 'Request sent', state: _StepState.done),
      _TrackingStep(title: 'Inspection / review pending', state: _StepState.active),
      _TrackingStep(title: 'Technician assigned', state: _StepState.upcoming),
      _TrackingStep(title: 'Completed', state: _StepState.upcoming),
    ];
  }

  static String _formatTime(dynamic raw) {
    final value = (raw ?? '').toString().trim();
    if (value.isEmpty) return '';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final two = (int v) => v.toString().padLeft(2, '0');
    return '${two(parsed.hour)}:${two(parsed.minute)}';
  }
}

enum _QuoteState { pending, ready, approved, rejected }

class _QuoteLineItem {
  final String label;
  final String value;
  const _QuoteLineItem({required this.label, required this.value});
}

class _QuoteProforma {
  final _QuoteState state;
  final String bandText;
  final String inspectionFeeText;
  final List<_QuoteLineItem> lines;
  final String totalText;

  const _QuoteProforma({
    required this.state,
    required this.bandText,
    required this.inspectionFeeText,
    required this.lines,
    required this.totalText,
  });
}