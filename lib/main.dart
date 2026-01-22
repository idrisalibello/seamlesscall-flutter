import 'package:flutter/material.dart';
// Prefix provider import to avoid collision with Riverpod
import 'package:provider/provider.dart' as legacy;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/constants/theme.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/auth_providers.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(
    // Use the prefixed provider to remove ambiguity
    legacy.ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const ProviderScope(child: SeamlessCallApp()),
    ),
  );
}

class SeamlessCallApp extends StatelessWidget {
  const SeamlessCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SeamlessCall',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:seamlesscall/features/auth/presentation/auth_providers.dart';
// import 'common/constants/theme.dart';
// import 'features/auth/presentation/splash_screen.dart';
// import 'package:provider/provider.dart';

// import 'package:flutter_riverpod/flutter_riverpod.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => AuthProvider(),
//       child: const ProviderScope(
//         child: SeamlessCallApp(),
//       ),
//     ),
//   );
// }

// class SeamlessCallApp extends StatelessWidget {
//   const SeamlessCallApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       title: 'SeamlessCall',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       darkTheme: AppTheme.darkTheme,
//       themeMode: ThemeMode.system,
//       home: const SplashScreen(),
//     );
//   }
// }
