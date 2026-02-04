import 'package:flutter/material.dart';
import 'package:seamlesscall/features/customer/presentation/customer_home_screen.dart';
import 'package:seamlesscall/features/customer/presentation/customer_jobs_screen.dart';
import 'package:seamlesscall/features/customer/presentation/customer_profile_screen.dart';
import 'package:seamlesscall/features/customer/presentation/customer_services_list.dart';
import 'package:seamlesscall/features/customer/presentation/customer_payments_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  late final Animation<double> _glow = Tween<double>(
    begin: 0.12,
    end: 0.30,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  late final List<Widget> _pages = const [
    CustomerHomeScreen(),
    ServicesListScreen(),
    CustomerJobsScreen(), // we keep your implementation; label becomes Orders
    CustomerPaymentsScreen(),
    CustomerProfileScreen(),
  ];

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
      animation: _glow,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: cs.background,
          body: _pages[_currentIndex],

          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: cs.surface.withOpacity(0.96),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(_glow.value),
                    blurRadius: 22,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),

                  backgroundColor: cs.surface,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,

                  selectedItemColor: cs.primary,
                  unselectedItemColor: cs.onSurface.withOpacity(0.62),
                  selectedFontSize: 12,
                  unselectedFontSize: 12,

                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.grid_view_rounded),
                      label: 'Services',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_long_rounded),
                      label: 'Orders',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_balance_wallet_rounded),
                      label: 'Payments',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline_rounded),
                      label: 'Account',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
