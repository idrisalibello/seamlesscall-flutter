import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seamlesscall/core/theme/theme_providers.dart';
import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
import 'package:seamlesscall/features/config/categories_screen.dart';
import 'package:seamlesscall/features/dashboard/dashboard_screen.dart';
import 'package:seamlesscall/features/operations/active_jobs_screen.dart';
import 'package:seamlesscall/features/operations/pending_jobs_screen.dart';
import 'package:seamlesscall/features/operations/scheduled_jobs_screen.dart';
import 'package:seamlesscall/features/operations/cancelled_jobs_screen.dart';
import 'package:seamlesscall/features/operations/dispatch_center_screen.dart';
import 'package:seamlesscall/features/operations/escalations_screen.dart';
import 'package:seamlesscall/features/people/customers_screen.dart';
import 'package:seamlesscall/features/people/providers_screen.dart';
import 'package:seamlesscall/features/people/verification_queue_screen.dart';
import 'package:seamlesscall/features/people/provider_performance_screen.dart';
import 'package:seamlesscall/features/finance/earnings_overview_screen.dart';
import 'package:seamlesscall/features/finance/provider_payouts_screen.dart';
import 'package:seamlesscall/features/finance/platform_commissions_screen.dart';
import 'package:seamlesscall/features/finance/refunds_disputes_screen.dart';
import 'package:seamlesscall/features/finance/ledger_screen.dart';
import 'package:seamlesscall/features/config/pricing_screen.dart';
import 'package:seamlesscall/features/config/coverage_screen.dart';
import 'package:seamlesscall/features/config/availability_screen.dart';
import 'package:seamlesscall/features/config/promotions_screen.dart';
import 'package:seamlesscall/features/config/appearance_screen.dart';
import 'package:seamlesscall/features/reports/reports_dashboard_screen.dart';
import 'package:seamlesscall/features/system/roles_permissions_screen.dart';
import 'package:seamlesscall/features/system/integrations_screen.dart';
import 'package:seamlesscall/features/system/feature_toggles_screen.dart';
import 'package:seamlesscall/features/system/maintenance_mode_screen.dart';
import 'package:seamlesscall/features/admin/presentation/admin_provider_applications.dart';
import 'package:seamlesscall/features/admin/presentation/create_admin_user_screen.dart';
import 'package:seamlesscall/features/system/presentation/users_list_screen.dart';

class _AdminMenuItem {
  final String label;
  final String route;
  final String? permission;

  const _AdminMenuItem({
    required this.label,
    required this.route,
    this.permission,
  });
}

class _AdminMenuSection {
  final String title;
  final List<_AdminMenuItem> items;

