// import 'package:flutter/material.dart';
// import 'customer_shell.dart';
// import 'provider_shell.dart';
// import 'admin_shell.dart';

// enum AppRole { customer, provider, admin }

// class AppShell extends StatelessWidget {
//   final AppRole role;

//   const AppShell({super.key, required this.role});

//   @override
//   Widget build(BuildContext context) {
//     switch (role) {
//       case AppRole.customer:
//         return const CustomerShell();
//       case AppRole.provider:
//         return const ProviderShell();
//       case AppRole.admin:
//         return const AdminShell();
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'customer_shell.dart';
import 'provider_shell.dart';
import 'admin_shell.dart';

enum AppRole { customer, provider, admin }

class AppShell extends StatelessWidget {
  final AppRole role;

  const AppShell({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case AppRole.customer:
        return const CustomerShell();
      case AppRole.provider:
        return const ProviderShell();
      case AppRole.admin:
        return const AdminShell();
    }
  }
}
