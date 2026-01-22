// import 'package:flutter/material.dart';
// import 'package:seamlesscall/features/dashboard/dashboard_screen.dart';

// class AdminShell extends StatefulWidget {
//   const AdminShell({super.key});

//   @override
//   State<AdminShell> createState() => _AdminShellState();
// }

// class _AdminShellState extends State<AdminShell> {
//   String _activeRoute = '/admin/dashboard';

//   void _navigate(String route) {
//     setState(() {
//       _activeRoute = route;
//     });
//   }

//   Widget _resolveScreen() {
//     switch (_activeRoute) {
//       case '/admin/dashboard':
//         return const DashboardScreen();
//       default:
//         return Center(child: Text('Screen for $_activeRoute'));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           AdminSidebar(activeRoute: _activeRoute, onNavigate: _navigate),
//           const VerticalDivider(width: 1, thickness: 1),
//           Expanded(child: _resolveScreen()),
//         ],
//       ),
//     );
//   }
// }

// class AdminSidebar extends ConsumerWidget {
//   final String activeRoute;
//   final Function(String route) onNavigate;

//   const AdminSidebar({
//     super.key,
//     required this.activeRoute,
//     required this.onNavigate,
//   });

//   // Using a private provider for local widget state (collapsed status)
//   static final _isCollapsedProvider = StateProvider.autoDispose<bool>((ref) => false);

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final theme = Theme.of(context);
//     final isCollapsed = ref.watch(_isCollapsedProvider);
//     final auth = ref.watch(authProvider);

//     return AnimatedContainer(
//       width: isCollapsed ? 80 : 280,
//       duration: const Duration(milliseconds: 200),
//       color: theme.scaffoldBackgroundColor,
//       child: Column(
//         children: [
//           // Header + collapse toggle
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment:
//                   isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
//               children: [
//                 if (!isCollapsed)
//                   Text(
//                     'Admin Panel',
//                     style: theme.textTheme.titleLarge?.copyWith(
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 IconButton(
//                   icon: Icon(
//                     isCollapsed ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
//                   ),
//                   onPressed: () => ref.read(_isCollapsedProvider.notifier).state = !isCollapsed,
//                 ),
//               ],
//             ),
//           ),
//           const Divider(thickness: 1),
//           // Menu sections
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               children: _buildSections(context, auth, isCollapsed),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildSections(BuildContext context, AuthProvider auth, bool isCollapsed) {
//     // Define the entire menu structure with required permissions
//     final allSections = [
//       _sectionData(
//         title: 'Dashboard',
//         icon: Icons.dashboard_outlined,
//         items: [_item('Overview', '/admin/dashboard', permission: 'view-dashboard')], // Placeholder permission
//       ),
//       _sectionData(
//         title: 'Operations',
//         icon: Icons.work_outline,
//         items: [
//           _item('Active Jobs', '/admin/jobs/active', permission: 'view-jobs'),
//           _item('Dispatch Center', '/admin/dispatch', permission: 'manage-dispatch'),
//           _item('Escalations', '/admin/escalations', permission: 'manage-escalations'),
//         ],
//       ),
//       _sectionData(
//         title: 'People',
//         icon: Icons.people_outline,
//         items: [
//           _item('Customers', '/admin/customers', permission: 'view-users'),
//           _item('Providers', '/admin/providers', permission: 'view-providers'),
//           _item('Verification Queue', '/admin/providers/verification', permission: 'approve-providers'),
//         ],
//       ),
//       _sectionData(
//         title: 'Finance',
//         icon: Icons.account_balance_wallet_outlined,
//         items: [
//           _item('Earnings Overview', '/admin/finance/earnings', permission: 'view-reports'),
//           _item('Provider Payouts', '/admin/finance/payouts', permission: 'manage-payouts'),
//           _item('Refunds & Disputes', '/admin/finance/disputes', permission: 'manage-refunds'),
//           _item('Ledger', '/admin/finance/ledger', permission: 'view-ledger'),
//         ],
//       ),
//       _sectionData(
//         title: 'System',
//         icon: Icons.security_outlined,
//         items: [
//           _item('Manage Users', '/admin/system/users', permission: 'view-users'),
//           _item('Create Admin', '/admin/system/create-admin', permission: 'create-users'),
//           _item('Roles & Permissions', '/admin/system/roles', permission: 'manage-roles'),
//         ],
//       ),
//     ];

//     final List<Widget> visibleSections = [];
//     for (final section in allSections) {
//       final visibleItems = section.items.where((item) => auth.hasPermission(item.permission)).toList();
//       if (visibleItems.isNotEmpty) {
//         visibleSections.add(
//           _buildSectionWidget(context, section.title, section.icon, visibleItems, isCollapsed)
//         );
//       }
//     }
//     return visibleSections;
//   }

//   // Helper widget to build the ExpansionTile
//   Widget _buildSectionWidget(BuildContext context, String title, IconData icon, List<_NavItem> items, bool isCollapsed) {
//     return ExpansionTile(
//       initiallyExpanded: true,
//       leading: Icon(icon),
//       title: isCollapsed ? const SizedBox.shrink() : Text(title),
//       childrenPadding: EdgeInsets.only(left: isCollapsed ? 0 : 12),
//       children: items.map((item) => ListTile(
//         leading: isCollapsed ? const Icon(Icons.circle, size: 8) : null,
//         title: isCollapsed ? const SizedBox.shrink() : Text(item.label),
//         dense: true,
//         selected: activeRoute == item.route,
//         onTap: () => onNavigate(item.route),
//         contentPadding: EdgeInsets.symmetric(horizontal: isCollapsed ? 28 : 32),
//       )).toList(),
//     );
//   }

//   // Data-holding helpers
//   _NavSection _sectionData({required String title, required IconData icon, required List<_NavItem> items}) {
//     return _NavSection(title: title, icon: icon, items: items);
//   }

//   _NavItem _item(String label, String route, {required String permission}) {
//     return _NavItem(label: label, route: route, permission: permission);
//   }
// }

// // Helper classes to hold menu data
// class _NavSection {
//   final String title;
//   final IconData icon;
//   final List<_NavItem> items;
//   _NavSection({required this.title, required this.icon, required this.items});
// }

// class _NavItem {
//   final String label;
//   final String route;
//   final String permission;

//   _NavItem({required this.label, required this.route, required this.permission});
// }
