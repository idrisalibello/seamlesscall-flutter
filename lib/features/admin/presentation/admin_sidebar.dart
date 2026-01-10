import 'package:flutter/material.dart';
import 'package:seamlesscall/features/dashboard/dashboard_screen.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  String _activeRoute = '/admin/dashboard';

  void _navigate(String route) {
    setState(() {
      _activeRoute = route;
    });
  }

  Widget _resolveScreen() {
    switch (_activeRoute) {
      case '/admin/dashboard':
        return const DashboardScreen();
      default:
        return Center(child: Text('Screen for $_activeRoute'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(activeRoute: _activeRoute, onNavigate: _navigate),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _resolveScreen()),
        ],
      ),
    );
  }
}

class AdminSidebar extends StatefulWidget {
  final String activeRoute;
  final Function(String route) onNavigate;

  const AdminSidebar({
    super.key,
    required this.activeRoute,
    required this.onNavigate,
  });

  @override
  State<AdminSidebar> createState() => _AdminSidebarState();
}

class _AdminSidebarState extends State<AdminSidebar> {
  bool _isCollapsed = false;

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      width: _isCollapsed ? 80 : 280,
      duration: const Duration(milliseconds: 200),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header + collapse toggle
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: _isCollapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                if (!_isCollapsed)
                  Text(
                    'Admin Panel',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _isCollapsed
                        ? Icons.arrow_forward_ios
                        : Icons.arrow_back_ios,
                  ),
                  onPressed: _toggleCollapse,
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          // Menu sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: _buildSections(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSections() {
    return [
      _section(
        title: 'Dashboard',
        icon: Icons.dashboard_outlined,
        items: [_item('Overview', '/admin/dashboard')],
      ),
      _section(
        title: 'Operations',
        icon: Icons.work_outline,
        items: [
          _item('Active Jobs', '/admin/jobs/active'),
          _item('Scheduled Jobs', '/admin/jobs/scheduled'),
          _item('Cancelled / Failed', '/admin/jobs/cancelled'),
          _item('Dispatch Center', '/admin/dispatch'),
          _item('Escalations', '/admin/escalations'),
        ],
      ),
      _section(
        title: 'People',
        icon: Icons.people_outline,
        items: [
          _item('Customers', '/admin/customers'),
          _item('Providers', '/admin/providers'),
          _item('Verification Queue', '/admin/providers/verification'),
          _item('Provider Performance', '/admin/providers/performance'),
        ],
      ),
      _section(
        title: 'Finance',
        icon: Icons.account_balance_wallet_outlined,
        items: [
          _item('Earnings Overview', '/admin/finance/earnings'),
          _item('Provider Payouts', '/admin/finance/payouts'),
          _item('Platform Commissions', '/admin/finance/commissions'),
          _item('Refunds & Disputes', '/admin/finance/disputes'),
          _item('Ledger', '/admin/finance/ledger'),
        ],
      ),
      _section(
        title: 'Configuration',
        icon: Icons.settings_outlined,
        items: [
          _item('Services & Categories', '/admin/config/services'),
          _item('Pricing & Fees', '/admin/config/pricing'),
          _item('Coverage Areas', '/admin/config/coverage'),
          _item('Availability Rules', '/admin/config/availability'),
          _item('Promotions', '/admin/config/promotions'),
        ],
      ),
      _section(
        title: 'Reports & Logs',
        icon: Icons.analytics_outlined,
        items: [
          _item('Job Reports', '/admin/reports/jobs'),
          _item('Revenue Reports', '/admin/reports/revenue'),
          _item('Activity Logs', '/admin/logs/activity'),
        ],
      ),
      _section(
        title: 'System',
        icon: Icons.security_outlined,
        items: [
          _item('Roles & Permissions', '/admin/system/roles'),
          _item('Integrations', '/admin/system/integrations'),
          _item('Feature Toggles', '/admin/system/features'),
          _item('Maintenance Mode', '/admin/system/maintenance'),
        ],
      ),
    ];
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<_NavItem> items,
  }) {
    return ExpansionTile(
      leading: Icon(icon),
      title: _isCollapsed ? const SizedBox.shrink() : Text(title),
      childrenPadding: const EdgeInsets.only(left: 12),
      children: items
          .map(
            (item) => ListTile(
              leading: _isCollapsed ? const Icon(Icons.circle, size: 8) : null,
              title: _isCollapsed ? const SizedBox.shrink() : Text(item.label),
              dense: true,
              selected: widget.activeRoute == item.route,
              onTap: () => widget.onNavigate(item.route),
              contentPadding: EdgeInsets.symmetric(
                horizontal: _isCollapsed ? 16 : 32,
              ),
            ),
          )
          .toList(),
    );
  }

  _NavItem _item(String label, String route) {
    return _NavItem(label: label, route: route);
  }
}

class _NavItem {
  final String label;
  final String route;

  _NavItem({required this.label, required this.route});
}
