import 'package:flutter/material.dart';

// dashboard
import 'package:seamlesscall/features/dashboard/dashboard_screen.dart';

// operations
import 'package:seamlesscall/features/operations/active_jobs_screen.dart';
import 'package:seamlesscall/features/operations/scheduled_jobs_screen.dart';
import 'package:seamlesscall/features/operations/cancelled_jobs_screen.dart';
import 'package:seamlesscall/features/operations/dispatch_center_screen.dart';
import 'package:seamlesscall/features/operations/escalations_screen.dart';

// people
import 'package:seamlesscall/features/people/customers_screen.dart';
import 'package:seamlesscall/features/people/providers_screen.dart';
import 'package:seamlesscall/features/people/verification_queue_screen.dart';
import 'package:seamlesscall/features/people/provider_performance_screen.dart';

// finance
import 'package:seamlesscall/features/finance/earnings_overview_screen.dart';
import 'package:seamlesscall/features/finance/provider_payouts_screen.dart';
import 'package:seamlesscall/features/finance/platform_commissions_screen.dart';
import 'package:seamlesscall/features/finance/refunds_disputes_screen.dart';
import 'package:seamlesscall/features/finance/ledger_screen.dart';

// config
import 'package:seamlesscall/features/config/services_screen.dart';
import 'package:seamlesscall/features/config/pricing_screen.dart';
import 'package:seamlesscall/features/config/coverage_screen.dart';
import 'package:seamlesscall/features/config/availability_screen.dart';
import 'package:seamlesscall/features/config/promotions_screen.dart';

//reports
import 'package:seamlesscall/features/reports/roles_permissions_report_screen.dart';
import 'package:seamlesscall/features/reports/integrations_report_screen.dart';
import 'package:seamlesscall/features/reports/feature_toggles_report_screen.dart';
import 'package:seamlesscall/features/reports/maintenance_mode_report_screen.dart';
import 'package:seamlesscall/features/reports/audit_trail_report_screen.dart';
import 'package:seamlesscall/features/reports/system_health_report_screen.dart';

// system
import 'package:seamlesscall/features/system/roles_permissions_screen.dart';
import 'package:seamlesscall/features/system/integrations_screen.dart';
import 'package:seamlesscall/features/system/feature_toggles_screen.dart';
import 'package:seamlesscall/features/system/maintenance_mode_screen.dart';
import 'package:seamlesscall/features/admin/presentation/admin_provider_applications.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  String _activeRoute = '/admin/dashboard';

  void _navigate(String route) {
    setState(() => _activeRoute = route);
  }

  Widget _resolveScreen() {
    switch (_activeRoute) {
      case '/admin/dashboard':
        return const DashboardScreen();

      // operations
      case '/admin/jobs/active':
        return const ActiveJobsScreen();
      case '/admin/jobs/scheduled':
        return const ScheduledJobsScreen();
      case '/admin/jobs/cancelled':
        return const CancelledJobsScreen();
      case '/admin/dispatch':
        return const DispatchCenterScreen();
      case '/admin/escalations':
        return const EscalationsScreen();

      // people
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

      // finance
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

      // config
      case '/admin/config/services':
        return const ServicesScreen();
      case '/admin/config/pricing':
        return const PricingScreen();
      case '/admin/config/coverage':
        return const CoverageScreen();
      case '/admin/config/availability':
        return const AvailabilityScreen();
      case '/admin/config/promotions':
        return const PromotionsScreen();

      // REPORTS
      case '/admin/reports/roles':
        return const RolesPermissionsReportScreen();

      case '/admin/reports/integrations':
        return const IntegrationsReportScreen();

      case '/admin/reports/features':
        return const FeatureTogglesReportScreen();

      case '/admin/reports/maintenance':
        return const MaintenanceModeReportScreen();

      case '/admin/reports/audit-trail':
        return const AuditTrailReportScreen();

      case '/admin/reports/system-health':
        return const SystemHealthReportScreen();

      // system
      case '/admin/system/roles':
        return const RolesPermissionsScreen();

      case '/admin/system/integrations':
        return const IntegrationsScreen();

      case '/admin/system/features':
        return const FeatureTogglesScreen();

      case '/admin/system/maintenance':
        return const MaintenanceModeScreen();

      default:
        return Center(child: Text('Screen not found for $_activeRoute'));
    }
  }

  List<PopupMenuEntry<String>> _mobileMenuItems() {
    PopupMenuItem<String> item(String label, String route) =>
        PopupMenuItem(value: route, child: Text(label));

    PopupMenuDivider divider() => const PopupMenuDivider();

    PopupMenuItem<String> header(String label) => PopupMenuItem(
      enabled: false,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );

    return [
      header('Dashboard'),
      item('Dashboard', '/admin/dashboard'),

      divider(),
      header('Operations'),
      item('Active Jobs', '/admin/jobs/active'),
      item('Scheduled Jobs', '/admin/jobs/scheduled'),
      item('Cancelled Jobs', '/admin/jobs/cancelled'),
      item('Dispatch Center', '/admin/dispatch'),
      item('Escalations', '/admin/escalations'),

      divider(),
      header('People'),
      item('Customers', '/admin/customers'),
      item('Providers', '/admin/providers'),
      item('Provider Applications', '/admin/providers/applications'),
      item('Verification Queue', '/admin/providers/verification'),
      item('Provider Performance', '/admin/providers/performance'),

      divider(),
      header('Finance'),
      item('Earnings Overview', '/admin/finance/earnings'),
      item('Provider Payouts', '/admin/finance/payouts'),
      item('Platform Commissions', '/admin/finance/commissions'),
      item('Refunds & Disputes', '/admin/finance/disputes'),
      item('Ledger', '/admin/finance/ledger'),

      divider(),
      header('Configuration'),
      item('Services', '/admin/config/services'),
      item('Pricing', '/admin/config/pricing'),
      item('Coverage', '/admin/config/coverage'),
      item('Availability', '/admin/config/availability'),
      item('Promotions', '/admin/config/promotions'),

      divider(),
      header('Reports'),
      item('Roles & Permissions', '/admin/reports/roles'),
      item('Integrations', '/admin/reports/integrations'),
      item('Feature Toggles', '/admin/reports/features'),
      item('Maintenance Mode', '/admin/reports/maintenance'),
      item('Audit Trail', '/admin/reports/audit-trail'),
      item('System Health', '/admin/reports/system-health'),

      //
      divider(),
      header('System'),
      item('Roles & Permissions', '/admin/system/roles'),
      item('Integrations', '/admin/system/integrations'),
      item('Feature Toggles', '/admin/system/features'),
      item('Maintenance Mode', '/admin/system/maintenance'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Admin'),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.menu),
                  onSelected: _navigate,
                  itemBuilder: (_) => _mobileMenuItems(),
                ),
              ],
            )
          : null,
      body: isMobile
          ? _resolveScreen()
          : Row(
              children: [
                SizedBox(
                  width: 280,
                  child: ListView(
                    children: _mobileMenuItems().map((entry) {
                      if (entry is PopupMenuDivider) {
                        return const Divider(height: 1);
                      }

                      if (entry is PopupMenuItem<String>) {
                        if (!entry.enabled) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              child: entry.child!,
                            ),
                          );
                        }

                        return ListTile(
                          title: entry.child,
                          selected: _activeRoute == entry.value,
                          onTap: () => _navigate(entry.value!),
                        );
                      }

                      return const SizedBox.shrink();
                    }).toList(),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _resolveScreen()),
              ],
            ),
    );
  }
}
