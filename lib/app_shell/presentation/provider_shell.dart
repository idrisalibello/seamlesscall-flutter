import 'package:flutter/material.dart';
import '../../features/providers/presentation/provider_home_screen.dart';
import '../../features/providers/presentation/provider_earnings_history_screen.dart';
import '../../features/providers/presentation/provider_availability_screen.dart';
import '../../features/providers/presentation/provider_document_upload_screen.dart';
import '../../features/providers/presentation/provider_profile_screen.dart';

class ProviderShell extends StatefulWidget {
  const ProviderShell({super.key});

  @override
  State<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends State<ProviderShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _controller;
  late Animation<double> _glow;

  final List<Widget> _pages = [
    const ProviderHomeScreen(),
    const ProviderEarningsHistoryScreen(),
    const ProviderAvailabilityScreen(),
    const ProviderDocumentUploadScreen(),
    const ProviderProfileScreen(),
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
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money_outlined),
                    label: 'Earnings',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.schedule_outlined),
                    label: 'Availability',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.upload_file_outlined),
                    label: 'Documents',
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
