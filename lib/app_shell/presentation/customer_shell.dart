import 'package:flutter/material.dart';
import 'package:seamlesscall/features/customer/presentation/customer_home_screen.dart';
import 'package:seamlesscall/features/customer/presentation/customer_jobs_screen.dart';
import 'package:seamlesscall/features/customer/presentation/customer_profile_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _controller;
  late Animation<double> _glow;

  final List<Widget> _pages = [
    const CustomerHomeScreen(),
    const CustomerJobsScreen(),
    const CustomerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _glow = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0B1120),
          body: _pages[_currentIndex],

          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F1526),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(_glow.value * 0.5),
                  blurRadius: 22,
                  spreadRadius: 2,
                ),
              ],
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),

                backgroundColor: const Color(0xFF0F1526),
                elevation: 0,
                selectedItemColor: Colors.blueAccent,
                unselectedItemColor: Colors.white70,
                type: BottomNavigationBarType.fixed,
                selectedFontSize: 12,
                unselectedFontSize: 12,

                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_rounded),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work_outline_rounded),
                    label: 'Jobs',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
