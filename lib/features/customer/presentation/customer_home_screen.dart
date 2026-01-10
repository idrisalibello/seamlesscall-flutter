import 'package:flutter/material.dart';
import 'package:seamlesscall/features/customer/presentation/apply_as_provider_screen.dart';
import '../../../common/widgets/main_layout.dart';
import 'customer_services_list.dart';
import 'customer_chat_screen.dart';
import 'customer_booking_request.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TEMP: replace with real user/provider state from backend
    final bool hasProviderProfile = false;
    final String providerStatus = 'none';
    // values: 'none' | 'pending' | 'approved'

    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 1200
        ? 4
        : width > 850
        ? 3
        : 2;
    final theme = Theme.of(context);

    return MainLayout(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          children: [
            _actionCard(
              icon: Icons.home_repair_service,
              title: "View Services",
              theme: theme,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ServicesListScreen()),
              ),
            ),
            _actionCard(
              icon: Icons.schedule,
              title: "Make a Booking",
              theme: theme,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingRequestScreen()),
              ),
            ),
            _actionCard(
              icon: Icons.chat,
              title: "Chat with Providers",
              theme: theme,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatShell()),
              ),
            ),
            if (!hasProviderProfile || providerStatus != 'approved')
              _actionCard(
                icon: providerStatus == 'pending'
                    ? Icons.hourglass_top_rounded
                    : Icons.upgrade_rounded,
                title: providerStatus == 'pending'
                    ? "Provider Application Pending"
                    : "Become a Provider",
                theme: theme,
                onTap: providerStatus == 'pending'
                    ? () {}
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ApplyAsProviderScreen(),
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required ThemeData theme,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF101822), const Color(0xFF0B1118)]
                : [const Color(0xFFFDFDFE), const Color(0xFFF5F6F9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.45)
                  : Colors.grey.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(-3, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 42,
                color: isDark
                    ? Colors.white.withOpacity(0.88)
                    : Colors.black87.withOpacity(0.75),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withOpacity(0.92)
                      : Colors.black.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
