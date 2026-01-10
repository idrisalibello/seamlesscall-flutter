import 'package:flutter/material.dart';

class CustomerJobsScreen extends StatefulWidget {
  const CustomerJobsScreen({super.key});

  @override
  State<CustomerJobsScreen> createState() => _CustomerJobsScreenState();
}

class _CustomerJobsScreenState extends State<CustomerJobsScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<Map<String, String>> _jobs = const [
    {"status": "In Progress", "title": "AC Repair", "date": "Dec 2, 2025"},
    {"status": "Completed", "title": "Plumbing Fix", "date": "Nov 26, 2025"},
    {"status": "Pending", "title": "House Cleaning", "date": "Upcoming"},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeIn,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Your Jobs",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Track your job progress and history",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: _jobs.length,
                  itemBuilder: (context, index) {
                    final job = _jobs[index];
                    return _AnimatedJobCard(
                      status: job["status"]!,
                      title: job["title"]!,
                      date: job["date"]!,
                      delay: 100 * index,
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

class _AnimatedJobCard extends StatefulWidget {
  final String status;
  final String title;
  final String date;
  final int delay;

  const _AnimatedJobCard({
    required this.status,
    required this.title,
    required this.date,
    required this.delay,
  });

  @override
  State<_AnimatedJobCard> createState() => _AnimatedJobCardState();
}

class _AnimatedJobCardState extends State<_AnimatedJobCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case "In Progress":
        return Colors.orangeAccent;
      case "Completed":
        return Colors.greenAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Card(
          color: const Color(0xFF151F2E),
          elevation: 6,
          shadowColor: Colors.black38,
          margin: const EdgeInsets.only(bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.work, size: 36, color: _statusColor(widget.status)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.date,
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.status,
                  style: TextStyle(
                    color: _statusColor(widget.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
