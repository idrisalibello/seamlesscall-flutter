import 'dart:ui';
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

  late final AnimationController _controller;
  late final Animation<double> _lift;

  final List<Widget> _pages = const [
    CustomerHomeScreen(),
    CustomerJobsScreen(),
    CustomerProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _lift = Tween<double>(
      begin: 0.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AnimatedBuilder(
      animation: _lift,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: cs.background,
          body: _pages[_currentIndex],

          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: cs.surface.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: cs.outlineVariant.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 18,
                        offset: Offset(0, 10 - _lift.value),
                      ),
                    ],
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: cs.primary,
                    unselectedItemColor: cs.onSurface.withOpacity(0.55),
                    selectedFontSize: 12,
                    unselectedFontSize: 12,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_rounded),
                        label: 'Home',
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
            ),
          ),
        );
      },
    );
  }
}
