import 'package:flutter/material.dart';
import 'job_tracking_screen.dart';

class CustomerJobsScreen extends StatefulWidget {
  const CustomerJobsScreen({super.key});

  @override
  State<CustomerJobsScreen> createState() => _CustomerJobsScreenState();
}

class _CustomerJobsScreenState extends State<CustomerJobsScreen> {
  // Replace with API later
  late List<_JobSummary> _jobs = _JobSummary.mockList();

  Future<void> _refresh() async {
    // TODO: call API later
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _jobs = _JobSummary.mockList(); // placeholder refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final ongoing = _jobs.where((j) => j.isOngoing).toList();
    final history = _jobs.where((j) => !j.isOngoing).toList();

    return Scaffold(
      backgroundColor: cs.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "My Jobs",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onBackground,
                          ),
                        ),
                      ),
                      _AnimatedIn(
                        delayMs: 80,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withOpacity(0.70),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            "${ongoing.length} ongoing",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: _AnimatedIn(
                    delayMs: 120,
                    child: _InfoBanner(
                      title: "Track your services like deliveries",
                      subtitle:
                          "Open a job to see progress, updates, and technician info.",
                    ),
                  ),
                ),
              ),

              if (ongoing.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: _AnimatedIn(
                      delayMs: 160,
                      child: Text(
                        "Ongoing",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onBackground,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  sliver: SliverList.separated(
                    itemCount: ongoing.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final job = ongoing[i];
                      return _AnimatedIn(
                        delayMs: 220 + (i * 70),
                        child: _Pressable(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  JobTrackingScreen(jobId: job.jobId),
                            ),
                          ),
                          child: _JobCard(job: job),
                        ),
                      );
                    },
                  ),
                ),
              ],

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                  child: _AnimatedIn(
                    delayMs: ongoing.isEmpty ? 160 : 360,
                    child: Text(
                      "History",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: cs.onBackground,
                      ),
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final job = history[i];
                    return _AnimatedIn(
                      delayMs: (ongoing.isEmpty ? 220 : 430) + (i * 60),
                      child: _Pressable(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobTrackingScreen(jobId: job.jobId),
                          ),
                        ),
                        child: _JobCard(job: job),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- Animation helpers ---------------- */

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
        scale: _down ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/* ---------------- UI components ---------------- */

class _InfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoBanner({required this.title, required this.subtitle});

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
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.70),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.local_shipping_rounded, color: cs.primary),
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
                    color: cs.onSurface.withOpacity(0.65),
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

class _JobCard extends StatelessWidget {
  final _JobSummary job;

  const _JobCard({required this.job});

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withOpacity(0.70),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(job.icon, color: cs.primary),
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
                        job.serviceName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    _StatusPill(status: job.statusLabel, tone: job.tone),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Job ${job.jobId} • ${job.location}",
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface.withOpacity(0.62),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        job.lastUpdate,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface.withOpacity(0.70),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: cs.onSurface.withOpacity(0.45),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final _Tone tone;

  const _StatusPill({required this.status, required this.tone});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    Color bg;
    Color fg;

    switch (tone) {
      case _Tone.info:
        bg = cs.primaryContainer.withOpacity(0.70);
        fg = cs.primary;
        break;
      case _Tone.success:
        bg = Colors.green.withOpacity(0.14);
        fg = Colors.green;
        break;
      case _Tone.warning:
        bg = Colors.orange.withOpacity(0.16);
        fg = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}

/* ---------------- Model (mock) ---------------- */

enum _Tone { info, success, warning }

class _JobSummary {
  final String jobId;
  final String serviceName;
  final String location;
  final String statusLabel;
  final String lastUpdate;
  final bool isOngoing;
  final IconData icon;
  final _Tone tone;

  const _JobSummary({
    required this.jobId,
    required this.serviceName,
    required this.location,
    required this.statusLabel,
    required this.lastUpdate,
    required this.isOngoing,
    required this.icon,
    required this.tone,
  });

  static List<_JobSummary> mockList() {
    return const [
      _JobSummary(
        jobId: "SC-1042",
        serviceName: "AC Repair",
        location: "Gwarinpa, Abuja",
        statusLabel: "En route",
        lastUpdate: "Technician is on the way • ETA 18 min",
        isOngoing: true,
        icon: Icons.ac_unit_rounded,
        tone: _Tone.info,
      ),
      _JobSummary(
        jobId: "SC-1033",
        serviceName: "Plumbing",
        location: "Wuse 2, Abuja",
        statusLabel: "In progress",
        lastUpdate: "Work started • Technician updating status",
        isOngoing: true,
        icon: Icons.plumbing_rounded,
        tone: _Tone.info,
      ),
      _JobSummary(
        jobId: "SC-1011",
        serviceName: "House Cleaning",
        location: "Jabi, Abuja",
        statusLabel: "Completed",
        lastUpdate: "Job completed • Awaiting rating",
        isOngoing: false,
        icon: Icons.cleaning_services_rounded,
        tone: _Tone.success,
      ),
      _JobSummary(
        jobId: "SC-1004",
        serviceName: "Electrical",
        location: "Maitama, Abuja",
        statusLabel: "Cancelled",
        lastUpdate: "Cancelled • Customer requested reschedule",
        isOngoing: false,
        icon: Icons.electrical_services_rounded,
        tone: _Tone.warning,
      ),
    ];
  }
}