  const _AdminMenuSection({
    required this.title,
    required this.items,
  });
}

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  String _activeRoute = '/admin/dashboard';

  static const List<_AdminMenuSection> _sections = [
    _AdminMenuSection(
      title: 'Dashboard',
      items: [
        _AdminMenuItem(
          label: 'Dashboard',
          route: '/admin/dashboard',
          permission: 'view-dashboard',
        ),
      ],
    ),
    _AdminMenuSection(
      title: 'Operations',
      items: [
        _AdminMenuItem(
          label: 'Active Jobs',
          route: '/admin/jobs/active',
          permission: 'view-active-jobs',
        ),
        _AdminMenuItem(
          label: 'Pending Jobs',
          route: '/admin/jobs/pending',
          permission: 'view-pending-jobs',
        ),
        _AdminMenuItem(
          label: 'Scheduled Jobs',
          route: '/admin/jobs/scheduled',
          permission: 'view-scheduled-jobs',
        ),
        _AdminMenuItem(
          label: 'Cancelled Jobs',
          route: '/admin/jobs/cancelled',
          permission: 'view-cancelled-jobs',
        ),
        _AdminMenuItem(
          label: 'Dispatch Center',
          route: '/admin/dispatch',
          permission: 'use-dispatch-center',
        ),
        _AdminMenuItem(
          label: 'Escalations',
          route: '/admin/escalations',
          permission: 'manage-escalations',
        ),
      ],
    ),
    _AdminMenuSection(
      title: 'People',
      items: [
        _AdminMenuItem(
          label: 'Customers',
          route: '/admin/customers',
          permission: 'view-customers',
        ),
        _AdminMenuItem(
          label: 'Providers',
          route: '/admin/providers',
          permission: 'view-providers',
        ),
        _AdminMenuItem(
          label: 'Provider Applications',
          route: '/admin/providers/applications',
          permission: 'manage-provider-applications',
        ),
        _AdminMenuItem(
          label: 'Verification Queue',
          route: '/admin/providers/verification',
          permission: 'view-verification-queue',
        ),
        _AdminMenuItem(
          label: 'Provider Performance',
          route: '/admin/providers/performance',
          permission: 'view-provider-performance',
        ),
      ],
    ),
    _AdminMenuSection(
      title: 'Finance',
      items: [
        _AdminMenuItem(
          label: 'Earnings Overview',
          route: '/admin/finance/earnings',
          permission: 'view-earnings-overview',
        ),
        _AdminMenuItem(
          label: 'Provider Payouts',
          route: '/admin/finance/payouts',
          permission: 'view-payouts',
        ),
        _AdminMenuItem(
          label: 'Platform Commissions',
          route: '/admin/finance/commissions',
          permission: 'view-platform-commissions',
        ),
        _AdminMenuItem(
          label: 'Refunds & Disputes',
          route: '/admin/finance/disputes',
          permission: 'view-refunds-disputes',
        ),
        _AdminMenuItem(
          label: 'Ledger',
          route: '/admin/finance/ledger',
          permission: 'view-ledger',
        ),
      ],
    ),
    _AdminMenuSection(
      title: 'Configuration',
      items: [
        _AdminMenuItem(
          label: 'Categories',
          route: '/admin/config/categories',
          permission: 'manage-categories',
        ),
        _AdminMenuItem(
          label: 'Pricing',
          route: '/admin/config/pricing',
          permission: 'manage-pricing',
        ),
        _AdminMenuItem(
          label: 'Coverage',
          route: '/admin/config/coverage',
          permission: 'manage-coverage',
        ),
        _AdminMenuItem(
          label: 'Availability',
          route: '/admin/config/availability',
          permission: 'manage-availability',
        ),
        _AdminMenuItem(
          label: 'Promotions',
          route: '/admin/config/promotions',
          permission: 'manage-promotions',
        ),
        _AdminMenuItem(
          label: 'Appearance',
          route: '/admin/config/appearance',
          permission: 'manage-appearance',
        ),
      ],
    ),
    _AdminMenuSection(
      title: 'Reports',
      items: [
        _AdminMenuItem(
          label: 'Overview',
          route: '/admin/reports/overview',
          permission: 'view-reports-dashboard',
        ),
        _AdminMenuItem(
          label: 'Operations Reports',
          route: '/admin/reports/operations',
          permission: 'view-operations-reports',
        ),
        _AdminMenuItem(
          label: 'Provider Reports',
          route: '/admin/reports/providers',
          permission: 'view-provider-reports',
        ),
        _AdminMenuItem(
          label: 'Customer Reports',
          route: '/admin/reports/customers',
          permission: 'view-customer-reports',
        ),
        _AdminMenuItem(
          label: 'Finance Reports',
          route: '/admin/reports/finance',
          permission: 'view-finance-reports',
        ),
        _AdminMenuItem(
          label: 'Promotion Reports',
          route: '/admin/reports/promotions',
          permission: 'view-promotion-reports',
        ),
      ],
    ),
    _AdminMenuSection(
      title: 'System',
      items: [
        _AdminMenuItem(
          label: 'Manage Users',
          route: '/admin/system/users',
          permission: 'view-users',
        ),
        _AdminMenuItem(
          label: 'Create Admin User',
          route: '/admin/system/create-admin',
          permission: 'create-admin-users',
        ),
        _AdminMenuItem(
          label: 'Roles & Permissions',
          route: '/admin/system/roles',
          permission: 'manage-roles',
        ),
        _AdminMenuItem(
          label: 'Integrations',
          route: '/admin/system/integrations',
          permission: 'manage-integrations',
        ),
        _AdminMenuItem(
          label: 'Feature Toggles',
          route: '/admin/system/features',
          permission: 'manage-feature-toggles',
        ),
        _AdminMenuItem(
          label: 'Maintenance Mode',
          route: '/admin/system/maintenance',
          permission: 'manage-maintenance-mode',
        ),
      ],
    ),
  ];

  void _navigate(String route) {
    setState(() => _activeRoute = route);
  }

  bool _hasAccess(Set<String> permissions, String? permission) {
    if (permission == null) return true;
    return permissions.contains(permission);
  }

  Widget _reportScreen(String initialSection, Set<String> permissions) {
    return ReportsDashboardScreen(
      initialSection: initialSection,
      permissions: permissions,
    );
  }

  Widget _screenForRoute(String route, Set<String> permissions) {
    switch (route) {
      case '/admin/dashboard':
        return const DashboardScreen();
      case '/admin/jobs/active':
        return const ActiveJobsScreen();
      case '/admin/jobs/pending':
        return const PendingJobsScreen();
      case '/admin/jobs/scheduled':
        return const ScheduledJobsScreen();
      case '/admin/jobs/cancelled':
        return const CancelledJobsScreen();
      case '/admin/dispatch':
        return const DispatchCenterScreen();
      case '/admin/escalations':
        return const EscalationsScreen();
      case '/admin/customers':
        return const CustomersScreen();
      case '/admin/providers':
        return const ProvidersScreen();
      case '/admin/providers/applications':
        return const AdminProviderApplicationsScreen();
      case '/admin/providers/verification':
        return const VerificationQueueScreen();
      case '/admin/providers/performance':
        return const ProviderPerformanceScreen();
      case '/admin/finance/earnings':
        return const EarningsOverviewScreen();
      case '/admin/finance/payouts':
        return const ProviderPayoutsScreen();
      case '/admin/finance/commissions':
        return const PlatformCommissionsScreen();
      case '/admin/finance/disputes':
        return const RefundsDisputesScreen();
      case '/admin/finance/ledger':
        return const LedgerScreen();
      case '/admin/config/categories':
        return const CategoriesScreen();
      case '/admin/config/pricing':
        return const PricingScreen();
      case '/admin/config/coverage':
        return const CoverageScreen();
      case '/admin/config/availability':
        return const AvailabilityScreen();
      case '/admin/config/promotions':
        return const PromotionsScreen();
      case '/admin/config/appearance':
        return const AppearanceScreen();
      case '/admin/reports/overview':
        return _reportScreen('overview', permissions);
      case '/admin/reports/operations':
        return _reportScreen('operations', permissions);
      case '/admin/reports/providers':
        return _reportScreen('providers', permissions);
      case '/admin/reports/customers':
        return _reportScreen('customers', permissions);
      case '/admin/reports/finance':
        return _reportScreen('finance', permissions);
      case '/admin/reports/promotions':
        return _reportScreen('promotions', permissions);
      case '/admin/system/create-admin':
        return const CreateAdminUserScreen();
      case '/admin/system/users':
        return const UsersListScreen();
      case '/admin/system/roles':
        return const RolesPermissionsScreen();
      case '/admin/system/integrations':
        return const IntegrationsScreen();
      case '/admin/system/features':
        return const FeatureTogglesScreen();
      case '/admin/system/maintenance':
        return const MaintenanceModeScreen();
      default:
        return Center(child: Text('Screen not found for $route'));
    }
  }

  List<_AdminMenuSection> _allowedSections(Set<String> permissions) {
    final sections = <_AdminMenuSection>[];
    for (final section in _sections) {
      final allowedItems = section.items
          .where((item) => _hasAccess(permissions, item.permission))
          .toList();
      if (allowedItems.isNotEmpty) {
        sections.add(_AdminMenuSection(title: section.title, items: allowedItems));
      }
    }
    return sections;
  }

  List<PopupMenuEntry<String>> _mobileMenuItems(List<_AdminMenuSection> sections) {
    PopupMenuItem<String> item(String label, String route) =>
        PopupMenuItem(value: route, child: Text(label));

    PopupMenuDivider divider() => const PopupMenuDivider();

    PopupMenuItem<String> header(String label) => PopupMenuItem(
          enabled: false,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        );

    final entries = <PopupMenuEntry<String>>[];
    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      if (i > 0) {
        entries.add(divider());
      }
      entries.add(header(section.title));
      for (final menuItem in section.items) {
        entries.add(item(menuItem.label, menuItem.route));
      }
    }
    return entries;
  }

  Widget _emptyAccessView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No admin modules are available for this account.\nAssign at least one permission to the user’s role.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final permissions = user?.permissions.toSet() ?? <String>{};

    final sections = _allowedSections(permissions);
    final allAllowedRoutes = sections
        .expand((section) => section.items)
        .map((e) => e.route)
        .toList();

    if (allAllowedRoutes.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: _emptyAccessView(),
      );
    }

    final effectiveRoute = allAllowedRoutes.contains(_activeRoute)
        ? _activeRoute
        : allAllowedRoutes.first;

    final isMobile = MediaQuery.of(context).size.width < 700;
    final theme = Theme.of(context);
    final preset = ref.watch(themeSettingsProvider).preset;
    final accent = preset.accentGradient.colors.first;
    final sidebarBg = theme.brightness == Brightness.dark
        ? preset.backgroundGradient.colors.first.withOpacity(0.92)
        : theme.colorScheme.surface;
    final selectedBg = accent.withOpacity(
      theme.brightness == Brightness.dark ? 0.20 : 0.12,
    );

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Admin'),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: _navigate,
                  itemBuilder: (_) => _mobileMenuItems(sections),
                ),
              ],
            )
          : null,
      body: isMobile
          ? _screenForRoute(effectiveRoute, permissions)
          : Row(
              children: [
                Container(
                  width: 280,
                  color: sidebarBg,
                  child: ListView(
                    children: _mobileMenuItems(sections).map((entry) {
                      if (entry is PopupMenuDivider) {
                        return Divider(height: 1, color: theme.dividerColor);
                      }
                      if (entry is PopupMenuItem<String>) {
                        if (!entry.enabled) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: DefaultTextStyle(
                              style: theme.textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              child: entry.child!,
                            ),
                          );
                        }

                        final selected = effectiveRoute == entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: selected ? selectedBg : Colors.transparent,
                            selected: selected,
                            selectedColor: accent,
                            iconColor: selected ? accent : theme.iconTheme.color,
                            textColor: selected ? accent : theme.textTheme.bodyMedium?.color,
                            title: entry.child,
                            onTap: () => _navigate(entry.value!),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                ),
                VerticalDivider(width: 1, color: theme.dividerColor),
                Expanded(child: _screenForRoute(effectiveRoute, permissions)),
              ],
            ),
    );
  }
}
