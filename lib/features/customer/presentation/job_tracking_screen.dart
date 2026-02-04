import 'package:flutter/material.dart';

class JobTrackingScreen extends StatefulWidget {
  final String jobId;

  const JobTrackingScreen({super.key, required this.jobId});

  @override
  State<JobTrackingScreen> createState() => _JobTrackingScreenState();
}

class _JobTrackingScreenState extends State<JobTrackingScreen> {
  // Replace with real API later.
  late final _TrackingModel model = _TrackingModel.mock(widget.jobId);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: CustomScrollView(
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
                  quote: model.quote, // add this field to model (below)
                  onApproveAndPay: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Approve & Pay: hook to gateway later"),
                      ),
                    );
                  },
                  onRequestChange: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Request change: hook to chat/support later",
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
                    // TODO: open live map / google maps later
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Map: hook to live map later"),
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
                    // TODO: route to technician chat
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Chat: hook to chat screen"),
                      ),
                    );
                  },
                  onCall: () {
                    // TODO: implement call intent
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Call: hook to call intent"),
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
                    // TODO: route based on status (e.g. reschedule, confirm arrival, rate job)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Primary: ${model.primaryActionText}"),
                      ),
                    );
                  },
                  onSecondary: () {
                    // TODO: dispute / support
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Report: hook to support/dispute"),
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
          // Header row
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

          // Lines
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

          // Rules note (Nigeria trust)
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

          // Actions
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
          // "Map" area (placeholder)
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
                  // Decorative "roads"
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.25,
                      child: CustomPaint(
                        painter: _RoadPainter(color: cs.primary),
                      ),
                    ),
                  ),

                  // Pins + path hint
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

          // Labels
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

    // Dashed center line (simple manual dashes)
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
          // Timeline column
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

          // Text
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

// ✅ You referenced this above, so it must exist.
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

  // 🔴 NEW (money + routing context)
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

    // 🔴 ADD THESE
    required this.quote,
    required this.pickupLabel,
    required this.destinationLabel,
    required this.distanceText,
    required this.updates,

    required this.primaryActionText,
    required this.steps,
  });

  static _TrackingModel mock(String jobId) {
    final _QuoteProforma quote;
    final String pickupLabel;
    final String destinationLabel;
    final String distanceText;
    final List<_TrackingUpdate> updates;

    return _TrackingModel(
      jobId: jobId,
      serviceName: "AC Repair",

      statusTitle: "Technician en route",
      statusHint: "Your technician is on the way. Keep your phone available.",
      etaText: "ETA 18 min",

      techName: "Khadijah Ismail",
      techRating: 4.8,
      techJobs: 127,

      // 🔴 QUOTE / PROFORMA
      quote: const _QuoteProforma(
        state: _QuoteState.ready,
        bandText: "₦8,000 – ₦12,000",
        inspectionFeeText: "₦2,000",
        lines: [
          _QuoteLineItem(label: "Base service", value: "₦8,000"),
          _QuoteLineItem(label: "Extra unit (1)", value: "₦2,000"),
          _QuoteLineItem(label: "Emergency surcharge", value: "₦1,000"),
          _QuoteLineItem(label: "Materials", value: "Excluded"),
        ],
        totalText: "₦11,000",
      ),

      // 🔴 MAP CONTEXT
      pickupLabel: "Your address (Customer location)",
      destinationLabel: "Technician route to you",
      distanceText: "6.2 km",

      // 🔴 UPDATE LOG
      updates: const [
        _TrackingUpdate(
          timeText: "09:10",
          title: "Request received",
          detail: "We received your request and started matching.",
          type: _UpdateType.info,
        ),
        _TrackingUpdate(
          timeText: "09:13",
          title: "Technician assigned",
          detail: "Khadijah accepted the job and is preparing to move.",
          type: _UpdateType.success,
        ),
        _TrackingUpdate(
          timeText: "09:20",
          title: "En route",
          detail: "Technician is currently on the way to your location.",
          type: _UpdateType.info,
        ),
      ],

      primaryActionText: "Share Location",

      steps: const [
        _TrackingStep(
          title: "Request sent",
          subtitle: "We received your request.",
          timeText: "09:10",
          state: _StepState.done,
        ),
        _TrackingStep(
          title: "Technician matched",
          subtitle: "A verified technician accepted your job.",
          timeText: "09:13",
          state: _StepState.done,
        ),
        _TrackingStep(
          title: "Technician en route",
          subtitle: "Technician is coming to your location.",
          timeText: "09:20",
          state: _StepState.active,
        ),
        _TrackingStep(
          title: "Arrived",
          subtitle: "Confirm arrival when the technician gets to you.",
          state: _StepState.upcoming,
        ),
        _TrackingStep(
          title: "Work in progress",
          subtitle: "Technician starts the job and updates status.",
          state: _StepState.upcoming,
        ),
        _TrackingStep(
          title: "Completed",
          subtitle: "Job completed. Payment and receipt available.",
          state: _StepState.upcoming,
        ),
      ],
    );
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
  final String bandText; // e.g. ₦8,000–₦12,000
  final String inspectionFeeText; // e.g. ₦2,000
  final List<_QuoteLineItem> lines;
  final String totalText; // e.g. ₦11,000

  const _QuoteProforma({
    required this.state,
    required this.bandText,
    required this.inspectionFeeText,
    required this.lines,
    required this.totalText,
  });
}
