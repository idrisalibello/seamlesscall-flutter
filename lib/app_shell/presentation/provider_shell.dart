import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/core/theme/theme_providers.dart';
import '../../features/providers/presentation/provider_home_screen.dart';
import '../../features/providers/presentation/provider_earnings_history_screen.dart';
import '../../features/providers/presentation/provider_availability_screen.dart';
import '../../features/providers/presentation/provider_document_upload_screen.dart';
import '../../features/providers/presentation/provider_profile_screen.dart';

class ProviderShell extends ConsumerStatefulWidget {
  const ProviderShell({super.key});

  @override
  ConsumerState<ProviderShell> createState() => _ProviderShellState();
}

class _ProviderShellState extends ConsumerState<ProviderShell>
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
      begin: 0.18,
      end: 0.42,
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
    final preset = ref.watch(themeSettingsProvider).preset;
    final backgroundColors = preset.backgroundGradient.colors;
    final accentColors = preset.accentGradient.colors;

    final shellBg = backgroundColors.first;
    final navBg = theme.brightness == Brightness.dark
        ? const Color(0xFF0F1526)
        : theme.colorScheme.surface;

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: shellBg,
          body: _pages[_currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: navBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: accentColors.first.withOpacity(_glow.value),
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
                backgroundColor: navBg,
                elevation: 0,
                selectedItemColor: accentColors.first,
                unselectedItemColor: theme.brightness == Brightness.dark
                    ? Colors.white70
                    : theme.colorScheme.onSurface.withOpacity(0.7),
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