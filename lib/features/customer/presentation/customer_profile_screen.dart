import 'package:flutter/material.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  final List<Map<String, dynamic>> _items = const [
    {"icon": Icons.settings, "label": "Account Settings", "isDanger": false},
    {
      "icon": Icons.receipt_long,
      "label": "Billing & Payments",
      "isDanger": false,
    },
    {"icon": Icons.help_outline, "label": "Help & Support", "isDanger": false},
    {"icon": Icons.logout, "label": "Logout", "isDanger": true},
  ];

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
                "Profile",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: const [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Idris Ali Bello",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "[idrisalibello@gmail.com](mailto:idrisalibello@gmail.com)",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return _AnimatedProfileItem(
                      icon: item["icon"],
                      label: item["label"],
                      isDanger: item["isDanger"],
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

class _AnimatedProfileItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDanger;
  final int delay;

  const _AnimatedProfileItem({
    required this.icon,
    required this.label,
    required this.isDanger,
    required this.delay,
  });

  @override
  State<_AnimatedProfileItem> createState() => _AnimatedProfileItemState();
}

class _AnimatedProfileItemState extends State<_AnimatedProfileItem>
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeIn,
      child: SlideTransition(
        position: _slideUp,
        child: Card(
          color: const Color(0xFF151F2E),
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            leading: Icon(
              widget.icon,
              color: widget.isDanger
                  ? Colors.redAccent
                  : Colors.lightBlueAccent,
            ),
            title: Text(
              widget.label,
              style: TextStyle(
                color: widget.isDanger ? Colors.redAccent : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
