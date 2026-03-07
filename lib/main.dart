import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/constants/theme.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/auth_providers.dart';
import 'core/network/dio_client.dart';
import 'core/theme/theme_providers.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
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

class SeamlessCallApp extends ConsumerWidget {
  const SeamlessCallApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SeamlessCall',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(settings.preset),
      darkTheme: AppTheme.darkTheme(settings.preset),
      themeMode: settings.mode,
      home: const SplashScreen(),
    );
  }
}