import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/constants/theme.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/auth_providers.dart';

import 'core/network/dio_client.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Create a single Riverpod container for the whole app.
  // This lets DioClient signal "auth expired" without importing UI/auth into DioClient.
  final container = ProviderContainer();

  DioClient.onAuthExpired = () {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      container.read(authProvider.notifier).logout(navigator);
    });
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SeamlessCallApp(),
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
